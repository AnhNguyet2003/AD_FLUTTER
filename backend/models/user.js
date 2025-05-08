const mongoose = require('mongoose') // Erase if already required
const bcrypt = require('bcrypt')
const crypto = require('crypto')
// Declare the Schema of the Mongo model
var userSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
    },
    password: {
        type: String,
        required: true,
    },
    role: {
        type: String,
        enum: ['Admin', 'User'],
        required: true,
        default: 'User',
    },
    name: {
        type: String,
        required: true,
    },
    address: {
        default: '',
        type: String,
        // required: true,
    },
    birthday: {
        type: Date,
        default: Date.now,

    },
    phone: {
        type: String,
        required: true,
        validate: {
            validator: function (value) {
                // Kiểm tra số điện thoại có đúng định dạng 10 số không
                return /^\d{10}$/.test(value);
            },
            message: 'Số điện thoại phải có định dạng 10 số.',
        },
    },
    avatar: {
        default: 'https://res.cloudinary.com/dronifdsy/image/upload/v1703691000/CosmeticsShop/srde4anqx7ogxodvrpef.jpg',
        type: String,
    },
    wishlist: [{ type: mongoose.Types.ObjectId, ref: 'Product' }],
    status: {
        type: Boolean,
        default: true, // Giá trị mặc định là true
    },
    refreshToken: {
        type: String,
    },

    passwordReset: {
        type: String,
    },

    passwordResetToken: {
        type: String,
    },

    passwordResetTokenTimeout: {
        type: String,
    },
    registerToken: {
        type: String,
    },
}, {
    timestamps: true
});
// {type: Date,default: Date.now,},
userSchema.pre('save', async function (next) {
    //generate userId
    if (!this.isNew) {
        return next()
    }
    // bcrypt password
    if (!this.isModified('password')) {
        return next()
    }
    const salt = bcrypt.genSaltSync(10)
    this.password = await bcrypt.hash(this.password, salt)

    next();

});

userSchema.methods = {
    isCorrectPassword: async function (password) {
        return await bcrypt.compare(password, this.password)
    },
    generatePasswordResetToken: function () {
        const resetToken = crypto.randomBytes(32).toString('hex')
        this.passwordResetToken = crypto.createHash('sha256').update(resetToken).digest('hex')
        this.passwordResetTokenTimeout = Date.now() + 300000 //5p 
        return resetToken
    }
}


//Export the model
module.exports = mongoose.model('User', userSchema);