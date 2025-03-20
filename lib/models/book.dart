class Book {
  final int? id;
  final String title;
  final String author;
  final String isbn;
  final String? description;
  final double price;
  final int stockQuantity;
  final int? categoryId;
  final String? publisher;
  final DateTime? publicationDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Book({
    this.id,
    required this.title,
    required this.author,
    required this.isbn,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.categoryId,
    this.publisher,
    this.publicationDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      isbn: map['isbn'],
      description: map['description'],
      price: double.parse(map['price']),
      stockQuantity: map['stock_quantity'],
      categoryId: map['category_id'],
      publisher: map['publisher'],
      publicationDate: map['publication_date'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'publisher': publisher,
      'publication_date': publicationDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
