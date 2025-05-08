const Product = require('../models/product')
const ProductCategory = require('../models/productCategory')
const asyncHandler = require('express-async-handler')

const createCategory = asyncHandler(async (req, res) => {
    const category = await ProductCategory.create(req.body)
    return res.status(201).json({
        success: category ? true : false,
        createdCategory: category ? category : 'Can not be created category'
    })
})

const getAllCategories = asyncHandler(async (req, res) => {
    const category = await ProductCategory.find().select('categoryName _id')
    return res.status(201).json({
        success: category ? true : false,
        productCategory: category ? category : 'Can not be get categorylist'
    })
})

const updateCategory = asyncHandler(async (req, res) => {
    const { pcid } = req.params
    const category = await ProductCategory.findByIdAndUpdate(pcid, req.body, { new: true })
    return res.status(201).json({
        success: category ? true : false,
        updatedCategory: category ? category : 'Can not be update category'
    })
})

const deleteCategory = asyncHandler(async (req, res) => {
    const { pcid } = req.params
    await Product.deleteMany({ category: pcid });
    const category = await ProductCategory.findByIdAndDelete(pcid)
    return res.status(201).json({
        success: category ? true : false,
        deletedCategory: category ? category : 'Can not be delete category'
    })
})




module.exports = {
    createCategory,
    getAllCategories,
    updateCategory,
    deleteCategory
}