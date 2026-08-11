import '../utils/diff_util.dart';

class GrammarResult {
  final String originalText;
  final String correctedText;
  final String explanation;
  final List<DiffSegment> diffs;

  const GrammarResult({
    required this.originalText,
    required this.correctedText,
    required this.explanation,
    required this.diffs,
  });

  factory GrammarResult.fromJson(Map<String, dynamic> json, String original) {
    final corrected = json['correctedText'] as String? ?? original;
    final exp = json['explanation'] as String? ?? 'No grammar issues found.';
    final diffsList = DiffUtil.calculateDiff(original, corrected);

    return GrammarResult(
      originalText: original,
      correctedText: corrected,
      explanation: exp,
      diffs: diffsList,
    );
  }
}

class SentenceCorrectionResult {
  final String originalSentence;
  final String primaryCorrection;
  final List<String> alternatives;
  final String explanation;
  final List<String> keyImprovements;

  const SentenceCorrectionResult({
    required this.originalSentence,
    required this.primaryCorrection,
    required this.alternatives,
    required this.explanation,
    required this.keyImprovements,
  });

  factory SentenceCorrectionResult.fromJson(
      Map<String, dynamic> json, String original) {
    return SentenceCorrectionResult(
      originalSentence: original,
      primaryCorrection: json['primaryCorrection'] as String? ?? original,
      alternatives: (json['alternatives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      explanation: json['explanation'] as String? ?? '',
      keyImprovements: (json['keyImprovements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class DraftResult {
  final String generatedDraft;
  final String type;
  final String tone;
  final String? subjectLine;
  final List<String> keyPointsCovered;

  const DraftResult({
    required this.generatedDraft,
    required this.type,
    required this.tone,
    this.subjectLine,
    required this.keyPointsCovered,
  });

  factory DraftResult.fromJson(Map<String, dynamic> json, String type, String tone) {
    return DraftResult(
      generatedDraft: json['generatedDraft'] as String? ?? '',
      type: type,
      tone: tone,
      subjectLine: json['subjectLine'] as String?,
      keyPointsCovered: (json['keyPointsCovered'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class DictionaryResult {
  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final List<String> definitions;
  final List<String> exampleSentences;
  final String? originNote;

  const DictionaryResult({
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.definitions,
    required this.exampleSentences,
    this.originNote,
  });

  factory DictionaryResult.fromJson(Map<String, dynamic> json, String searchWord) {
    return DictionaryResult(
      word: json['word'] as String? ?? searchWord,
      pronunciation: json['pronunciation'] as String? ?? '',
      partOfSpeech: json['partOfSpeech'] as String? ?? 'Noun / Verb',
      definitions: (json['definitions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Definition not found.'],
      exampleSentences: (json['exampleSentences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      originNote: json['originNote'] as String?,
    );
  }
}

class SynonymsResult {
  final String word;
  final List<String> synonyms;
  final List<String> antonyms;
  final String? contextNote;

  const SynonymsResult({
    required this.word,
    required this.synonyms,
    required this.antonyms,
    this.contextNote,
  });

  factory SynonymsResult.fromJson(Map<String, dynamic> json, String searchWord) {
    return SynonymsResult(
      word: json['word'] as String? ?? searchWord,
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      antonyms: (json['antonyms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      contextNote: json['contextNote'] as String?,
    );
  }
}

class SentenceMakerResult {
  final String topicOrWord;
  final List<String> beginnerSentences;
  final List<String> intermediateSentences;
  final List<String> advancedSentences;
  final String usageTips;

  const SentenceMakerResult({
    required this.topicOrWord,
    required this.beginnerSentences,
    required this.intermediateSentences,
    required this.advancedSentences,
    required this.usageTips,
  });

  factory SentenceMakerResult.fromJson(Map<String, dynamic> json, String searchWord) {
    return SentenceMakerResult(
      topicOrWord: json['topicOrWord'] as String? ?? searchWord,
      beginnerSentences: (json['beginnerSentences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      intermediateSentences: (json['intermediateSentences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      advancedSentences: (json['advancedSentences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      usageTips: json['usageTips'] as String? ?? '',
    );
  }
}
