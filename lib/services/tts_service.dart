import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class TtsService {
  static const String _ttsApiUrl =
      'https://myapplication--cathy-tts-chatterbox-fastapi-app.modal.run/tts';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
  ));

  Future<File> synthesizeSpeech(
    String text, {
    File? voiceFile,
    Function(int, int)? onProgress,
  }) async {
    try {
      print('🎙️ [TTS] Starting TTS synthesis');
      print('📝 [TTS] Text length: ${text.length} characters');

      final formData = FormData.fromMap({
        'text': text,
        if (voiceFile != null)
          'voice_file': await MultipartFile.fromFile(
            voiceFile.path,
            filename: 'voice.wav',
          ),
      });

      final response = await _dio.post(
        _ttsApiUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onReceiveProgress: (received, total) {
          if (onProgress != null && total != -1) {
            onProgress(received, total);
          }
        },
      );

      if (response.statusCode == 200) {
        final result = response.data;

        if (result['status'] == 'error') {
          throw Exception('TTS Error: ${result['error']}');
        }

        // Decode base64 audio
        final audioBase64 = result['audio'] as String;
        final audioBytes = _base64Decode(audioBase64);

        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final audioFile = File(
            '${tempDir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.wav');
        await audioFile.writeAsBytes(audioBytes);

        print('✅ [TTS] Audio saved to ${audioFile.path}');
        print('🔊 [TTS] Duration: ${result['duration']}s');

        return audioFile;
      } else {
        throw Exception('TTS API returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [TTS] Dio error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Zeitüberschreitung - Server antwortet nicht');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Keine Verbindung zum TTS-Server möglich');
      }
      throw Exception('TTS Fehler: ${e.message}');
    } catch (e) {
      print('❌ [TTS] Error: $e');
      throw Exception('TTS Fehler: $e');
    }
  }

  Uint8List _base64Decode(String base64) {
    return Uint8List.fromList(
      base64
          .split('')
          .map((c) => c.codeUnitAt(0))
          .toList(),
    );
  }
}
