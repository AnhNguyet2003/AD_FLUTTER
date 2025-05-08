const router = require('express').Router()
const ctrls = require('../controllers/voucher')
const { verifyAccessToken, isAdmin } = require('../middlewares/verifyToken')


router.post('/', [verifyAccessToken, isAdmin], ctrls.createVoucher)

router.get('/', ctrls.getAllVouchers)

router.put('/:vid', [verifyAccessToken, isAdmin], ctrls.updateVoucher)

router.delete('/:vid', [verifyAccessToken, isAdmin], ctrls.deleteVoucher)
module.exports = router