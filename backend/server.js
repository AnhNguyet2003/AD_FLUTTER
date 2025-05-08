const express = require('express')
require('dotenv').config()

const dbConnect = require('./config/dbconnect')
const initRoutes = require('./routes')

const cookieParser = require('cookie-parser')
const cors = require('cors')
const socketIo = require('socket.io');
const http = require('http')


const app = express()
const server = http.createServer(app);

const io = socketIo(server, {
    cors: {
        origin: process.env.CLIENT_URL,
        methods: ['GET', 'POST'],
        credentials: true
    }
});
app.use(cors({
    origin: process.env.CLIENT_URL,
    methods: ['POST', 'PUT', 'GET', 'DELETE'],
    credentials: true

}))
const port = process.env.PORT || 8181
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(cookieParser())

// Middleware để phân tích dữ liệu JSON
app.use(express.json());
// Middleware để phân tích dữ liệu URL-encoded
app.use(express.urlencoded({ extended: true }));

dbConnect()
initRoutes(app)

app.use('/', (req, res) => { res.send('Server on') })


// Socket.io logic for chat
io.on('connection', (socket) => {
    console.log('A user connected');

    // Join a conversation
    socket.on('joinRoom', ({ sessionId }) => {
        socket.join(sessionId);
        console.log(`A user joined room: ${sessionId}`);
    });

    // Listen for chatMessage
    socket.on('chatMessage', ({ sessionId, message }) => {
        io.to(sessionId).emit('message', message);
    });

    // Runs when client disconnects
    socket.on('disconnect', () => {
        console.log('User disconnected');
    });
});


server.listen(port, () => {
    console.log('Server running on port: ' + port);
});