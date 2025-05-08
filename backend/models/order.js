const mongoose = require('mongoose'); // Erase if already required

// Declare the Schema of the Mongo model
var orderSchema = new mongoose.Schema({
    products: [{
        product: { type: mongoose.Types.ObjectId, ref: 'Product' },
        count: Number,
    }],
    status: {
        type: String,
        default: 'Pending',
        enum: ['Cancelled', 'Pending', 'Confirmed', 'Shipped'],
    },
    total: Number,
    voucher: {
        type: mongoose.Types.ObjectId, ref: 'Voucher'
    },
    orderBy: {
        type: mongoose.Types.ObjectId,
        ref: 'User',
    },
    address: {
        type: String,
        default:''
    },
    phone: {
        type: Number,

    },
    recipient: {
        type: String,
        default: ''
    },
    note: String,
    paymentMethod: {
        type: String,
        default: 'Cash',
        enum: ['Cash', 'VnPay', 'PayPal'],
    }}, { timestamps: true }); 

//Export the model
module.exports = mongoose.model('Order', orderSchema);