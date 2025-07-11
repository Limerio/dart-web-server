# Bookstore Management System

A full-stack web application built with Dart that provides a complete bookstore management system with user authentication, book catalog management, and administrative features.

## 🚀 Features

- **User Authentication**: JWT-based authentication with role-based access control
- **Book Management**: Complete CRUD operations for books with search functionality
- **Category Management**: Organize books by categories
- **User Management**: Admin panel for managing users
- **Responsive Frontend**: Modern HTML/CSS/JavaScript interface with TailwindCSS
- **RESTful API**: Well-documented API endpoints
- **Database Integration**: PostgreSQL with automated migrations
- **Docker Support**: Containerized deployment
- **Kubernetes Ready**: K8s manifests for production deployment
- **CI/CD Pipeline**: GitHub Actions for automated testing and deployment

## 🛠️ Tech Stack

### Backend

- **Dart**: Core programming language
- **Shelf**: HTTP server framework
- **PostgreSQL**: Primary database
- **JWT**: Authentication tokens
- **Docker**: Containerization

### Frontend

- **HTML5**: Markup
- **TailwindCSS**: Styling framework
- **Vanilla JavaScript**: Client-side logic
- **Responsive Design**: Mobile-first approach

### DevOps

- **GitHub Actions**: CI/CD pipeline
- **Docker**: Container runtime
- **Kubernetes**: Container orchestration
- **PostgreSQL**: Database management

## 📋 Prerequisites

Before running this application, ensure you have the following installed:

