const pool = require('../config/db');

// GET all products (optional ?category=slug filter)
exports.getAllProducts = async (req, res) => {
  try {
    const { category } = req.query;
    let query = `
      SELECT p.*, c.name as category_name, c.slug as category_slug
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.is_available = 1
    `;
    const params = [];

    if (category) {
      query += ' AND c.slug = ?';
      params.push(category);
    }

    query += ' ORDER BY p.name';
    const [products] = await pool.query(query, params);
    res.json(products);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// GET featured products
exports.getFeatured = async (req, res) => {
  try {
    const [products] = await pool.query(`
      SELECT p.*, c.name as category_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.is_featured = 1 AND p.is_available = 1
      LIMIT 5
    `);
    res.json(products);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// GET products by category slug
exports.getByCategory = async (req, res) => {
  try {
    const [products] = await pool.query(`
      SELECT p.*, c.name as category_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE c.slug = ? AND p.is_available = 1
    `, [req.params.slug]);
    res.json(products);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// GET single product with options
exports.getProduct = async (req, res) => {
  try {
    const [products] = await pool.query(`
      SELECT p.*, c.name as category_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.id = ?
    `, [req.params.id]);

    if (products.length === 0)
      return res.status(404).json({ message: 'Product not found' });

    const [options] = await pool.query(
      'SELECT * FROM product_options WHERE product_id = ?',
      [req.params.id]
    );

    res.json({ ...products[0], options });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};