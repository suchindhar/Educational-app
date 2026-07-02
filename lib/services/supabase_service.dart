// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../data/local_content.dart';
import 'dart:io';
import 'dart:math';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ─── AUTH ───────────────────────────────────────────────────
  static Future<AuthResponse> signUp(
      String email, String password, String name) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static User? get currentUser {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }
  static String get userName =>
      currentUser?.userMetadata?['full_name'] ?? 'Scholar';
  static Future<void> signOut() => _client.auth.signOut();

  // ─── CONTENT ────────────────────────────────────────────────
  static Future<List<Unit>> getUnits() async {
    // Returning local content directly as requested
    return LocalContent.units;
  }

  static Future<List<Topic>> getTopics(String unitId) async {
    final unit = LocalContent.units.firstWhere((u) => u.id == unitId,
        orElse: () => _seedUnits().firstWhere((u) => u.id == unitId));
    return unit.topics;
  }

  static Future<List<CaseLaw>> getCaseLaws(String unitId) async {
    final unit = LocalContent.units.firstWhere((u) => u.id == unitId,
        orElse: () => _seedUnits().firstWhere((u) => u.id == unitId));
    return unit.caseLaws;
  }

  static Future<List<QuizQuestion>> getRandomQuestions(
    String unitId, {
    int count = 10,
    String? type,
  }) async {
    try {
      var query =
          _client.from('questions').select().eq('unit_id', unitId);
      if (type != null) query = query.eq('type', type);
      final response = await query;
      final all = (response as List)
          .map((q) => QuizQuestion.fromMap(q))
          .toList();
      all.shuffle(Random());
      return all.take(count).toList();
    } catch (_) {
      return _seedQuestions(unitId, count: count);
    }
  }

  // ─── FILE UPLOAD (Supabase Storage – 1 GB free) ─────────────
  @Deprecated('Use GitHubStorageService for free storage')
  static Future<String?> uploadFile(
      File file, String unitId, String topicId) async {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      final fileName =
          '${unitId}_${topicId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final path = 'unit_materials/$fileName';
      
      await _client.storage.from('pdfs').upload(path, file);
      final url = _client.storage.from('pdfs').getPublicUrl(path);
      
      await _client
          .from('topics')
          .update({'pdf_url': url}).eq('id', topicId);
      return url;
    } catch (e) {
      return null;
    }
  }

  /// Updates only the database record with a file URL (useful for GitHub-hosted files)
  static Future<bool> updateTopicFileUrl(String topicId, String url) async {
    try {
      await _client.from('topics').update({'pdf_url': url}).eq('id', topicId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─── PROGRESS ───────────────────────────────────────────────
  static Future<Map<String, UserProgress>> getUserProgress() async {
    final user = currentUser;
    if (user == null) return {};
    try {
      final response = await _client
          .from('user_progress')
          .select()
          .eq('user_id', user.id);
      final map = <String, UserProgress>{};
      for (final row in (response as List)) {
        final p = UserProgress.fromMap(row);
        map[p.unitId] = p;
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveProgress(
      String unitId, int xp, bool unlockNext) async {
    final user = currentUser;
    if (user == null) return;
    try {
      await _client.from('user_progress').upsert({
        'user_id': user.id,
        'unit_id': unitId,
        'xp_earned': xp,
        'is_unlocked': true,
        'completed_at': DateTime.now().toIso8601String(),
      });
      if (unlockNext) {
        final currentUnit = await _client
            .from('units')
            .select('number')
            .eq('id', unitId)
            .single();
        final nextUnit = await _client
            .from('units')
            .select('id')
            .eq('number', (currentUnit['number'] as int) + 1)
            .maybeSingle();
        if (nextUnit != null) {
          await _client.from('user_progress').upsert({
            'user_id': user.id,
            'unit_id': nextUnit['id'],
            'is_unlocked': true,
          });
        }
      }
    } catch (_) {}
  }

  // ─── DAILY LEADERBOARD ──────────────────────────────────────
  static Future<void> submitScore(String challengeId, int score) async {
    final user = currentUser;
    if (user == null) return;
    try {
      final challenge = await _client
          .from('daily_challenges')
          .select('leaderboard')
          .eq('id', challengeId)
          .single();
      List<dynamic> lb = challenge['leaderboard'] ?? [];
      final idx = lb.indexWhere((e) => e['user_id'] == user.id);
      final entry = {
        'user_id': user.id,
        'name': userName,
        'score': score,
        'timestamp': DateTime.now().toIso8601String(),
      };
      if (idx >= 0) {
        if (score > (lb[idx]['score'] ?? 0)) lb[idx] = entry;
      } else {
        lb.add(entry);
      }
      lb.sort((a, b) =>
          (b['score'] ?? 0).compareTo(a['score'] ?? 0));
      if (lb.length > 50) lb = lb.sublist(0, 50);
      await _client
          .from('daily_challenges')
          .update({'leaderboard': lb}).eq('id', challengeId);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getGlobalLeaderboard() async {
    try {
      final response = await _client
          .from('user_progress')
          .select('user_id, xp_earned, profiles(full_name)');
      
      final Map<String, Map<String, dynamic>> aggregated = {};
      for (final row in (response as List)) {
        final id = row['user_id'];
        final name = row['profiles']?['full_name'] ?? 'Scholar';
        final xp = row['xp_earned'] ?? 0;
        
        if (aggregated.containsKey(id)) {
          aggregated[id]!['xp'] = (aggregated[id]!['xp'] as int) + (xp as int);
        } else {
          aggregated[id] = {'name': name, 'xp': xp};
        }
      }

      final list = aggregated.values.toList();
      list.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
      return list.take(50).toList();
    } catch (e) {
      return [
        {'name': 'Arjun Mehta', 'xp': 1450},
        {'name': 'Priya Sharma', 'xp': 1220},
        {'name': 'Rahul V.', 'xp': 980},
        {'name': 'Advocate Anjali', 'xp': 850},
      ];
    }
  }

  // ─── ADMIN ──────────────────────────────────────────────────
  static Future<void> insertQuestion(Map<String, dynamic> data) async {
    await _client.from('questions').insert(data);
  }

  static Future<void> insertCaseLaw(Map<String, dynamic> data) async {
    await _client.from('case_laws').insert(data);
  }

  static Future<void> insertTopic(Map<String, dynamic> data) async {
    await _client.from('topics').insert(data);
  }

  // ─── SEED DATA (fallback when Supabase not configured) ──────
  static List<Unit> _seedUnits() {
    return [
      Unit(
        id: 'unit1',
        number: 1,
        title: 'Historical Background of Indian Constitution',
        description:
            'Trace the evolution from Regulating Act 1773 to Independence Act 1947',
        color: '#6B9080',
        topics: _seedTopicsUnit1(),
        caseLaws: [],
        questions: _seedQuestionsUnit1(),
      ),
      Unit(
        id: 'unit2',
        number: 2,
        title: 'Making of Constitution & Salient Features',
        description: 'Drafting Committee, Sources, Preamble, Berubari, Kesavananda',
        color: '#BC6C25',
        topics: _seedTopicsUnit2(),
        caseLaws: _seedCaseLawsUnit2(),
        questions: _seedQuestionsUnit2(),
      ),
      Unit(
        id: 'unit3',
        number: 3,
        title: 'Union and Citizenship',
        description: 'Articles 1–11, Formation of States, Citizenship Act 1955',
        color: '#606C38',
        topics: [],
        caseLaws: [],
        questions: _seedQuestionsUnit3(),
      ),
      Unit(
        id: 'unit4',
        number: 4,
        title: 'Fundamental Rights (Part III)',
        description: 'Articles 12–35, Doctrines, Landmark cases',
        color: '#9C6644',
        topics: [],
        caseLaws: _seedCaseLawsUnit4(),
        questions: _seedQuestionsUnit4(),
      ),
      Unit(
        id: 'unit5',
        number: 5,
        title: 'Directive Principles & Fundamental Duties',
        description: 'Part IV, Art 51A, Relation between FR & DPSP',
        color: '#7F5539',
        topics: [],
        caseLaws: [],
        questions: _seedQuestionsUnit5(),
      ),
      Unit(
        id: 'unit6',
        number: 6,
        title: 'Amendment & Basic Structure',
        description: 'Article 368, Types of amendment, Basic Structure Doctrine',
        color: '#4A6FA5',
        topics: [],
        caseLaws: _seedCaseLawsUnit6(),
        questions: _seedQuestionsUnit6(),
      ),
    ];
  }

  static List<Topic> _seedTopicsUnit1() => [
        Topic(
          id: 't1_1', unitId: 'unit1',
          title: 'Regulating Act 1773',
          content:
              'The Regulating Act of 1773 was the first step taken by the British Government to control and regulate the affairs of the East India Company in India. It was the first act of British Parliament to assume sovereign control over the company. Key provisions included: establishment of a Governor-General and a Council of four members at Calcutta; establishment of a Supreme Court at Calcutta (1774); prohibition of servants of the Company from engaging in private trade.',
          keyPoints: [
            'First Parliamentary control over EIC',
            'Created post of Governor-General (Warren Hastings first)',
            'Established Supreme Court at Calcutta in 1774',
            'Prohibited servants from private trade or accepting gifts',
          ],
          articles: [],
          orderIndex: 1,
        ),
        Topic(
          id: 't1_2', unitId: 'unit1',
          title: "Pitt's India Act 1784",
          content:
              "Pitt's India Act of 1784 rectified the defects of the Regulating Act. It established a system of double government by establishing a Board of Control. The Act distinguished between the commercial and political functions of the Company.",
          keyPoints: [
            'Created Board of Control with 6 members',
            'Distinguished commercial vs political functions',
            'British Government supremacy established',
            'Court of Directors retained commercial functions',
          ],
          articles: [],
          orderIndex: 2,
        ),
        Topic(
          id: 't1_3', unitId: 'unit1',
          title: 'Charter Acts (1793–1853)',
          content:
              'A series of acts that progressively increased Crown control. Charter Act 1813 ended EIC trade monopoly except for tea and China trade. Charter Act 1833 made Governor-General of Bengal the Governor-General of India (first: Lord William Bentinck). Charter Act 1853 introduced open competition for civil services.',
          keyPoints: [
            '1793: Powers of Board of Control enlarged',
            '1813: Trade monopoly broken (except tea/China)',
            '1833: Governor-General of India created',
            '1853: Open competition for ICS introduced',
          ],
          articles: [],
          orderIndex: 3,
        ),
        Topic(
          id: 't1_4', unitId: 'unit1',
          title: 'Government of India Act 1858',
          content:
              'Passed after the Revolt of 1857, this act transferred power from EIC to the British Crown. India was now to be governed by and in the name of Her Majesty. Office of Secretary of State for India was created with a 15-member Council of India.',
          keyPoints: [
            'Transfer of power from EIC to British Crown',
            'Governor-General became Viceroy of India',
            'Secretary of State created with India Council',
            'Direct Crown rule established – end of Company rule',
          ],
          articles: [],
          orderIndex: 4,
        ),
        Topic(
          id: 't1_5', unitId: 'unit1',
          title: 'Government of India Act 1935',
          content:
              'The most detailed constitutional document for British India. Abolished dyarchy at the provinces and introduced provincial autonomy. Proposed an All India Federation (never came into being). Introduced dyarchy at the Centre. Established Federal Court, RBI, Federal Public Service Commission.',
          keyPoints: [
            'Provincial autonomy introduced',
            'Dyarchy abolished at provinces, introduced at Centre',
            'Federal Court established',
            'RBI, FPSC established',
            'Bicameral legislature in 6 provinces',
          ],
          articles: [],
          orderIndex: 5,
        ),
        Topic(
          id: 't1_6', unitId: 'unit1',
          title: 'Indian Independence Act 1947 & Constituent Assembly',
          content:
              'Passed on 18 July 1947, it partitioned British India into two independent dominions: India and Pakistan. India became independent on 15 August 1947. The Constituent Assembly was set up under Cabinet Mission Plan 1946. It had 299 members. Dr B.R. Ambedkar was Chairman of the Drafting Committee. Constitution adopted on 26 November 1949 and came into force on 26 January 1950.',
          keyPoints: [
            'Two independent dominions: India & Pakistan',
            'Independence: 15 August 1947',
            'Constituent Assembly under Cabinet Mission Plan 1946',
            'Drafting Committee: Chairman Dr B.R. Ambedkar',
            'Constitution adopted: 26 Nov 1949',
            'Constitution in force: 26 Jan 1950',
          ],
          articles: [],
          orderIndex: 6,
        ),
      ];

  static List<Topic> _seedTopicsUnit2() => [
        Topic(
          id: 't2_1', unitId: 'unit2',
          title: 'Drafting Committee & Sources',
          content:
              'The Drafting Committee was appointed on 29 August 1947 with Dr B.R. Ambedkar as Chairman. The Constitution drew heavily from different sources: Government of India Act 1935 (structural framework), UK Constitution (parliamentary system, rule of law), US Constitution (fundamental rights, judicial review), Irish Constitution (DPSP), Canadian Constitution (federation with strong centre), Australian Constitution (concurrent list).',
          keyPoints: [
            'Drafting Committee: 29 Aug 1947',
            'GOI Act 1935 – structural backbone',
            'UK – Parliamentary democracy, Rule of Law',
            'USA – FR, Judicial Review, Preamble',
            'Ireland – DPSP',
            'Canada – Strong Centre Federation',
            'Australia – Concurrent List',
          ],
          articles: [],
          orderIndex: 1,
        ),
        Topic(
          id: 't2_2', unitId: 'unit2',
          title: 'Preamble of the Constitution',
          content:
              'The Preamble is the introduction to the Constitution. It declares India to be a Sovereign, Socialist, Democratic, Secular Republic. "Socialist" and "Secular" were added by 42nd Amendment 1976. The Preamble is not enforceable in court but is a key to understanding the Constitution (Berubari Union case).',
          keyPoints: [
            'Sovereign, Socialist, Secular, Democratic, Republic',
            'Socialist & Secular added by 42nd Amendment (1976)',
            'Justice: social, economic, political',
            'Liberty of thought, expression, belief, faith, worship',
            'Equality of status and opportunity',
            'Fraternity – dignity & unity of nation',
          ],
          articles: [],
          orderIndex: 2,
        ),
      ];

  static List<CaseLaw> _seedCaseLawsUnit2() => [
        CaseLaw(
          id: 'cl2_1', unitId: 'unit2',
          name: 'Berubari Union Case',
          year: '1960',
          court: 'Supreme Court of India',
          facts:
              'Question arose whether cession of Berubari Union to Pakistan required a constitutional amendment.',
          held:
              'Preamble is not a part of the Constitution and cannot be used to override express provisions. However, it is a key to understanding the spirit of the Constitution.',
          significance:
              'Preamble cannot be used to give wider meaning to constitutional provisions. Later overruled in Kesavananda.',
          relatedArticles: [],
        ),
        CaseLaw(
          id: 'cl2_2', unitId: 'unit2',
          name: 'Kesavananda Bharati v. State of Kerala',
          year: '1973',
          court: 'Supreme Court of India (13-judge bench)',
          facts:
              'Petitioner challenged the Kerala land reform laws as violating fundamental rights. Also questioned Parliament\'s power to amend the Constitution.',
          held:
              'Parliament can amend any part of the Constitution including Fundamental Rights but cannot destroy the "Basic Structure" of the Constitution. Preamble is part of the Constitution.',
          significance:
              'Established the Basic Structure Doctrine. Most important constitutional case in Indian history.',
          relatedArticles: ['Article 368', 'Article 13'],
        ),
      ];

  static List<CaseLaw> _seedCaseLawsUnit4() => [
        CaseLaw(
          id: 'cl4_1', unitId: 'unit4',
          name: 'A.K. Gopalan v. State of Madras',
          year: '1950',
          court: 'Supreme Court of India',
          facts:
              'Petitioner was detained under Preventive Detention Act. He challenged it as violating Articles 19, 21 and 22.',
          held:
              'Held that each article of Part III is independent of others. Procedure established by law in Art. 21 means procedure prescribed by statute, not natural justice.',
          significance:
              'Took a narrow view of Art. 21. Later overruled by Maneka Gandhi case.',
          relatedArticles: ['Article 19', 'Article 21', 'Article 22'],
        ),
        CaseLaw(
          id: 'cl4_2', unitId: 'unit4',
          name: 'Maneka Gandhi v. Union of India',
          year: '1978',
          court: 'Supreme Court of India',
          facts:
              'Petitioner\'s passport was impounded without giving reasons. She challenged it under Article 21.',
          held:
              '"Procedure established by law" must be fair, just and reasonable. Overruled A.K. Gopalan. Articles 14, 19 and 21 are not mutually exclusive but form a golden triangle.',
          significance:
              'Expanded scope of Art. 21 enormously. Right to life includes right to live with dignity.',
          relatedArticles: ['Article 14', 'Article 19', 'Article 21'],
        ),
        CaseLaw(
          id: 'cl4_3', unitId: 'unit4',
          name: 'Golaknath v. State of Punjab',
          year: '1967',
          court: 'Supreme Court of India',
          facts:
              'Punjab Security of Land Tenures Act was challenged as violating fundamental rights.',
          held:
              'Parliament cannot amend Fundamental Rights at all. FRs are given a transcendental and immutable position.',
          significance:
              'Was later overruled by Kesavananda Bharati case in 1973.',
          relatedArticles: ['Article 13', 'Article 368'],
        ),
      ];

  static List<CaseLaw> _seedCaseLawsUnit6() => [
        CaseLaw(
          id: 'cl6_1', unitId: 'unit6',
          name: 'Minerva Mills v. Union of India',
          year: '1980',
          court: 'Supreme Court of India',
          facts:
              'Provisions of 42nd Amendment that gave Parliament unlimited power to amend the Constitution were challenged.',
          held:
              'Struck down clauses of 42nd Amendment that gave Parliament absolute power to amend. Harmony between FR and DPSP is part of Basic Structure.',
          significance:
              'Reinforced Basic Structure doctrine. Balance between FR and DPSP is essential.',
          relatedArticles: ['Article 31C', 'Article 368'],
        ),
        CaseLaw(
          id: 'cl6_2', unitId: 'unit6',
          name: 'I.R. Coelho v. State of Tamil Nadu',
          year: '2007',
          court: 'Supreme Court of India (9-judge bench)',
          facts:
              'Laws placed in 9th Schedule after 24 April 1973 were challenged for violating fundamental rights.',
          held:
              'Laws in 9th Schedule are not immune from judicial review if they violate Basic Structure or damage FR under Articles 14, 19, 21.',
          significance:
              'No law is beyond judicial review if it damages Basic Structure.',
          relatedArticles: ['Article 31B', 'Article 14', 'Article 19'],
        ),
      ];

  static List<QuizQuestion> _seedQuestions(String unitId,
      {int count = 10}) {
    final all = _allSeedQuestions();
    final filtered = all.where((q) => q.unitId == unitId).toList();
    if (filtered.isEmpty) return all.take(count).toList();
    filtered.shuffle(Random());
    return filtered.take(count).toList();
  }

  static List<QuizQuestion> _seedQuestionsUnit1() =>
      _allSeedQuestions().where((q) => q.unitId == 'unit1').toList();
  static List<QuizQuestion> _seedQuestionsUnit2() =>
      _allSeedQuestions().where((q) => q.unitId == 'unit2').toList();
  static List<QuizQuestion> _seedQuestionsUnit3() =>
      _allSeedQuestions().where((q) => q.unitId == 'unit3').toList();
  static List<QuizQuestion> _seedQuestionsUnit4() =>
      _allSeedQuestions().where((q) => q.unitId == 'unit4').toList();
  static List<QuizQuestion> _seedQuestionsUnit5() =>
      _allSeedQuestions().where((q) => q.unitId == 'unit5').toList();
  static List<QuizQuestion> _seedQuestionsUnit6() =>
      _allSeedQuestions().where((q) => q.unitId == 'unit6').toList();

  static List<QuizQuestion> _allSeedQuestions() => [
        // UNIT 1
        QuizQuestion(id: 'q1_1', unitId: 'unit1', type: 'mcq',
            question: 'The Regulating Act was passed in which year?',
            options: ['1773', '1784', '1813', '1858'],
            correctIndex: 0,
            explanation: 'The Regulating Act of 1773 was the first British Parliamentary legislation to control the East India Company.'),
        QuizQuestion(id: 'q1_2', unitId: 'unit1', type: 'mcq',
            question: "Pitt's India Act was passed in?",
            options: ['1773', '1784', '1813', '1833'],
            correctIndex: 1,
            explanation: "Pitt's India Act 1784 established the Board of Control and created a system of double government."),
        QuizQuestion(id: 'q1_3', unitId: 'unit1', type: 'mcq',
            question: 'The first Governor-General of Bengal under the Regulating Act 1773 was?',
            options: ['Lord Cornwallis', 'Warren Hastings', 'Lord Wellesley', 'Lord Dalhousie'],
            correctIndex: 1,
            explanation: 'Warren Hastings was appointed the first Governor-General of Bengal under the Regulating Act 1773.'),
        QuizQuestion(id: 'q1_4', unitId: 'unit1', type: 'mcq',
            question: 'Which Charter Act introduced open competition for civil services?',
            options: ['Charter Act 1793', 'Charter Act 1813', 'Charter Act 1833', 'Charter Act 1853'],
            correctIndex: 3,
            explanation: 'Charter Act 1853 introduced open competition for selection of civil servants.'),
        QuizQuestion(id: 'q1_5', unitId: 'unit1', type: 'truefalse',
            question: 'The Government of India Act 1935 introduced provincial autonomy.',
            options: ['Valid', 'Invalid'],
            correctIndex: 0,
            explanation: 'True. GOI Act 1935 abolished dyarchy at the provinces and introduced provincial autonomy.'),
        QuizQuestion(id: 'q1_6', unitId: 'unit1', type: 'mcq',
            question: 'Indian Constitution was adopted on?',
            options: ['15 August 1947', '26 January 1950', '26 November 1949', '29 August 1947'],
            correctIndex: 2,
            explanation: 'The Constitution was adopted by the Constituent Assembly on 26 November 1949 and came into force on 26 January 1950.'),
        QuizQuestion(id: 'q1_7', unitId: 'unit1', type: 'mcq',
            question: 'The Cabinet Mission Plan that set up the Constituent Assembly was in?',
            options: ['1945', '1946', '1947', '1948'],
            correctIndex: 1,
            explanation: 'The Cabinet Mission Plan of 1946 proposed the formation of the Constituent Assembly.'),
        QuizQuestion(id: 'q1_8', unitId: 'unit1', type: 'mcq',
            question: 'Dyarchy at the Centre was introduced by which Act?',
            options: ['Morley-Minto Reforms 1909', 'Montague-Chelmsford Reforms 1919', 'Government of India Act 1935', 'Indian Independence Act 1947'],
            correctIndex: 2,
            explanation: 'GOI Act 1935 introduced dyarchy at the Centre while abolishing it at the provincial level.'),

        // UNIT 2
        QuizQuestion(id: 'q2_1', unitId: 'unit2', type: 'mcq',
            question: 'Who was the Chairman of the Drafting Committee of the Constitution?',
            options: ['Dr Rajendra Prasad', 'Jawaharlal Nehru', 'Dr B.R. Ambedkar', 'Sardar Patel'],
            correctIndex: 2,
            explanation: 'Dr B.R. Ambedkar was appointed Chairman of the Drafting Committee on 29 August 1947.'),
        QuizQuestion(id: 'q2_2', unitId: 'unit2', type: 'mcq',
            question: 'The words "Socialist" and "Secular" were added to the Preamble by which amendment?',
            options: ['40th Amendment', '42nd Amendment', '44th Amendment', '46th Amendment'],
            correctIndex: 1,
            explanation: '42nd Constitutional Amendment Act 1976 added "Socialist" and "Secular" to the Preamble.'),
        QuizQuestion(id: 'q2_3', unitId: 'unit2', type: 'mcq',
            question: 'The concept of Directive Principles of State Policy was borrowed from?',
            options: ['USA', 'UK', 'Ireland', 'Canada'],
            correctIndex: 2,
            explanation: 'DPSP was borrowed from the Irish Constitution (Articles 45–51).'),
        QuizQuestion(id: 'q2_4', unitId: 'unit2', type: 'mcq',
            question: 'In Berubari Union case (1960), the Supreme Court held that Preamble is?',
            options: ['Part of the Constitution', 'Not part of the Constitution', 'Enforceable in courts', 'None of the above'],
            correctIndex: 1,
            explanation: 'In Berubari Union case, the SC held Preamble is NOT part of the Constitution. This was later revised in Kesavananda Bharati.'),
        QuizQuestion(id: 'q2_5', unitId: 'unit2', type: 'mcq',
            question: 'The Basic Structure Doctrine was established in which case?',
            options: ['A.K. Gopalan', 'Golaknath', 'Kesavananda Bharati', 'Minerva Mills'],
            correctIndex: 2,
            explanation: 'Kesavananda Bharati v. State of Kerala (1973) established the Basic Structure Doctrine in a landmark 13-judge bench decision.'),
        QuizQuestion(id: 'q2_6', unitId: 'unit2', type: 'truefalse',
            question: 'The Preamble of India declares India as a Sovereign Socialist Secular Democratic Republic.',
            options: ['Valid', 'Invalid'],
            correctIndex: 0,
            explanation: 'True. After the 42nd Amendment 1976, the Preamble reads: Sovereign Socialist Secular Democratic Republic.'),

        // UNIT 3
        QuizQuestion(id: 'q3_1', unitId: 'unit3', type: 'mcq',
            question: 'Article 1 of the Constitution declares India as?',
            options: ['A Federal State', 'A Union of States', 'A Confederation', 'A Unitary State'],
            correctIndex: 1,
            explanation: 'Article 1 declares "India, that is Bharat, shall be a Union of States." The word "Union" was deliberately chosen over "Federation".'),
        QuizQuestion(id: 'q3_2', unitId: 'unit3', type: 'mcq',
            question: 'Citizenship provisions are contained in?',
            options: ['Articles 1-4', 'Articles 5-11', 'Articles 12-35', 'Articles 36-51'],
            correctIndex: 1,
            explanation: 'Articles 5-11 deal with citizenship at the commencement of the Constitution.'),
        QuizQuestion(id: 'q3_3', unitId: 'unit3', type: 'mcq',
            question: 'India follows which type of citizenship?',
            options: ['Dual citizenship', 'Single citizenship', 'Multiple citizenship', 'No citizenship'],
            correctIndex: 1,
            explanation: 'India provides for single citizenship, unlike the USA which has dual citizenship (state + national).'),
        QuizQuestion(id: 'q3_4', unitId: 'unit3', type: 'mcq',
            question: 'The Citizenship Act was passed in?',
            options: ['1950', '1952', '1955', '1960'],
            correctIndex: 2,
            explanation: 'Citizenship Act 1955 regulates the acquisition and termination of Indian citizenship.'),

        // UNIT 4
        QuizQuestion(id: 'q4_1', unitId: 'unit4', type: 'mcq',
            question: 'Fundamental Rights are contained in which Part of the Constitution?',
            options: ['Part II', 'Part III', 'Part IV', 'Part IVA'],
            correctIndex: 1,
            explanation: 'Part III of the Constitution (Articles 12-35) deals with Fundamental Rights.'),
        QuizQuestion(id: 'q4_2', unitId: 'unit4', type: 'mcq',
            question: 'The Doctrine of Eclipse applies to?',
            options: ['Pre-constitutional laws inconsistent with FRs', 'Post-constitutional laws', 'Constitutional amendments', 'None of these'],
            correctIndex: 0,
            explanation: 'Doctrine of Eclipse: A pre-constitutional law inconsistent with FR is not void but merely eclipsed/dormant and can be revived if the FR is amended.'),
        QuizQuestion(id: 'q4_3', unitId: 'unit4', type: 'mcq',
            question: 'In Maneka Gandhi case, "procedure established by law" under Art. 21 was held to mean?',
            options: ['Any procedure in a statute', 'Fair, just and reasonable procedure', 'Procedure as per natural justice only', 'Procedure as per CrPC'],
            correctIndex: 1,
            explanation: 'Maneka Gandhi (1978) held that procedure must be fair, just and reasonable, overruling A.K. Gopalan\'s restrictive view.'),
        QuizQuestion(id: 'q4_4', unitId: 'unit4', type: 'mcq',
            question: 'Right to Constitutional Remedies is found in which Article?',
            options: ['Article 19', 'Article 21', 'Article 32', 'Article 226'],
            correctIndex: 2,
            explanation: 'Article 32 provides the Right to Constitutional Remedies. Dr Ambedkar called it the "heart and soul of the Constitution".'),
        QuizQuestion(id: 'q4_5', unitId: 'unit4', type: 'mcq',
            question: 'Which article abolishes untouchability?',
            options: ['Article 14', 'Article 15', 'Article 17', 'Article 18'],
            correctIndex: 2,
            explanation: 'Article 17 abolishes untouchability and its practice in any form is a punishable offence.'),
        QuizQuestion(id: 'q4_6', unitId: 'unit4', type: 'truefalse',
            question: 'Article 14 guarantees equality only to citizens of India.',
            options: ['Valid', 'Invalid'],
            correctIndex: 1,
            explanation: 'Invalid. Article 14 guarantees equality before law and equal protection of law to ALL persons (including foreigners), not just citizens.'),

        // UNIT 5
        QuizQuestion(id: 'q5_1', unitId: 'unit5', type: 'mcq',
            question: 'Directive Principles of State Policy are contained in?',
            options: ['Part III', 'Part IV', 'Part IVA', 'Part V'],
            correctIndex: 1,
            explanation: 'DPSP are contained in Part IV of the Constitution (Articles 36-51).'),
        QuizQuestion(id: 'q5_2', unitId: 'unit5', type: 'mcq',
            question: 'Fundamental Duties are contained in?',
            options: ['Article 49A', 'Article 51A', 'Article 52A', 'Article 53A'],
            correctIndex: 1,
            explanation: 'Article 51A (Part IVA) contains the Fundamental Duties. They were added by the 42nd Amendment 1976.'),
        QuizQuestion(id: 'q5_3', unitId: 'unit5', type: 'mcq',
            question: 'DPSP are?',
            options: ['Justiciable', 'Non-justiciable', 'Enforceable in High Courts only', 'Enforceable through Article 32'],
            correctIndex: 1,
            explanation: 'DPSPs are non-justiciable – they cannot be enforced in a court of law (Article 37). But they are fundamental to governance.'),
        QuizQuestion(id: 'q5_4', unitId: 'unit5', type: 'mcq',
            question: 'In Unni Krishnan v. State of A.P., the SC held that right to education up to 14 years is a?',
            options: ['Directive Principle', 'Fundamental Right under Art. 21', 'Fundamental Duty', 'None'],
            correctIndex: 1,
            explanation: 'Unni Krishnan (1993) held right to education up to age 14 flows from Art. 21. This led to Art. 21A being inserted.'),

        // UNIT 6
        QuizQuestion(id: 'q6_1', unitId: 'unit6', type: 'mcq',
            question: 'Power to amend the Constitution is contained in?',
            options: ['Article 356', 'Article 360', 'Article 368', 'Article 370'],
            correctIndex: 2,
            explanation: 'Article 368 in Part XX of the Constitution deals with the power of Parliament to amend the Constitution.'),
        QuizQuestion(id: 'q6_2', unitId: 'unit6', type: 'mcq',
            question: 'The Basic Structure Doctrine means Parliament?',
            options: ['Cannot amend the Constitution at all', 'Can amend any part including FRs', 'Can amend but cannot destroy essential features', 'Can only amend with state ratification'],
            correctIndex: 2,
            explanation: 'Basic Structure Doctrine (Kesavananda 1973): Parliament can amend the Constitution but cannot destroy its basic structure or essential features.'),
        QuizQuestion(id: 'q6_3', unitId: 'unit6', type: 'mcq',
            question: 'In Golaknath case (1967), the SC held that Parliament?',
            options: ['Can amend FR with 2/3 majority', 'Cannot amend Fundamental Rights at all', 'Can amend FR with state ratification', 'Can amend FR only for socio-economic reasons'],
            correctIndex: 1,
            explanation: 'Golaknath (1967) held Parliament cannot amend Fundamental Rights. It was overruled by Kesavananda Bharati in 1973.'),
        QuizQuestion(id: 'q6_4', unitId: 'unit6', type: 'truefalse',
            question: 'Laws placed in the 9th Schedule are completely immune from judicial review.',
            options: ['Valid', 'Invalid'],
            correctIndex: 1,
            explanation: 'Invalid. I.R. Coelho case (2007) held that 9th Schedule laws enacted after 24 April 1973 can be challenged if they violate the Basic Structure.'),
      ];
}
