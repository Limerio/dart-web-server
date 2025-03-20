import 'package:postgres/postgres.dart';

import '../models/book.dart';

class BookRepository {
  final PostgreSQLConnection _connection;

  BookRepository(this._connection);

  Future<List<Book>> findAll({int? categoryId}) async {
    String query = 'SELECT * FROM books';
    Map<String, dynamic> values = {};

    if (categoryId != null) {
      query += ' WHERE category_id = @category_id';
      values['category_id'] = categoryId;
    }

    final result = await _connection.query(query, substitutionValues: values);

    return result
        .map(
          (row) => Book.fromMap({
            'id': row[0],
            'title': row[1],
            'author': row[2],
            'isbn': row[3],
            'description': row[4],
            'price': row[5],
            'stock_quantity': row[6],
            'category_id': row[7],
            'publisher': row[8],
            'publication_date': row[9],
            'created_at': row[10],
            'updated_at': row[11],
          }),
        )
        .toList();
  }

  Future<Book?> findById(int id) async {
    final result = await _connection.query(
      'SELECT * FROM books WHERE id = @id',
      substitutionValues: {'id': id},
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    return Book.fromMap({
      'id': row[0],
      'title': row[1],
      'author': row[2],
      'isbn': row[3],
      'description': row[4],
      'price': row[5],
      'stock_quantity': row[6],
      'category_id': row[7],
      'publisher': row[8],
      'publication_date': row[9],
      'created_at': row[10],
      'updated_at': row[11],
    });
  }

  Future<Book?> findByIsbn(String isbn) async {
    final result = await _connection.query(
      'SELECT * FROM books WHERE isbn = @isbn',
      substitutionValues: {'isbn': isbn},
    );

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    return Book.fromMap({
      'id': row[0],
      'title': row[1],
      'author': row[2],
      'isbn': row[3],
      'description': row[4],
      'price': row[5],
      'stock_quantity': row[6],
      'category_id': row[7],
      'publisher': row[8],
      'publication_date': row[9],
      'created_at': row[10],
      'updated_at': row[11],
    });
  }

  Future<List<Book>> search(String query) async {
    final result = await _connection.query(
      '''
      SELECT * FROM books
      WHERE title LIKE @query OR author LIKE @query OR isbn LIKE @query
      ''',
      substitutionValues: {'query': '%$query%'},
    );

    return result
        .map(
          (row) => Book.fromMap({
            'id': row[0],
            'title': row[1],
            'author': row[2],
            'isbn': row[3],
            'description': row[4],
            'price': row[5],
            'stock_quantity': row[6],
            'category_id': row[7],
            'publisher': row[8],
            'publication_date': row[9],
            'created_at': row[10],
            'updated_at': row[11],
          }),
        )
        .toList();
  }

  Future<Book> create(Book book) async {
    final result = await _connection.query(
      '''
      INSERT INTO books (
        title, author, isbn, description, price, stock_quantity,
        category_id, publisher, publication_date
      )
      VALUES (
        @title, @author, @isbn, @description, @price, @stock_quantity,
        @category_id, @publisher, @publication_date
      )
      RETURNING *
      ''',
      substitutionValues: {
        'title': book.title,
        'author': book.author,
        'isbn': book.isbn,
        'description': book.description,
        'price': book.price,
        'stock_quantity': book.stockQuantity,
        'category_id': book.categoryId,
        'publisher': book.publisher,
        'publication_date': book.publicationDate,
      },
    );

    final row = result.first;
    return Book.fromMap({
      'id': row[0],
      'title': row[1],
      'author': row[2],
      'isbn': row[3],
      'description': row[4],
      'price': row[5],
      'stock_quantity': row[6],
      'category_id': row[7],
      'publisher': row[8],
      'publication_date': row[9],
      'created_at': row[10],
      'updated_at': row[11],
    });
  }

  Future<Book?> update(int id, Map<String, dynamic> bookData) async {
    final setClause = bookData.keys.map((key) => '$key = @$key').join(', ');

    final values = {...bookData, 'id': id};

    final result = await _connection.query('''
      UPDATE books
      SET $setClause, updated_at = CURRENT_TIMESTAMP
      WHERE id = @id
      RETURNING *
      ''', substitutionValues: values);

    if (result.isEmpty) {
      return null;
    }

    final row = result.first;
    return Book.fromMap({
      'id': row[0],
      'title': row[1],
      'author': row[2],
      'isbn': row[3],
      'description': row[4],
      'price': row[5],
      'stock_quantity': row[6],
      'category_id': row[7],
      'publisher': row[8],
      'publication_date': row[9],
      'created_at': row[10],
      'updated_at': row[11],
    });
  }

  Future<bool> delete(int id) async {
    final result = await _connection.execute(
      'DELETE FROM books WHERE id = @id',
      substitutionValues: {'id': id},
    );

    return result > 0;
  }
}
