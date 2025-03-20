import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:server/middleware/auth_middleware.dart';
import 'package:server/utils/handler_utils.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../models/user.dart';
import '../repositories/user_repository.dart';
import '../utils/jwt_util.dart';
import '../utils/password_util.dart';

class UserRoutes {
  final PostgreSQLConnection _db;
  late final UserRepository _repository;

  UserRoutes(this._db) {
    _repository = UserRepository(_db);
  }

  Router get router {
    final router = Router();

    // Public routes
    router.post('/register', _register);
    router.post('/login', _login);
    router.get(
      '/profile',
      Pipeline().addMiddleware(authMiddleware()).addHandler(_getProfile),
    );

    // Protected routes
    router.get(
      '/',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addMiddleware(adminMiddleware())
          .addHandler(_getAllUsers),
    );
    router.get(
      '/<id>',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler(pathParamHandler(_getUserById)),
    );
    router.put(
      '/<id>',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler(pathParamHandler(_updateUser)),
    );
    router.delete(
      '/<id>',
      Pipeline()
          .addMiddleware(authMiddleware())
          .addHandler(pathParamHandler(_deleteUser)),
    );

    return router;
  }

  Future<Response> _getProfile(Request request) async {
    final userId = request.context['userId'];
    if (userId == null) {
      return Response(401, body: json.encode({'error': 'Unauthorized'}));
    }

    final user = await _repository.findById(userId as int);
    if (user == null) {
      return Response(404, body: json.encode({'error': 'User not found'}));
    }

    return Response(200, body: json.encode(user.toJson()));
  }

  Future<Response> _register(Request request) async {
    final payload = json.decode(await request.readAsString());

    if (payload['email'] == null ||
        payload['password'] == null ||
        payload['full_name'] == null) {
      return Response(
        400,
        body: json.encode({'error': 'Missing required fields'}),
      );
    }

    // Check if user already exists
    final existingUser = await _repository.findByEmail(payload['email']);
    if (existingUser != null) {
      return Response(409, body: json.encode({'error': 'User already exists'}));
    }

    final user = User(
      email: payload['email'],
      passwordHash: payload['password'],
      fullName: payload['full_name'],
      role: payload['role'] ?? 'customer',
    );

    final createdUser = await _repository.create(user);

    final token = JwtUtil.generateToken(user);

    return Response(
      201,
      body: json.encode({'user': createdUser.toJson(), 'token': token}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _login(Request request) async {
    final payload = json.decode(await request.readAsString());

    if (payload['email'] == null || payload['password'] == null) {
      return Response(
        400,
        body: json.encode({'error': 'Email and password are required'}),
      );
    }

    final user = await _repository.findByEmail(payload['email']);
    if (user == null) {
      return Response(401, body: json.encode({'error': 'Invalid credentials'}));
    }

    final isValid = await PasswordUtil.verifyPassword(
      payload['password'],
      user.passwordHash,
    );
    if (!isValid) {
      return Response(401, body: json.encode({'error': 'Invalid credentials'}));
    }

    final token = JwtUtil.generateToken(user);

    return Response(
      200,
      body: json.encode({'user': user.toJson(), 'token': token}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _getAllUsers(Request request) async {
    final users = await _repository.findAll();
    return Response(
      200,
      body: json.encode(users.map((user) => user.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _getUserById(Request request, String id) async {
    final userId = int.tryParse(id);
    if (userId == null) {
      return Response(400, body: json.encode({'error': 'Invalid user ID'}));
    }

    final user = await _repository.findById(userId);
    if (user == null) {
      return Response(404, body: json.encode({'error': 'User not found'}));
    }

    return Response(
      200,
      body: json.encode(user.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _updateUser(Request request, String id) async {
    final userId = int.tryParse(id);
    if (userId == null) {
      return Response(400, body: json.encode({'error': 'Invalid user ID'}));
    }

    final payload = json.decode(await request.readAsString());

    // Remove protected fields
    payload.remove('id');
    payload.remove('password_hash');
    payload.remove('created_at');
    payload.remove('updated_at');

    // Handle password update
    if (payload['password'] != null) {
      payload['password_hash'] = await PasswordUtil.hashPassword(
        payload['password'],
      );
      payload.remove('password');
    }

    final updatedUser = await _repository.update(userId, payload);
    if (updatedUser == null) {
      return Response(404, body: json.encode({'error': 'User not found'}));
    }

    return Response(
      200,
      body: json.encode(updatedUser.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _deleteUser(Request request, String id) async {
    final userId = int.tryParse(id);
    if (userId == null) {
      return Response(400, body: json.encode({'error': 'Invalid user ID'}));
    }

    final success = await _repository.delete(userId);
    if (!success) {
      return Response(404, body: json.encode({'error': 'User not found'}));
    }

    return Response(204);
  }
}
