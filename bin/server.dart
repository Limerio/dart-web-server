import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:server/config/database.dart';
import 'package:server/middleware/cors_middleware.dart';
import 'package:server/middleware/error_middleware.dart';
import 'package:server/middleware/logging_middleware.dart';
import 'package:server/routes/book.dart';
import 'package:server/routes/category.dart';
import 'package:server/routes/user.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

void main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final host = Platform.environment['HOST'] ?? 'localhost';

  final db = await DatabaseConnection.initialize();

  final currentDir = Directory.current.path;
  final staticHandler = createStaticHandler(
    path.join(currentDir, 'static'),
    defaultDocument: 'index.html',
  );

  final router = Router();
  router.mount('/api/users', UserRoutes(db).router.call);
  router.mount('/api/books', BookRoutes(db).router.call);
  router.mount('/api/categories', CategoryRoutes(db).router.call);
  router.get('/<path|.*>', staticHandler.call);

  router.all('/<ignored|.*>', (Request request) {
    return Response.notFound('Route not found');
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware())
      .addMiddleware(errorMiddleware())
      .addMiddleware(logRequestsMiddleware())
      .addHandler(router.call);

  final server = await serve(handler, host, port);
  print('Server listening on port ${server.port}');
}
