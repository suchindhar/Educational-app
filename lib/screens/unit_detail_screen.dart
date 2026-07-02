// lib/screens/unit_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/models.dart';
import 'notes_screen.dart';
import 'games/flashcard_screen.dart';
import 'games/quiz_screen.dart';
import 'games/match_screen.dart';
import 'games/verdict_screen.dart';
import 'games/caselaw_screen.dart';
import 'revision_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class UnitDetailScreen extends StatelessWidget {
  final Unit unit;
  const UnitDetailScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final color =
        AppColors.unitColors[(unit.number - 1) % AppColors.unitColors.length];

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, color),
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
                    subtitle:
                        '${unit.topics.length} topics • Read & PDF support',
                    color: AppColors.secondary,
                    onTap: () => _go(context, NotesScreen(unit: unit)),
                  ),
                  const SizedBox(height: 10),
                  _actionTile(
                    context,
                    icon: Icons.account_tree_rounded,
                    title: 'Revision Mind Map',
                    subtitle: 'Visual tree of key points',
                    color: const Color(0xFF2E7D52),
                    onTap: () => _go(context, RevisionScreen(unit: unit)),
                  ),
                  if (unit.videoUrl != null && unit.videoUrl!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _actionTile(
                      context,
                      icon: Icons.play_circle_fill_rounded,
                      title: 'Watch Video Lesson',
                      subtitle: 'Video overview of this unit',
                      color: Colors.redAccent,
                      onTap: () async {
                        final url = Uri.parse(unit.videoUrl!);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ],

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
                    childAspectRatio: 1.15,
                    children: [
                      _gameCard(context,
                          emoji: '🃏',
                          title: 'Flashcard',
                          subtitle: 'Flip & Learn',
                          color: const Color(0xFF6B9080),
                          onTap: () => _go(
                              context, FlashcardScreen(unit: unit))),
                      _gameCard(context,
                          emoji: '⚡',
                          title: 'Quick Quiz',
                          subtitle: 'Test your knowledge',
                          color: const Color(0xFFBC6C25),
                          onTap: () =>
                              _go(context, QuizScreen(unit: unit))),
                      _gameCard(context,
                          emoji: '🔗',
                          title: 'Match Pairs',
                          subtitle: 'Connect concepts',
                          color: const Color(0xFF606C38),
                          onTap: () =>
                              _go(context, MatchScreen(unit: unit))),
                      _gameCard(context,
                          emoji: '⚖️',
                          title: 'Verdict Call',
                          subtitle: 'Valid or Invalid?',
                          color: const Color(0xFF9C6644),
                          onTap: () =>
                              _go(context, VerdictScreen(unit: unit))),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Full-width case law game
                  _actionTile(
                    context,
                    icon: Icons.gavel_rounded,
                    title: 'Case Law Memory',
                    subtitle:
                        '${unit.caseLaws.length} cases • Facts & Holdings',
                    color: const Color(0xFF4A6FA5),
                    onTap: () =>
                        _go(context, CaseLawScreen(unit: unit)),
                  ),

                  const SizedBox(height: 24),

                  // ── CLASS MATERIALS ─────────────────────────
                  if (unit.topics.any((t) => t.pdfUrl != null && t.pdfUrl!.isNotEmpty)) ...[
                    _sectionHeader('📂 Class Materials'),
                    const SizedBox(height: 12),
                    ...unit.topics
                        .where((t) => t.pdfUrl != null && t.pdfUrl!.isNotEmpty)
                        .map((t) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _actionTile(
                                context,
                                icon: t.pdfUrl!.toLowerCase().contains('.pdf') 
                                    ? Icons.picture_as_pdf_rounded 
                                    : Icons.slideshow_rounded,
                                title: t.title,
                                subtitle: t.pdfUrl!.toLowerCase().contains('.pdf')
                                    ? 'Detailed PDF Notes'
                                    : 'Class Presentation (PPT)',
                                color: Colors.orange.shade800,
                                onTap: () async {
                                  final url = Uri.parse(t.pdfUrl!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                            )),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color color) {
    return SliverAppBar(
      expandedHeight: 180,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
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
                  Row(
                    children: [
                      _statBadge('${unit.topics.length} Topics',
                          Icons.menu_book_rounded),
                      const SizedBox(width: 8),
                      _statBadge(
                          '${unit.caseLaws.length} Cases', Icons.gavel),
                      const SizedBox(width: 8),
                      _statBadge(
                          '${unit.questions.length} Q\'s', Icons.quiz),
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
          Text(label,
              style:
                  const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark));
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [
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
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textMedium, fontSize: 12)),
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
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(
                    color: AppColors.textMedium, fontSize: 11)),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  void _go(BuildContext context, Widget screen) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => screen));
  }
}
