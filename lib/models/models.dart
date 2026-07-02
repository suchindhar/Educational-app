// lib/models/models.dart

class Unit {
  final String id;
  final int number;
  final String title;
  final String description;
  final String color;
  final bool isPublished;
  final List<Topic> topics;
  final List<CaseLaw> caseLaws;
  final List<QuizQuestion> questions;
  final String? videoUrl;

  Unit({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.color,
    this.isPublished = true,
    this.topics = const [],
    this.caseLaws = const [],
    this.questions = const [],
    this.videoUrl,
  });

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'] ?? '',
      number: map['number'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      color: map['color'] ?? '#6B9080',
      isPublished: map['is_published'] ?? true,
      topics: (map['topics'] as List? ?? [])
          .map((t) => Topic.fromMap(t))
          .toList(),
      caseLaws: (map['case_laws'] as List? ?? [])
          .map((c) => CaseLaw.fromMap(c))
          .toList(),
      questions: (map['questions'] as List? ?? [])
          .map((q) => QuizQuestion.fromMap(q))
          .toList(),
      videoUrl: map['video_url'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'number': number,
        'title': title,
        'description': description,
        'color': color,
        'is_published': isPublished,
        'video_url': videoUrl,
      };
}

class Topic {
  final String id;
  final String unitId;
  final String title;
  final String content;
  final List<String> keyPoints;
  final List<String> articles;
  final String? pdfUrl;
  final String? videoUrl;
  final int orderIndex;

  Topic({
    required this.id,
    required this.unitId,
    required this.title,
    required this.content,
    this.keyPoints = const [],
    this.articles = const [],
    this.pdfUrl,
    this.videoUrl,
    this.orderIndex = 0,
  });

  factory Topic.fromMap(Map<String, dynamic> map) {
    return Topic(
      id: map['id'] ?? '',
      unitId: map['unit_id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      keyPoints: List<String>.from(map['key_points'] ?? []),
      articles: List<String>.from(map['articles'] ?? []),
      pdfUrl: map['pdf_url'],
      videoUrl: map['video_url'],
      orderIndex: map['order_index'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'unit_id': unitId,
        'title': title,
        'content': content,
        'key_points': keyPoints,
        'articles': articles,
        'pdf_url': pdfUrl,
        'video_url': videoUrl,
        'order_index': orderIndex,
      };
}

class CaseLaw {
  final String id;
  final String unitId;
  final String name;
  final String year;
  final String court;
  final String facts;
  final String held;
  final String significance;
  final List<String> relatedArticles;

  CaseLaw({
    required this.id,
    required this.unitId,
    required this.name,
    required this.year,
    required this.court,
    required this.facts,
    required this.held,
    required this.significance,
    this.relatedArticles = const [],
  });

  factory CaseLaw.fromMap(Map<String, dynamic> map) {
    return CaseLaw(
      id: map['id'] ?? '',
      unitId: map['unit_id'] ?? '',
      name: map['name'] ?? '',
      year: map['year'] ?? '',
      court: map['court'] ?? '',
      facts: map['facts'] ?? '',
      held: map['held'] ?? '',
      significance: map['significance'] ?? '',
      relatedArticles: List<String>.from(map['related_articles'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'unit_id': unitId,
        'name': name,
        'year': year,
        'court': court,
        'facts': facts,
        'held': held,
        'significance': significance,
        'related_articles': relatedArticles,
      };
}

class QuizQuestion {
  final String id;
  final String unitId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String type; // 'mcq', 'truefalse', 'match', 'flashcard'
  final int difficulty;
  final String? caseName;

  QuizQuestion({
    required this.id,
    required this.unitId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.type = 'mcq',
    this.difficulty = 1,
    this.caseName,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      unitId: map['unit_id'] ?? '',
      question: map['question'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correct_index'] ?? 0,
      explanation: map['explanation'] ?? '',
      type: map['type'] ?? 'mcq',
      difficulty: map['difficulty'] ?? 1,
      caseName: map['case_name'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'unit_id': unitId,
        'question': question,
        'options': options,
        'correct_index': correctIndex,
        'explanation': explanation,
        'type': type,
        'difficulty': difficulty,
        'case_name': caseName,
      };
}

class MatchPair {
  final String id;
  final String left;
  final String right;

  MatchPair({required this.id, required this.left, required this.right});
}

class UserProgress {
  final String unitId;
  int xpEarned;
  bool isUnlocked;
  DateTime? completedAt;
  int streakDays;

  UserProgress({
    required this.unitId,
    this.xpEarned = 0,
    this.isUnlocked = false,
    this.completedAt,
    this.streakDays = 0,
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      unitId: map['unit_id'] ?? '',
      xpEarned: map['xp_earned'] ?? 0,
      isUnlocked: map['is_unlocked'] ?? false,
      completedAt: map['completed_at'] != null
          ? DateTime.tryParse(map['completed_at'])
          : null,
    );
  }
}

enum GameMode { flashcards, quiz, match, verdict, caseLaw }
