class DocumentModel {
  final String id;
  final String title;
  final String author;
  final String category;
  final int year;
  final bool available;
  final String imagePath;

  DocumentModel({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.year,
    required this.available,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'category': category,
      'year': year,
      'available': available,
      'imagePath': imagePath,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      category: map['category'] ?? '',
      year: map['year'] ?? 0,
      available: map['available'] ?? true,
      imagePath: map['imagePath'] ?? 'assets/images/documents/Book1.jpg',
    );
  }
}