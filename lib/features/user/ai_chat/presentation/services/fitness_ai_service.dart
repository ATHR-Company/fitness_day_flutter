import 'dart:convert';
import 'package:http/http.dart' as http;

/// Sends a conversation history to OpenRouter and returns the AI reply.
/// Uses the same API key and endpoint as the meal scanner.
class FitnessAiService {
  FitnessAiService({required this.apiKey});

  final String apiKey;

  // Same model as meal scan — confirmed working
  static const String _model = 'google/gemma-4-26b-a4b-it:free';
  static const String _endpoint =
      'https://openrouter.ai/api/v1/chat/completions';

  static const String _systemPrompt =
      'أنت مدرب لياقة بدنية وأخصائي تغذية متخصص اسمك "مدربك الذكي". '
      'قاعدة مهمة: يجب أن يكون ردك دائماً بنفس لغة آخر رسالة أرسلها المستخدم — '
      'إذا كتب بالعربية فرد بالعربية، وإذا كتب بالإنجليزية فرد بالإنجليزية. '
      'اجعل ردودك قصيرة وعملية ومشجعة. '
      'تجيب فقط على أسئلة اللياقة البدنية والتغذية والصحة وفقدان الوزن وبناء العضلات. '
      'لا تناقش مواضيع خارج نطاق اللياقة والصحة. '
      'استخدم ردوداً ودية ومحفزة مع إيموجي مناسبة. '
      '\n\n'
      'You are a fitness coach and nutrition specialist named "Smart Coach". '
      'IMPORTANT RULE: Always reply in the SAME language as the user\'s last message — '
      'if they write in Arabic, reply in Arabic; if they write in English, reply in English. '
      'Keep replies short, practical and encouraging. '
      'Only answer questions about fitness, nutrition, health, weight loss and muscle building. '
      'Do not discuss topics outside fitness and health. '
      'Use a friendly, motivating tone with suitable emojis.';

  /// [messages] is a list of {role, content} maps representing the conversation.
  Future<String> sendMessage(List<Map<String, String>> messages) async {
    // An empty key is a setup problem, not a server one — surface it clearly
    // instead of letting OpenRouter reply with a bare 401.
    if (apiKey.trim().isEmpty) {
      throw Exception(
        'مفتاح خدمة الذكاء الاصطناعي غير مُعدّ. تأكد من وجود OPENROUTER_API_KEY في ملف .env.',
      );
    }

    // Gemma models don't support the 'system' role — inject system prompt
    // as a prefix in the first user message instead.
    final List<Map<String, dynamic>> apiMessages = [];

    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      if (i == 0 && msg['role'] == 'user') {
        apiMessages.add({
          'role': 'user',
          'content': '$_systemPrompt\n\n${msg['content']}',
        });
      } else {
        apiMessages.add(msg);
      }
    }

    int maxRetries = 3;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      late http.Response response;
      try {
        response = await http
            .post(
              Uri.parse(_endpoint),
              headers: {
                'Authorization': 'Bearer $apiKey',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': _model,
                'messages': apiMessages,
                'max_tokens': 500,
              }),
            )
            .timeout(const Duration(seconds: 60));
      } catch (_) {
        throw Exception('تعذر الاتصال. تأكد من اتصال الإنترنت.');
      }

      if (response.statusCode == 429) {
        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
          continue;
        }
        throw Exception('الخادم مشغول جداً. يرجى المحاولة بعد قليل.');
      }

      if (response.statusCode != 200) {
        throw Exception('خطأ في الخادم (${response.statusCode}). حاول مرة أخرى.');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        return choices[0]['message']['content'] as String;
      }
      throw Exception('استجابة غير صالحة من الذكاء الاصطناعي.');
    }
    throw Exception('فشل الاتصال بالخادم.');
  }
}
