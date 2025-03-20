# Dart Web Application

## Tech Stack

- Dart
- HTML
- TailwindCSS
- JavaScript

## Setup and Installation

1. Make sure you have Dart SDK installed
2. Clone this repository
3. Run `dart pub get` to install dependencies
4. Set up your PostgreSQL database
5. Copy `.env.example` to `.env` and update with your configuration
6. Run `dart run bin/server.dart` to start the server

## API Endpoints

### Authentication

- `POST /api/users/register` - Register a new user
- `POST /api/users/login` - Login and get JWT token

### Users

- `GET /api/users` - Get all users (admin only)
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Books

- `GET /api/books` - Get all books
- `GET /api/books/search?q=query` - Search books
- `GET /api/books/:id` - Get book by ID
- `POST /api/books` - Create new book (admin only)
- `PUT /api/books/:id` - Update book (admin only)
- `DELETE /api/books/:id` - Delete book (admin only)

### Categories

- `GET /api/categories` - Get all categories
- `GET /api/categories/:id` - Get category by ID
- `POST /api/categories` - Create new category (admin only)
- `PUT /api/categories/:id` - Update category (admin only)
- `DELETE /api/categories/:id` - Delete category (admin only)
