const { request } = require('express')
const Product = require('../models/product')
const asyncHandler = require('express-async-handler')
const slugify = require('slugify')
const Category = require('../models/productCategory');

// const createProduct = asyncHandler(async (req, res) => {
//     console.log("===CREATE==== " + req.body)
//     if (Object.keys(req.body).length === 0) throw new Error('Missing input!!');

//     // Tạo sản phẩm từ req.body
//     if (req.body && req.body.productName) req.body.slug = slugify(req.body.productName);
//     const newProduct = await Product.create(req.body);

//     // Kiểm tra xem sản phẩm đã tạo thành công hay không
//     if (!newProduct) throw new Error('Cannot create product');

//     // Tiến hành tải ảnh lên cho sản phẩm
//     if (!req.files || req.files.length === 0) {
//         throw new Error('No images uploaded');
//     }

//     const { _id: pid } = newProduct; // Lấy id của sản phẩm mới tạo

//     // Cập nhật thông tin ảnh cho sản phẩm bằng hàm uploadImageProduct
//     const product = await Product.findByIdAndUpdate(
//         pid,
//         { $push: { imageUrl: { $each: req.files.map(ele => ele.path) } } },
//         { new: true }
//     ).populate('brand', 'brandName -_id').populate('category', 'categoryName -_id');

//     // Kiểm tra và trả về kết quả tải ảnh
//     if (product) {
//         // Nếu tải ảnh thành công, trả về thông tin sản phẩm đã được cập nhật
//         return res.status(200).json({ success: true, updatedProduct: product });
//     } else {
//         // Nếu có lỗi khi tải ảnh, trả về thông báo lỗi
//         throw new Error('Failed to upload images');
//     }
// });

const createProduct = asyncHandler(async (req, res) => {
    console.log("===CREATE==== ", req.body);
    console.log("===FILES==== ", req.files);

    if (Object.keys(req.body).length === 0) {
        console.error('Error: Missing input!!');
        throw new Error('Missing input!!');
    }

    // Tạo slug từ productName
    if (req.body && req.body.productName) {
        req.body.slug = slugify(req.body.productName);
    }

    // Tạo sản phẩm từ req.body
    const newProduct = await Product.create(req.body);
    if (!newProduct) {
        console.error('Error creating product:', req.body);
        throw new Error('Cannot create product');
    }

    // Kiểm tra hình ảnh
    if (!req.files || req.files.length === 0) {
        console.error('Error: No images uploaded');
        throw new Error('No images uploaded');
    }

    const { _id: pid } = newProduct; // Lấy id của sản phẩm mới tạo

    // Cập nhật thông tin ảnh cho sản phẩm
    const product = await Product.findByIdAndUpdate(
        pid,
        { $push: { imageUrl: { $each: req.files.map(ele => ele.path) } } },
        { new: true }
    ).populate('brand', 'brandName -_id').populate('category', 'categoryName -_id');

    // Kiểm tra và trả về kết quả tải ảnh
    if (product) {
        // Nếu tải ảnh thành công, trả về thông tin sản phẩm đã được cập nhật
        return res.status(200).json({ success: true, updatedProduct: product });
    } else {
        console.error('Failed to update product:', pid);
        throw new Error('Failed to upload images');
    }
});
const getProduct = asyncHandler(async (req, res) => {
    const { pid } = req.params
    const product = await Product.findById(pid).populate('brand', 'brandName -_id').populate('category', 'categoryName -_id').populate({
        path: 'ratings',
        populate: {
            path: 'postedBy',
            select: 'name avatar'
        }
    })
    return res.status(200).json({
        success: product ? true : false,
        productData: product ? product : 'Cannot find product'
    })
})

