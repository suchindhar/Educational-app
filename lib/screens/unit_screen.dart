import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/content_models.dart';
import '../services/github_content_service.dart';
import 'topic_screen.dart';
import 'quiz_screen.dart';
import 'flashcard_screen.dart';
import 'revision_screen.dart';
import 'notes_screen.dart';
import 'match_screen.dart';
import 'verdict_screen.dart';
import 'case_law_screen.dart';

class UnitScreen extends StatelessWidget {
  final UnitContent unit;
  const UnitScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final svc = Provider.of<GitHubContentService>(context, listen: false);
    final allQuizSets = svc.quizzesForUnit(unit.id);

    // Route each game to the correct quiz set from GitHub or Auto-gen
    QuizSet? verdictSet;
    QuizSet? quizSet;
    QuizSet? matchSet;

    for (var qs in allQuizSets) {
      if (qs.title == 'Verdict Call') verdictSet = qs;
      if (qs.title == 'Quick Quiz') quizSet = qs;
      if (qs.title == 'Match Pairs') matchSet = qs;
    }
    
    final flashcardSet = svc.flashcardsForUnit(unit.id);
    final color = AppColors.unitColors[(unit.number - 1) % AppColors.unitColors.length];

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, color, quizSet),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── LEARN ──────────────────────────────────
                  _sectionHeader('📚 Learn'),
                  const SizedBox(height: 12),
                  _actionTile(
                    context,
                    icon: Icons.menu_book_rounded,
                    title: 'Study Notes',
                    subtitle: '${unit.topics.length} Expert Lessons',
                    color: AppColors.secondary,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesScreen(unit: unit))),
                  ),
                  const SizedBox(height: 10),
                  _actionTile(
                    context,
                    icon: Icons.fact_check_rounded,
                    title: 'Quick Revision',
                    subtitle: 'Core concepts for exam success',
                    color: const Color(0xFF2E7D52),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RevisionScreen(unit: unit))),
                  ),

                  const SizedBox(height: 24),

                  // ── PRACTICE ────────────────────────────────
                  _sectionHeader('🎮 Practice Games'),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _gameCard(context,
                          imagePath: 'assets/images/Flip and Learn.png',
                          title: 'Flashcard',
                          subtitle: '',
                          count: flashcardSet?.cards.length ?? 0,
                          color: const Color(0xFF6B9080),
                          onTap: flashcardSet != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardScreen(flashcardSet: flashcardSet, unitColor: color))) : null),
                      _gameCard(context,
                          imagePath: 'assets/images/Verdict_Call.png',
                          title: 'Verdict Call',
                          subtitle: '',
                          count: verdictSet?.questions.length ?? 0,
                          color: const Color(0xFF9C6644),
                          onTap: verdictSet != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => VerdictScreen(quizSet: verdictSet!))) : null),
                      _gameCard(context,
                          imagePath: 'assets/images/match.png',
                          title: 'Match Pairs',
                          subtitle: '',
                          count: matchSet?.questions.length ?? 0,
                          color: const Color(0xFF606C38),
                          onTap: matchSet != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => MatchScreen(quizSet: matchSet!, unitColor: color))) : null),
                      _gameCard(context,
                          imagePath: 'assets/images/quiz.png',
                          title: 'Quick Quiz',
                          subtitle: '',
                          count: quizSet?.questions.length ?? 0,
                          color: const Color(0xFFBC6C25),
                          onTap: quizSet != null ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(quizSet: quizSet!, unitColor: color))) : null),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Full-width case law game
                  _actionTile(
                    context,
                    icon: Icons.gavel_rounded,
                    title: 'Case Law Memory',
                    subtitle: 'Master key Constitutional rulings',
                    color: const Color(0xFF4A6FA5),
                    onTap: () {
                      final cases = unit.topics.where((t) {
                        final title = t.title.toLowerCase();
                        final content = t.content.toLowerCase();
                        final isCase = title.contains('⚖️') || title.contains('🧠') || title.contains('case law') || 
                                       title.contains(' v. ') || RegExp(r'\bv\.\b').hasMatch(title) ||
                                       (content.contains('facts:') && (content.contains('judgment:') || content.contains('significance:')));
                        return isCase;
                      }).toList();

                      // Extreme deduplication using "Root Case Name" extraction
                      final Set<String> seenCases = {};
                      final List<Topic> uniqueCases = [];
                      for (var c in cases) {
                        String t = c.title.toLowerCase()
                            .replaceAll('⚖️', '').replaceAll('🧠', '')
                            .replaceAll(RegExp(r'^case law\s*[-–:]?\s*'), '')
                            .replaceAll(RegExp(r'\(?\d{4}\)?'), '') // Remove years like (1775)
                            .trim();
                            
                        // Extract everything before "v.", "vs", or "case"
                        int v1 = t.indexOf(' v. ');
                        int v2 = t.indexOf(' vs ');
                        int v3 = t.indexOf(' case');
                        
                        int split = t.length;
                        if (v1 != -1 && v1 < split) split = v1;
                        if (v2 != -1 && v2 < split) split = v2;
                        if (v3 != -1 && v3 < split) split = v3;
                        
                        String rootName = t.substring(0, split).replaceAll(RegExp(r'[^a-z0-9]'), '');
                        if (rootName.isEmpty) rootName = t.replaceAll(RegExp(r'[^a-z0-9]'), '');
                        
                        if (!seenCases.contains(rootName)) {
                          seenCases.add(rootName);
                          uniqueCases.add(c);
                        }
                      }
                      
                      if (uniqueCases.isNotEmpty) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => CaseLawScreen(
                          topics: uniqueCases,
                          unitColor: color,
                        )));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No case laws found in this unit yet.')));
                      }
                    },
                  ),

                  const SizedBox(height: 40),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color color, QuizSet? quizSet) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: color,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'UNIT ${unit.number}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    unit.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3),
                  ),
                  const SizedBox(height: 10),
                   Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statBadge('${unit.topics.where((t) => !t.title.toLowerCase().contains('case')).length} Lessons', Icons.menu_book_rounded),
                      _statBadge('${unit.topics.where((t) => t.title.toLowerCase().contains('case')).length} Cases', Icons.gavel),
                      _statBadge('${quizSet?.questions.length ?? 10} Q\'s', Icons.quiz),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark));
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFF5F5F5) : AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(onTap == null ? 0.1 : 0.25)),
          boxShadow: onTap == null 
            ? [] 
            : [
                BoxShadow(
                  color: color.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMedium, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05);
  }

  Widget _gameCard(
    BuildContext context, {
    required String imagePath,
    required String title,
    required String subtitle,
    required Color color,
    int count = 0,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFF5F5F5) : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    imagePath,
                    height: 60,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(Icons.gamepad_rounded, color: color, size: 30),
                  ),
                ),
                const SizedBox(height: 10),
                Center(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark))),
                if (subtitle.isNotEmpty)
                  Center(child: Text(subtitle, style: const TextStyle(color: AppColors.textMedium, fontSize: 10))),
              ],
            ),
            if (count > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('$count', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.98, 0.98));
  }
}

