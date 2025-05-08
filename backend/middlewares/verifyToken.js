const jwt = require('jsonwebtoken')
const asyncHandler = require('express-async-handler')

const verifyAccessToken = asyncHandler(async (req, res, next) => {
    //Bearer token
    // headers: {authorization: Bearer token}
    if (req?.headers?.authorization?.startsWith('Bearer')) {
        const token = req.headers.authorization.split(' ')[1]
        jwt.verify(token, process.env.JWT_SECRET, (err, decode) => {
            if (err) return res.status(401).json({
                success: false,
                mess: 'Trạng thái đăng nhập đã hết hạn. Vui lòng đăng nhập!!'
            })
            req.user = decode
            next()
        })
    } else {
        return res.status(401).json({
            success: false,
            mess: 'Yêu cầu đăng nhập để sử dụng chức năng trên'
        })
    }
})


const isAdmin = asyncHandler((req, res, next) => {
    const { role } = req.user
    if (role !== 'Admin')
        return res.status(401).json({
            success: false,
            mess: 'Bạn cần là Admin để sử dụng chức năng này'
        })
    next()
})

module.exports = {
    verifyAccessToken,
    isAdmin
}