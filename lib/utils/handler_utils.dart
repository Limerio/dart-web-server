import 'package:shelf/shelf.dart';

Handler pathParamHandler(
  Future<Response> Function(Request, String) handler, {
  int paramIndex = 0,
}) {
  return (Request request) {
    final pathSegments = request.url.pathSegments;
    if (pathSegments.length > paramIndex) {
      final param = pathSegments[paramIndex];
      return handler(request, param);
    }
    return Future.value(Response(400, body: 'Missing required path parameter'));
  };
}
