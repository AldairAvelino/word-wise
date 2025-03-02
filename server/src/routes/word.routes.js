const express = require('express');
const fetch = require('node-fetch');
const { body, validationResult } = require('express-validator');
const { authMiddleware, optionalAuth } = require('../middleware/auth.middleware');
const { supabaseClient, supabaseAdmin } = require('../config/supabase');
const { createClient } = require('@supabase/supabase-js');
const router = express.Router();

// Validation middleware for saving words
const validateSaveWord = [
  body('word').trim().notEmpty().withMessage('Word is required')
];

// Get word definition from Dictionary API
router.get('/search/:word', optionalAuth, async (req, res) => {
  try {
    const { word } = req.params;
    const response = await fetch(`${process.env.DICTIONARY_API_URL}/${word}`);
    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.message || 'Word not found');
    }

    // If user is authenticated, check if word is saved
    let isSaved = false;
    let isLiked = false;
    let isMastered = false;

    if (req.user) {
      const { data: savedWord } = await supabaseClient
        .from('saved_words')
        .select('*')
        .eq('user_id', req.user.id)
        .eq('word', word.toLowerCase())
        .single();

      if (savedWord) {
        isSaved = true;
        isLiked = savedWord.is_liked;
        isMastered = savedWord.is_mastered;
      }
    }

    res.json({
      ...data[0],
      isSaved,
      isLiked,
      isMastered
    });
  } catch (error) {
    console.error('Word Search Error:', error);
    res.status(404).json({ error: error.message });
  }
});

// Save a word
router.post('/save', authMiddleware, validateSaveWord, async (req, res) => {
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

    const { word } = req.body;
    console.log('Word to save:', word);
    
    if (!word) {
      return res.status(400).json({
        error: 'Word is required',
        received: req.body
      });
    }

    const userId = req.user.id;
    console.log('User ID:', userId);
    const normalizedWord = word.toLowerCase().trim();

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

    // Check if word exists in dictionary before saving
    try {
      const response = await fetch(`${process.env.DICTIONARY_API_URL}/${normalizedWord}`);
      const data = await response.json();

      if (!response.ok) {
        return res.status(404).json({
          error: 'Word not found in dictionary',
          details: data.message || 'No additional details'
        });
      }
    } catch (apiError) {
      console.error('Dictionary API Error:', apiError);
      return res.status(502).json({
        error: 'Failed to verify word in dictionary',
        details: apiError.message
      });
    }

    // Check if word is already saved using authenticated client
    const { data: existingWord, error: checkError } = await authClient
      .from('saved_words')
      .select('*')
      .eq('user_id', userId)
      .eq('word', normalizedWord)
      .maybeSingle();

    if (checkError) {
      console.error('Check existing word error:', checkError);
      throw checkError;
    }

    if (existingWord) {
      return res.status(409).json({
        error: 'Word is already saved',
        word: existingWord
      });
    }

    // Save the word using authenticated client
    const { data: savedWord, error: saveError } = await authClient
      .from('saved_words')
      .insert({
        user_id: userId,
        word: normalizedWord,
        is_mastered: false,
        is_liked: false,
        created_at: new Date().toISOString()
      })
      .select()
      .maybeSingle();

    if (saveError) {
      console.error('Save word error:', saveError);
      throw saveError;
    }

    if (!savedWord) {
      throw new Error('Word was not saved properly');
    }

    res.status(201).json({
      message: 'Word saved successfully',
      word: savedWord
    });
  } catch (error) {
    console.error('Save Word Error:', error);
    res.status(500).json({
      error: 'Failed to save word',
      details: error.message
    });
  }
});

