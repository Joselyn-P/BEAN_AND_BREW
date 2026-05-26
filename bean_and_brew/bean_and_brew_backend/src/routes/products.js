const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');

router.get('/', productController.getAllProducts);
router.get('/featured', productController.getFeatured);
router.get('/category/:slug', productController.getByCategory);
router.get('/:id', productController.getProduct);

module.exports = router;