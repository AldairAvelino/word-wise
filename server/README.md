# WordWise Server

This is the backend server for the WordWise English Dictionary App. It provides RESTful APIs for user management, word definitions, game functionality, and user progress tracking.

## Technology Stack

- Node.js
- Express.js
- Supabase (PostgreSQL)
- Dictionary API (dictionaryapi.dev)

## Prerequisites

- Node.js (v14 or higher)
- npm (v6 or higher)
- Supabase account and project

## Setup

1. Clone the repository and navigate to the server directory:
```bash
cd server
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the server directory and add your environment variables:
```env
PORT=3000
NODE_ENV=development

# Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# JWT Configuration
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=24h

# Dictionary API Configuration
DICTIONARY_API_URL=https://api.dictionaryapi.dev/api/v2/entries/en
```

4. Start the development server:
```bash
npm run dev
```

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Create a new user account
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `POST /api/auth/reset-password` - Request password reset
- `GET /api/auth/me` - Get current user

### Words
- `GET /api/words/search/:word` - Search for word definitions
- `POST /api/words/save` - Save a word
- `GET /api/words/saved` - Get user's saved words
- `PUT /api/words/:id/like` - Toggle word like status
- `PUT /api/words/:id/master` - Toggle word mastered status
- `DELETE /api/words/:id` - Delete saved word
- `GET /api/words/daily` - Get daily word

### Games
- `POST /api/games/score` - Submit game score
- `GET /api/games/history` - Get user's game history
- `GET /api/games/leaderboard/:gameType` - Get game leaderboard
- `GET /api/games/best-scores` - Get user's best scores
- `GET /api/games/stats` - Get game statistics
- `POST /api/games/multiplayer/start` - Start multiplayer game
- `PUT /api/games/multiplayer/:sessionId` - Update game state
- `GET /api/games/multiplayer/active` - Get active multiplayer games

### User Profile
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile
- `GET /api/user/statistics` - Get user statistics
- `GET /api/user/settings` - Get user settings
- `PUT /api/user/settings` - Update user settings
- `GET /api/user/progress` - Get user progress
- `DELETE /api/user/account` - Delete user account

## Development

### Running Tests
```bash
npm test
```

### Code Style
The project uses ESLint for code linting. Run the linter:
```bash
npm run lint
```

## Database Schema

The application uses Supabase (PostgreSQL) with the following main tables:

- users
- saved_words
- game_scores
- game_sessions
- daily_words

For detailed schema information, refer to the technical specification document.

## Security

The server implements several security measures:

- JWT authentication
- Request rate limiting
- Input validation
- CORS protection
- Security headers (Helmet)
- Secure password handling

## Error Handling

The application uses a centralized error handling middleware. All errors are properly logged and returned with appropriate HTTP status codes.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License. 