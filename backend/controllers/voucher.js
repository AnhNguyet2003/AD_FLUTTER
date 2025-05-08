const Voucher = require('../models/voucher')
const asyncHandler = require('express-async-handler')

const createVoucher = asyncHandler(async (req, res) => {
    const { name, discount, expire } = req.body
    if (!name || !discount || !expire) throw new Error('Missing input')
    const voucher = await Voucher.create({
        ...req.body,
        expire: Date.now() + +expire * 24 * 60 * 60 * 1000
    })
    return res.status(201).json({
        success: voucher ? true : false,
        newVoucher: voucher ? voucher : 'Can not be created new voucher'
    })
})

const findByName = asyncHandler(async (req, res) => {
    const { name } = req.body

    const voucher = await Voucher.findOne({ name }).exec()

    return res.status(201).json({
        success: voucher ? true : false,
        result: voucher ? "" : 'voucher is not existing'
    })
})

const getAllVouchers = asyncHandler(async (req, res) => {
    const voucher = await Voucher.find().select('name _id discount expire')
    return res.status(200).json({
        success: voucher ? true : false,
        voucherList: voucher ? voucher : 'Can not be get voucherlist'
    })
})

const updateVoucher = asyncHandler(async (req, res) => {
    const { vid } = req.params
    if (Object.keys(req.body).length === 0) throw new Error('Missing input')
    let updatedVoucherData = { ...req.body };
    if (req.body.expire) {
        updatedVoucherData.expire = new Date(Date.now() + req.body.expire * 24 * 60 * 60 * 1000);
    }
    const voucher = await Voucher.findByIdAndUpdate(vid, updatedVoucherData, { new: true });
    return res.status(200).json({
        success: voucher ? true : false,
        updateVoucher: voucher ? voucher : 'Can not be update voucher'
    })
})

const deleteVoucher = asyncHandler(async (req, res) => {
    const { vid } = req.params
    const voucher = await Voucher.findByIdAndDelete(vid)
    return res.status(200).json({
        success: voucher ? true : false,
        deletedBrand: voucher ? voucher : 'Can not be delete voucher'
    })
})
module.exports = {
    createVoucher,
    getAllVouchers,
    updateVoucher,
    deleteVoucher,
    findByName
}