import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../models/voice.dart';

class StorageService {
  static final StorageService instance = StorageService._();
  StorageService._();

  late SharedPreferences _prefs;

  static const String _booksKey = 'books';
  static const String _voicesKey = 'voices';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Books
  Future<List<Book>> getBooks() async {
    final String? booksJson = _prefs.getString(_booksKey);
    if (booksJson == null) return [];

    final List<dynamic> decoded = json.decode(booksJson);
    return decoded.map((json) => Book.fromJson(json)).toList();
  }

  Future<void> saveBooks(List<Book> books) async {
    final String encoded = json.encode(books.map((b) => b.toJson()).toList());
    await _prefs.setString(_booksKey, encoded);
  }

  Future<void> addBook(Book book) async {
    final books = await getBooks();
    books.add(book);
    await saveBooks(books);
  }

  Future<void> deleteBook(String bookId) async {
    final books = await getBooks();
    books.removeWhere((b) => b.id == bookId);
    await saveBooks(books);
  }

  Future<void> updateBook(Book book) async {
    final books = await getBooks();
    final index = books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      books[index] = book;
      await saveBooks(books);
    }
  }

  // Voices
  Future<List<Voice>> getVoices() async {
    final String? voicesJson = _prefs.getString(_voicesKey);
    if (voicesJson == null) {
      // Return default voice
      return [
        Voice(
          id: 'default',
          name: 'Standard Stimme',
          description: 'Standard TTS Stimme',
          createdAt: DateTime.now(),
          isDefault: true,
        ),
      ];
    }

    final List<dynamic> decoded = json.decode(voicesJson);
    return decoded.map((json) => Voice.fromJson(json)).toList();
  }

  Future<void> saveVoices(List<Voice> voices) async {
    final String encoded = json.encode(voices.map((v) => v.toJson()).toList());
    await _prefs.setString(_voicesKey, encoded);
  }

  Future<void> addVoice(Voice voice) async {
    final voices = await getVoices();
    voices.add(voice);
    await saveVoices(voices);
  }

  Future<void> deleteVoice(String voiceId) async {
    final voices = await getVoices();
    voices.removeWhere((v) => v.id == voiceId && !v.isDefault);
    await saveVoices(voices);
  }
}
