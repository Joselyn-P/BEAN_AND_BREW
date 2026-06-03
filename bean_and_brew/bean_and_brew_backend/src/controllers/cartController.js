const pool = require('../config/db');

// Get or create cart for user
async function getOrCreateCart(userId) {
  const [carts] = await pool.query(
    'SELECT * FROM carts WHERE user_id = ?', [userId]
  );
  if (carts.length > 0) return carts[0];

  await pool.query(
    'INSERT INTO carts (id, user_id) VALUES (UUID(), ?)', [userId]
  );
  const [newCart] = await pool.query(
    'SELECT * FROM carts WHERE user_id = ?', [userId]
  );
  return newCart[0];
}

// GET /api/cart
exports.getCart = async (req, res) => {
  try {
    const cart = await getOrCreateCart(req.user.id);

    const [items] = await pool.query(`
      SELECT ci.*, p.name, p.image_url, p.base_price
      FROM cart_items ci
      LEFT JOIN products p ON ci.product_id = p.id
      WHERE ci.cart_id = ?
    `, [cart.id]);

    const subtotal = items.reduce((sum, item) => {
      return sum + (parseFloat(item.item_price) * item.quantity);
    }, 0);

    res.json({
      cart_id: cart.id,
      items,
      subtotal: subtotal.toFixed(2),
      tax: (subtotal * 0.08).toFixed(2),
      total: (subtotal * 1.08).toFixed(2),
      item_count: items.reduce((sum, item) => sum + item.quantity, 0),
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// POST /api/cart/items
exports.addItem = async (req, res) => {
  const { product_id, quantity, selected_options, item_price } = req.body;

  try {
    const cart = await getOrCreateCart(req.user.id);

    // Check if same product with same options already in cart
    const [existing] = await pool.query(
      'SELECT * FROM cart_items WHERE cart_id = ? AND product_id = ?',
      [cart.id, product_id]
    );

    if (existing.length > 0) {
      // Update quantity
      await pool.query(
        'UPDATE cart_items SET quantity = quantity + ? WHERE id = ?',
        [quantity, existing[0].id]
      );
    } else {
      // Add new item
      await pool.query(
        'INSERT INTO cart_items (id, cart_id, product_id, quantity, selected_options, item_price) VALUES (UUID(), ?, ?, ?, ?, ?)',
        [cart.id, product_id, quantity, JSON.stringify(selected_options), item_price]
      );
    }

    // Return updated cart
    const [items] = await pool.query(`
      SELECT ci.*, p.name, p.image_url, p.base_price
      FROM cart_items ci
      LEFT JOIN products p ON ci.product_id = p.id
      WHERE ci.cart_id = ?
    `, [cart.id]);

    const subtotal = items.reduce((sum, item) => {
      return sum + (parseFloat(item.item_price) * item.quantity);
    }, 0);

    res.status(201).json({
      cart_id: cart.id,
      items,
      subtotal: subtotal.toFixed(2),
      tax: (subtotal * 0.08).toFixed(2),
      total: (subtotal * 1.08).toFixed(2),
      item_count: items.reduce((sum, item) => sum + item.quantity, 0),
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// PUT /api/cart/items/:id
exports.updateItem = async (req, res) => {
  const { quantity } = req.body;
  try {
    if (quantity <= 0) {
      await pool.query('DELETE FROM cart_items WHERE id = ?', [req.params.id]);
    } else {
      await pool.query(
        'UPDATE cart_items SET quantity = ? WHERE id = ?',
        [quantity, req.params.id]
      );
    }
    res.json({ message: 'Cart updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// DELETE /api/cart/items/:id
exports.removeItem = async (req, res) => {
  try {
    await pool.query('DELETE FROM cart_items WHERE id = ?', [req.params.id]);
    res.json({ message: 'Item removed' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// POST /api/cart/promo
exports.applyPromo = async (req, res) => {
  const { code } = req.body;
  try {
    const [promos] = await pool.query(
      'SELECT * FROM promo_codes WHERE code = ? AND (expires_at IS NULL OR expires_at > NOW())',
      [code]
    );

    if (promos.length === 0)
      return res.status(404).json({ message: 'Invalid or expired promo code' });

    const promo = promos[0];
    if (promo.max_uses && promo.used_count >= promo.max_uses)
      return res.status(400).json({ message: 'Promo code has reached its limit' });

    res.json({
      id: promo.id,
      code: promo.code,
      discount_type: promo.discount_type,
      discount_value: promo.discount_value,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};