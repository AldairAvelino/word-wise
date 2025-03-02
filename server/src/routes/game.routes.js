const express = require('express');
const { body, validationResult } = require('express-validator');
const { authMiddleware } = require('../middleware/auth.middleware');
const { supabaseClient } = require('../config/supabase');
const { createClient } = require('@supabase/supabase-js');
const router = express.Router();

// Valid game types
const VALID_GAME_TYPES = ['word_match', 'fill_blanks', 'flashcards', 'word_duel'];

// Validation middleware for game score
const validateGameScore = [
  body('game_type')
    .trim()
    .notEmpty()
    .withMessage('Game type is required')
    .isIn(VALID_GAME_TYPES)
    .withMessage('Invalid game type. Must be one of: ' + VALID_GAME_TYPES.join(', ')),
  body('score')
    .isInt({ min: 0 })
    .withMessage('Score must be a non-negative number')
];

// Submit game score
router.post('/score', authMiddleware, validateGameScore, async (req, res) => {
  try {
    console.log('Request body:', req.body);

    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      console.log('Validation errors:', errors.array());
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { game_type, score } = req.body;
    const userId = req.user.id;

    // Check if the profile exists
    const { data: profileData, error: profileError } = await supabaseClient
      .from('profiles')
      .select('id')
      .eq('id', userId)
      .single();

    if (profileError || !profileData) {
      return res.status(400).json({
        error: 'Profile does not exist for this user',
        details: profileError?.message || 'Profile not found'
      });
    }

    // Create an authenticated Supabase client using the user's access token
    const authClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY,
      {
        global: {
          headers: {
            Authorization: req.headers.authorization
          }
        }
      }
    );

    const { data, error } = await authClient
      .from('game_scores')
      .insert({
        user_id: userId,
        game_type,
        score,
        played_at: new Date().toISOString()
      })
      .select()
      .maybeSingle();

    if (error) {
      console.error('Submit score error:', error);
      throw error;
    }

    if (!data) {
      throw new Error('Failed to save game score');
    }

    res.status(201).json(data);
  } catch (error) {
    console.error('Submit Score Error:', error);
    res.status(500).json({
      error: 'Failed to save game score',
      details: error.message
    });
  }
});

// Get user's game history
router.get('/history', authMiddleware, async (req, res) => {
  try {
    const { data, error } = await supabaseClient
      .from('game_scores')
      .select('*')
      .eq('user_id', req.user.id)
      .order('played_at', { ascending: false });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Get Game History Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get game leaderboard
router.get('/leaderboard/:gameType', async (req, res) => {
  try {
    const { gameType } = req.params;

    // Validate game type
    if (!VALID_GAME_TYPES.includes(gameType)) {
      return res.status(400).json({
        error: 'Invalid game type',
        details: `Game type must be one of: ${VALID_GAME_TYPES.join(', ')}`
      });
    }

    // Create a client to use for the query
    const { data, error } = await supabaseClient
      .from('game_scores')
      .select(`
        id,
        score,
        played_at,
        game_type,
        user_id,
        profiles (
          username,
          avatar_url
        )
      `)
      .eq('game_type', gameType)
      .order('score', { ascending: false })
      .limit(10);

    if (error) {
      console.error('Leaderboard query error:', error);
      throw error;
    }

    // Format the response
    const formattedData = data.map(entry => ({
      id: entry.id,
      score: entry.score,
      played_at: entry.played_at,
      game_type: entry.game_type,
      player: {
        username: entry.profiles?.username || 'Anonymous',
        avatar_url: entry.profiles?.avatar_url
      }
    }));

    res.json(formattedData);
  } catch (error) {
    console.error('Get Leaderboard Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get user's best scores
router.get('/best-scores', authMiddleware, async (req, res) => {
  try {
    const { data, error } = await supabaseClient
      .rpc('get_user_best_scores', {
        user_id_param: req.user.id
      });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Get Best Scores Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get game statistics
router.get('/stats', authMiddleware, async (req, res) => {
  try {
    const { data, error } = await supabaseClient
      .rpc('get_user_game_stats', {
        user_id_param: req.user.id
      });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Get Game Stats Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Start a multiplayer game session
router.post('/multiplayer/start', authMiddleware, async (req, res) => {
  try {
    const { game_type, opponent_id } = req.body;
    const userId = req.user.id;

    // Validate game_type and opponent_id
    if (!game_type || !opponent_id) {
      return res.status(400).json({ error: 'Game type and opponent ID are required.' });
    }

    // Check if the opponent is the same as the user
    if (userId === opponent_id) {
      return res.status(400).json({ error: 'You cannot play against yourself.' });
    }

    // Check if the opponent exists
    const { data: opponentData, error: opponentError } = await supabaseClient
      .from('profiles')
      .select('id')
      .eq('id', opponent_id)
      .single();

    if (opponentError || !opponentData) {
      return res.status(400).json({ error: 'Opponent does not exist.' });
    }

    const { data, error } = await supabaseClient
      .from('game_sessions')
      .insert({
        game_type,
        player1_id: userId,
        player2_id: opponent_id,
        status: 'active',
        started_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) throw error;

    res.status(201).json(data);
  } catch (error) {
    console.error('Start Multiplayer Game Error:', error);
    res.status(400).json({ error: error.message });
  }
});

// Update multiplayer game state
router.put('/multiplayer/:sessionId', authMiddleware, async (req, res) => {
  try {
    const { sessionId } = req.params;
    const { game_state, status } = req.body;

    const { data, error } = await supabaseClient
      .from('game_sessions')
      .update({
        game_state,
        status,
        updated_at: new Date().toISOString()
      })
      .eq('id', sessionId)
      .select()
      .single();

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Update Game State Error:', error);
    res.status(400).json({ error: error.message });
  }
});

// Get active multiplayer games
router.get('/multiplayer/active', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;

    const { data, error } = await supabaseClient
      .from('game_sessions')
      .select(`
        *,
        player1:player1_id (username),
        player2:player2_id (username)
      `)
      .or(`player1_id.eq.${userId},player2_id.eq.${userId}`)
      .eq('status', 'active')
      .order('started_at', { ascending: false });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Get Active Games Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get completed multiplayer games
router.get('/multiplayer/completed', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;

    const { data, error } = await supabaseClient
      .from('game_sessions')
      .select(`
        *,
        player1:player1_id (username),
        player2:player2_id (username)
      `)
      .or(`player1_id.eq.${userId},player2_id.eq.${userId}`)
      .eq('status', 'completed')
      .order('started_at', { ascending: false });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Get Active Games Error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router; 