import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../utils/jwt_util.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: json.encode({'error': 'Authentication required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);
      final payload = JwtUtil.verifyToken(token);
      final updatedRequest = request.change(
        context: {
          'userId': payload['userId'],
          'userEmail': payload['email'],
          'userRole': payload['role'],
        },
      );

      return await innerHandler(updatedRequest);
    };
  };
}

Middleware adminMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final userRole = request.context['userRole'];
      if (userRole != 'admin') {
        return Response(
          403,
          body: json.encode({'error': 'Admin access required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return await innerHandler(request);
    };
  };
}
