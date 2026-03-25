import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/storage_service.dart';

class BooksProvider with ChangeNotifier {
  List<Book> _books = [];
  bool _isLoading = false;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  BooksProvider() {
    loadBooks();
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _books = await StorageService.instance.getBooks();
      _books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error loading books: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBook(Book book) async {
    try {
      await StorageService.instance.addBook(book);
      _books.insert(0, book);
      notifyListeners();
    } catch (e) {
      print('Error adding book: $e');
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await StorageService.instance.deleteBook(bookId);
      _books.removeWhere((b) => b.id == bookId);
      notifyListeners();
    } catch (e) {
      print('Error deleting book: $e');
      rethrow;
    }
  }

  Future<void> updateBook(Book book) async {
    try {
      await StorageService.instance.updateBook(book);
      final index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = book;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating book: $e');
      rethrow;
    }
  }

  Book? getBook(String bookId) {
    try {
      return _books.firstWhere((b) => b.id == bookId);
    } catch (e) {
      return null;
    }
  }
}
