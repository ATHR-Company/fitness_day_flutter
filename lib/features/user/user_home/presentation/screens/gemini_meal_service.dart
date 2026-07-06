import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'meal_analysis_model.dart';

/// Thrown when the Gemini API call fails or returns an unexpected response.
class MealAnalysisException implements Exception {
  final String message;
  MealAnalysisException(this.message);
  @override
  String toString() => message;
}

/// Handles sending a meal photo to Gemini's vision model and parsing
/// the nutritional breakdown from the response.
///
/// IMPORTANT (security):
/// Never ship a raw Gemini API key inside the compiled app — anyone can
/// decompile the APK/IPA and extract it, then abuse your quota/billing.
/// The right long-term setup is:
///   Flutter app -> your backend (Firebase Cloud Function / Node / etc.)
///                -> Gemini API (key stored server-side)
/// For local testing you can call Gemini directly with the key below,
/// but move it behind a backend before releasing to real users.
class GeminiMealService {
  GeminiMealService({required this.apiKey});

  /// Get a free key from https://aistudio.google.com/apikey
  final String apiKey;

  static const String _model = 'gemini-2.0-flash';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const String _prompt = '''
أنت خبير تغذية. حلل صورة الوجبة المرفقة وارجع تحليلاً غذائياً دقيقاً.
أجب فقط بصيغة JSON صالحة بدون أي نص إضافي أو علامات markdown، بالشكل التالي بالضبط:
{
  "meal_name": "اسم الوجبة بالعربي",
  "ingredients": [
    {"name": "اسم المكون", "approx_amount": "الكمية التقريبية (مثال: 150 جرام)", "calories": 0}
  ],
  "calories": 0,
  "protein_g": 0,
  "carbs_g": 0,
  "fat_g": 0,
  "notes": "أي ملاحظات مهمة عن دقة التقدير أو مكونات غير واضحة"
}
إذا لم تستطع تمييز الطعام في الصورة بوضوح، اذكر ذلك في notes وقدم أفضل تخمين ممكن.
كل الأرقام يجب أن تكون قيماً عددية (numbers) وليست نصوصاً.
''';

  /// Compresses [imageFile], sends it to Gemini along with the analysis
  /// prompt, and parses the JSON response into a [MealAnalysisResult].
  Future<MealAnalysisResult> analyzeMeal(File imageFile) async {
    final Uint8List compressedBytes = await _compressImage(imageFile);
    final String base64Image = base64Encode(compressedBytes);
    final Uri url = Uri.parse('$_endpoint?key=$apiKey');

    final Map<String, dynamic> body = {
      'contents': [
        {
          'parts': [
            {'text': _prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              }
            },
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
      },
    };

    http.Response response;
    try {
      response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw MealAnalysisException('تعذر الاتصال بالخادم. تأكد من اتصال الإنترنت.');
    }

    if (response.statusCode == 429) {
      throw MealAnalysisException(
        'تم تجاوز الحد المسموح به. انتظر دقيقة وحاول مرة أخرى.',
      );
    }
    if (response.statusCode != 200) {
      debugPrint('Gemini error body: ${response.body}');
      throw MealAnalysisException(
        'فشل تحليل الوجبة (كود ${response.statusCode}). حاول مرة أخرى.',
      );
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final String text =
          decoded['candidates'][0]['content']['parts'][0]['text'] as String;
      final String cleanedJson = _stripMarkdownFences(text);
      final Map<String, dynamic> resultJson = jsonDecode(cleanedJson);
      return MealAnalysisResult.fromJson(resultJson);
    } catch (e) {
      throw MealAnalysisException('تعذر فهم استجابة التحليل. حاول التقاط صورة أوضح.');
    }
  }

  String _stripMarkdownFences(String text) {
    return text.replaceAll('```json', '').replaceAll('```', '').trim();
  }

  /// Downscales and compresses the image so we don't waste bandwidth /
  /// API quota sending a full-resolution camera photo.
  Future<Uint8List> _compressImage(File file) async {
    final Uint8List? result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1024,
      minHeight: 1024,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    if (result == null) {
      // Fallback: send original bytes if compression fails for any reason.
      return await file.readAsBytes();
    }
    return result;
  }
}
