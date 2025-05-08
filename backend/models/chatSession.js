const mongoose = require('mongoose'); // Erase if already required

// Declare the Schema of the Mongo model
var chatSessionSchema = new mongoose.Schema({
    adminUserID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    customerUserID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    startDate: { 
        type: Date, 
        default: Date.now 
    },
    endDate: {
        type: Date
    },
    status: {
        type: String,
        default: 'Active',
        enum: ['Active', 'Closed'],
        required: true
    },
});

//Export the model
module.exports = mongoose.model('ChatSession', chatSessionSchema);