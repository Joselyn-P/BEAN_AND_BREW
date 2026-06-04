const pool = require('../config/db');

// POST /api/orders — place a new order
exports.placeOrder = async (req, res) => {
  const { fulfillment_type, payment_method, address_id, promo_code_id } = req.body;

  try {
    // Get user's cart
    const [carts] = await pool.query(
      'SELECT * FROM carts WHERE user_id = ?', [req.user.id]
    );
    if (carts.length === 0)
      return res.status(400).json({ message: 'Cart is empty' });

    const cart = carts[0];

    // Get cart items
    const [items] = await pool.query(`
      SELECT ci.*, p.name, p.image_url, p.base_price
      FROM cart_items ci
      LEFT JOIN products p ON ci.product_id = p.id
      WHERE ci.cart_id = ?
    `, [cart.id]);

    if (items.length === 0)
      return res.status(400).json({ message: 'Cart is empty' });

    // Calculate totals
    const subtotal = items.reduce((sum, item) => {
      return sum + (parseFloat(item.item_price) * item.quantity);
    }, 0);
    const tax = subtotal * 0.08;
    const delivery_fee = fulfillment_type === 'delivery' ? 2.00 : 0.00;
    const total = subtotal + tax + delivery_fee;

    // Create order
    await pool.query(
      `INSERT INTO orders 
       (id, user_id, address_id, promo_code_id, fulfillment_type, status, subtotal, tax, delivery_fee, total, payment_method)
       VALUES (UUID(), ?, ?, ?, ?, 'confirmed', ?, ?, ?, ?, ?)`,
      [req.user.id, address_id || null, promo_code_id || null,
       fulfillment_type, subtotal.toFixed(2), tax.toFixed(2),
       delivery_fee.toFixed(2), total.toFixed(2), payment_method]
    );

    // Get the created order
    const [orders] = await pool.query(
      'SELECT * FROM orders WHERE user_id = ? ORDER BY placed_at DESC LIMIT 1',
      [req.user.id]
    );
    const order = orders[0];

    // Copy cart items to order items
    for (const item of items) {
      await pool.query(
        `INSERT INTO order_items (id, order_id, product_id, quantity, selected_options, item_price)
         VALUES (UUID(), ?, ?, ?, ?, ?)`,
        [order.id, item.product_id, item.quantity,
         JSON.stringify(item.selected_options), item.item_price]
      );
    }

    // Add initial tracking entry
    await pool.query(
      `INSERT INTO order_tracking (id, order_id, status, note)
       VALUES (UUID(), ?, 'confirmed', 'Order received and confirmed')`,
      [order.id]
    );

    // Clear cart
    await pool.query('DELETE FROM cart_items WHERE cart_id = ?', [cart.id]);

    res.status(201).json({
      message: 'Order placed successfully',
      order_id: order.id,
      order,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// GET /api/orders — get all orders for user
exports.getOrders = async (req, res) => {
  try {
    const [orders] = await pool.query(
      `SELECT o.*,
        (SELECT COUNT(*) FROM order_items WHERE order_id = o.id) as item_count
       FROM orders o
       WHERE o.user_id = ?
       ORDER BY o.placed_at DESC`,
      [req.user.id]
    );
    res.json(orders);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// GET /api/orders/:id — get single order with items + tracking
exports.getOrder = async (req, res) => {
  try {
    const [orders] = await pool.query(
      'SELECT * FROM orders WHERE id = ? AND user_id = ?',
      [req.params.id, req.user.id]
    );
    if (orders.length === 0)
      return res.status(404).json({ message: 'Order not found' });

    const order = orders[0];

    // Get order items
    const [items] = await pool.query(`
      SELECT oi.*, p.name, p.image_url
      FROM order_items oi
      LEFT JOIN products p ON oi.product_id = p.id
      WHERE oi.order_id = ?
    `, [order.id]);

    // Get tracking
    const [tracking] = await pool.query(
      'SELECT * FROM order_tracking WHERE order_id = ? ORDER BY timestamp ASC',
      [order.id]
    );

    res.json({ ...order, items, tracking });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};