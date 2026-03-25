import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/voice.dart';
import '../providers/voices_provider.dart';

class VoiceLibraryScreen extends StatefulWidget {
  const VoiceLibraryScreen({super.key});

  @override
  State<VoiceLibraryScreen> createState() => _VoiceLibraryScreenState();
}

class _VoiceLibraryScreenState extends State<VoiceLibraryScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  String? _recordedPath;

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎭 Stimmen Bibliothek'),
      ),
      body: Consumer<VoicesProvider>(
        builder: (context, voicesProvider, child) {
          if (voicesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final voices = voicesProvider.voices;

          return Column(
            children: [
              Expanded(
                child: voices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.record_voice_over_outlined,
                              size: 100,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Noch keine Stimmen',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: voices.length,
                        itemBuilder: (context, index) {
                          final voice = voices[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: voice.isDefault
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                child: Icon(
                                  voice.isDefault
                                      ? Icons.volume_up
                                      : Icons.record_voice_over,
                                  color: voice.isDefault
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              title: Text(voice.name),
                              subtitle: Text(voice.description),
                              trailing: voice.isDefault
                                  ? const Chip(label: Text('Standard'))
                                  : PopupMenuButton(
                                      itemBuilder: (context) => [
                                        if (voice.audioPath != null)
                                          const PopupMenuItem(
                                            value: 'play',
                                            child: Row(
                                              children: [
                                                Icon(Icons.play_arrow),
                                                SizedBox(width: 8),
                                                Text('Anhören'),
                                              ],
                                            ),
                                          ),
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
                                        if (value == 'play' &&
                                            voice.audioPath != null) {
                                          await _player.play(
                                              DeviceFileSource(voice.audioPath!));
                                        } else if (value == 'delete') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Stimme löschen?'),
                                              content: Text(
                                                  'Möchtest du "${voice.name}" wirklich löschen?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, false),
                                                  child: const Text('Abbrechen'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context, true),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  child: const Text('Löschen'),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            await voicesProvider
                                                .deleteVoice(voice.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content:
                                                        Text('✅ Stimme gelöscht')),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVoiceDialog,
        icon: const Icon(Icons.add),
        label: const Text('Stimme aufnehmen'),
      ),
    );
  }

  Future<void> _showAddVoiceDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Neue Stimme aufnehmen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sprich mindestens 5 Sekunden\nfür beste Ergebnisse',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (_isRecording) {
                      await _stopRecording();
                      setState(() {});
                    } else {
                      await _startRecording();
                      setState(() {});
                    }
                  },
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Aufnahme stoppen' : 'Aufnahme starten'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : null,
                  ),
                ),
                if (_recordedPath != null) ...[
                  const SizedBox(height: 12),
                  const Text('✅ Aufnahme bereit',
                      style: TextStyle(color: Colors.green)),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _player.play(DeviceFileSource(_recordedPath!));
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Anhören'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _recordedPath = null;
                Navigator.pop(context);
              },
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: _recordedPath == null
                  ? null
                  : () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('❌ Bitte Namen eingeben')),
                        );
                        return;
                      }

                      final voice = Voice(
                        id: const Uuid().v4(),
                        name: name,
                        description: descController.text.trim().isEmpty
                            ? 'Benutzerdefinierte Stimme: $name'
                            : descController.text.trim(),
                        audioPath: _recordedPath,
                        createdAt: DateTime.now(),
                      );

                      await context.read<VoicesProvider>().addVoice(voice);

                      _recordedPath = null;
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ Stimme "$name" gespeichert!')),
                        );
                      }
                    },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordedPath = path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Fehler: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _recorder.stop();
      setState(() {
        _isRecording = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Fehler beim Stoppen: $e')),
      );
    }
  }
}
