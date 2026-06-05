const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');

// GET /api/profile/favorites
router.get('/favorites', auth, async (req, res) => {
  const pool = require('../config/db');
  try {
    const [favorites] = await pool.query(`
      SELECT p.* FROM favorites f
      LEFT JOIN products p ON f.product_id = p.id
      WHERE f.user_id = ?
      ORDER BY f.created_at DESC
      LIMIT 10
    `, [req.user.id]);
    res.json(favorites);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/profile/favorites/:productId — toggle favorite
router.post('/favorites/:productId', auth, async (req, res) => {
  const pool = require('../config/db');
  try {
    const [existing] = await pool.query(
      'SELECT * FROM favorites WHERE user_id = ? AND product_id = ?',
      [req.user.id, req.params.productId]
    );
    if (existing.length > 0) {
      await pool.query(
        'DELETE FROM favorites WHERE user_id = ? AND product_id = ?',
        [req.user.id, req.params.productId]
      );
      res.json({ favorited: false });
    } else {
      await pool.query(
        'INSERT INTO favorites (id, user_id, product_id) VALUES (UUID(), ?, ?)',
        [req.user.id, req.params.productId]
      );
      res.json({ favorited: true });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;