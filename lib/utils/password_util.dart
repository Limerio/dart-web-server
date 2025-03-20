import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class PasswordUtil {
  static Future<String> hashPassword(String password) async {
    // Generate a random salt
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final salt = base64.encode(saltBytes);

    // Hash the password with the salt
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    final hash = base64.encode(digest.bytes);

    // Return salt and hash separated by a delimiter
    return '$salt:$hash';
  }

  static Future<bool> verifyPassword(String password, String storedHash) async {
    // Extract salt and hash
    final parts = storedHash.split(':');
    if (parts.length != 2) {
      return false;
    }

    final salt = parts[0];
    final hash = parts[1];

    // Hash the password with the extracted salt
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    final computedHash = base64.encode(digest.bytes);

    // Compare the computed hash with the stored hash
    return computedHash == hash;
  }
}
