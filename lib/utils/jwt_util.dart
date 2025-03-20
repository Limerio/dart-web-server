import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../models/user.dart';

class JwtUtil {
  static String getSecretKey() {
    return Platform.environment['JWT_SECRET'] ?? 'your_jwt_secret_key';
  }

  static String generateToken(User user) {
    final jwt = JWT({
      'userId': user.id,
      'email': user.email,
      'role': user.role,
    });

    return jwt.sign(SecretKey(getSecretKey()), expiresIn: Duration(days: 1));
  }

  static Map<String, dynamic> verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(getSecretKey()));
      return jwt.payload;
    } on JWTExpiredException {
      throw Exception('Token expired');
    } on JWTException catch (e) {
      throw Exception(e.message);
    }
  }
}
