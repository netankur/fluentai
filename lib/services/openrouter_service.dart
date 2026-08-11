import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_response.dart';
import 'ai_service.dart';

class OpenRouterService implements AIService {
  final String apiKey;
  final String model;

  OpenRouterService({required this.apiKey, required this.model});

  String _cleanJsonResponse(String rawText) {
    var cleaned = rawText.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }

  Future<Map<String, dynamic>> _callOpenRouterApi(String prompt) async {
    if (apiKey.trim().isEmpty) {
      throw const AIServiceException(
          'OpenRouter API key is missing. Please set your API key in Settings.');
    }

    final modelName =
        model.trim().isEmpty ? 'google/gemini-2.5-flash' : model.trim();
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${apiKey.trim()}',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://fluentai.app',
          'X-Title': 'FluentAI Assistant',
        },
        body: jsonEncode({
          'model': modelName,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are FluentAI, a helpful English writing assistant. Always respond with strict valid JSON.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'response_format': {'type': 'json_object'}
        }),
      );

      if (response.statusCode != 200) {
        final errJson = jsonDecode(response.body);
        final errMsg = errJson['error']?['message'] ??
            'OpenRouter API error (Status ${response.statusCode})';
        throw AIServiceException(errMsg);
      }

      final resData = jsonDecode(response.body);
      final choices = resData['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw const AIServiceException(
            'Empty response received from OpenRouter API.');
      }

      final content = choices[0]['message']?['content'] as String?;
      if (content == null || content.trim().isEmpty) {
        throw const AIServiceException('No text output from OpenRouter API.');
      }

      final cleanedText = _cleanJsonResponse(content);
      return jsonDecode(cleanedText) as Map<String, dynamic>;
    } on AIServiceException {
      rethrow;
    } catch (e) {
      throw AIServiceException('OpenRouter Service Error: ${e.toString()}');
    }
  }

  @override
  Future<GrammarResult> correctGrammar(String text) async {
    final prompt = '''
Check the following text for grammar, spelling, punctuation, and style issues.
Respond strictly in JSON format with exact keys:
"correctedText": (string, corrected version),
"explanation": (string, summary of corrections)

Input Text:
"$text"
''';
    final json = await _callOpenRouterApi(prompt);
    return GrammarResult.fromJson(json, text);
  }

  @override
  Future<SentenceCorrectionResult> correctSentence(
      String sentence, String style) async {
    final prompt = '''
Rephrase and refine this sentence in "$style" style.
Respond strictly in JSON with keys:
"primaryCorrection": (string, best rephrased version),
"alternatives": (array of 2-3 strings),
"explanation": (string),
"keyImprovements": (array of strings)

Original Sentence:
"$sentence"
''';
    final json = await _callOpenRouterApi(prompt);
    return SentenceCorrectionResult.fromJson(json, sentence);
  }

  @override
  Future<DraftResult> generateDraft({
    required String prompt,
    required String tone,
    required String type,
    String? replyToMessage,
  }) async {
    final isReply = replyToMessage != null && replyToMessage.trim().isNotEmpty;
    final contextPrompt = isReply
        ? '''
Write a reply to this received message: "$replyToMessage"
User instructions: "$prompt"
Type: $type
Tone: $tone
'''
        : '''
Draft a $type based on: "$prompt".
Tone: $tone
''';

    final fullPrompt = '''
$contextPrompt
Respond strictly in JSON with keys:
"subjectLine": (string or null),
"generatedDraft": (string, complete draft text),
"keyPointsCovered": (array of strings)
''';

    final json = await _callOpenRouterApi(fullPrompt);
    return DraftResult.fromJson(json, type, tone);
  }

  @override
  Future<DictionaryResult> lookupWord(String word) async {
    final prompt = '''
Dictionary lookup for English word/phrase: "$word".
Respond strictly in JSON with keys:
"word": (string),
"pronunciation": (string IPA),
"partOfSpeech": (string),
"definitions": (array of strings),
"exampleSentences": (array of strings),
"originNote": (string)
''';
    final json = await _callOpenRouterApi(prompt);
    return DictionaryResult.fromJson(json, word);
  }

  @override
  Future<SynonymsResult> fetchSynonymsAndAntonyms(String word) async {
    final prompt = '''
Find synonyms and antonyms for word: "$word".
Respond strictly in JSON with keys:
"word": (string),
"synonyms": (array of strings),
"antonyms": (array of strings),
"contextNote": (string)
''';
    final json = await _callOpenRouterApi(prompt);
    return SynonymsResult.fromJson(json, word);
  }

  @override
  Future<SentenceMakerResult> makeSentences(String topicOrWord) async {
    final prompt = '''
Generate sample sentences for topic/word: "$topicOrWord".
Respond strictly in JSON with keys:
"topicOrWord": (string),
"beginnerSentences": (array of 3 strings),
"intermediateSentences": (array of 3 strings),
"advancedSentences": (array of 3 strings),
"usageTips": (string)
''';
    final json = await _callOpenRouterApi(prompt);
    return SentenceMakerResult.fromJson(json, topicOrWord);
  }
}
