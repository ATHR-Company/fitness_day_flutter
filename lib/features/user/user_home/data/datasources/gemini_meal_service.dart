import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

import 'package:fitness_day/core/constant/app_locale.dart';
import 'package:fitness_day/features/user/user_home/data/datasources/meal_analysis_exception.dart';
import 'package:fitness_day/features/user/user_home/data/datasources/meal_analysis_prompt.dart';
import 'package:fitness_day/features/user/user_home/data/models/meal_analysis_model.dart';

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

  /// Compresses [imageFile], sends it to Gemini along with the analysis
  /// prompt, and parses the JSON response into a [MealAnalysisResult].
  ///
  /// [languageCode] decides the language of the returned free-text fields;
  /// it defaults to the app's active language.
  Future<MealAnalysisResult> analyzeMeal(
    File imageFile, {
    String? languageCode,
  }) async {
    final String prompt =
        buildMealAnalysisPrompt(languageCode ?? AppLocale.langCode);
    final Uint8List compressedBytes = await _compressImage(imageFile);
    final String base64Image = base64Encode(compressedBytes);
    final Uri url = Uri.parse('$_endpoint?key=$apiKey');

    final Map<String, dynamic> body = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
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

    final http.Response response;
    try {
      response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const MealAnalysisException.connectionFailed();
    }

    if (response.statusCode == 429) {
      throw const MealAnalysisException.rateLimited();
    }
    if (response.statusCode != 200) {
      debugPrint('Gemini error body: ${response.body}');
      throw MealAnalysisException.requestFailed(response.statusCode);
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final String text =
          decoded['candidates'][0]['content']['parts'][0]['text'] as String;
      final Map<String, dynamic> resultJson =
          jsonDecode(_stripMarkdownFences(text));
      return MealAnalysisResult.fromJson(resultJson);
    } catch (_) {
      throw const MealAnalysisException.unreadableResponse();
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
