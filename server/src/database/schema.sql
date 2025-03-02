-- Drop existing type if it exists (with CASCADE to remove dependent objects)
DROP TYPE IF EXISTS public.game_type CASCADE;
DROP TABLE IF EXISTS public.game_scores CASCADE;
DROP TABLE IF EXISTS public.saved_words CASCADE;
DROP TABLE IF EXISTS public.daily_words CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Create profiles table first (since it depends on auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    avatar_url TEXT,
    settings JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Enable RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Policies for profiles
CREATE POLICY "Public profiles are viewable by everyone"
    ON public.profiles
    FOR SELECT
    TO PUBLIC
    USING (true);

CREATE POLICY "Users can update own profile"
    ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id);

-- Create trigger to automatically create profile for new users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, username)
    VALUES (NEW.id, NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile after user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Create game type enum
CREATE TYPE public.game_type AS ENUM (
    'word_match',
    'fill_blanks',
    'flashcards',
    'word_duel'
);

-- Create game_scores table with reference to profiles
CREATE TABLE IF NOT EXISTS public.game_scores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    game_type public.game_type NOT NULL,
    score INTEGER NOT NULL CHECK (score >= 0),
    played_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create RLS policies for game_scores
ALTER TABLE public.game_scores ENABLE ROW LEVEL SECURITY;

-- Policy to allow anyone to view game scores (for leaderboard)
CREATE POLICY "Users can view game scores"
    ON public.game_scores
    FOR SELECT
    TO PUBLIC
    USING (true);

-- Policy to allow users to insert their own game scores
CREATE POLICY "Users can insert their own game scores"
    ON public.game_scores
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Create game sessions table
CREATE TABLE IF NOT EXISTS public.game_sessions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    game_type public.game_type NOT NULL,
    player1_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    player2_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create game_status enum
CREATE TYPE public.game_status AS ENUM (
    'active',
    'inactive',
    'completed',
    'paused'
);

-- Update game_sessions table to use the new enum type for status
ALTER TABLE public.game_sessions
  ALTER COLUMN status TYPE public.game_status USING status::public.game_status;

-- Create saved_words table
CREATE TABLE IF NOT EXISTS public.saved_words (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    word VARCHAR(100) NOT NULL,
    is_mastered BOOLEAN DEFAULT false,
    is_liked BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    UNIQUE(user_id, word)
);

-- Create RLS policies for saved_words
ALTER TABLE public.saved_words ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own saved words"
    ON public.saved_words
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own saved words"
    ON public.saved_words
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own saved words"
    ON public.saved_words
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own saved words"
    ON public.saved_words
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Create daily_words table
CREATE TABLE IF NOT EXISTS public.daily_words (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    word VARCHAR(100) NOT NULL,
    date DATE NOT NULL UNIQUE,
    data JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Create RLS policies for daily_words
ALTER TABLE public.daily_words ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view daily words"
    ON public.daily_words
    FOR SELECT
    TO PUBLIC
    USING (true);

CREATE POLICY "Authenticated users can insert daily words"
    ON public.daily_words
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS game_scores_user_id_idx ON public.game_scores(user_id);
CREATE INDEX IF NOT EXISTS game_scores_game_type_idx ON public.game_scores(game_type);
CREATE INDEX IF NOT EXISTS game_scores_score_idx ON public.game_scores(score);
CREATE INDEX IF NOT EXISTS saved_words_user_id_idx ON public.saved_words(user_id);
CREATE INDEX IF NOT EXISTS saved_words_word_idx ON public.saved_words(word);
CREATE INDEX IF NOT EXISTS daily_words_date_idx ON public.daily_words(date);

-- Create trigger to update profile updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at(); 