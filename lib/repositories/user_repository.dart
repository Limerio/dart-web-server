import 'package:postgres/postgres.dart';
import '../models/user.dart';
import '../utils/password_util.dart';

class UserRepository {
  final PostgreSQLConnection _connection;

  UserRepository(this._connection);

  Future<List<User>> findAll() async {
    final result = await _connection.query('SELECT * FROM users');

    return result
        .map(
          (row) => User.fromMap({
            'id': row[0],
            'email': row[1],
            'password_hash': row[2],
            'full_name': row[3],
            'role': row[4],
            'created_at': row[5],
            'updated_at': row[6],
          }),
        )
        .toList();
  }

  Future<User?> findById(int id) async {
    final result = await _connection.query(
      'SELECT * FROM users WHERE id = @id',
      substitutionValues: {'id': id},
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    return User.fromMap({
      'id': row[0],
      'email': row[1],
      'password_hash': row[2],
      'full_name': row[3],
      'role': row[4],
      'created_at': row[5],
      'updated_at': row[6],
    });
  }

  Future<User?> findByEmail(String email) async {
    final result = await _connection.query(
      'SELECT * FROM users WHERE email = @email',
      substitutionValues: {'email': email},
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    return User.fromMap({
      'id': row[0],
      'email': row[1],
      'password_hash': row[2],
      'full_name': row[3],
      'role': row[4],
      'created_at': row[5],
      'updated_at': row[6],
    });
  }

  Future<User> create(User user) async {
    final hashedPassword = await PasswordUtil.hashPassword(user.passwordHash);

    final result = await _connection.query(
      '''
      INSERT INTO users (email, password_hash, full_name, role)
      VALUES (@email, @password_hash, @full_name, @role)
      RETURNING *
      ''',
      substitutionValues: {
        'email': user.email,
        'password_hash': hashedPassword,
        'full_name': user.fullName,
        'role': user.role,
      },
    );

    final row = result.first;
    return User.fromMap({
      'id': row[0],
      'email': row[1],
      'password_hash': row[2],
      'full_name': row[3],
      'role': row[4],
      'created_at': row[5],
      'updated_at': row[6],
    });
  }

  Future<User?> update(int id, Map<String, dynamic> userData) async {
    final setClause = userData.keys.map((key) => '$key = @$key').join(', ');

    final values = {...userData, 'id': id};

    final result = await _connection.query('''
      UPDATE users
      SET $setClause, updated_at = CURRENT_TIMESTAMP
      WHERE id = @id
      RETURNING *
      ''', substitutionValues: values);

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    return User.fromMap({
      'id': row[0],
      'email': row[1],
      'password_hash': row[2],
      'full_name': row[3],
      'role': row[4],
      'created_at': row[5],
      'updated_at': row[6],
    });
  }

  Future<bool> delete(int id) async {
    final result = await _connection.execute(
      'DELETE FROM users WHERE id = @id',
      substitutionValues: {'id': id},
    );

    return result > 0;
  }
}
