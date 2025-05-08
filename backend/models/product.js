const mongoose = require('mongoose'); // Erase if already required

// Declare the Schema of the Mongo model
var productSchema = new mongoose.Schema({
    productName: {
        type: String,
        required: true,
        unique: true,
        trim: true,
    },
    slug: {
        type: String,
        required: true,
        //unique: true,
        lowercase: true,
    },
    description: {
        type: String,
        required: true,
    },
    price: {
        type: Number,
        required: true,
    },
    brand: {
        type: mongoose.Types.ObjectId,
        ref: 'Brand',
        required: true,
    },
    category: {
        type: mongoose.Types.ObjectId,
        ref: 'ProductCategory',
        required: true,
    },
    stockQuantity: {
        type: Number,
        default: 1000
    },
    soldQuantity: {
        type: Number,
        default: 0
    },
    imageUrl: {
        type: Array,
        //required: true,
        default:[]
    },
    ratings: [
        {
            star: { type: Number },
            postedBy: { type: mongoose.Types.ObjectId, ref: 'User' },
            comment: { type: String },
            updatedAt: {
                type: Date
            }
        }
    ],
    totalRatings: {
        type: Number,
        default: 0,
    }

}, {
    timestamps: true
});

//Export the model
module.exports = mongoose.model('Product', productSchema);