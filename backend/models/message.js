const mongoose = require('mongoose'); // Erase if already required

// Declare the Schema of the Mongo model
var messageSchema = new mongoose.Schema({
    senderUserID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
        index: true
    },
    sessionID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'ChatSession',
        required: true,
    },
    messageText: {
        type: String,
        required: true
    },
}, {
    timestamps: true
});

//Export the model
module.exports = mongoose.model('Message', messageSchema);