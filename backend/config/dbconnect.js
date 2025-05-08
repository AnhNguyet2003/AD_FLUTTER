 const {default: mongoose} = require('mongoose')

 const dbConnect = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGODB_URI)
        if (conn.connection.readyState == 1) console.log('DB connection is ready to connect')
        else console.log('Connection is not ready to connect')

    } catch (error) {
        console.log('DB connection error')
        throw new Error(error)
    }
 }
 module.exports = dbConnect 