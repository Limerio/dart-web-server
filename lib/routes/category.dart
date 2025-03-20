import 'dart:convert';
import 'package:server/middleware/auth_middleware.dart';
import 'package:server/utils/handler_utils.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryRoutes {
  final PostgreSQLConnection _db;
  late final CategoryRepository _repository;

  CategoryRoutes(this._db) {
    _repository = CategoryRepository(_db);
  }

  Router get router {
    final router = Router();

    router.get('/', _getAllCategories);
    router.get('/<id>', _getCategoryById);

    router.post(
      '/',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addMiddleware(adminMiddleware())
          .addHandler(_createCategory),
    );
    router.put(
      '/<id>',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addMiddleware(adminMiddleware())
          .addHandler(pathParamHandler(_updateCategory)),
    );
    router.delete(
      '/<id>',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addMiddleware(adminMiddleware())
          .addHandler(pathParamHandler(_deleteCategory)),
    );

    return router;
  }

  Future<Response> _getAllCategories(Request request) async {
    final categories = await _repository.findAll();
    return Response(
      200,
      body: json.encode(
        categories.map((category) => category.toMap()).toList(),
      ),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _getCategoryById(Request request, String id) async {
    final categoryId = int.tryParse(id);
    if (categoryId == null) {
      return Response(400, body: json.encode({'error': 'Invalid category ID'}));
    }

    final category = await _repository.findById(categoryId);
    if (category == null) {
      return Response(404, body: json.encode({'error': 'Category not found'}));
    }

    return Response(
      200,
      body: json.encode(category.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _createCategory(Request request) async {
    final payload = json.decode(await request.readAsString());

    if (payload['name'] == null) {
      return Response(
        400,
        body: json.encode({'error': 'Category name is required'}),
      );
    }

    final category = Category(
      name: payload['name'],
      description: payload['description'],
    );

    final createdCategory = await _repository.create(category);

    return Response(
      201,
      body: json.encode(createdCategory.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _updateCategory(Request request, String id) async {
    final categoryId = int.tryParse(id);
    if (categoryId == null) {
      return Response(400, body: json.encode({'error': 'Invalid category ID'}));
    }

    final payload = json.decode(await request.readAsString());

    payload.remove('id');
    payload.remove('created_at');
    payload.remove('updated_at');

    final updatedCategory = await _repository.update(categoryId, payload);
    if (updatedCategory == null) {
      return Response(404, body: json.encode({'error': 'Category not found'}));
    }

    return Response(
      200,
      body: json.encode(updatedCategory.toMap()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _deleteCategory(Request request, String id) async {
    final categoryId = int.tryParse(id);
    if (categoryId == null) {
      return Response(400, body: json.encode({'error': 'Invalid category ID'}));
    }

    final success = await _repository.delete(categoryId);
    if (!success) {
      return Response(404, body: json.encode({'error': 'Category not found'}));
    }

    return Response(204);
  }
}
