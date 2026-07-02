// lib/screens/games/quiz_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../constants/app_theme.dart';
import '../../models/models.dart';
import '../../services/question_generator.dart';
import '../../services/supabase_service.dart';

class QuizScreen extends StatefulWidget {
  final Unit unit;
  const QuizScreen({super.key, required this.unit});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  List<QuizQuestion> questions = [];
  int current = 0;
  int? selected;
  bool answered = false;
  int score = 0;
  int streak = 0;
  int bestStreak = 0;
  int timeLeft = 20;
  Timer? _timer;
  bool loading = true;
  late ConfettiController _confetti;
  late AnimationController _shakeCtrl;
  bool _showExplanation = false;

  // Unique color palette per option — not Kahoot colours
  static const List<_OptionTheme> _optionThemes = [
    _OptionTheme(
      bg: Color(0xFF6B3FA0),   // Violet
      light: Color(0xFF9D6FD0),
      icon: '◆',
    ),
    _OptionTheme(
      bg: Color(0xFF0F7EA6),   // Ocean teal
      light: Color(0xFF42A8CC),
      icon: '●',
    ),
    _OptionTheme(
      bg: Color(0xFFBC6C25),   // Amber-brown
      light: Color(0xFFD4924F),
      icon: '▲',
    ),
    _OptionTheme(
      bg: Color(0xFF2E7D52),   // Forest green
      light: Color(0xFF56A878),
      icon: '★',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    questions = await QuestionGenerator.generateForUnit(
        widget.unit.id, count: 10);
    setState(() => loading = false);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() { timeLeft = 20; _showExplanation = false; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        t.cancel();
        _answer(-1);
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void _answer(int index) {
    if (answered) return;
    _timer?.cancel();
    final correct = index == questions[current].correctIndex;

    if (correct) {
      final timeBonus = (timeLeft * 5).clamp(0, 100);
      final streakBonus = (streak * 5).clamp(0, 50);
      score += 100 + timeBonus + streakBonus;
      streak++;
      if (streak > bestStreak) bestStreak = streak;
      _confetti.play();
    } else {
      streak = 0;
      if (index != -1) _shakeCtrl.forward().then((_) => _shakeCtrl.reset());
    }

    setState(() {
      selected = index;
      answered = true;
      _showExplanation = true;
    });

    // Check if it's the last question to trigger score sync
    if (current == questions.length - 1) {
       // Sync to GitHub
       GitHubContentService().saveScoreToGitHub(
         SupabaseService.userName, 
         score, 
         'Quick Quiz - ${widget.unit.title}'
       );
    }

    Future.delayed(const Duration(milliseconds: 3000), () { // Increased delay to 3s to allow reading the Review
      if (!mounted) return;
      if (current < questions.length - 1) {
        setState(() {
          current++;
          selected = null;
          answered = false;
          _showExplanation = false;
        });
        _startTimer();
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    final xp = (score / 10).round();
    SupabaseService.saveProgress(widget.unit.id, xp, false);

    final correct = questions.where((q) {
      final idx = questions.indexOf(q);
      return idx == questions.indexOf(questions[current]) &&
          q.correctIndex == selected;
    }).length;

    // Count properly
    int correctCount = 0;
    // since we can't track per question easily here, show score/max approach
    final maxScore = questions.length * (100 + 100 + 50); // rough max
    final pct = (score / (questions.length * 200)).clamp(0.0, 1.0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A5F), Color(0xFF2E4A7A)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏆', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text('Quiz Complete!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                _resultQuip(pct),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _resultCard('Total Score', '$score pts', AppColors.gold),
              const SizedBox(height: 8),
              _resultCard('Best Streak', '🔥 $bestStreak', const Color(0xFFE07A5F)),
              const SizedBox(height: 8),
              _resultCard('XP Earned', '+$xp XP', const Color(0xFF56A878)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          current = 0;
                          selected = null;
                          answered = false;
                          score = 0;
                          streak = 0;
                          bestStreak = 0;
                          loading = true;
                          _showExplanation = false;
                        });
                        _load();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Again'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit quiz
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white24,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // THE NEW REVEAL BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to a special "Unlocked" version of leaderboard
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const _LiveLeaderboardReveal(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.emoji_events_rounded, size: 20),
                  label: const Text('REVEAL RANKINGS', 
                    style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: const Color(0xFF1E3A5F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
    );
  }

  String _resultQuip(double pct) {
    if (pct >= 0.85) return 'Outstanding performance, Legal Eagle! 🦅';
    if (pct >= 0.65) return 'Great work! Keep studying, Scholar! 📚';
    if (pct >= 0.40) return 'Good effort! Review the notes and try again.';
    return 'Don\'t give up! Every attempt builds knowledge.';
  }

  Widget _resultCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E3A5F),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 20),
              const Text('Preparing questions...',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      );
    }
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(title: const Text('Quick Quiz')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final q = questions[current];
    final progress = (current + 1) / questions.length;
    final timerPct = timeLeft / 20;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1F3D),
      body: Stack(
        children: [
          // Background decoration circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 25,
              colors: const [
                AppColors.gold,
                Colors.white,
                Color(0xFF56A878),
                Color(0xFF6B3FA0),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.white54, size: 20),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Progress bar
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Q ${current + 1} of ${questions.length}',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation(
                                    AppColors.gold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Score badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.gold.withOpacity(0.4)),
                        ),
                        child: Text(
                          '$score',
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Timer + Streak ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _timerWidget(timerPct),
                      if (streak > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE07A5F).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFE07A5F)
                                    .withOpacity(0.5)),
                          ),
                          child: Text(
                            '🔥 $streak streak',
                            style: const TextStyle(
                                color: Color(0xFFE07A5F),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ).animate().scale(),
                      const SizedBox(),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Question card ───────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 120),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          q.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.45),
                        ),
                        if (q.caseName != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.gold.withOpacity(0.3)),
                            ),
                            child: Text(
                              '📌 ${q.caseName}',
                              style: const TextStyle(
                                  color: AppColors.gold, fontSize: 11),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                      .animate(key: ValueKey(current))
                      .fadeIn()
                      .slideY(begin: -0.05),
                ),

                const SizedBox(height: 16),

                // ── Answer options ──────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _optionBtn(q, 0),
                              const SizedBox(width: 10),
                              _optionBtn(q, 1),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (q.options.length > 2)
                          Expanded(
                            child: Row(
                              children: [
                                _optionBtn(q, 2),
                                const SizedBox(width: 10),
                                _optionBtn(q, 3),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Explanation banner (REVIEW SECTION) ──────────────────────────
                if (_showExplanation && q.explanation.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: answered && selected == q.correctIndex
                          ? const Color(0xFF1B5E20).withOpacity(0.9) // Deep Green
                          : const Color(0xFFB71C1C).withOpacity(0.9), // Deep Red
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: answered && selected == q.correctIndex 
                          ? Colors.greenAccent.withOpacity(0.5) 
                          : Colors.redAccent.withOpacity(0.5)
                      )
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              answered && selected == q.correctIndex ? Icons.check_circle_outline : Icons.help_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              answered && selected == q.correctIndex ? 'REVIEW: EXCELLENT!' : 'REVIEW: LEARN WHY',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                           q.explanation,
                           style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).animate().slideY(begin: 0.3).fadeIn(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timerWidget(double pct) {
    Color c;
    if (pct < 0.25) {
      c = Colors.red.shade400;
    } else if (pct < 0.5) {
      c = Colors.orange.shade400;
    } else {
      c = AppColors.gold;
    }
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: pct,
            strokeWidth: 4,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(c),
          ),
          Text(
            '$timeLeft',
            style: TextStyle(
                color: c, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _optionBtn(QuizQuestion q, int index) {
    if (index >= q.options.length) {
      return const Expanded(child: SizedBox());
    }
    final theme = _optionThemes[index % _optionThemes.length];
    Color bgColor = theme.bg;
    bool isCorrect = answered && index == q.correctIndex;
    bool isWrong = answered && index == selected && index != q.correctIndex;
    bool dimmed = answered && index != q.correctIndex && index != selected;

    if (isCorrect) bgColor = const Color(0xFF2E7D52);
    if (isWrong) bgColor = const Color(0xFFB91C1C);
    if (dimmed) bgColor = theme.bg.withOpacity(0.35);

    return Expanded(
      child: GestureDetector(
        onTap: answered ? null : () => _answer(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: answered || dimmed
                ? []
                : [
                    BoxShadow(
                      color: theme.bg.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
            border: Border.all(
              color: isCorrect
                  ? Colors.greenAccent.withOpacity(0.5)
                  : isWrong
                      ? Colors.red.shade300.withOpacity(0.5)
                      : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Stack(
            children: [
              // Shape icon (top-left)
              Positioned(
                top: 10,
                left: 12,
                child: Text(
                  theme.icon,
                  style: TextStyle(
                      color: Colors.white.withOpacity(dimmed ? 0.2 : 0.35),
                      fontSize: 16),
                ),
              ),

              // Option text (center)
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                  child: Text(
                    q.options[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dimmed ? Colors.white38 : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ),

              // Result icon (top-right)
              if (answered && (isCorrect || isWrong))
                Positioned(
                  top: 10,
                  right: 10,
                  child: Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTheme {
  final Color bg;
  final Color light;
  final String icon;
  const _OptionTheme(
      {required this.bg, required this.light, required this.icon});
}

class _LiveLeaderboardReveal extends StatefulWidget {
  const _LiveLeaderboardReveal();

  @override
  State<_LiveLeaderboardReveal> createState() => _LiveLeaderboardRevealState();
}

class _LiveLeaderboardRevealState extends State<_LiveLeaderboardReveal> {
  bool loading = true;
  List<Map<String, dynamic>> topUsers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await SupabaseService.getGlobalLeaderboard();
    if (mounted) {
      setState(() {
        topUsers = data;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1F3D),
      appBar: AppBar(
        title: const Text('Live Battle Rankings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Close reveal
            Navigator.pop(context); // Exit quiz back to home
          },
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: topUsers.length,
              itemBuilder: (context, i) {
                final user = topUsers[i];
                final isTop3 = i < 3;
                final color = i == 0 ? AppColors.gold : (i == 1 ? Colors.white70 : Colors.brown.shade300);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: isTop3 ? Border.all(color: color.withOpacity(0.5)) : null,
                  ),
                  child: Row(
                    children: [
                      Text('${i + 1}', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(width: 16),
                      CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Text(user['name']?[0] ?? 'S', style: TextStyle(color: color))),
                      const SizedBox(width: 16),
                      Expanded(child: Text(user['name'] ?? 'Scholar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      Text('${user['xp']} XP', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ).animate().slideX(begin: 0.1).fadeIn(delay: (i * 50).ms);
              },
            ),
    );
  }
}
