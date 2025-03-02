const express = require('express');
const { body } = require('express-validator');
const { supabaseClient } = require('../config/supabase');
const { authMiddleware } = require('../middleware/auth.middleware');
const router = express.Router();

// Validation middleware
const validateSignup = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('username').isLength({ min: 3 })
];

const validateLogin = [
  body('email').isEmail().normalizeEmail(),
  body('password').exists()
];

// Sign up
router.post('/signup', validateSignup, async (req, res) => {
  try {
    const { email, password, username } = req.body;

    // Try to sign in with email to check if user exists
    const { data: signInCheck, error: signInError } = await supabaseClient.auth.signInWithOtp({
      email: email,
      options: {
        shouldCreateUser: false
      }
    });

    // If no error during sign in check, it means user exists
    if (!signInError || (signInCheck && signInCheck.user)) {
      return res.status(409).json({
        error: 'An account with this email already exists'
      });
    }

    const { data, error } = await supabaseClient.auth.signUp({
      email,
      password,
      options: {
        data: {
          username
        }
      }
    });

    if (error) {
      if (error.message.includes('User already registered') || 
          error.message.includes('Email already registered')) {
        return res.status(409).json({
          error: 'An account with this email already exists'
        });
      }
      throw error;
    }

    if (!data.user) {
      return res.status(409).json({
        error: 'An account with this email already exists'
      });
    }

    res.status(201).json({
      message: 'User created successfully',
      user: data.user
    });
  } catch (error) {
    console.error('Signup Error:', error);
    res.status(400).json({ error: error.message });
  }
});

// Sign in
router.post('/login', validateLogin, async (req, res) => {
  try {
    const { email, password } = req.body;

    const { data, error } = await supabaseClient.auth.signInWithPassword({
      email,
      password
    });

    if (error) throw error;

    res.json({
      message: 'Login successful',
      session: data.session,
      user: data.user
    });
  } catch (error) {
    console.error('Login Error:', error);
    res.status(401).json({ error: error.message });
  }
});

// Sign out
router.post('/logout', authMiddleware, async (req, res) => {
  try {
    const { error } = await supabaseClient.auth.signOut();
    
    if (error) throw error;

    res.json({ message: 'Logged out successfully' });
  } catch (error) {
    console.error('Logout Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Password reset request
router.post('/reset-password', async (req, res) => {
  try {
    const { email } = req.body;

    const { error } = await supabaseClient.auth.resetPasswordForEmail(email);

    if (error) throw error;

    res.json({ message: 'Password reset email sent' });
  } catch (error) {
    console.error('Password Reset Error:', error);
    res.status(400).json({ error: error.message });
  }
});

// Get current user
router.get('/me', authMiddleware, async (req, res) => {
  try {
    res.json({ user: req.user });
  } catch (error) {
    console.error('Get User Error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router; 