const pool = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');

// REGISTER
exports.register = async (req, res) => {
  const { full_name, email, password } = req.body;

  if (!full_name || !email || !password)
    return res.status(400).json({ message: 'All fields are required' });

  try {
    // Check if email already exists
    const [existing] = await pool.query(
      'SELECT id FROM users WHERE email = ?', [email]
    );
    if (existing.length > 0)
      return res.status(409).json({ message: 'Email already registered' });

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Insert user
    const [result] = await pool.query(
      'INSERT INTO users (id, full_name, email, password_hash, auth_provider) VALUES (UUID(), ?, ?, ?, ?)',
      [full_name, email, password_hash, 'email']
    );

    // Get the newly created user
    const [users] = await pool.query(
      'SELECT id, full_name, email, profile_photo_url FROM users WHERE email = ?',
      [email]
    );
    const user = users[0];

    // Generate JWT
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({ token, user });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// LOGIN
exports.login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password)
    return res.status(400).json({ message: 'Email and password are required' });

  try {
    // Find user
    const [users] = await pool.query(
      'SELECT * FROM users WHERE email = ?', [email]
    );
    if (users.length === 0)
      return res.status(401).json({ message: 'Invalid email or password' });

    const user = users[0];

    // Check password
    const match = await bcrypt.compare(password, user.password_hash);
    if (!match)
      return res.status(401).json({ message: 'Invalid email or password' });

    // Generate JWT
    const token = jwt.sign(
      { id: user.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        profile_photo_url: user.profile_photo_url,
      },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

exports.googleLogin = async (req, res) => {
  const { access_token } = req.body;

  if (!access_token) {
    return res.status(400).json({
      message: 'No access token provided',
    });
  }

  try {
    const googleResponse = await fetch(
      'https://www.googleapis.com/oauth2/v3/userinfo',
      {
        headers: {
          Authorization: `Bearer ${access_token}`,
        },
      }
    );

    const payload = await googleResponse.json();

    const googleId = payload.sub;
    const email = payload.email;
    const fullName = payload.name;
    const profilePhoto = payload.picture;

    const [existing] = await pool.query(
      'SELECT * FROM users WHERE email = ? OR google_id = ?',
      [email, googleId]
    );

    let user;

    if (existing.length > 0) {
      user = existing[0];

      if (!user.google_id) {
        await pool.query(
          'UPDATE users SET google_id = ?, profile_photo_url = ?, auth_provider = ? WHERE id = ?',
          [googleId, profilePhoto, 'google', user.id]
        );
      }
    } else {
      await pool.query(
        `INSERT INTO users
        (id, google_id, full_name, email, profile_photo_url, auth_provider)
        VALUES (UUID(), ?, ?, ?, ?, 'google')`,
        [googleId, fullName, email, profilePhoto]
      );

      const [newUser] = await pool.query(
        'SELECT * FROM users WHERE email = ?',
        [email]
      );

      user = newUser[0];
    }

    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
      },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        full_name: user.full_name,
        email: user.email,
        profile_photo_url: user.profile_photo_url,
      },
    });
  } catch (err) {
    console.error('Google auth error:', err);
    res.status(401).json({
      message: 'Google authentication failed',
    });
  }
};