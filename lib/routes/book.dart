import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:server/middleware/auth_middleware.dart';
import 'package:server/utils/handler_utils.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/book.dart';
import '../repositories/book_repository.dart';
import '../repositories/category_repository.dart';

class BookRoutes {
  final PostgreSQLConnection _db;
  late final BookRepository _repository;
  late final CategoryRepository _categoryRepository;

  BookRoutes(this._db) {
    _repository = BookRepository(_db);
    _categoryRepository = CategoryRepository(_db);
  }

  Router get router {
    final router = Router();

    router.get('/', _getAllBooks);
    router.get('/search', _searchBooks);
    router.get('/<id>', _getBookById);

    router.post(
      '/',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addMiddleware(adminMiddleware())
          .addHandler(_createBook),
    );
    router.put(
      '/<id>',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addMiddleware(adminMiddleware())
          .addHandler(pathParamHandler(_updateBook)),
    );
    router.delete(
      '/<id>',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addMiddleware(adminMiddleware())
          .addHandler(pathParamHandler(_deleteBook)),
    );

    return router;
  }

  Future<Response> _getAllBooks(Request request) async {
    final queryParams = request.url.queryParameters;
    final categoryId =
        queryParams['category_id'] != null
            ? int.tryParse(queryParams['category_id']!)
            : null;

    final books = await _repository.findAll(categoryId: categoryId);

    final booksWithCategory = await Future.wait(
      books.map((book) async {
        final bookMap = book.toMap();
        if (book.categoryId != null) {
          final category = await _categoryRepository.findById(book.categoryId!);
          bookMap['category'] = {
            'id': book.categoryId,
            'name': category?.name ?? 'Unknown',
          };
        }
        return bookMap;
      }),
    );

    return Response(
      200,
      body: json.encode(booksWithCategory),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _searchBooks(Request request) async {
    final query = request.url.queryParameters['query'] ?? '';
    if (query.isEmpty) {
      return Response(
        400,
        body: json.encode({'error': 'Search query is required'}),
      );
    }

    final books = await _repository.search(query);
    return Response(
      200,
      body: json.encode(books.map((book) => book.toMap()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _getBookById(Request request, String id) async {
    final bookId = int.tryParse(id);
    if (bookId == null) {
      return Response(400, body: json.encode({'error': 'Invalid book ID'}));
    }

    final book = await _repository.findById(bookId);
    if (book == null) {
      return Response(404, body: json.encode({'error': 'Book not found'}));
    }

    return Response(
      200,
      body: json.encode(book.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _createBook(Request request) async {
    final payload = json.decode(await request.readAsString());

    if (payload['title'] == null ||
        payload['author'] == null ||
        payload['isbn'] == null ||
        payload['price'] == null) {
      return Response(
        400,
        body: json.encode({'error': 'Missing required fields'}),
      );
    }

    final existingBook = await _repository.findByIsbn(payload['isbn']);
    if (existingBook != null) {
      return Response(
        409,
        body: json.encode({'error': 'Book with this ISBN already exists'}),
      );
    }

    final book = Book(
      title: payload['title'],
      author: payload['author'],
      isbn: payload['isbn'],
      description: payload['description'],
      price: double.parse(payload['price'].toString()),
      stockQuantity:
          payload['stock_quantity'] != null
              ? int.parse(payload['stock_quantity'].toString())
              : 0,
      categoryId:
          payload['category_id'] != null
              ? int.parse(payload['category_id'].toString())
              : null,
      publisher: payload['publisher'],
      publicationDate:
          payload['publication_date'] != null
              ? DateTime.parse(payload['publication_date'])
              : null,
    );

    final createdBook = await _repository.create(book);

    return Response(
      201,
      body: json.encode(createdBook.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _updateBook(Request request, String id) async {
    final bookId = int.tryParse(id);
    if (bookId == null) {
      return Response(400, body: json.encode({'error': 'Invalid book ID'}));
    }

    final payload = json.decode(await request.readAsString());

    payload.remove('id');
    payload.remove('created_at');
    payload.remove('updated_at');

    if (payload['price'] != null) {
      payload['price'] = double.parse(payload['price'].toString());
    }

    if (payload['stock_quantity'] != null) {
      payload['stock_quantity'] = int.parse(
        payload['stock_quantity'].toString(),
      );
    }

    if (payload['category_id'] != null) {
      payload['category_id'] = int.parse(payload['category_id'].toString());
    }

    if (payload['publication_date'] != null) {
      payload['publication_date'] = DateTime.parse(payload['publication_date']);
    }

    final updatedBook = await _repository.update(bookId, payload);
    if (updatedBook == null) {
      return Response(404, body: json.encode({'error': 'Book not found'}));
    }

    return Response(
      200,
      body: json.encode(updatedBook.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _deleteBook(Request request, String id) async {
    final bookId = int.tryParse(id);
    if (bookId == null) {
      return Response(400, body: json.encode({'error': 'Invalid book ID'}));
    }

    final success = await _repository.delete(bookId);
    if (!success) {
      return Response(404, body: json.encode({'error': 'Book not found'}));
    }

    return Response(204);
  }
}
