const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cartController');
const auth = require('../middleware/auth');

router.get('/', auth, cartController.getCart);
router.post('/items', auth, cartController.addItem);
router.put('/items/:id', auth, cartController.updateItem);
router.delete('/items/:id', auth, cartController.removeItem);
router.post('/promo', auth, cartController.applyPromo);

module.exports = router;