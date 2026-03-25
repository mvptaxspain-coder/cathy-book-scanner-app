import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/book.dart';
import '../models/voice.dart';
import '../providers/voices_provider.dart';
import '../providers/books_provider.dart';
import '../services/tts_service.dart';
import '../widgets/progress_dialog.dart';

class BookReaderScreen extends StatefulWidget {
  final Book book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final TtsService _ttsService = TtsService();
  final AudioPlayer _player = AudioPlayer();
  Voice? _selectedVoice;
  int _currentPageIndex = 0;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    _selectedVoice = context.read<VoicesProvider>().defaultVoice;

    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _player.onPlayerComplete.listen((_) {
      if (_currentPageIndex < widget.book.totalPages - 1) {
        _nextPage();
      } else {
        setState(() {
          _isPlaying = false;
        });
      }
    });

    // Update last read
    final updatedBook = Book(
      id: widget.book.id,
      title: widget.book.title,
      pages: widget.book.pages,
      createdAt: widget.book.createdAt,
      lastRead: DateTime.now(),
    );
    context.read<BooksProvider>().updateBook(updatedBook);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = widget.book.pages[_currentPageIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.title),
      ),
      body: Column(
        children: [
          // Voice Selector
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎭 Stimme auswählen:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Consumer<VoicesProvider>(
                    builder: (context, voicesProvider, child) {
                      return DropdownButton<Voice>(
                        isExpanded: true,
                        value: _selectedVoice,
                        items: voicesProvider.voices
                            .map((voice) => DropdownMenuItem(
                                  value: voice,
                                  child: Text(voice.name),
                                ))
                            .toList(),
                        onChanged: (voice) {
                          setState(() {
                            _selectedVoice = voice;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Page Navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentPageIndex > 0 ? _previousPage : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  'Seite ${_currentPageIndex + 1} von ${widget.book.totalPages}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: _currentPageIndex < widget.book.totalPages - 1
                      ? _nextPage
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),

          // Page Content
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentPage.imagePath != null)
                      Center(
                        child: ClipRRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(currentPage.imagePath!),
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    if (currentPage.imagePath != null) const SizedBox(height: 16),
                    Text(
                      currentPage.text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Player Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (_isLoadingAudio)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12.0),
                    child: LinearProgressIndicator(),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: _currentPageIndex > 0 ? _previousPage : null,
                      icon: const Icon(Icons.skip_previous),
                      iconSize: 36,
                    ),
                    FloatingActionButton.large(
                      onPressed: _isLoadingAudio ? null : _togglePlayPause,
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 36,
                      ),
                    ),
                    IconButton(
                      onPressed: _currentPageIndex < widget.book.totalPages - 1
                          ? _nextPage
                          : null,
                      icon: const Icon(Icons.skip_next),
                      iconSize: 36,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
      _player.stop();
    }
  }

  void _nextPage() {
    if (_currentPageIndex < widget.book.totalPages - 1) {
      setState(() {
        _currentPageIndex++;
      });
      _player.stop();
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _playCurrentPage();
    }
  }

  Future<void> _playCurrentPage() async {
    if (_selectedVoice == null) return;

    setState(() {
      _isLoadingAudio = true;
    });

    try {
      final currentPage = widget.book.pages[_currentPageIndex];

      // Show progress dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ProgressDialog(
            message: 'Generiere Audio...\n🎙️ TTS läuft...',
          ),
        );
      }

      // Get voice file if not default
      File? voiceFile;
      if (!_selectedVoice!.isDefault && _selectedVoice!.audioPath != null) {
        voiceFile = File(_selectedVoice!.audioPath!);
      }

      // Synthesize speech
      final audioFile = await _ttsService.synthesizeSpeech(
        currentPage.text,
        voiceFile: voiceFile,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
      }

      // Play audio
      await _player.play(DeviceFileSource(audioFile.path));

      setState(() {
        _isLoadingAudio = false;
      });
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
      }

      setState(() {
        _isLoadingAudio = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Fehler: $e')),
        );
      }
    }
  }
}
