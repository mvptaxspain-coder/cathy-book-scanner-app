class Book {
  final String id;
  final String title;
  final List<BookPage> pages;
  final DateTime createdAt;
  DateTime? lastRead;

  Book({
    required this.id,
    required this.title,
    required this.pages,
    required this.createdAt,
    this.lastRead,
  });

  int get totalPages => pages.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'pages': pages.map((p) => p.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'lastRead': lastRead?.toIso8601String(),
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    pages: (json['pages'] as List)
        .map((p) => BookPage.fromJson(p as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastRead: json['lastRead'] != null
        ? DateTime.parse(json['lastRead'] as String)
        : null,
  );
}

class BookPage {
  final int pageNumber;
  final String text;
  final String? imagePath;

  BookPage({
    required this.pageNumber,
    required this.text,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'text': text,
    'imagePath': imagePath,
  };

  factory BookPage.fromJson(Map<String, dynamic> json) => BookPage(
    pageNumber: json['pageNumber'] as int,
    text: json['text'] as String,
    imagePath: json['imagePath'] as String?,
  );
}
