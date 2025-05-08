const notFound = (req, res, next) => { 
    const error = new Error(`Route ${req.originalUrl} is not found`);
    res.status(404)
    next(error)
}

const errHandler = (error, req, res, next) => {
    const statusCode = res.statusCode === 200 ? 500 : res.statusCode
    res.status(statusCode).json({
        success: false,
        mess: error?.message
    })
}

module.exports = {
    notFound,
    errHandler
}