// lib/screens/games/verdict_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_theme.dart';
import '../../models/models.dart';
import '../../services/question_generator.dart';
import '../../services/supabase_service.dart';

class VerdictScreen extends StatefulWidget {
  final Unit unit;
  const VerdictScreen({super.key, required this.unit});

  @override
  State<VerdictScreen> createState() => _VerdictScreenState();
}

class _VerdictScreenState extends State<VerdictScreen>
    with SingleTickerProviderStateMixin {
  List<QuizQuestion> questions = [];
  int current = 0;
  int? selected;
  bool answered = false;
  int correct = 0;
  int score = 0;
  int timeLeft = 8;
  Timer? _timer;
  bool loading = true;
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final all = await SupabaseService.getRandomQuestions(
        widget.unit.id, count: 20);
    questions =
        QuestionGenerator.generateVerdictQuestions(all).take(10).toList();
    setState(() => loading = false);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => timeLeft = 8);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        t.cancel();
        _verdict(-1);
      } else {
        setState(() => timeLeft--);
      }
    });
  }

  void _verdict(int idx) {
    if (answered) return;
    _timer?.cancel();
    final isCorrect =
        idx == questions[current].correctIndex;

    if (isCorrect) {
      correct++;
      score += 100 + timeLeft * 12;
    } else {
      _shakeCtrl.forward(from: 0);
    }

    setState(() {
      selected = idx;
      answered = true;
    });

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      if (current < questions.length - 1) {
        setState(() {
          current++;
          selected = null;
          answered = false;
        });
        _startTimer();
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    final xp = (score / 15).round();
    SupabaseService.saveProgress(widget.unit.id, xp, false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardLight,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              correct >= questions.length * 0.7 ? '⚖️ Verdict: MASTER!' : '📚 Keep Studying!',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 12),
            Text(
              '$correct / ${questions.length} correct',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Score: $score pts',
                style: const TextStyle(
                    color: AppColors.secondary, fontSize: 16)),
            Text('+$xp XP',
                style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(title: const Text('Verdict Call')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final q = questions[current];
    final timerPct = timeLeft / 8;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Column(
                    children: [
                      const Text('VERDICT CALL',
                          style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontSize: 13)),
                      Text('${current + 1} / ${questions.length}',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text('$score',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E))),
                  ),
                ],
              ),
            ),

            // Timer bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: timerPct,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(
                    timerPct < 0.3
                        ? AppColors.error
                        : timerPct < 0.6
                            ? AppColors.warning
                            : AppColors.gold,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('$timeLeft s',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ),
            ),

            // Statement card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AnimatedBuilder(
                  animation: _shakeCtrl,
                  builder: (_, child) {
                    final offset = _shakeCtrl.value < 0.5
                        ? _shakeCtrl.value * 16
                        : (1 - _shakeCtrl.value) * 16;
                    return Transform.translate(
                      offset: Offset(offset * (answered ? -1 : 1), 0),
                      child: child,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: answered
                            ? (selected == q.correctIndex
                                ? AppColors.success
                                : AppColors.error)
                            : AppColors.gold.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⚖️',
                              style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 20),
                          const Text('STATEMENT',
                              style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Text(
                            q.question,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                height: 1.5),
                          ),
                          if (answered) ...[
                            const SizedBox(height: 20),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 12),
                            Text(
                              q.explanation,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Valid / Invalid buttons
            if (!answered)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _verdict(1),
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.error.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, color: Colors.white, size: 28),
                              SizedBox(width: 8),
                              Text('INVALID',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ),
                    ).animate().slideX(begin: -0.2),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _verdict(0),
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.success.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.white, size: 28),
                              SizedBox(width: 8),
                              Text('VALID',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 1)),
                            ],
                          ),
                        ),
                      ),
                    ).animate().slideX(begin: 0.2),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: selected == q.correctIndex
                        ? AppColors.success
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      selected == q.correctIndex
                          ? '✅ Correct! Next...'
                          : '❌ Wrong! The answer is: ${q.options[q.correctIndex]}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                ).animate().scale(),
              ),
          ],
        ),
      ),
    );
  }
}
