import 'dart:io';
import 'package:postgres/postgres.dart';

class DatabaseConnection {
  static PostgreSQLConnection? _instance;

  static Future<PostgreSQLConnection> initialize() async {
    if (_instance == null) {
      final host = Platform.environment['DB_HOST'] ?? 'localhost';
      final port = int.parse(Platform.environment['DB_PORT'] ?? '5432');
      final database = Platform.environment['DB_NAME'] ?? 'bookshop';
      final username = Platform.environment['DB_USER'] ?? 'postgres';
      final password = Platform.environment['DB_PASSWORD'] ?? 'postgres';

      _instance = PostgreSQLConnection(
        host,
        port,
        database,
        username: username,
        password: password,
      );

      await _instance!.open();
      print('Database connection established');

      // Run migrations if needed
      await _runMigrations(_instance!);
    }

    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }

  static Future<void> _runMigrations(PostgreSQLConnection connection) async {
    // Create users table
    await connection.query('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        full_name VARCHAR(255) NOT NULL,
        role VARCHAR(50) NOT NULL DEFAULT 'customer',
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create categories table
    await connection.query('''
      CREATE TABLE IF NOT EXISTS categories (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) UNIQUE NOT NULL,
        description TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create books table
    await connection.query('''
      CREATE TABLE IF NOT EXISTS books (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        author VARCHAR(255) NOT NULL,
        isbn VARCHAR(20) UNIQUE NOT NULL,
        description TEXT,
        price DECIMAL(10, 2) NOT NULL,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        category_id INTEGER REFERENCES categories(id),
        publisher VARCHAR(255),
        publication_date DATE,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }
}
