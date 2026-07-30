import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

import 'package:fitness_day/core/constant/app_locale.dart';
import 'package:fitness_day/features/user/user_home/data/datasources/meal_analysis_exception.dart';
import 'package:fitness_day/features/user/user_home/data/datasources/meal_analysis_prompt.dart';
import 'package:fitness_day/features/user/user_home/data/models/meal_analysis_model.dart';

/// Sends a meal photo to OpenRouter's vision model and parses the nutritional
/// breakdown out of the response.
///
/// Failures are reported as a [MealAnalysisException] carrying a translation
/// key, so nothing here has to know which language the app is in — except the
/// prompt, which asks the model to answer in the user's language.
///
/// IMPORTANT (security):
/// Never ship a raw API key inside the compiled app — anyone can decompile the
/// APK/IPA and extract it. Move this behind your own backend before releasing
/// to real users.
class OpenRouterMealService {
  OpenRouterMealService({required this.apiKey});

  final String apiKey;

  static const String _model = 'google/gemma-4-26b-a4b-it:free';
  static const String _endpoint =
      'https://openrouter.ai/api/v1/chat/completions';

  /// Compresses [imageFile], sends it to OpenRouter with the analysis prompt,
  /// and parses the JSON answer into a [MealAnalysisResult].
  ///
  /// [languageCode] decides the language of the returned meal name,
  /// ingredients and notes; it defaults to the app's active language.
  Future<MealAnalysisResult> analyzeMeal(
    File imageFile, {
    String? languageCode,
  }) async {
    // An empty key is a setup problem, not a server one — say so plainly
    // instead of surfacing OpenRouter's generic 401.
    if (apiKey.trim().isEmpty) {
      throw const MealAnalysisException.missingApiKey();
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
              'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
            },
            {
              'type': 'text',
              'text': buildMealAnalysisPrompt(
                  languageCode ?? AppLocale.langCode),
            },
          ],
        },
      ],
    };

    final http.Response response;
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
    } catch (_) {
      throw const MealAnalysisException.connectionFailed();
    }

    if (response.statusCode == 429) {
      throw const MealAnalysisException.rateLimited();
    }
    if (response.statusCode != 200) {
      debugPrint('OpenRouter error body: ${response.body}');
      throw MealAnalysisException.requestFailed(response.statusCode);
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(response.body);
      final String text = decoded['choices'][0]['message']['content'] as String;
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

  /// Downscales and compresses the image so a full-resolution camera photo
  /// doesn't waste bandwidth and API quota.
  Future<Uint8List> _compressImage(File file) async {
    final Uint8List? result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1024,
      minHeight: 1024,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    return result ?? await file.readAsBytes();
  }
}
