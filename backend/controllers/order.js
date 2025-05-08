const Order = require('../models/order')
const Cart = require('../models/cart');
const Voucher = require('../models/voucher')
const Product = require('../models/product')
const asyncHandler = require('express-async-handler')

const createOrder = asyncHandler(async (req, res) => {
    const { _id } = req.user
    const voucher = req.body.voucher;
    let total = req.body.total;
    if (voucher) {
        const selectedVoucher = await Voucher.findById(voucher);
        if (!selectedVoucher) {
            return res.status(400).json({
                success: false,
                mess: 'Voucher không tồn tại',
            });
        }
        total *= 1 - selectedVoucher.discount / 100;
        total = Math.round(total / 1000) * 1000;
    }

    const data = {
        products: req.body.products,
        orderBy: _id,
        total: total,
        voucher: voucher || null,
        address: req.body.address || '',
        phone: req.body.phone || null,
        recipient: req.body.recipient || '',
        note: req.body.note || '',
        paymentMethod: req.body.paymentMethod || 'Cash',
        status: req.body.status || 'Pending'
    };

    const paidProducts = [];

    data.products.forEach((productItem) => {
        paidProducts.push(productItem.product)
    });

    // Tạo đơn hàng

    const orderedProducts = data.products
    const soldOutProducts = []

    await Promise.all(
        orderedProducts.map(async (productItem) => {
            const productId = productItem.product;
            const quantityOrdered = productItem.count;
            const product = await Product.findById(productId);
            if (product) {
                if (product.stockQuantity >= quantityOrdered) {
                    // Giảm stockQuantity
                    product.stockQuantity -= quantityOrdered;
                    // Tăng soldQuantity
                    product.soldQuantity += quantityOrdered;
                    // Lưu cập nhật của sản phẩm
                    await product.save();
                }
                else {
                    soldOutProducts.push(product);
                }
            }
        })
    )

    if (soldOutProducts.length > 0) {
        return res.status(400).json({
            success: false,
            status: "soldout",
            mess: 'Không đủ số lượng sản phẩm để mua',
            product: soldOutProducts
        });
    } else {

        const result = await Order.create(data);
        await Cart.updateOne({ userId: _id }, { $pull: { products: { product: { $in: paidProducts } } } });

        return res.status(201).json({
            success: result ? true : false,
            result: result ? result : 'Tạo đơn hàng bị lỗi'
        })
    }
})

const updateStatus = asyncHandler(async (req, res) => {
    const { oid } = req.params
    const { status } = req.body
    if (!status) throw new Error('Lỗi dữ liệu truyền vào')
    const orderBeforeUpdate = await Order.findById(oid).populate('products.product');
    const currentStatus = orderBeforeUpdate.status;
    if (currentStatus === 'Cancelled') {
        return res.status(400).json({
            success: false,
            mess: 'Không thể mua lại đơn hàng đã hủy',
        });
    }
    if (status === 'Cancelled' && currentStatus !== 'Cancelled') {
        // Cập nhật stockQuantity và soldQuantity của từng sản phẩm trong đơn hàng
        await Promise.all(
            orderBeforeUpdate.products.map(async (productItem) => {
                const product = productItem.product;
                const quantityCancelled = productItem.count;

                // Tăng stockQuantity
                product.stockQuantity += quantityCancelled;
                // Giảm soldQuantity
                product.soldQuantity -= quantityCancelled;

                // Lưu cập nhật của sản phẩm
                await product.save();
            })
        );
    }
    const result = await Order.findByIdAndUpdate(oid, { status }, { new: true })
    return res.json({
        success: result ? true : false,
        result: result ? result : 'Error for order'
    })
})

const getUserOrder = asyncHandler(async (req, res) => {
    const { _id } = req.user
    const result = await Order.find({ orderBy: _id }).populate('products.product').sort({ updatedAt: -1 }).exec()
    return res.json({
        success: result ? true : false,
        result: result ? result : 'Lỗi lấy danh sách đơn hàng'
    })
})

const getAllOrders = asyncHandler(async (req, res) => {
    const result = await Order.find().populate('products.product').sort({ updatedAt: -1 }).exec()
    return res.json({
        success: result ? true : false,
        result: result ? result : 'Lỗi lấy danh sách đơn hàng'
    })
})
// const getOrdersByTime = asyncHandler(async (req, res) => {
//     const { startDate, endDate, toDay } = req.query;
//     const convertDate = (dateStr, isEndDate = false) => {
//         if (!dateStr) return undefined;
//         const parts = dateStr.split('/');
//         const date = new Date(parts[2], parts[1] - 1, parts[0]);
//         if (isEndDate) {
//             date.setHours(23, 59, 59, 999);
//         } else {
//             date.setHours(0, 0, 0, 0);
//         }
//         return date;
//     };

//     const start = convertDate(startDate);
//     const end = convertDate(endDate, true);

//     try {

//         let orders;
//         if (!start || !end) {

//             if (toDay) {
//                 const today = new Date()
//                 today.setHours(0, 0, 0, 0)
//                 orders = await Order.find({
//                     status: 'Shipped',
//                     updatedAt: { $gte: today, $lte: new Date(today.getTime() + 24 * 60 * 60 * 1000) }
//                 }).populate({ path: 'products.product', select: 'productName price imageUrl' })
//                 console.log("MONEY " + orders)
//             } else {

//                 orders = await Order.find({
//                     status: 'Shipped'
//                 }).populate({ path: 'products.product', select: 'productName price imageUrl' })
//             }
//         } else {

//             orders = await Order.find({
//                 status: 'Shipped',
//                 updatedAt: { $gte: start, $lte: end }
//             }).populate({ path: 'products.product', select: 'productName price imageUrl' });
//         }

//         return res.json({ success: true, orders });
//     } catch (error) {
//         console.error(error);
//         res.status(500).json({ mess: 'Lỗi máy chủ khi truy vấn đơn hàng.' });
//     }
// });


const getOrdersByTime = asyncHandler(async (req, res) => {
    const { startDate, endDate, toDay } = req.query;
    
    const convertDate = (dateStr, isEndDate = false) => {
        if (!dateStr) return undefined;
        const parts = dateStr.split('/');
        const date = new Date(parts[2], parts[1] - 1, parts[0]);
        if (isEndDate) {
            date.setHours(23, 59, 59, 999);
        } else {
            date.setHours(0, 0, 0, 0);
        }
        return date;
    };

    const start = convertDate(startDate);
    const end = convertDate(endDate, true);

    try {
        let total = 0;

        if (!start || !end) {
            if (toDay) {
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                const orders = await Order.find({
                    status: 'Shipped',
                    updatedAt: { $gte: today, $lt: new Date(today.getTime() + 24 * 60 * 60 * 1000) }
                });
                
                total = orders.reduce((acc, order) => acc + order.total, 0); // Tổng tiền
                console.log("Tổng tiền hôm nay: " + total);
            } else {
                const orders = await Order.find({
                    status: 'Shipped'
                });
                
                total = orders.reduce((acc, order) => acc + order.total, 0); // Tổng tiền
            }
        } else {
            const orders = await Order.find({
                status: 'Shipped',
                updatedAt: { $gte: start, $lte: end }
            });
            
            total = orders.reduce((acc, order) => acc + order.total, 0); // Tổng tiền
        }

        return res.json({ success: true, total }); // Trả về tổng tiền
    } catch (error) {
        console.error(error);
        res.status(500).json({ mess: 'Lỗi máy chủ khi truy vấn đơn hàng.' });
    }
});


module.exports = {
    createOrder,
    updateStatus,
    getUserOrder,
    getAllOrders,
    getOrdersByTime
}