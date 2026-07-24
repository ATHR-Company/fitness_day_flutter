import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'meal_analysis_model.dart';
import 'meal_exceptions.dart';

/// Handles sending a meal photo to OpenRouter's vision model and parsing
/// the nutritional breakdown from the response.
///
/// Uses meta-llama/llama-3.2-11b-vision-instruct:free — free tier, supports
/// vision, and works without regional restrictions.
///
/// IMPORTANT (security):
/// Never ship a raw API key inside the compiled app — anyone can decompile
/// the APK/IPA and extract it. Move this behind your own backend before
/// releasing to real users.
class OpenRouterMealService {
  OpenRouterMealService({required this.apiKey});

  final String apiKey;

  static const String _model =
      'google/gemma-4-26b-a4b-it:free';
  static const String _endpoint =
      'https://openrouter.ai/api/v1/chat/completions';

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

  /// Compresses [imageFile], sends it to OpenRouter along with the analysis
  /// prompt, and parses the JSON response into a [MealAnalysisResult].
  Future<MealAnalysisResult> analyzeMeal(File imageFile) async {
    // An empty key is a setup problem, not a server one — say so plainly
    // instead of surfacing OpenRouter's generic 401.
    if (apiKey.trim().isEmpty) {
      throw MealAnalysisException(
        'مفتاح خدمة الذكاء الاصطناعي غير مُعدّ. تأكد من وجود OPENROUTER_API_KEY في ملف .env.',
      );
    }

    final Uint8List compressedBytes = await _compressImage(imageFile);
    final String base64Image = base64Encode(compressedBytes);

    final Map<String, dynamic> body = {
      'model': _model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
            {
              'type': 'text',
              'text': _prompt,
            },
          ],
        },
      ],
    };

    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
    } catch (e) {
      throw MealAnalysisException(
          'تعذر الاتصال بالخادم. تأكد من اتصال الإنترنت.');
    }

    if (response.statusCode == 429) {
      throw MealAnalysisException(
        'تم تجاوز الحد المسموح به. انتظر دقيقة وحاول مرة أخرى.',
      );
    }
    if (response.statusCode != 200) {
      debugPrint('OpenRouter error body: ${response.body}');
      throw MealAnalysisException(
        'فشل تحليل الوجبة (كود ${response.statusCode}). حاول مرة أخرى.',
      );
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final String text =
          decoded['choices'][0]['message']['content'] as String;
      final String cleanedJson = _stripMarkdownFences(text);
      final Map<String, dynamic> resultJson = jsonDecode(cleanedJson);
      return MealAnalysisResult.fromJson(resultJson);
    } catch (e) {
      throw MealAnalysisException(
          'تعذر فهم استجابة التحليل. حاول التقاط صورة أوضح.');
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
      return await file.readAsBytes();
    }
    return result;
  }
}
