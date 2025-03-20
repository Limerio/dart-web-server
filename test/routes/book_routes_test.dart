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

  group('Book API Tests', () {
    late int testBookId;
    late int testCategoryId;

    // Setup a test category to use with books
    setUp(() async {
      // Create test category with unique name to avoid duplicate key error
      final category = {
        'name': 'Test Category ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'Category for testing books',
      };

      final categoryResponse = await http.post(
        Uri.parse('$baseUrl/api/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $adminToken',
        },
        body: json.encode(category),
      );

      expect(
        categoryResponse.statusCode,
        equals(201),
        reason: 'Failed to create category: ${categoryResponse.body}',
      );

      final categoryBody = json.decode(categoryResponse.body);
      testCategoryId = categoryBody['id'];

      // Verify the category ID is not null
      expect(
        testCategoryId,
        isNotNull,
        reason: 'Category ID should not be null',
      );
    });

    group('Book CRUD Operations', () {
      test('should create a new book with admin privileges', () async {
        final newBook = {
          'title': 'Test Book ${DateTime.now().millisecondsSinceEpoch}',
          'author': 'Test Author',
          'isbn':
              '978${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}',
          'price': 19.99,
          'description': 'A book for testing',
          'stock_quantity': 10,
          'category_id': testCategoryId,
          'publisher': 'Test Publisher',
          'publication_date': '2023-01-01',
        };

        final response = await http.post(
          Uri.parse('$baseUrl/api/books'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
          body: json.encode(newBook),
        );

        expect(
          response.statusCode,
          equals(201),
          reason: 'Failed to create book: ${response.body}',
        );

        final body = json.decode(response.body);
        expect(body['title'], equals(newBook['title']));
        testBookId = body['id'];

        // Verify the book ID is not null
        expect(testBookId, isNotNull, reason: 'Book ID should not be null');
      });

      test('should get all books without authentication', () async {
        // First ensure we have a book to retrieve
        expect(
          testBookId,
          isNotNull,
          reason: 'Test book ID should be set before this test',
        );

        final response = await http.get(
          Uri.parse('$baseUrl/api/books'),
          headers: {'Content-Type': 'application/json'},
        );

        expect(
          response.statusCode,
          equals(200),
          reason: 'Failed to get books: ${response.body}',
        );

        final body = json.decode(response.body);
        expect(body, isList);
        expect(
          body.length,
          greaterThan(0),
          reason: 'Expected at least one book',
        );
      });

      test('should get a book by ID', () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/books/$testBookId'),
          headers: {'Content-Type': 'application/json'},
        );

        expect(
          response.statusCode,
          equals(200),
          reason: 'Failed to get book by ID: ${response.body}',
        );

        final body = json.decode(response.body);
        expect(body['id'], equals(testBookId));
      });

      test('should search books by title', () async {
        final response = await http.get(
          Uri.parse('$baseUrl/api/books/search?query=Test'),
          headers: {'Content-Type': 'application/json'},
        );

        expect(
          response.statusCode,
          equals(200),
          reason: 'Failed to search books: ${response.body}',
        );

        final body = json.decode(response.body);
        expect(body, isList);
        expect(
          body.length,
          greaterThan(0),
          reason: 'Expected at least one book in search results',
        );
      });

      test('should update a book with admin privileges', () async {
        final updates = {'title': 'Updated Test Book', 'price': 24.99};

        final response = await http.put(
          Uri.parse('$baseUrl/api/books/$testBookId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
          body: json.encode(updates),
        );

        expect(
          response.statusCode,
          equals(200),
          reason: 'Failed to update book: ${response.body}',
        );

        final body = json.decode(response.body);
        expect(body['title'], equals(updates['title']));
        expect(body['price'], equals(updates['price']));
      });

      test('should reject update without admin privileges', () async {
        final updates = {'title': 'This should fail'};

        final response = await http.put(
          Uri.parse('$baseUrl/api/books/$testBookId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $userToken',
          },
          body: json.encode(updates),
        );

        expect(
          response.statusCode,
          equals(403),
          reason: 'Expected 403 forbidden, got: ${response.statusCode}',
        );
      });

      test('should delete a book with admin privileges', () async {
        final response = await http.delete(
          Uri.parse('$baseUrl/api/books/$testBookId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $adminToken',
          },
        );

        expect(
          response.statusCode,
          equals(204),
          reason: 'Failed to delete book: ${response.statusCode}',
        );

        // Verify book is deleted
        final getResponse = await http.get(
          Uri.parse('$baseUrl/api/books/$testBookId'),
          headers: {'Content-Type': 'application/json'},
        );

        expect(
          getResponse.statusCode,
          equals(404),
          reason: 'Book should be deleted, but got: ${getResponse.statusCode}',
        );
      });
    });
  });
}
