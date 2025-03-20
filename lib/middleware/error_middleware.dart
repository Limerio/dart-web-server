import 'dart:convert';
import 'package:shelf/shelf.dart';

Middleware errorMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (e, stackTrace) {
        print('Error handling request: $e');
        print(stackTrace);

        return Response(
          500,
          body: json.encode({'error': 'Internal server error'}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    };
  };
}
