const router = require('express').Router()
const ctrls = require('../controllers/chat')
const { verifyAccessToken, isAdmin } = require('../middlewares/verifyToken')


router.post('/start', verifyAccessToken, ctrls.startChatSession)
router.post('/send', verifyAccessToken, ctrls.sendMessage)
router.get('/messages/:sessionID', verifyAccessToken, ctrls.getMessages)
router.put('/close/:sessionID', verifyAccessToken, ctrls.closeChatSession)


module.exports = router