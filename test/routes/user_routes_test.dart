import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../utils/test_utils.dart';

void main() {
  final testUtils = TestUtils();
  late String baseUrl;
  late String adminToken;
  late String userToken;

  setUpAll(() async {
    // Start server and get test tokens
    final serverInfo = await testUtils.startServer();
    baseUrl = serverInfo.url;
    adminToken = await testUtils.getAdminToken();
    userToken = await testUtils.getUserToken();
  });

  tearDownAll(() async {
    // Cleanup and stop the server
    await testUtils.stopServer();
  });

  group('User API Tests', () {
    // Registration tests
    group('Registration', () {
      test('should register a new user', () async {
        final newUser = {
          'email': 'newuser@example.com',
          'password': 'password123',
          'full_name': 'New User',
        };

        final response = await http.post(
          Uri.parse('$baseUrl/api/users/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newUser),
        );

        expect(response.statusCode, equals(201));
        final body = json.decode(response.body);
        expect(body['user']['email'], equals(newUser['email']));
        expect(body['user']['full_name'], equals(newUser['full_name']));
        expect(body['token'], isNotNull);
      });

      test('should return 409 if user already exists', () async {
        final existingUser = {
          'email': 'newuser@example.com',
          'password': 'password123',
          'full_name': 'New User',
        };

        final response = await http.post(
          Uri.parse('$baseUrl/api/users/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(existingUser),
        );

        expect(response.statusCode, equals(409));
      });

      test('should return 400 if required fields are missing', () async {
        final incompleteUser = {
          'email': 'incomplete@example.com',
          // missing password and full_name
        };

        final response = await http.post(
          Uri.parse('$baseUrl/api/users/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(incompleteUser),
        );

        expect(response.statusCode, equals(400));
      });
    });

    // Login tests
    group('Login', () {
      test('should login successfully with valid credentials', () async {
        final credentials = {
          'email': 'newuser@example.com',
          'password': 'password123',
        };

        final response = await http.post(
          Uri.parse('$baseUrl/api/users/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(credentials),
        );

        expect(response.statusCode, equals(200));
        final body = json.decode(response.body);
        expect(body['user']['email'], equals(credentials['email']));
        expect(body['token'], isNotNull);
      });

      test('should return 401 with invalid credentials', () async {
        final wrongCredentials = {
          'email': 'newuser@example.com',
          'password': 'wrongpassword',
        };

        final response = await http.post(
          Uri.parse('$baseUrl/api/users/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(wrongCredentials),
        );

        expect(response.statusCode, equals(401));
      });
    });

    // Profile tests
    group('Profile', () {
      test('should get user profile with valid token', () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/users/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
        );

        expect(response.statusCode, equals(200));
        final body = json.decode(response.body);
        expect(body['email'], isNotNull);
        expect(body['full_name'], isNotNull);
      });

      test('should return 401 without token', () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/users/profile'),
          headers: {'Content-Type': 'application/json'},
        );

        expect(response.statusCode, equals(401));
      });
    });

    // Admin only routes
    group('Admin Routes', () {
      test('should get all users with admin token', () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/users'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
        );

        expect(response.statusCode, equals(200));
        final body = json.decode(response.body);
        expect(body, isList);
      });

      test('should return 401 with non-admin token', () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/users'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
        );

        expect(response.statusCode, equals(403));
      });
    });

    // CRUD operations with authentication
    group('User CRUD Operations', () {
      late int testUserId;

      setUp(() async {
        // Create a test user to manipulate
        final newUser = {
          'email':
              'testcrud${DateTime.now().millisecondsSinceEpoch}@example.com',
          'password': 'password123',
          'full_name': 'Test CRUD User',
        };

        final response = await http.post(
          Uri.parse('$baseUrl/api/users/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newUser),
        );

        // Check if registration was successful
        expect(response.statusCode, equals(201));
        final body = json.decode(response.body);
        testUserId = body['user']['id'];
      });

      test('should get user by ID', () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/users/$testUserId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
        );

        expect(response.statusCode, equals(200));
        final body = json.decode(response.body);
        expect(body['id'], equals(testUserId));
      });

      test('should update user', () async {
        final updates = {'full_name': 'Updated CRUD User'};

        final response = await http.put(
          Uri.parse('$baseUrl/api/users/$testUserId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
          body: json.encode(updates),
        );

        expect(response.statusCode, equals(200));
        final body = json.decode(response.body);
        expect(body['full_name'], equals(updates['full_name']));
      });

      test('should delete user', () async {
        final response = await http.delete(
          Uri.parse('$baseUrl/api/users/$testUserId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
        );

        expect(response.statusCode, equals(204));

        // Verify user is deleted
        final getResponse = await http.get(
          Uri.parse('$baseUrl/api/users/$testUserId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
        );

        expect(getResponse.statusCode, equals(404));
      });
    });
  });
}
