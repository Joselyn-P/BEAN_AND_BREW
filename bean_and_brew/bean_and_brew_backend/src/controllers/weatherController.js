const pool = require('../config/db');
const axios = require('axios');

exports.getRecommendations = async (req, res) => {
  try {
    const { lat, lon } = req.query;

    // Call OpenWeather API
    const weatherRes = await axios.get(
      `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${process.env.OPENWEATHER_API_KEY}&units=metric`
    );

    const weatherMain = weatherRes.data.weather[0].main;
    const temp = weatherRes.data.main.temp;
    const city = weatherRes.data.name;

    // Map weather to drink type
    const hotWeather = ['Rain', 'Drizzle', 'Thunderstorm', 'Snow'];
    const recommendationType = hotWeather.includes(weatherMain) ? 'hot' : 'cold';

    // Get recommended products from DB
    const [products] = await pool.query(`
      SELECT p.* FROM products p
      WHERE p.temperature_type = ? OR p.temperature_type = 'both'
      AND p.is_available = 1
      ORDER BY RAND()
      LIMIT 5
    `, [recommendationType]);

    res.json({
      condition: weatherMain,
      temp,
      city,
      recommendationType,
      products,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};