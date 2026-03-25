import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/books_provider.dart';
import 'book_reader_screen.dart';

class BooksLibraryScreen extends StatelessWidget {
  const BooksLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Meine Bücher'),
      ),
      body: Consumer<BooksProvider>(
        builder: (context, booksProvider, child) {
          if (booksProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = booksProvider.books;

          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Noch keine Bücher',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scanne Seiten und speichere\nsie als Buch im Scanner-Tab',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final dateFormat = DateFormat('dd.MM.yyyy');

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookReaderScreen(book: book),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.menu_book, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: Theme.of(context).textTheme.titleLarge,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${book.totalPages} Seite${book.totalPages != 1 ? 'n' : ''}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                  Text(
                                    'Erstellt: ${dateFormat.format(book.createdAt)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                  if (book.lastRead != null)
                                    Text(
                                      'Zuletzt gelesen: ${dateFormat.format(book.lastRead!)}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Löschen'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) async {
                                if (value == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Buch löschen?'),
                                      content: Text(
                                          'Möchtest du "${book.title}" wirklich löschen?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Abbrechen'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Löschen'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await booksProvider.deleteBook(book.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('✅ Buch gelöscht')),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
