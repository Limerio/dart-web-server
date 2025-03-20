import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import 'package:server/config/database.dart';
import 'package:server/middleware/cors_middleware.dart';
import 'package:server/middleware/error_middleware.dart';
import 'package:server/middleware/logging_middleware.dart';
import 'package:server/routes/book.dart';
import 'package:server/routes/category.dart';
import 'package:server/routes/user.dart';
import 'package:server/utils/password_util.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class ServerInfo {
  final String url;
  final HttpServer server;

  ServerInfo(this.url, this.server);
}

class TestUtils {
  PostgreSQLConnection? _db;
  HttpServer? _server;
  String? _baseUrl;
  String password = "password123";

  Future<ServerInfo> startServer() async {
    // Use a test database or in-memory database if possible
    _db = await DatabaseConnection.initialize();

    // Reset database tables for tests
    await _resetDatabase();

    // Create the router exactly like in your main app
    final router = Router();
    router.mount('/api/users', UserRoutes(_db!).router.call);
    router.mount('/api/books', BookRoutes(_db!).router.call);
    router.mount('/api/categories', CategoryRoutes(_db!).router.call);

    // Create a handler with the same middleware as your main app
    final handler = Pipeline()
        .addMiddleware(corsMiddleware())
        .addMiddleware(errorMiddleware())
        .addMiddleware(logRequestsMiddleware())
        .addHandler(router.call);

    // Start the server on a random port
    _server = await shelf_io.serve(handler, 'localhost', 0);
    _baseUrl = 'http://localhost:${_server!.port}';

    return ServerInfo(_baseUrl!, _server!);
  }

  Future<void> stopServer() async {
    await _server?.close(force: true);
    await _db?.close();
  }

  Future<void> _resetDatabase() async {
    // This would drop and recreate tables or clear them
    // The order matters due to foreign keys
    final tables = ['books', 'categories', 'users'];

    // Disable foreign key constraints temporarily
    try {
      await _db!.execute('SET session_replication_role = replica;');
    } catch (e) {
      print('Warning: Could not disable constraints: $e');
    }

    for (final table in tables) {
      try {
        // Try truncate which is faster
        await _db!.execute('TRUNCATE TABLE $table CASCADE');
      } catch (e) {
        print('Warning: Could not truncate $table: $e');
        // Fall back to delete
        await _db!.execute('DELETE FROM $table');
      }

      // Reset sequences if using PostgreSQL
      try {
        await _db!.execute("ALTER SEQUENCE ${table}_id_seq RESTART WITH 1");
      } catch (e) {
        print('Warning: Could not reset sequence for $table: $e');
      }
    }

    // Re-enable foreign key constraints
    try {
      await _db!.execute('SET session_replication_role = default;');
    } catch (e) {
      print('Warning: Could not re-enable constraints: $e');
    }

    // Create admin user for testing
    await _createTestUsers();
  }

  Future<void> _createTestUsers() async {
    final hashedPassword = await PasswordUtil.hashPassword(password);

    // Create an admin user
    await _db!.execute('''
      INSERT INTO users (email, password_hash, full_name, role)
      VALUES ('admin@test.com', '$hashedPassword', 'Admin User', 'admin')
    ''');

    // Create a regular user
    await _db!.execute('''
      INSERT INTO users (email, password_hash, full_name, role)
      VALUES ('user@test.com', '$hashedPassword', 'Regular User', 'customer')
    ''');
  }

  Future<String> getAdminToken() async {
    return _getToken('admin@test.com', password);
  }

  Future<String> getUserToken() async {
    return _getToken('user@test.com', password);
  }

  Future<String> _getToken(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get token: ${response.body}');
    }

    final data = json.decode(response.body);
    return data['token'];
  }
}
