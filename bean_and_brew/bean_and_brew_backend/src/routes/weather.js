const express = require('express');
const router = express.Router();
const weatherController = require('../controllers/weatherController');

router.get('/recommend', weatherController.getRecommendations);

module.exports = router;