import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/content_models.dart';
import '../constants/unit1_content.dart';
import '../constants/unit1_questions.dart';


class GitHubContentService extends ChangeNotifier {
  static const String _githubUser = 'karinafathima2002-del';
  static const String _githubRepo = 'LEX-LEARN';
  static const String _branch = 'main';
  static const String _token = String.fromEnvironment('GITHUB_TOKEN', defaultValue: '');
  
  static const String _rawBase = 'https://raw.githubusercontent.com/$_githubUser/$_githubRepo/$_branch';

  bool _isLoading = false;
  final List<UnitContent> _units = [];
  final List<ClassMaterial> _materials = []; // New dedicated materials list
  final Map<String, List<QuizSet>> _quizzes = {};
  final Map<String, FlashcardSet> _flashcards = {};

  bool get isLoading => _isLoading;
  List<UnitContent> get units => _units;
  List<ClassMaterial> get materials => _materials; // Getter for materials

  GitHubContentService() {
    fetchAll();
  }

  Future<void> fetchAll({bool force = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final List<UnitContent> fetchedUnits = [];
      _quizzes.clear();
      _flashcards.clear();
      bool dataChanged = false;
      
      // Reduced delays for better responsiveness
      await Future.delayed(const Duration(milliseconds: 500));


      for (int i = 1; i <= 6; i++) {
        // Smaller delay between units
        await Future.delayed(const Duration(milliseconds: 100));
        
        // ── Fetch Main Content ──
        final contentUrl = '$_rawBase/unit$i.txt';
        final caseUrl = '$_rawBase/caselawunit$i.txt';
        final quizUrl = '$_rawBase/quizunit$i.txt';
        final verdictUrl = '$_rawBase/verdictunit$i.txt';
        final flashUrl = '$_rawBase/flashcardsunit$i.txt';
        final matchUrl = '$_rawBase/matchunit$i.txt';

        try {
          final res = await http.get(Uri.parse(contentUrl));
          
          UnitContent? unit;

          if (res.statusCode == 200) {
            final content = res.body;
            unit = await compute(_parseRawDocumentStatic, _ParseParams(i, content));
          } else if (i == 1) {
            // Fallback for Unit 1
            unit = await compute(_parseRawDocumentStatic, _ParseParams(1, unit1RawContent));
            if (unit != null) _applyUnit1StaticMaterials(unit);
          }

          if (unit != null) {
            await _fetchGameData(unit, caseUrl, quizUrl, verdictUrl, flashUrl, matchUrl);
            
            // Add or update the unit in the list immediately
            final existingIdx = _units.indexWhere((u) => u.number == i);
            if (existingIdx != -1) {
              _units[existingIdx] = unit;
            } else {
              _units.add(unit);
              _units.sort((a, b) => a.number.compareTo(b.number));
            }
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error fetching unit $i: $e');
        }
      }

      // ── Fetch Materials from /materials folder ──
      await fetchMaterials();
    } catch (e) {
      debugPrint('Fetch Error: $e');
    } finally {
      // ── Ensure all 6 units exist so they stay unlocked ──
      for (int i = 1; i <= 6; i++) {
        if (!_units.any((u) => u.number == i)) {
          String unitTitle = 'Unit $i';
          if (i == 1) unitTitle = 'Historical Background';
          if (i == 2) unitTitle = 'Making of Constitution';
          if (i == 3) unitTitle = 'Union and Citizenship';
          if (i == 4) unitTitle = 'Fundamental Rights';
          if (i == 5) unitTitle = 'DPSP & Duties';
          if (i == 6) unitTitle = 'Union Executive';

          _units.add(UnitContent(
            id: 'unit$i',
            number: i,
            title: unitTitle,
            description: 'Tap to view content',
            color: _getUnitColorStatic(i),
            topics: [
              Topic(
                id: 'placeholder_$i',
                title: 'Content Coming Soon',
                content: 'We are currently updating the content for Unit $i. Check back shortly!',
                keyPoints: ['Updating soon...'],
              )
            ],
          ));
        }
      }
      _units.sort((a, b) => a.number.compareTo(b.number));
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchGameData(UnitContent unit, String caseUrl, String quizUrl, String verdictUrl, String flashUrl, String matchUrl) async {
    final unitId = unit.id;
    final i = unit.number;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    bool dataChanged = false;
    
    try {
      final results = await Future.wait([
        http.get(Uri.parse(caseUrl)).catchError((_) => http.Response('', 404)),
        http.get(Uri.parse(quizUrl)).catchError((_) => http.Response('', 404)),
        http.get(Uri.parse(verdictUrl)).catchError((_) => http.Response('', 404)),
        http.get(Uri.parse(matchUrl)).catchError((_) => http.Response('', 404)),
        http.get(Uri.parse(flashUrl)).catchError((_) => http.Response('', 404)),
      ]);

      String decodeApiContent(http.Response res) {
        if (res.statusCode != 200) return '';
        return res.body;
      }

      final caseBody = decodeApiContent(results[0]);
      final quizBody = decodeApiContent(results[1]);
      final verdictBody = decodeApiContent(results[2]);
      final matchBody = decodeApiContent(results[3]);
      final flashBody = decodeApiContent(results[4]);

      // 1. Process Case Laws
      if (caseBody.isNotEmpty) {
        final cases = _parseRawDocument(unit.number, caseBody);
        if (cases != null) {
          // ... rest of the merge logic below ...
          // Merge and Deduplicate by Title
          for (var newTopic in cases.topics) {
            String cleanTitle(String t) {
              String s = t.toLowerCase()
                  .replaceAll('⚖️', '').replaceAll('🧠', '')
                  .replaceAll(RegExp(r'case law\s*[-–:]?\s*'), '')
                  .replaceAll(RegExp(r'\(?\d{4}\)?'), '') // Strip year variations
                  .trim();
              int v1 = s.indexOf(' v. ');
              int v2 = s.indexOf(' vs ');
              int v3 = s.indexOf(' case');
              int split = s.length;
              if (v1 != -1 && v1 < split) split = v1;
              if (v2 != -1 && v2 < split) split = v2;
              if (v3 != -1 && v3 < split) split = v3;
              String rootName = s.substring(0, split).replaceAll(RegExp(r'[^a-z0-9]'), '');
              return rootName.isEmpty ? s.replaceAll(RegExp(r'[^a-z0-9]'), '') : rootName;
            }
            final existingIdx = unit.topics.indexWhere(
              (t) => cleanTitle(t.title) == cleanTitle(newTopic.title)
            );
            if (existingIdx != -1) {
              // Update existing topic with better content from caselaw file
              unit.topics[existingIdx] = newTopic;
            } else {
              unit.topics.add(newTopic);
            }
          }
          dataChanged = true;
        }
      }

      // 2. Process Quiz & Verdict
      final List<QuizSet> unitQuizzes = [];

      if (quizBody.isNotEmpty) {
        final questions = _parseQuestionsFromText(unitId, quizBody);
        if (questions.isNotEmpty) {
           unitQuizzes.add(QuizSet(id: '${unitId}_quiz', unitId: unitId, title: 'Quick Quiz', questions: questions));
        }
      }
      
      if (verdictBody.isNotEmpty) {
        final questions = _parseQuestionsFromText(unitId, verdictBody, isVerdict: true);
        if (questions.isNotEmpty) {
           unitQuizzes.add(QuizSet(id: '${unitId}_verdict', unitId: unitId, title: 'Verdict Call', questions: questions));
        }
      }

      // 3. Process Match Pairs
      if (matchBody.isNotEmpty) {
        final questions = _parseMatchFromText(unitId, matchBody);
        if (questions.isNotEmpty) {
           unitQuizzes.add(QuizSet(id: '${unitId}_match', unitId: unitId, title: 'Match Pairs', questions: questions));
        }
      }

      if (unitQuizzes.isNotEmpty) {
        _quizzes[unitId] = unitQuizzes;
        dataChanged = true;
      }

      // 4. Process Flashcards
      if (flashBody.isNotEmpty) {
        final cards = _parseFlashcardsFromText(unitId, flashBody);
        if (cards.isNotEmpty) {
           _flashcards[unitId] = FlashcardSet(id: '${unitId}_fc', unitId: unitId, title: 'Revision Cards', cards: cards);
           dataChanged = true;
        }
      }

      // ── AUTO-GENERATION FALLBACK ──
      // If no quiz was found on GitHub, generate it from the main unit content
      if (!_quizzes.containsKey(unitId) || _quizzes[unitId]!.isEmpty) {
        _autoGenerateMaterials(unit);
        dataChanged = true;
      }
      
      if (dataChanged) notifyListeners();
    } catch (_) {}
  }

  List<QuizQuestion> _parseMatchFromText(String unitId, String text) {
     final List<QuizQuestion> questions = [];
     final lines = text.split('\n');
     for (var line in lines) {
       if (line.trim().isEmpty) continue;
       final parts = line.split('|');
       if (parts.length >= 2) {
         questions.add(QuizQuestion(
           id: 'm_${DateTime.now().millisecondsSinceEpoch}_${questions.length}',
           type: QuizType.matchFollowing,
           question: '${parts[0].trim()} :: ${parts[1].trim()}',
           options: [parts[1].trim()],
           answer: [MatchPair(left: parts[0].trim(), right: parts[1].trim())],
         ));
       }
     }
     return questions;
  }

  List<Flashcard> _parseFlashcardsFromText(String unitId, String text) {
    final List<Flashcard> cards = [];
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      final parts = line.split('|');
      if (parts.length >= 2) {
        cards.add(Flashcard(
          id: 'fc_${DateTime.now().millisecondsSinceEpoch}_${cards.length}',
          front: parts[0].trim(),
          back: parts[1].trim(),
        ));
      }
    }
    return cards;
  }

  List<QuizQuestion> _parseQuestionsFromText(String unitId, String text, {bool isVerdict = false}) {
    final List<QuizQuestion> questions = [];
    final lines = text.split('\n');
    
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      
      final parts = line.split('|');
      List<String> options = [];
      int correctIdx = 0;
      String explanation = 'Correct answer identified.';

      if (parts.length >= 6) {
        // Format: Question | OptA | OptB | OptC | OptD | CorrectIdx | Explanation (Length 7)
        // or Question | OptA | OptB | OptC | OptD | CorrectIdx (Length 6)
        int idxPos = parts.length - 2;
        if (int.tryParse(parts[idxPos].trim()) != null) {
          options = parts.sublist(1, idxPos).map((e) => e.trim()).toList();
          correctIdx = int.tryParse(parts[idxPos].trim()) ?? 0;
          explanation = parts.last.trim();
        } else {
          idxPos = parts.length - 1;
          options = parts.sublist(1, idxPos).map((e) => e.trim()).toList();
          correctIdx = int.tryParse(parts[idxPos].trim()) ?? 0;
        }
      } else if (parts.length == 5 && int.tryParse(parts[3].trim()) != null) {
        // Format: Question | OptA | OptB | CorrectIdx | Explanation
        options = [parts[1].trim(), parts[2].trim()];
        correctIdx = int.tryParse(parts[3].trim()) ?? 0;
        explanation = parts[4].trim();
      } else if (parts.length >= 3) {
        // Original format: Question | OptA, OptB, OptC | CorrectIdx | Explanation
        options = parts[1].split(',').map((e) => e.trim()).toList();
        correctIdx = int.tryParse(parts[2].trim()) ?? 0;
        if (parts.length > 3) explanation = parts[3].trim();
      } else {
        continue;
      }

      questions.add(QuizQuestion(
        id: 'q_${DateTime.now().millisecondsSinceEpoch}_${questions.length}',
        type: isVerdict ? QuizType.trueFalse : QuizType.multipleChoice,
        question: parts[0].trim(),
        options: options.isEmpty ? ['Option A'] : options,
        answer: (correctIdx >= 0 && correctIdx < options.length) ? options[correctIdx] : (options.isNotEmpty ? options[0] : 'Answer'),
        explanation: explanation,
      ));
    }
    return questions;
  }

  /// Fetches all files from the 'materials/' folder in the GitHub repository
  Future<void> fetchMaterials() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      // Using GitHub API to list folder contents
      final apiUrl = 'https://api.github.com/repos/$_githubUser/$_githubRepo/contents/materials';
      
      debugPrint('🔍 Fetching materials from: $apiUrl');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'Cache-Control': 'no-cache',
        },
      );
      
      debugPrint('📡 Materials Response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> files = jsonDecode(response.body);
        _materials.clear();
        
        for (var file in files) {
          final name = file['name'] as String;
          final downloadUrl = file['download_url'] as String;
          
          final lowerName = name.toLowerCase().trim();
          if (lowerName.endsWith('.pdf') || lowerName.endsWith('.pptx') || lowerName.endsWith('.ppt')) {
            // Try to extract unit number from filename (e.g., "Unit1_Intro.pptx")
            final unitMatch = RegExp(r'unit\s*(\d+)', caseSensitive: false).firstMatch(name);
            final unitNum = unitMatch != null ? int.parse(unitMatch.group(1)!) : 0;
            
            _materials.add(ClassMaterial(
              id: file['sha'] ?? name,
              title: name.replaceAll(RegExp(r'\.(pdf|pptx|ppt)$', caseSensitive: false), '').replaceAll('_', ' ').trim(),
              url: downloadUrl,
              fileType: lowerName.endsWith('.pdf') ? 'pdf' : 'pptx',
              unitNumber: unitNum,
            ));
          }
        }
        debugPrint('✅ Found ${_materials.length} materials');
        notifyListeners();
      } else {
        debugPrint('❌ Failed to fetch materials: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching materials: $e');
    }
  }

  /// Manual refresh for everything
  Future<void> refresh() {
    return fetchAll(force: true);
  }

  /// Saves the user score to a JSON file in your GitHub repository
  Future<bool> saveScoreToGitHub(String userName, int score, String quizTitle) async {
    try {
      debugPrint('Uploading score for $userName: $score in $quizTitle to GitHub...');
      // Note: Real GitHub API implementation would go here
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────
  // UNIT 1 — Static high-quality materials
  // ─────────────────────────────────────────────────────────
  void _applyUnit1StaticMaterials(UnitContent unit) {
    // Verdict Call (trueFalse questions)
    final verdictSet = QuizSet(
      id: 'verdict_unit1',
      unitId: 'unit1',
      title: 'Verdict Call',
      questions: unit1VerdictQuestions,
    );

    // Match Pairs
    final matchSet = QuizSet(
      id: 'match_unit1',
      unitId: 'unit1',
      title: 'Match Pairs',
      questions: unit1MatchQuestions,
    );

    _quizzes['unit1'] = [verdictSet, matchSet];
    _flashcards['unit1'] = FlashcardSet(
      id: 'main_unit1',
      unitId: 'unit1',
      title: 'Revision Flashcards',
      cards: unit1Flashcards,
    );
  }

  // ─────────────────────────────────────────────────────────
  // AUTO-GENERATE for other units (units 2-6)
  // ─────────────────────────────────────────────────────────
  void _autoGenerateMaterials(UnitContent unit) {
    List<QuizQuestion> verdictQuestions = [];
    List<QuizQuestion> matchQuestions = [];
    List<Flashcard> flashcards = [];
    
    for (var topic in unit.topics) {
      final sentences = topic.content
        .split(RegExp(r'\. |\n'))
        .map((s) => s.trim())
        .where((s) => s.length > 40 && !s.startsWith('•') && !s.startsWith('–'))
        .toList();

      // Generate flashcard per topic
      if (sentences.isNotEmpty) {
        flashcards.add(Flashcard(
          id: 'fc_${topic.id}',
          front: topic.title,
          back: sentences.take(3).join('. '),
        ));
      }

      // Generate Verdict Call from topic sentences
      for (int i = 0; i < sentences.length && verdictQuestions.length < 15; i++) {
        final s = sentences[i];
        verdictQuestions.add(QuizQuestion(
          id: 'v_${topic.id}_$i',
          type: QuizType.trueFalse,
          question: s,
          options: ['VALID', 'INVALID'],
          answer: 'VALID',
          explanation: 'This is a factual statement from the study material on ${topic.title}.',
        ));
      }

      // Generate Match pairs from bullet points in the topic
      final bullets = topic.content.split('\n')
        .where((l) => l.trim().startsWith('•'))
        .map((l) => l.trim().replaceFirst('•', '').trim())
        .where((l) => l.length > 3 && l.length < 40)
        .toList();

      if (bullets.length >= 2 && matchQuestions.length < 8) {
        matchQuestions.add(QuizQuestion(
          id: 'm_${topic.id}',
          type: QuizType.matchFollowing,
          question: '${topic.title} :: ${bullets.first}',
          options: [bullets.first], 
          answer: [MatchPair(left: topic.title, right: bullets.first)],
        ));
      }
    }

    if (verdictQuestions.isNotEmpty) {
      verdictQuestions.shuffle();
      _quizzes[unit.id] = [
        QuizSet(id: 'verdict_${unit.id}', unitId: unit.id, title: 'Verdict Call', questions: verdictQuestions.take(15).toList()),
        if (matchQuestions.length >= 2)
          QuizSet(id: 'match_${unit.id}', unitId: unit.id, title: 'Match the Following', questions: matchQuestions),
      ];
    }
    if (flashcards.isNotEmpty) {
      _flashcards[unit.id] = FlashcardSet(
        id: 'auto_${unit.id}',
        unitId: unit.id,
        title: 'Quick Revision',
        cards: flashcards,
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // PARSERS
  // ─────────────────────────────────────────────────────────
  static UnitContent? _parseRawDocumentStatic(_ParseParams params) {
    return _parseRawDocumentInternal(params.unitNum, params.rawText);
  }

  static UnitContent? _parseRawDocumentInternal(int unitNum, String rawText) {
    if (rawText.contains(RegExp(r'_{10,}'))) {
      return _parseUnderscoreFormatInternal(unitNum, rawText);
    } else if (rawText.contains('---')) {
      return _parseDashFormatInternal(unitNum, rawText);
    }
    
    // FALLBACK: Simple format (Split by double newlines)
    return _parseSimpleFormatInternal(unitNum, rawText);
  }

  UnitContent? _parseRawDocument(int unitNum, String rawText) => _parseRawDocumentInternal(unitNum, rawText);

  static UnitContent? _parseSimpleFormatInternal(int unitNum, String rawText) {
    final List<Topic> topics = [];
    final sections = rawText.split(RegExp(r'\n\n+'));
    
    for (var section in sections) {
      final trimmed = section.trim();
      if (trimmed.isEmpty) continue;
      
      final lines = trimmed.split('\n');
      final title = lines[0].trim();
      final body = lines.sublist(1).join('\n').trim();
      
      if (body.isNotEmpty) {
        topics.add(Topic(
          id: 'u${unitNum}_s${topics.length}',
          title: title,
          content: body,
          keyPoints: _extractKeyPointsStatic(body),
        ));
      }
    }
    
    if (topics.isEmpty) return null;
    return UnitContent(
      id: 'unit$unitNum',
      number: unitNum,
      title: 'Unit $unitNum Content',
      description: 'Fetched from GitHub',
      color: _getUnitColorStatic(unitNum),
      topics: topics,
    );
  }

  static UnitContent? _parseUnderscoreFormatInternal(int unitNum, String rawText) {
    final List<Topic> topics = [];
    
    // Split by underscores OR by "Part X" headers that start on a new line
    final sections = rawText.split(RegExp(r'(?:_{10,})|(?:\n(?=Part \d+))'));
    
    String unitTitle = 'Unit $unitNum';
    
    for (int i = 0; i < sections.length; i++) {
      final trimmed = sections[i].trim();
      if (trimmed.isEmpty) continue;
      
      final lines = trimmed.split('\n');
      if (lines.isEmpty) continue;
      String title = lines[0].trim();
      
      final cleanTitle = title
          .replaceAll('UNIT $unitNum – ', '')
          .replaceAll(RegExp(r'UNIT \d+ – '), '')
          .trim();

      if (i == 0 && unitTitle == 'Unit $unitNum' && cleanTitle.isNotEmpty) {
        unitTitle = cleanTitle;
      }

      // Check if this section contains multiple case laws indicated by 🧠
      if (trimmed.contains('🧠') && !cleanTitle.contains('🧠')) {
        final caseSections = trimmed.split(RegExp(r'\n(?=🧠)'));
        for (var cs in caseSections) {
          final caseLines = cs.trim().split('\n');
          if (caseLines.isEmpty) continue;
          final caseTitle = caseLines[0].trim();
          topics.add(Topic(
            id: '${unitNum}_case_${topics.length}',
            title: caseTitle,
            content: caseLines.sublist(1).join('\n').trim(),
            keyPoints: _extractKeyPointsStatic(cs),
            videoUrl: null,
          ));
        }
        continue;
      }

      bool isSubSection = cleanTitle.toLowerCase().contains('illustration') || 
                          cleanTitle.toLowerCase().contains('example');

      if (isSubSection && topics.isNotEmpty) {
        final lastTopic = topics.last;
        final subBody = lines.sublist(1).join('\n').trim();
        // Attach under the previous topic and collect any new key points from this subsection
        final newKeyPoints = _extractKeyPointsStatic(subBody);
        topics[topics.length - 1] = Topic(
          id: lastTopic.id,
          title: lastTopic.title,
          content: '${lastTopic.content}\n\n**${cleanTitle.toUpperCase()}**\n$subBody',
          keyPoints: [...lastTopic.keyPoints, ...newKeyPoints],
          videoUrl: lastTopic.videoUrl,
        );
      } else if (cleanTitle.isNotEmpty) {
        final body = lines.length > 1 ? lines.sublist(1).join('\n').trim() : '';
        if (body.length > 5) { // Relaxed requirement for small snippets
          topics.add(Topic(
            id: '${unitNum}_${topics.length}',
            title: cleanTitle,
            content: body,
            keyPoints: _extractKeyPointsStatic(body),
            videoUrl: null,
          ));
        }
      }
    }

    if (topics.isEmpty) return null;

    return UnitContent(
      id: 'unit$unitNum',
      number: unitNum,
      title: unitTitle,
      description: 'Historical Background & Law',
      color: _getUnitColorStatic(unitNum),
      topics: topics,
    );
  }

  static UnitContent? _parseDashFormatInternal(int unitNum, String rawText) {
    final List<Topic> topics = [];
    final sections = rawText.split(RegExp(r'---+\s*'));
    String unitTitle = 'Unit $unitNum';

    for (var section in sections) {
      final trimmed = section.trim();
      if (trimmed.isEmpty) continue;

      final lines = trimmed.split('\n');
      final header = lines[0].trim().toUpperCase().replaceAll('-', '').trim();
      final body = lines.sublist(1).join('\n').trim();

      if (header.startsWith('TOPIC')) {
        final title = header.replaceFirst('TOPIC:', '').replaceFirst('TOPIC', '').trim();
        topics.add(Topic(
          id: 'u${unitNum}_t${topics.length}',
          title: title.isEmpty ? 'Overview' : title,
          content: body,
          keyPoints: _extractKeyPointsStatic(body),
        ));
        if (unitTitle.contains('Unit')) unitTitle = title.isEmpty ? unitTitle : title;
      }
    }
    if (topics.isEmpty) return null;

    return UnitContent(
      id: 'unit$unitNum',
      number: unitNum,
      title: unitTitle,
      description: 'Historical Background & Law',
      color: _getUnitColorStatic(unitNum),
      topics: topics,
    );
  }

  static List<String> _extractKeyPointsStatic(String content) {
    if (content.isEmpty) return [];
    final lines = content.split('\n');
    final List<String> points = [];
    
    // 1. Try to find explicit bullets or structured markers
    for (var l in lines) {
      final t = l.trim();
      if (t.isEmpty) continue;
      
      // Standard bullets plus fact markers
      if (t.startsWith('•') || t.startsWith('-') || t.startsWith('⚡') || t.startsWith('📌') || t.startsWith('🚨') || t.startsWith('🎯') || t.startsWith('🔍')) {
        final p = t.replaceFirst(RegExp(r'^[•\-\⚡\📌\🚨\🎯\🔍]\s*'), '').trim();
        if (p.isNotEmpty) points.add(p);
      } 
      // Factual markers (Facts: Issue: etc) - only if they contain actual content after the colon
      else if (t.contains(':') && t.length > 20 && t.length < 200) {
        if (t.startsWith('Facts') || t.startsWith('Judgment') || t.startsWith('Significance') || t.startsWith('Issue') || t.startsWith('Key Concept')) {
           points.add(t.trim());
        }
      }
    }

    // 2. Fallback: If very few points found, identify "Goal/Action" sentences
    if (points.length < 3) {
      final paragraphs = content.split('\n\n');
      int count = 0;
      for (var p in paragraphs) {
        if (count > 8) break; // Limit scanning to top paragraphs for speed
        final cleanP = p.trim();
        if (cleanP.length < 50) continue;
        count++;
        
        // Take the first sentence of the paragraph
        final sentences = cleanP.split(RegExp(r'\. |\? '));
        if (sentences.isNotEmpty) {
          final first = sentences[0].trim();
          if (first.length > 30 && first.length < 200) {
            // Check if it sounds like a feature or outcome
            final lower = first.toLowerCase();
            if (lower.contains('was') || lower.contains('became') || lower.contains('introduced') || 
                lower.contains('created') || lower.contains('aimed') || lower.contains('established') ||
                lower.contains('abolished') || lower.contains('transformed')) {
              if (!points.contains(first)) points.add(first);
            }
          }
        }
      }
    }

    return points;
  }

  static String _getUnitColorStatic(int n) {
    const caps = ['#1E3A5F', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899'];
    return caps[(n - 1) % caps.length];
  }

  List<QuizSet> quizzesForUnit(String unitId) => _quizzes[unitId] ?? [];
  FlashcardSet? flashcardsForUnit(String unitId) => _flashcards[unitId];
}

class _ParseParams {
  final int unitNum;
  final String rawText;
  _ParseParams(this.unitNum, this.rawText);
}
