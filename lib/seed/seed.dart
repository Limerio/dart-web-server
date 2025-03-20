import 'dart:math';
import 'package:faker/faker.dart';
import 'package:postgres/postgres.dart';

import '../models/book.dart';
import '../models/category.dart';
import '../config/database.dart';

const int minBookCount = 50;
const int maxAdditionalBookCount = 51;
const int maxCategoryDescriptionSentences = 3;
const int maxBookDescriptionSentences = 5;
const int maxBookTitleWords = 3;
const int isbnPart2Min = 1;
const int isbnPart2Max = 9;
const int isbnPart3Min = 100;
const int isbnPart3Max = 999;
const int isbnPart4Min = 10000;
const int isbnPart4Max = 99999;
const int isbnPart5Min = 1;
const int isbnPart5Max = 9;
const int priceMinCents = 499;
const int priceMaxCents = 9999;
const int stockMin = 0;
const int stockMax = 100;
const int daysInYear = 365;
const int yearsBack = 30;
const int printProgressInterval = 10;

void main() async {
  try {
    final seeder = DatabaseSeeder();
    await seeder.seed();
  } catch (e) {
    print('Error seeding database: $e');
  } finally {
    await DatabaseConnection.close();
  }
}

class DatabaseSeeder {
  final Faker faker = Faker();
  final Random random = Random();
  late PostgreSQLConnection connection;

  // Define category names that make sense for a bookstore
  final List<String> categoryNames = [
    'Fiction',
    'Non-Fiction',
    'Science Fiction',
    'Fantasy',
    'Mystery',
    'Thriller',
    'Romance',
    'Biography',
    'History',
    'Science',
    'Technology',
    'Self-Help',
    'Business',
    'Children\'s Books',
  ];

  // Define publishing companies
  final List<String> publishers = [
    'Penguin Random House',
    'HarperCollins',
    'Simon & Schuster',
    'Macmillan Publishers',
    'Hachette Book Group',
    'Oxford University Press',
    'Cambridge University Press',
    'Wiley',
    'Scholastic',
    'Pearson Education',
  ];

  Future<void> seed() async {
    connection = await DatabaseConnection.initialize();
    print('Starting database seeding process...');
    await _clearExistingData();
    final categories = await _seedCategories();
    print('Categories seeded: ${categories.length}');
    final books = await _seedBooks(categories);
    print('Books seeded: ${books.length}');
    print('Database seeding completed successfully.');
  }

  Future<void> _clearExistingData() async {
    await connection.query('DELETE FROM books');
    await connection.query('DELETE FROM categories');
    print('Existing data cleared');
  }

  Future<List<Category>> _seedCategories() async {
    final now = DateTime.now();
    final List<Category> categories = [];

    for (var categoryName in categoryNames) {
      final description = faker.lorem
          .sentences(random.nextInt(maxCategoryDescriptionSentences) + 1)
          .join(' ');
      final result = await connection.query(
        'INSERT INTO categories (name, description, created_at, updated_at) VALUES (@name, @description, @createdAt, @updatedAt) RETURNING id',
        substitutionValues: {
          'name': categoryName,
          'description': description,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      );
      final id = result.first[0] as int;
      categories.add(
        Category(
          id: id,
          name: categoryName,
          description: description,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    return categories;
  }

  Future<List<Book>> _seedBooks(List<Category> categories) async {
    final now = DateTime.now();
    final List<Book> books = [];
    final bookCount = random.nextInt(maxAdditionalBookCount) + minBookCount;

    for (int i = 0; i < bookCount; i++) {
      final category = categories[random.nextInt(categories.length)];
      final publicationDate = DateTime.now().subtract(
        Duration(days: random.nextInt(daysInYear * yearsBack)),
      );
      final price =
          (random.nextInt(priceMaxCents - priceMinCents) + priceMinCents) / 100;
      final stockQuantity = random.nextInt(stockMax - stockMin + 1) + stockMin;
      final title = _generateBookTitle();
      final author = faker.person.name();
      final isbn = _generateISBN();
      final description = faker.lorem
          .sentences(random.nextInt(maxBookDescriptionSentences) + 1)
          .join(' ');
      final publisher = publishers[random.nextInt(publishers.length)];
      final result = await connection.query(
        'INSERT INTO books (title, author, isbn, description, price, stock_quantity, category_id, publisher, publication_date, created_at, updated_at) VALUES (@title, @author, @isbn, @description, @price, @stockQuantity, @categoryId, @publisher, @publicationDate, @createdAt, @updatedAt) RETURNING id',
        substitutionValues: {
          'title': title,
          'author': author,
          'isbn': isbn,
          'description': description,
          'price': price,
          'stockQuantity': stockQuantity,
          'categoryId': category.id,
          'publisher': publisher,
          'publicationDate': publicationDate.toIso8601String(),
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      );
      final id = result.first[0] as int;
      books.add(
        Book(
          id: id,
          title: title,
          author: author,
          isbn: isbn,
          description: description,
          price: price,
          stockQuantity: stockQuantity,
          categoryId: category.id,
          publisher: publisher,
          publicationDate: publicationDate,
          createdAt: now,
          updatedAt: now,
        ),
      );
      if ((i + 1) % printProgressInterval == 0) {
        print('Inserted ${i + 1} books of $bookCount');
      }
    }
    return books;
  }

  String _generateBookTitle() {
    // Generate more realistic book titles
    final titleFormats = [
      () => 'The ${faker.lorem.word()} of ${faker.lorem.word().capitalize()}',
      () =>
          '${faker.lorem.word().capitalize()} ${faker.lorem.word().capitalize()}',
      () =>
          'A ${faker.lorem.word().capitalize()} of ${faker.lorem.word().capitalize()}',
      () => faker.lorem.words(random.nextInt(3) + 2).join(' ').capitalize(),
      () =>
          '${faker.lorem.word().capitalize()}: ${faker.lorem.words(random.nextInt(maxBookTitleWords) + 1).join(' ')}',
      () =>
          'The ${faker.lorem.word().capitalize()} ${faker.lorem.word().capitalize()}',
    ];

    return titleFormats[random.nextInt(titleFormats.length)]();
  }

  String _generateISBN() {
    return '978-${random.nextInt(isbnPart2Max) + isbnPart2Min}-${random.nextInt(isbnPart3Max - isbnPart3Min + 1) + isbnPart3Min}-${random.nextInt(isbnPart4Max - isbnPart4Min + 1) + isbnPart4Min}-${random.nextInt(isbnPart5Max) + isbnPart5Min}';
  }
}

// Extension method to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : this[0].toUpperCase() + substring(1);
  }
}
