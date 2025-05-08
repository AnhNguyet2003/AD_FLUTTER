const mongoose = require('mongoose'); // Erase if already required

// Declare the Schema of the Mongo model
var cartSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        unique: true
    },
    // Tham chiếu đến sản phẩm (Liên kết với bảng Products)
    products: [{
        product: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Product'
        },
        quantity: Number
    }],
}, {
    timestamps: true
});

//Export the model
module.exports = mongoose.model('Cart', cartSchema);