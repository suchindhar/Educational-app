import 'dart:convert';

enum QuizType { multipleChoice, trueFalse, matchFollowing }

class UnitContent {
  final String id;
  final int number;
  final String title;
  final String description;
  final String color;
  final List<Topic> topics;

  UnitContent({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.color,
    required this.topics,
  });

  factory UnitContent.fromJson(Map<String, dynamic> json) {
    return UnitContent(
      id: json['id'] ?? '',
      number: json['number'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? '#1E3A5F',
      topics: (json['topics'] as List? ?? [])
          .map((t) => Topic.fromJson(t))
          .toList(),
    );
  }
}

class Topic {
  final String id;
  final String title;
  final String content;
  final List<String> keyPoints;
  final String? videoUrl;
  final String? pdfUrl;

  Topic({
    required this.id,
    required this.title,
    required this.content,
    required this.keyPoints,
    this.videoUrl,
    this.pdfUrl,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      keyPoints: List<String>.from(json['key_points'] ?? []),
      videoUrl: json['video_url'],
      pdfUrl: json['pdf_url'],
    );
  }
}

class QuizSet {
  final String id;
  final String unitId;
  final String title;
  final List<QuizQuestion> questions;

  QuizSet({
    required this.id,
    required this.unitId,
    required this.title,
    required this.questions,
  });

  factory QuizSet.fromJson(Map<String, dynamic> json) {
    return QuizSet(
      id: json['id'] ?? '',
      unitId: json['unit_id'] ?? '',
      title: json['title'] ?? '',
      questions: (json['questions'] as List? ?? [])
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
    );
  }
}

class QuizQuestion {
  final String id;
  final QuizType type;
  final String question;
  final List<String> options;
  final dynamic answer; // String for MC/TF, List<MatchPair> for Match
  final String? explanation;

  QuizQuestion({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.answer,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    QuizType qType;
    switch (json['type']) {
      case 'true_false': qType = QuizType.trueFalse; break;
      case 'match_following': qType = QuizType.matchFollowing; break;
      default: qType = QuizType.multipleChoice;
    }

    dynamic finalAnswer = json['answer'];
    if (qType == QuizType.matchFollowing && json['pairs'] != null) {
      finalAnswer = (json['pairs'] as List)
          .map((p) => MatchPair(left: p['left'], right: p['right']))
          .toList();
    }

    return QuizQuestion(
      id: json['id'] ?? '',
      type: qType,
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: finalAnswer,
      explanation: json['explanation'],
    );
  }
}

class MatchPair {
  final String left;
  final String right;
  MatchPair({required this.left, required this.right});
}

class FlashcardSet {
  final String id;
  final String unitId;
  final String title;
  final List<Flashcard> cards;

  FlashcardSet({
    required this.id,
    required this.unitId,
    required this.title,
    required this.cards,
  });

  factory FlashcardSet.fromJson(Map<String, dynamic> json) {
    return FlashcardSet(
      id: json['id'] ?? '',
      unitId: json['unit_id'] ?? '',
      title: json['title'] ?? 'Revision Flashcards',
      cards: (json['cards'] as List? ?? [])
          .map((c) => Flashcard.fromJson(c))
          .toList(),
    );
  }

  factory FlashcardSet.fromTopics(String unitId, List<Topic> topics) {
    return FlashcardSet(
      id: 'auto_$unitId',
      unitId: unitId,
      title: 'Topic Revision',
      cards: topics
          .where((t) => t.keyPoints.isNotEmpty)
          .map((t) => Flashcard(
                id: 'auto_${t.id}',
                front: t.title,
                back: t.keyPoints.join(' • '),
              ))
          .toList(),
    );
  }
}


class Flashcard {
  final String id;
  final String front;
  final String back;

  Flashcard({required this.id, required this.front, required this.back});

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] ?? '',
      front: json['front'] ?? '',
      back: json['back'] ?? '',
    );
  }
}

class ClassMaterial {
  final String id;
  final String title;
  final String url;
  final String fileType; // 'pdf' or 'pptx'
  final int unitNumber;

  ClassMaterial({
    required this.id,
    required this.title,
    required this.url,
    required this.fileType,
    this.unitNumber = 0,
  });
}
