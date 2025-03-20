import 'package:postgres/postgres.dart';
import '../models/category.dart';

class CategoryRepository {
  final PostgreSQLConnection _connection;

  CategoryRepository(this._connection);

  Future<List<Category>> findAll() async {
    final result = await _connection.query('SELECT * FROM categories');

    return result
        .map(
          (row) => Category.fromMap({
            'id': row[0],
            'name': row[1],
            'description': row[2],
            'created_at': row[3],
            'updated_at': row[4],
          }),
        )
        .toList();
  }

  Future<Category?> findById(int id) async {
    final result = await _connection.query(
      'SELECT * FROM categories WHERE id = @id',
      substitutionValues: {'id': id},
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    return Category.fromMap({
      'id': row[0],
      'name': row[1],
      'description': row[2],
      'created_at': row[3],
      'updated_at': row[4],
    });
  }

  Future<Category> create(Category category) async {
    final result = await _connection.query(
      '''
      INSERT INTO categories (name, description)
      VALUES (@name, @description)
      RETURNING *
      ''',
      substitutionValues: {
        'name': category.name,
        'description': category.description,
      },
    );

    final row = result.first;
    return Category.fromMap({
      'id': row[0],
      'name': row[1],
      'description': row[2],
      'created_at': row[3],
      'updated_at': row[4],
    });
  }

  Future<Category?> update(int id, Map<String, dynamic> categoryData) async {
    final setClause = categoryData.keys.map((key) => '$key = @$key').join(', ');

    final values = {...categoryData, 'id': id};

    final result = await _connection.query('''
      UPDATE categories
      SET $setClause, updated_at = CURRENT_TIMESTAMP
      WHERE id = @id
      RETURNING *
      ''', substitutionValues: values);

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    return Category.fromMap({
      'id': row[0],
      'name': row[1],
      'description': row[2],
      'created_at': row[3],
      'updated_at': row[4],
    });
  }

  Future<bool> delete(int id) async {
    final result = await _connection.execute(
      'DELETE FROM categories WHERE id = @id',
      substitutionValues: {'id': id},
    );

    return result > 0;
  }
}
