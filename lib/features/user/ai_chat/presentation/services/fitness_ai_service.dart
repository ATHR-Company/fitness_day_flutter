import 'dart:convert';
import 'package:http/http.dart' as http;

/// Sends a conversation history to OpenRouter and returns the AI reply.
/// Uses the same API key and endpoint as the meal scanner.
class FitnessAiService {
  FitnessAiService({required this.apiKey});

  final String apiKey;

  static const String _model = 'meta-llama/llama-3.3-70b-instruct:free';
  static const String _endpoint =
      'https://openrouter.ai/api/v1/chat/completions';

  static const Map<String, dynamic> _systemMessage = {
    'role': 'system',
    'content': '''أنت مدرب لياقة بدنية وأخصائي تغذية متخصص اسمك "مدربك الذكي".
ردودك باللغة العربية دائماً، قصيرة وعملية ومشجعة.
تجيب فقط على أسئلة اللياقة البدنية والتغذية والصحة وفقدان الوزن وبناء العضلات.
لا تناقش مواضيع خارج نطاق اللياقة والصحة.
استخدم ردوداً ودية ومحفزة مع إيموجي مناسبة.''',
  };

  /// [messages] is a list of {role, content} maps representing the conversation.
  Future<String> sendMessage(List<Map<String, String>> messages) async {
    final List<Map<String, dynamic>> fullMessages = [
      _systemMessage,
      ...messages,
    ];

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
              'messages': fullMessages,
              'max_tokens': 500,
            }),
          )
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw Exception('تعذر الاتصال. تأكد من اتصال الإنترنت.');
    }

    if (response.statusCode == 429) {
      throw Exception('تم تجاوز الحد المسموح. انتظر قليلاً وحاول مرة أخرى.');
    }
    if (response.statusCode != 200) {
      throw Exception('خطأ في الخادم (${response.statusCode}). حاول مرة أخرى.');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded['choices'][0]['message']['content'] as String;
  }
}
