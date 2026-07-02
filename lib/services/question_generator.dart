// lib/services/question_generator.dart
import 'dart:math';
import '../models/models.dart';
import 'supabase_service.dart';

class QuestionGenerator {
  static final Random _rng = Random();

  static Future<List<QuizQuestion>> generateForUnit(
    String unitId, {
    int count = 10,
    String? typeFilter,
  }) async {
    final base = await SupabaseService.getRandomQuestions(
      unitId,
      count: count * 2,
      type: typeFilter,
    );
    if (base.isEmpty) return [];

    final cases = await SupabaseService.getCaseLaws(unitId);
    final generated = <QuizQuestion>[];

    for (int i = 0; i < count && i < base.length; i++) {
      final q = base[i];
      if (typeFilter != null) {
        generated.add(q);
        continue;
      }

      final variation = _rng.nextInt(3);
      switch (variation) {
        case 0:
          generated.add(q);
          break;
        case 1:
          if (cases.isNotEmpty) {
            generated.add(
              _toCaseBased(q, cases[_rng.nextInt(cases.length)]),
            );
          } else {
            generated.add(q);
          }
          break;
        case 2:
          generated.add(_reverseQuestion(q));
          break;
      }
    }

    generated.shuffle(_rng);
    return generated.take(count).toList();
  }

  static QuizQuestion _toCaseBased(QuizQuestion q, CaseLaw c) {
    return QuizQuestion(
      id: '${q.id}_case',
      unitId: q.unitId,
      question: 'Regarding ${c.name} (${c.year}): ${q.question}',
      options: q.options,
      correctIndex: q.correctIndex,
      explanation: '${c.held}\n\n${q.explanation}',
      type: q.type,
      caseName: c.name,
    );
  }

  static QuizQuestion _reverseQuestion(QuizQuestion q) {
    final exp = q.explanation;
    final truncated = exp.length > 120 ? '${exp.substring(0, 120)}...' : exp;
    return QuizQuestion(
      id: '${q.id}_rev',
      unitId: q.unitId,
      question: truncated,
      options: ['Valid', 'Invalid'],
      correctIndex: 0,
      explanation: q.question,
      type: 'truefalse',
      caseName: q.caseName,
    );
  }

  /// Generate matching pairs from questions for the Match game
  static List<MatchPair> generateMatchPairs(List<QuizQuestion> questions) {
    final pairs = <MatchPair>[];
    for (final q in questions.take(6)) {
      pairs.add(MatchPair(
        id: q.id,
        left: q.question.length > 60
            ? '${q.question.substring(0, 60)}...'
            : q.question,
        right: q.options[q.correctIndex],
      ));
    }
    pairs.shuffle(_rng);
    return pairs;
  }

  /// Generate flashcard pairs (question front, answer + explanation back)
  static List<Map<String, String>> generateFlashcards(
      List<QuizQuestion> questions) {
    return questions.map((q) {
      return {
        'front': q.question,
        'back': q.options[q.correctIndex],
        'detail': q.explanation,
        'case': q.caseName ?? '',
      };
    }).toList();
  }

  /// Generate verdict statements (valid / invalid) from truefalse type
  static List<QuizQuestion> generateVerdictQuestions(
      List<QuizQuestion> all) {
    final verdicts =
        all.where((q) => q.type == 'truefalse').toList();
    if (verdicts.isEmpty) {
      // Convert MCQs to verdict format
      return all.take(8).map((q) {
        final isCorrect = _rng.nextBool();
        final wrongIndex = (q.correctIndex + 1) % q.options.length;
        return QuizQuestion(
          id: '${q.id}_verdict',
          unitId: q.unitId,
          question: isCorrect
              ? 'STATEMENT: ${q.options[q.correctIndex]} is the answer to: "${q.question}"'
              : 'STATEMENT: ${q.options[wrongIndex]} is the answer to: "${q.question}"',
          options: ['Valid', 'Invalid'],
          correctIndex: isCorrect ? 0 : 1,
          explanation: q.explanation,
          type: 'truefalse',
          caseName: q.caseName,
        );
      }).toList();
    }
    verdicts.shuffle(_rng);
    return verdicts;
  }
}
