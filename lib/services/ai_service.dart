import '../models/ai_response.dart';

abstract class AIService {
  Future<GrammarResult> correctGrammar(String text);
  Future<SentenceCorrectionResult> correctSentence(String sentence, String style);
  Future<DraftResult> generateDraft({
    required String prompt,
    required String tone,
    required String type,
    String? replyToMessage,
  });
  Future<DictionaryResult> lookupWord(String word);
  Future<SynonymsResult> fetchSynonymsAndAntonyms(String word);
  Future<SentenceMakerResult> makeSentences(String topicOrWord);
}

class AIServiceException implements Exception {
  final String message;
  const AIServiceException(this.message);

  @override
  String toString() => message;
}
