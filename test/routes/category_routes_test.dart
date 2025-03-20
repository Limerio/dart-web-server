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

  group('Category API Tests', () {
    late int testCategoryId;

    group('Category CRUD Operations', () {
      test('should create a new category with admin privileges', () async {
        final newCategory = {
          'name': 'Test Category ${DateTime.now().millisecondsSinceEpoch}',
          'description': 'A category for testing',
        };

        final response = await http.post(
          Uri.parse('$baseUrl/api/categories'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
          body: json.encode(newCategory),
        );

        expect(response.statusCode, equals(201));
        final body = json.decode(response.body);
        expect(body['name'], equals(newCategory['name']));
        testCategoryId = body['id'];
      });

      test('should get all categories without authentication', () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/categories'),
          headers: {'Content-Type': 'application/json'},
        );

        expect(response.statusCode, equals(200));
        final body = json.decode(response.body);
        expect(body, isList);
      });

      test('should get a category by ID', () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/categories/$testCategoryId'),
          headers: {'Content-Type': 'application/json'},
        );

        expect(response.statusCode, equals(200));
        final body = json.decode(response.body);
        expect(body['id'], equals(testCategoryId));
      });

      test('should update a category with admin privileges', () async {
        final updates = {
          'name': 'Updated Test Category',
          'description': 'Updated description',
        };

        final response = await http.put(
          Uri.parse('$baseUrl/api/categories/$testCategoryId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
          body: json.encode(updates),
        );

        expect(response.statusCode, equals(200));
        final body = json.decode(response.body);
        expect(body['name'], equals(updates['name']));
        expect(body['description'], equals(updates['description']));
      });

      test('should reject update without admin privileges', () async {
        final updates = {'name': 'This should fail'};

        final response = await http.put(
          Uri.parse('$baseUrl/api/categories/$testCategoryId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
          body: json.encode(updates),
        );

        expect(response.statusCode, equals(403));
      });

      test('should delete a category with admin privileges', () async {
        final response = await http.delete(
          Uri.parse('$baseUrl/api/categories/$testCategoryId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
        );

        expect(response.statusCode, equals(204));

        // Verify category is deleted
        final getResponse = await http.get(
          Uri.parse('$baseUrl/api/categories/$testCategoryId'),
          headers: {'Content-Type': 'application/json'},
        );

        expect(getResponse.statusCode, equals(404));
      });
    });
  });
}
