import 'dart:io';
import 'package:dio/dio.dart';

class OcrService {
  static const String _ocrApiUrl =
      'https://myapplication--cathy-ocr-qwen-fastapi-app.modal.run/ocr';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 120),
    receiveTimeout: const Duration(seconds: 120),
  ));

  Future<String> extractText(File imageFile) async {
    try {
      print('🔍 [OCR] Starting OCR for ${imageFile.path}');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'page.jpg',
        ),
      });

      final response = await _dio.post(
        _ocrApiUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data;

        if (result['status'] == 'error') {
          throw Exception('OCR Error: ${result['error']}');
        }

        final text = result['text']?.toString().trim() ?? '';
        print('✅ [OCR] Extracted ${text.length} characters');

        if (text.isEmpty) {
          throw Exception('Kein Text im Bild gefunden');
        }

        return text;
      } else {
        throw Exception('OCR API returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [OCR] Dio error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Zeitüberschreitung - Server antwortet nicht');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Keine Verbindung zum OCR-Server möglich');
      }
      throw Exception('OCR Fehler: ${e.message}');
    } catch (e) {
      print('❌ [OCR] Error: $e');
      throw Exception('OCR Fehler: $e');
    }
  }

  Future<List<String>> extractTextFromMultipleImages(
      List<File> imageFiles,
      {Function(int current, int total)? onProgress}) async {
    final List<String> results = [];

    for (int i = 0; i < imageFiles.length; i++) {
      if (onProgress != null) {
        onProgress(i + 1, imageFiles.length);
      }

      final text = await extractText(imageFiles[i]);
      results.add(text);
    }

    return results;
  }
}
