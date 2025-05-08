const nodemailer = require('nodemailer')
const { OAuth2Client } = require('google-auth-library')
const asyncHandler = require('express-async-handler')


const myOAuth2Client = new OAuth2Client(
    process.env.GOOGLE_MAILER_CLIENT_ID,
    process.env.GOOGLE_MAILER_CLIENT_SECRET
)
// Set Refresh Token vào OAuth2Client Credentials
myOAuth2Client.setCredentials({
    refresh_token: process.env.GOOGLE_MAILER_REFRESH_TOKEN
})

const getAccessToken = async () => {
    const accessTokenObject = await myOAuth2Client.getAccessToken();
    return accessTokenObject.token;
};


const sendMail = asyncHandler(async (data) => {
    const { email, html, subject } = data
    const accessTokenObject = await myOAuth2Client.getAccessToken();
    const accessToken = accessTokenObject.token;


    const transporter = nodemailer.createTransport({
        service: 'Gmail',
        auth: {
            type: 'OAuth2',
            user: process.env.EMAIL_USER,
            clientId: process.env.GOOGLE_MAILER_CLIENT_ID,
            clientSecret: process.env.GOOGLE_MAILER_CLIENT_SECRET,
            refreshToken: process.env.GOOGLE_MAILER_REFRESH_TOKEN,
            accessToken: accessToken,
        },
    });

    // async..await is not allowed in global scope, must use a wrapper
    const mailOptions = {
        from: '"Cosmetics" <no-reply@cosmeticshop.com>',
        to: email, // Thêm thông tin người nhận email
        subject: subject,
        html: html,
    };


    transporter.sendMail(mailOptions, (error, info) => {
        if (error) {
            console.log('Error sending email: ' + error);
        } else {
            console.log('Email sent: %s', info.response);
        }
    });
})

module.exports = sendMail