// Get user's saved words
router.get('/saved', authMiddleware, async (req, res) => {
  try {
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
      .from('saved_words')
      .select('*')
      .eq('user_id', req.user.id)
      .order('created_at', { ascending: false });

    if (error) throw error;

    res.json(data);
  } catch (error) {
    console.error('Get Saved Words Error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Toggle word like status
router.put('/:id/like', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { is_liked } = req.body;

    // Validate request body
    if (typeof is_liked !== 'boolean') {
      return res.status(400).json({
        error: 'Invalid request',
        details: 'is_liked must be a boolean value'
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

    // First check if the word exists and belongs to the user
    const { data: existingWord, error: checkError } = await authClient
      .from('saved_words')
      .select('*')
      .eq('id', id)
      .eq('user_id', req.user.id)
      .maybeSingle();

    if (checkError) {
      console.error('Check word error:', checkError);
      throw checkError;
    }

    if (!existingWord) {
      return res.status(404).json({
        error: 'Word not found',
        details: 'The specified word does not exist or does not belong to you'
      });
    }

    // Update the word's like status
    const { data: updatedWord, error: updateError } = await authClient
      .from('saved_words')
      .update({ is_liked })
      .eq('id', id)
      .eq('user_id', req.user.id)
      .select()
      .maybeSingle();

    if (updateError) {
      console.error('Update word error:', updateError);
      throw updateError;
    }

    if (!updatedWord) {
      throw new Error('Failed to update word');
    }

    res.json(updatedWord);
  } catch (error) {
    console.error('Toggle Like Error:', error);
    res.status(500).json({
      error: 'Failed to update word',
      details: error.message
    });
  }
});

// Toggle word mastered status
router.put('/:id/master', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { is_mastered } = req.body;

    // Validate request body
    if (typeof is_mastered !== 'boolean') {
      return res.status(400).json({
        error: 'Invalid request',
        details: 'is_mastered must be a boolean value'
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

    // First check if the word exists and belongs to the user
    const { data: existingWord, error: checkError } = await authClient
      .from('saved_words')
      .select('*')
      .eq('id', id)
      .eq('user_id', req.user.id)
      .maybeSingle();

    if (checkError) {
      console.error('Check word error:', checkError);
      throw checkError;
    }

    if (!existingWord) {
      return res.status(404).json({
        error: 'Word not found',
        details: 'The specified word does not exist or does not belong to you'
      });
    }

    // Update the word's mastered status
    const { data: updatedWord, error: updateError } = await authClient
      .from('saved_words')
      .update({ is_mastered })
      .eq('id', id)
      .eq('user_id', req.user.id)
      .select()
      .maybeSingle();

    if (updateError) {
      console.error('Update word error:', updateError);
      throw updateError;
    }

    if (!updatedWord) {
      throw new Error('Failed to update word');
    }

    res.json(updatedWord);
  } catch (error) {
    console.error('Toggle Mastered Error:', error);
    res.status(500).json({
      error: 'Failed to update word',
      details: error.message
    });
  }
});

// Delete saved word
router.delete('/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;

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

    const { error } = await authClient
      .from('saved_words')
      .delete()
      .eq('id', id)
      .eq('user_id', req.user.id);

    if (error) throw error;

    res.json({ message: 'Word deleted successfully' });
  } catch (error) {
    console.error('Delete Word Error:', error);
    res.status(400).json({ error: error.message });
  }
});

// Get daily word
router.get('/daily', optionalAuth, async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];

    // Create an authenticated Supabase client if user is authenticated
    const client = req.user ? createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY,
      {
        global: {
          headers: {
            Authorization: req.headers.authorization
          }
        }
      }
    ) : supabaseAdmin;

    // Try to get today's word
    const { data: dailyWord, error } = await client
      .from('daily_words')
      .select('*')
      .eq('date', today)
      .maybeSingle();

    if (error) {
      console.error('Get daily word error:', error);
      throw error;
    }

    if (dailyWord) {
      return res.json(dailyWord);
    }

    // If no daily word exists, create one using the Random Word API
    try {
      // First, get a random word from the Random Word API
      const randomWordResponse = await fetch('https://random-word-api.herokuapp.com/word');
      if (!randomWordResponse.ok) {
        throw new Error('Failed to fetch random word');
      }
      const [randomWord] = await randomWordResponse.json();
      
      // Fetch complete word information from Dictionary API
      const response = await fetch(`${process.env.DICTIONARY_API_URL}/${randomWord}`);
      const wordData = await response.json();

      // If the random word is not found in the dictionary, try again up to 3 times
      let attempts = 1;
      const maxAttempts = 3;

      while ((!response.ok || !wordData[0]) && attempts < maxAttempts) {
        console.log(`Attempt ${attempts + 1}: Word '${randomWord}' not found in dictionary, trying another word...`);
        
        // Get another random word
        const retryResponse = await fetch('https://random-word-api.herokuapp.com/word');
        const [newRandomWord] = await retryResponse.json();
        
        // Try to get its definition
        const retryDictionaryResponse = await fetch(`${process.env.DICTIONARY_API_URL}/${newRandomWord}`);
        wordData = await retryDictionaryResponse.json();
        response.ok = retryDictionaryResponse.ok;
        
        attempts++;
      }

      if (!response.ok || !wordData[0]) {
        throw new Error('Could not find a suitable word in the dictionary after multiple attempts');
      }

      // Extract relevant information
      const {
        word,
        phonetic,
        phonetics,
        meanings,
        sourceUrls
      } = wordData[0];

      // Find the first available audio URL
      const audioUrl = phonetics.find(p => p.audio)?.audio || '';

      // Process meanings to extract definitions, examples, synonyms, and antonyms
      const processedMeanings = meanings.map(meaning => ({
        partOfSpeech: meaning.partOfSpeech,
        definitions: meaning.definitions.map(def => ({
          definition: def.definition,
          example: def.example || null,
          synonyms: def.synonyms || [],
          antonyms: def.antonyms || []
        })),
        synonyms: meaning.synonyms || [],
        antonyms: meaning.antonyms || []
      }));

      // Combine all synonyms and antonyms
      const allSynonyms = [...new Set([
        ...meanings.flatMap(m => m.synonyms || []),
        ...meanings.flatMap(m => m.definitions.flatMap(d => d.synonyms || []))
      ])];

      const allAntonyms = [...new Set([
        ...meanings.flatMap(m => m.antonyms || []),
        ...meanings.flatMap(m => m.definitions.flatMap(d => d.antonyms || []))
      ])];

      // Create the daily word entry with complete information
      const dailyWordData = {
        word,
        phonetic,
        audioUrl,
        meanings: processedMeanings,
        synonyms: allSynonyms,
        antonyms: allAntonyms,
        sourceUrls
      };

      // Save to database using admin client
      const { data: newDailyWord, error: createError } = await supabaseAdmin
        .from('daily_words')
        .upsert({
          word: word.toLowerCase(),
          date: today,
          data: dailyWordData
        })
        .select()
        .maybeSingle();

      if (createError) {
        console.error('Create daily word error:', createError);
        throw createError;
      }

      if (!newDailyWord) {
        throw new Error('Failed to create daily word');
      }

      return res.json(newDailyWord);
    } catch (apiError) {
      console.error('Dictionary API Error:', apiError);
      throw new Error('Failed to create daily word: ' + apiError.message);
    }
  } catch (error) {
    console.error('Daily Word Error:', error);
    res.status(500).json({
      error: 'Failed to get or create daily word',
      details: error.message
    });
  }
});

module.exports = router; 