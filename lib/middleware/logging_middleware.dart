import 'package:shelf/shelf.dart';

Middleware logRequestsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final startTime = DateTime.now();
      print('${request.method} ${request.url} - Started at $startTime');

      final response = await innerHandler(request);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print(
        '${request.method} ${request.url} - ${response.statusCode} - Completed in ${duration.inMilliseconds}ms',
      );

      return response;
    };
  };
}
