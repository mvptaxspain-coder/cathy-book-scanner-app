import 'package:flutter/foundation.dart';
import '../models/voice.dart';
import '../services/storage_service.dart';

class VoicesProvider with ChangeNotifier {
  List<Voice> _voices = [];
  bool _isLoading = false;

  List<Voice> get voices => _voices;
  bool get isLoading => _isLoading;

  VoicesProvider() {
    loadVoices();
  }

  Future<void> loadVoices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _voices = await StorageService.instance.getVoices();
    } catch (e) {
      print('Error loading voices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVoice(Voice voice) async {
    try {
      await StorageService.instance.addVoice(voice);
      _voices.add(voice);
      notifyListeners();
    } catch (e) {
      print('Error adding voice: $e');
      rethrow;
    }
  }

  Future<void> deleteVoice(String voiceId) async {
    try {
      await StorageService.instance.deleteVoice(voiceId);
      _voices.removeWhere((v) => v.id == voiceId);
      notifyListeners();
    } catch (e) {
      print('Error deleting voice: $e');
      rethrow;
    }
  }

  Voice? getVoice(String voiceId) {
    try {
      return _voices.firstWhere((v) => v.id == voiceId);
    } catch (e) {
      return null;
    }
  }

  Voice get defaultVoice {
    try {
      return _voices.firstWhere((v) => v.isDefault);
    } catch (e) {
      return Voice(
        id: 'default',
        name: 'Standard Stimme',
        description: 'Standard TTS',
        createdAt: DateTime.now(),
        isDefault: true,
      );
    }
  }
}
