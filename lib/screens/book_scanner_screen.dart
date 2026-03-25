import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart';
import '../providers/books_provider.dart';
import '../services/ocr_service.dart';
import '../widgets/progress_dialog.dart';

class BookScannerScreen extends StatefulWidget {
  const BookScannerScreen({super.key});

  @override
  State<BookScannerScreen> createState() => _BookScannerScreenState();
}

class _BookScannerScreenState extends State<BookScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  final List<ScanResult> _scannedPages = [];
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📷 Buch Scanner'),
      ),
      body: Column(
        children: [
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Foto aufnehmen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Aus Galerie'),
                  ),
                ),
              ],
            ),
          ),

          // Scanned Pages List
          Expanded(
            child: _scannedPages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 100,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Noch keine Seiten gescannt',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nimm ein Foto auf oder wähle\nein Bild aus der Galerie',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scannedPages.length,
                    itemBuilder: (context, index) {
                      final page = _scannedPages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(page.imagePath),
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text('Seite ${index + 1}'),
                          subtitle: Text(
                            page.text.length > 50
                                ? '${page.text.substring(0, 50)}...'
                                : page.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _scannedPages.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Save Button
          if (_scannedPages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveAsBook,
                  icon: const Icon(Icons.save),
                  label: Text('Als Buch speichern (${_scannedPages.length} Seiten)'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (image == null) return;

      setState(() {
        _isProcessing = true;
      });

      if (!mounted) return;

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const ProgressDialog(
          message: 'Verarbeite Bild...\n🤖 OCR läuft...',
        ),
      );

      try {
        // Run OCR
        final text = await _ocrService.extractText(File(image.path));

        if (!mounted) return;
        Navigator.of(context).pop(); // Close progress dialog

        setState(() {
          _scannedPages.add(ScanResult(
            imagePath: image.path,
            text: text,
          ));
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Seite erfolgreich gescannt!')),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Close progress dialog

        setState(() {
          _isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Fehler: $e')),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Fehler beim Öffnen der Kamera: $e')),
      );
    }
  }

  Future<void> _saveAsBook() async {
    final titleController = TextEditingController(text: 'Neues Buch');

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buch speichern'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Buchtitel',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, titleController.text),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    final book = Book(
      id: const Uuid().v4(),
      title: result,
      pages: _scannedPages
          .asMap()
          .entries
          .map((entry) => BookPage(
                pageNumber: entry.key + 1,
                text: entry.value.text,
                imagePath: entry.value.imagePath,
              ))
          .toList(),
      createdAt: DateTime.now(),
    );

    try {
      await context.read<BooksProvider>().addBook(book);

      if (!mounted) return;

      setState(() {
        _scannedPages.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Buch "$result" gespeichert!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Fehler beim Speichern: $e')),
      );
    }
  }
}

class ScanResult {
  final String imagePath;
  final String text;

  ScanResult({required this.imagePath, required this.text});
}