- [Dart SDK](https://dart.dev/get-dart) (>= 3.7.2)
- [PostgreSQL](https://www.postgresql.org/download/) (>= 12.0)
- [Docker](https://www.docker.com/get-started/) (optional, for containerized deployment)
- [Git](https://git-scm.com/downloads)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Limerio/dart-web-server.git
cd dart-web-server
```

### 2. Install Dependencies

```bash
dart pub get
```

### 3. Database Setup

#### Option A: Using Docker (Recommended)

```bash
docker-compose up -d
```

#### Option B: Manual PostgreSQL Setup

1. Create a PostgreSQL database named `bookshop`
2. Create a user with appropriate permissions
3. Update your environment variables (see below)

### 4. Environment Configuration

Create a `.env` file in the root directory with the following variables:

```env
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=bookshop
DB_USER=postgres
DB_PASSWORD=postgres

# Server Configuration
HOST=localhost
PORT=8080

# Security
JWT_SECRET=your_super_secret_jwt_key_here
```

### 5. Run the Application

```bash
dart run bin/server.dart
```

The application will be available at `http://localhost:8080`

## 📁 Project Structure

```
dart-web-server/
├── bin/
│   └── server.dart              # Application entry point
├── lib/
│   ├── config/
│   │   └── database.dart        # Database configuration
│   ├── middleware/              # HTTP middleware
│   │   ├── auth_middleware.dart
│   │   ├── cors_middleware.dart
│   │   ├── error_middleware.dart
│   │   └── logging_middleware.dart
│   ├── models/                  # Data models
│   │   ├── book.dart
│   │   ├── category.dart
│   │   └── user.dart
│   ├── repositories/            # Data access layer
│   │   ├── book_repository.dart
│   │   ├── category_repository.dart
│   │   └── user_repository.dart
│   ├── routes/                  # API routes
│   │   ├── book.dart
│   │   ├── category.dart
│   │   └── user.dart
│   ├── seed/                    # Database seeding
│   │   └── seed.dart
│   └── utils/                   # Utility functions
│       ├── handler_utils.dart
│       ├── jwt_util.dart
│       ├── password_util.dart
│       └── validation_util.dart
├── static/                      # Frontend assets
│   ├── js/
│   │   ├── api.js
│   │   └── auth.js
│   ├── books.html
│   ├── categories.html
│   ├── index.html
│   ├── login.html
│   ├── profile.html
│   └── register.html
├── test/                        # Test files
│   ├── routes/
│   ├── utils/
│   └── test_runner.dart
├── k8s/                         # Kubernetes manifests
├── docker-compose.yaml          # Docker Compose configuration
├── Dockerfile                   # Docker image definition
└── pubspec.yaml                 # Dart dependencies
```

## 🔧 Development

### Running Tests

```bash
# Run all tests
dart test

# Run tests with coverage
dart test --coverage=coverage

# Run specific test file
dart test test/routes/book_routes_test.dart
```

### Code Quality

```bash
# Format code
dart format .

# Analyze code
dart analyze

# Fix common issues
dart fix --apply
```

### Database Seeding

To populate the database with sample data:

```bash
dart run lib/seed/seed.dart
```

This will create:

- Sample categories (Fiction, Non-Fiction, Science Fiction, etc.)
- 50-100 random books with realistic data
- Test users (admin and regular user)

## 📚 API Documentation

### Authentication

| Method | Endpoint              | Description             | Auth Required |
| ------ | --------------------- | ----------------------- | ------------- |
| POST   | `/api/users/register` | Register a new user     | No            |
| POST   | `/api/users/login`    | Login and get JWT token | No            |

### Users

| Method | Endpoint         | Description    | Auth Required |
| ------ | ---------------- | -------------- | ------------- |
| GET    | `/api/users`     | Get all users  | Admin         |
| GET    | `/api/users/:id` | Get user by ID | Yes           |
| PUT    | `/api/users/:id` | Update user    | Yes           |
| DELETE | `/api/users/:id` | Delete user    | Admin         |

### Books

| Method | Endpoint                    | Description     | Auth Required |
| ------ | --------------------------- | --------------- | ------------- |
| GET    | `/api/books`                | Get all books   | No            |
| GET    | `/api/books/search?q=query` | Search books    | No            |
| GET    | `/api/books/:id`            | Get book by ID  | No            |
| POST   | `/api/books`                | Create new book | Admin         |
| PUT    | `/api/books/:id`            | Update book     | Admin         |
| DELETE | `/api/books/:id`            | Delete book     | Admin         |

### Categories

| Method | Endpoint              | Description         | Auth Required |
| ------ | --------------------- | ------------------- | ------------- |
| GET    | `/api/categories`     | Get all categories  | No            |
| GET    | `/api/categories/:id` | Get category by ID  | No            |
| POST   | `/api/categories`     | Create new category | Admin         |
| PUT    | `/api/categories/:id` | Update category     | Admin         |
| DELETE | `/api/categories/:id` | Delete category     | Admin         |

### Authentication Headers

For protected endpoints, include the JWT token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

### Example API Requests

#### Register a new user

```bash
curl -X POST http://localhost:8080/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "fullName": "John Doe"
  }'
```

#### Login

```bash
curl -X POST http://localhost:8080/api/users/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

#### Create a book (Admin only)

```bash
curl -X POST http://localhost:8080/api/books \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin-token>" \
  -d '{
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald",
    "description": "A classic American novel",
    "price": 12.99,
    "stock": 50,
    "categoryId": 1
  }'
```

## 🐳 Docker Deployment

### Build and Run with Docker

```bash
# Build the Docker image
docker build -t bookstore-app .

# Run the container
docker run -p 8080:8080 --env-file .env bookstore-app
```

### Using Docker Compose

```bash
# Start all services (app + database)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## ☸️ Kubernetes Deployment

### Prerequisites

- Kubernetes cluster
- kubectl configured
- Docker images pushed to a registry

### Deploy to Kubernetes

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Create ConfigMap and Secrets (create these first)
kubectl create configmap bookshop-config \
  --from-literal=DB_HOST=postgres-service \
  --from-literal=DB_PORT=5432 \
  --from-literal=DB_NAME=bookshop \
  --from-literal=DB_USER=postgres \
  --from-literal=HOST=0.0.0.0 \
  --from-literal=PORT=8080 \
  -n bookshop

kubectl create secret generic bookshop-secrets \
  --from-literal=DB_PASSWORD=postgres \
  --from-literal=JWT_SECRET=your-secret-key \
  -n bookshop

# Deploy PostgreSQL
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml

# Deploy application
kubectl apply -f k8s/app-deployment.yaml
kubectl apply -f k8s/app-service.yaml
kubectl apply -f k8s/ingress.yaml
```

## 🧪 Testing

### Test Structure

The project includes comprehensive tests for:

- API endpoints
- Authentication middleware
- Database operations
- Utility functions

### Running Tests

```bash
# Run all tests
dart test

# Run with verbose output
dart test --verbose

# Run specific test suite
dart test test/routes/book_routes_test.dart

# Run tests with coverage
dart test --coverage=coverage
```

### Test Environment

Tests use a separate database connection and automatically:

- Set up test data before each test
- Clean up after each test
- Use realistic test scenarios

## 🚀 CI/CD Pipeline

The project includes GitHub Actions workflows for:

### Main Workflow (`.github/workflows/main.yml`)

- Runs on every push and pull request
- Tests against PostgreSQL service
- Runs code formatting checks
- Runs static analysis
- Executes test suite

### Release Workflow (`.github/workflows/release.yml`)

- Triggers on version tags
- Builds binaries for Linux, Windows, and macOS
- Creates GitHub releases with artifacts

## 🔒 Security

### Authentication

- JWT tokens with configurable expiration
- Password hashing using bcrypt
- Role-based access control (Admin/Customer)

### Environment Variables

- Sensitive data stored in environment variables
- Kubernetes secrets for production deployment
- No hardcoded credentials

### API Security

- CORS middleware for cross-origin requests
- Input validation on all endpoints
- SQL injection prevention through parameterized queries

## 📖 Additional Resources

- [Dart Documentation](https://dart.dev/guides)
- [Shelf Framework](https://pub.dev/packages/shelf)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
