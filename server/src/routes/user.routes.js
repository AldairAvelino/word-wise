const express = require('express');
const { body } = require('express-validator');
const { authMiddleware } = require('../middleware/auth.middleware');
const { supabaseClient } = require('../config/supabase');
const { createClient } = require('@supabase/supabase-js');
const router = express.Router();

// Get user profile
router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const { data, error } = await supabaseClient
      .from('profiles')
      .select('*')
      .eq('id', req.user.id)
      .single();

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Get Profile Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update user profile
router.put('/profile', [
  authMiddleware,
  body('username').optional().isLength({ min: 3 }),
  body('avatar_url').optional().isURL().withMessage('Avatar URL must be a valid URL')  // Validate avatar_url if provided
], async (req, res) => {
  try {
    const updates = {};
    if (req.body.username) updates.username = req.body.username;
    if (req.body.avatar_url !== undefined) updates.avatar_url = req.body.avatar_url; // Allow null

    // Log the updates object and user ID
    console.log('User ID:', req.user.id);
    console.log('Updates:', updates);

    // Create an authenticated client using the user's token
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

    // First verify the profile exists
    const { data: existingProfile, error: profileError } = await authClient
      .from('profiles')
      .select('*')
      .eq('id', req.user.id)
      .maybeSingle();

    console.log('Existing profile check:', { existingProfile, profileError });

    if (profileError) {
      console.error('Profile check error:', profileError);
      return res.status(500).json({
        error: 'Error checking profile existence',
        details: profileError.message
      });
    }

    if (!existingProfile) {
      console.log('Profile not found, attempting to create one');
      // Try to create the profile if it doesn't exist
      const { data: newProfile, error: createError } = await authClient
        .from('profiles')
        .insert({ id: req.user.id, ...updates })
        .select()
        .single();

      if (createError) {
        console.error('Profile creation error:', createError);
        return res.status(400).json({
          error: 'Could not create profile',
          details: createError.message
        });
      }

      return res.json(newProfile);
    }

    // Update the existing profile
    const { data: updatedProfile, error: updateError } = await authClient
      .from('profiles')
      .update(updates)
      .eq('id', req.user.id)
      .select()
      .single();

    console.log('Update result:', { updatedProfile, updateError });

    if (updateError) {
      console.error('Profile update error:', updateError);
      return res.status(400).json({
        error: 'Could not update profile',
        details: updateError.message
      });
    }

    if (!updatedProfile) {
      return res.status(404).json({
        error: 'Profile not found after update',
        details: 'No rows were affected by the update'
      });
    }

    res.json(updatedProfile);
  } catch (error) {
    console.error('Update Profile Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get user statistics
router.get('/statistics', authMiddleware, async (req, res) => {
  try {
    // Create an authenticated client using the user's token
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

    // Log user ID for debugging
    console.log('Fetching statistics for user:', req.user.id);

    const [savedWords, gameScores] = await Promise.all([
      authClient
        .from('saved_words')
        .select('*')
        .eq('user_id', req.user.id),
      authClient
        .from('game_scores')
        .select('*')
        .eq('user_id', req.user.id)
    ]);

    console.log('Saved words result:', { data: savedWords.data, error: savedWords.error });
    console.log('Game scores result:', { data: gameScores.data, error: gameScores.error });

    if (savedWords.error) throw savedWords.error;
    if (gameScores.error) throw gameScores.error;

    const statistics = {
      totalSavedWords: savedWords.data.length,
      masteredWords: savedWords.data.filter(word => word.is_mastered).length,
      likedWords: savedWords.data.filter(word => word.is_liked).length,
      totalGamesPlayed: gameScores.data.length,
      averageScore: gameScores.data.reduce((acc, curr) => acc + curr.score, 0) / (gameScores.data.length || 1)
    };

    console.log('Calculated statistics:', statistics);

    res.json(statistics);
  } catch (error) {
    console.error('Get Statistics Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Get user settings
router.get('/settings', authMiddleware, async (req, res) => {
  try {
    // Create an authenticated client using the user's token
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
      .from('profiles')
      .select('settings')
      .eq('id', req.user.id)
      .single();

    if (error) throw error;

    // Return empty object if settings is null
    res.json(data.settings || {});
  } catch (error) {
    console.error('Get Settings Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Update user settings
router.put('/settings', [
  authMiddleware,
  body('settings').isObject()
], async (req, res) => {
  try {
    const { settings } = req.body;

    // Create an authenticated client using the user's token
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
      .from('profiles')
      .update({ settings })
      .eq('id', req.user.id)
      .select()
      .single();

    if (error) throw error;

    // Return empty object if settings is null
    res.json(data.settings || {});
  } catch (error) {
    console.error('Update Settings Error:', error);
    res.status(400).json({ error: error.message });
  }
});

// Get user progress
router.get('/progress', authMiddleware, async (req, res) => {
  try {
    // Create an authenticated client using the user's token
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

    // Log user ID for debugging
    console.log('Fetching progress for user:', req.user.id);

    const { data: savedWords, error: savedWordsError } = await authClient
      .from('saved_words')
      .select('*')
      .eq('user_id', req.user.id)
      .order('created_at', { ascending: false });

    console.log('Saved words result:', { data: savedWords, error: savedWordsError });

    if (savedWordsError) throw savedWordsError;

    const progress = {
      totalWords: savedWords.length,
      masteredWords: savedWords.filter(word => word.is_mastered).length,
      likedWords: savedWords.filter(word => word.is_liked).length,
      recentActivity: savedWords.slice(0, 5),
      masteryRate: (savedWords.filter(word => word.is_mastered).length / (savedWords.length || 1)) * 100
    };

    console.log('Calculated progress:', progress);

    res.json(progress);
  } catch (error) {
    console.error('Get Progress Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Reactivate user account
router.put('/account/reactivate', authMiddleware, async (req, res) => {
  try {
    // Create an authenticated client using the user's token
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

    // First check if the profile exists and is actually deactivated
    const { data: existingProfile, error: checkError } = await authClient
      .from('profiles')
      .select('*')
      .eq('id', req.user.id)
      .single();

    if (checkError) {
      console.error('Profile check error:', checkError);
      throw checkError;
    }

    if (!existingProfile) {
      return res.status(404).json({
        error: 'Profile not found',
        details: 'No profile exists for this user'
      });
    }

    if (existingProfile.is_active) {
      return res.status(400).json({
        error: 'Account already active',
        details: 'This account is not deactivated'
      });
    }

    // Reactivate the account
    const { data: profile, error: profileError } = await authClient
      .from('profiles')
      .update({ is_active: true })
      .eq('id', req.user.id)
      .select()
      .single();

    if (profileError) {
      console.error('Profile reactivation error:', profileError);
      throw profileError;
    }

    res.json({ 
      message: 'Account reactivated successfully',
      profile
    });
  } catch (error) {
    console.error('Reactivate Account Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Soft delete (deactivate) user account
router.delete('/account/deactive', authMiddleware, async (req, res) => {
  try {
    // Create an authenticated client using the user's token
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

    // Update profile to set is_active to false
    const { data: profile, error: profileError } = await authClient
      .from('profiles')
      .update({ is_active: false })
      .eq('id', req.user.id)
      .select()
      .single();

    if (profileError) {
      console.error('Profile deactivation error:', profileError);
      throw profileError;
    }

    res.json({ 
      message: 'Account deactivated successfully',
      profile
    });
  } catch (error) {
    console.error('Deactivate Account Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Permanent delete user account
router.delete('/account/force', authMiddleware, async (req, res) => {
  try {
    // Create an authenticated client using the user's token
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

    // Delete all user data from related tables
    await Promise.all([
      authClient
        .from('saved_words')
        .delete()
        .eq('user_id', req.user.id),
      authClient
        .from('game_scores')
        .delete()
        .eq('user_id', req.user.id),
      authClient
        .from('profiles')
        .delete()
        .eq('id', req.user.id)
    ]);

    // Delete user authentication data
    const { error: authError } = await authClient.auth.admin.deleteUser(req.user.id);
    if (authError) throw authError;

    res.json({ message: 'Account permanently deleted' });
  } catch (error) {
    console.error('Permanent Delete Account Error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router; 