const getAllProduct = asyncHandler(async (req, res) => {
    const queries = { ...req.query }
    // Tach cac truong dac biet ra khoi query
    const excludeFields = ['limit', 'sort', 'page', 'fields']
    excludeFields.forEach(field => delete queries[field])

    // Format operators cho dung chuan mongoose
    let queryString = JSON.stringify(queries)
    queryString = queryString.replace(/\b(gte|gt|lt|lte)\b/g, matchedElements => `$${matchedElements}`)
    const formatedQueries = JSON.parse(queryString)

    //Filter
    if (queries?.productName) formatedQueries.productName = { $regex: decodeURIComponent(queries.productName), $options: 'i' }
    let queryCommand = Product.find(formatedQueries).populate('brand', '_id brandName').populate('category', '_id categoryName')
    // if (queries?.categoryId) formatedQueries.categoryId = 
    if (queries?.categoryId) {
        formatedQueries.category = queries.categoryId;
        queryCommand = Product.find({ category: formatedQueries.category }).populate('brand', '_id brandName').populate('category', '_id categoryName')
    }
    //Sort
    if (req.query.sort) {
        const sortBy = req.query.sort.split(',').join(' ')
        queryCommand = queryCommand.sort(sortBy)
    }

    // Fields limit
    if (req.query.fields) {
        const fields = req.query.fields.split(',').join(' ')
        queryCommand = queryCommand.select(fields)
    }

    //Pagination
    //limit: số object lấy về trong 1 api
    // skip: 1
    const page = +req.query.page
    const limit = +req.query.limit

    if (page && limit) {

        const skip = (page - 1) * limit
        queryCommand.skip(skip).limit(limit)
    }

    //Execute query

    const response = await queryCommand.exec();
    console.log("response " + response);

    if (!response || response.length === 0) {
        return res.status(404).json({
            success: false,
            productData: 'Cannot get product',
        });
    }
    let counts
    counts = await Product.countDocuments(formatedQueries);
    if (queries?.categoryId)
        counts = await Product.countDocuments(
            formatedQueries.category ? { category: formatedQueries.category } : {}
        );
    return res.status(200).json({
        success: true,
        counts,
        productData: response,

    });
    //const product = await Product.find()

})


const updateProduct = asyncHandler(async (req, res) => {
    const { pid } = req.params
    console.log("Request Body:", JSON.stringify(req.body, null, 2));
    console.log("Repóne Body:", JSON.stringify(res.body, null, 2));
    if (req.body && req.body.productName) req.body.slug = slugify(req.body.productName)
    const updatedProduct = await Product.findByIdAndUpdate(pid, req.body, { new: true })
    console.log("Updated Product:", JSON.stringify(updatedProduct, null, 2));
    return res.status(200).json({
        success: updatedProduct ? true : false,
        updatedProduct: updatedProduct ? updatedProduct : 'Updated product is failed'
    })
})

const deleteProduct = asyncHandler(async (req, res) => {
    const { pid } = req.params
    if (!pid) throw new Error("Missing Inputs")
    const deletedProduct = await Product.findByIdAndDelete(pid);
    return res.status(200).json({
        success: deletedProduct ? true : false,
        deletedProduct: deletedProduct ? deletedProduct : "Cannot delete product"
    })
})

const rating = asyncHandler(async (req, res) => {
    const { _id } = req.user
    const { star, comment, pid, updatedAt } = req.body
    if (!star || !pid) throw new Error('Missing input')
    const product = await Product.findById(pid)
    if (!product) throw new Error('Product not found')

    const existingRating = product.ratings.find(ele => ele.postedBy && ele.postedBy.toString() === _id)

    if (existingRating) {
        existingRating.star = star
        existingRating.comment = comment
        existingRating.updatedAt = updatedAt
        // existingRating.updatedAt = Date.now()
    } else {
        product.ratings.push({ star, comment, postedBy: _id, updatedAt })
    }
    await product.save()
    //Sum ratings
    const count = product.ratings.length
    const sumRatings = product.ratings.reduce((sum, ele) => sum + +ele.star, 0)
    product.totalRatings = Math.round(sumRatings * 10 / count) / 10

    await product.save()

    return res.status(200).json({
        status: true,
        product
    })

})

const uploadImageProduct = asyncHandler(async (req, res) => {
    const { pid } = req.params
    if (!req.files) throw new Error('Missing inputs')
    const product = await Product.findByIdAndUpdate(pid, { $push: { imageUrl: { $each: req.files.map(ele => ele.path) } } }, { new: true }).populate('brand', 'brandName -_id').populate('category', 'categoryName -_id')
    return res.status(200).json({
        status: product ? true : false,
        updated: product ? product : 'Cannot upload images'
    })
})

module.exports = {
    createProduct,
    getProduct,
    getAllProduct,
    updateProduct,
    deleteProduct,
    rating,
    uploadImageProduct
}