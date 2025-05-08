const Brand = require('../models/brand')
const asyncHandler = require('express-async-handler')

const createBrand = asyncHandler(async (req, res) => {
    const brand = await Brand.create(req.body)
    return res.status(201).json({
        success: brand ? true : false,
        createdBrand: brand ? brand : 'Can not be created brand'
    })
})

const getAllBrands = asyncHandler(async (req, res) => {
    const brand = await Brand.find().select('brandName _id')
    return res.status(201).json({
        success: brand ? true : false,
        brandList: brand ? brand : 'Can not be get brandlist'
    })
})

const updateBrand = asyncHandler(async (req, res) => {
    const { bid } = req.params
    const brand = await Brand.findByIdAndUpdate(bid, req.body, { new: true })
    return res.status(201).json({
        success: brand ? true : false,
        updatedBrand: brand ? brand : 'Can not be update brand'
    })
})

const deleteBrand = asyncHandler(async (req, res) => {
    const { bid } = req.params
    const brand = await Brand.findByIdAndDelete(bid)
    return res.status(201).json({
        success: brand ? true : false,
        deletedBrand: brand ? brand : 'Can not be delete brand'
    })
})



module.exports = {
    createBrand,
    getAllBrands,
    updateBrand,
    deleteBrand
}