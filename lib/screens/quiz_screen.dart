import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../constants/app_theme.dart';
import '../models/content_models.dart';

class QuizScreen extends StatefulWidget {
  final QuizSet quizSet;
  final Color unitColor;

  const QuizScreen({super.key, required this.quizSet, required this.unitColor});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIdx = 0;
  int score = 0;
  int streak = 0;
  int timeLeft = 15;
  Timer? timer;
  bool answered = false;
  dynamic selectedAnswer;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    startTimer();
  }

  void startTimer() {
    timeLeft = 15;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        _onAnswered(null);
      }
    });
  }

  void _onAnswered(dynamic answer) {
    if (answered) return;
    timer?.cancel();
    
    final currentQ = widget.quizSet.questions[currentIdx];
    bool isCorrect = false;

    if (currentQ.type == QuizType.multipleChoice) {
      isCorrect = (answer is int && currentQ.options[answer] == currentQ.answer);
    } else if (currentQ.type == QuizType.trueFalse) {
      // Our questions use 'A' = VALID, 'B' = INVALID
      isCorrect = (answer == currentQ.answer);
    }

    setState(() {
      selectedAnswer = answer;
      answered = true;
      if (isCorrect) {
        streak++;
        score += (100 * (1 + (streak * 0.1))).toInt();
      } else {
        streak = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (currentIdx < widget.quizSet.questions.length - 1) {
        setState(() {
          currentIdx++;
          answered = false;
          selectedAnswer = null;
        });
        startTimer();
      } else {
        _confettiController.play();
        _showResults();
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28), side: BorderSide(color: widget.unitColor.withOpacity(0.5))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, color: AppColors.gold, size: 80),
            const SizedBox(height: 16),
            const Text('CHALLENGE COMPLETE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2)),
            const SizedBox(height: 24),
            _resultStat('TOTAL SCORE', '$score', widget.unitColor),
            _resultStat('MAX STREAK', '🔥 $streak', Colors.orange),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.unitColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
              child: const Text('FINISH', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultStat(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.quizSet.questions[currentIdx];
    final progress = (currentIdx + 1) / widget.quizSet.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [widget.unitColor.withOpacity(0.15), const Color(0xFF0F172A)],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(progress, q.type),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuestionDisplay(q.question),
                          const SizedBox(height: 40),
                          if (q.type == QuizType.multipleChoice) _buildScholarOptions(q),
                          if (q.type == QuizType.trueFalse) _buildVerdictOptions(q),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [AppColors.gold, Colors.white, Colors.blueAccent],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double progress, QuizType type) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timerOrb(),
              Column(
                children: [
                  Text('${(progress * 100).toInt()}% COMPLETE', style: TextStyle(color: widget.unitColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Container(
                    width: 100, height: 4,
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                    child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: progress, child: Container(decoration: BoxDecoration(color: widget.unitColor, borderRadius: BorderRadius.circular(10)))),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                  const Text('PTS', style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timerOrb() {
    return Container(
      width: 54, height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: timeLeft < 5 ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05),
        border: Border.all(color: timeLeft < 5 ? Colors.red : Colors.white24, width: 2),
      ),
      child: Center(
        child: Text('$timeLeft', style: TextStyle(color: timeLeft < 5 ? Colors.red : Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
      ),
    ).animate(target: timeLeft < 5 ? 1 : 0).shake(hz: 8);
  }

  Widget _buildQuestionDisplay(String text) {
    return Column(
      children: [
        const Icon(Icons.menu_book_rounded, color: Colors.white24, size: 32),
        const SizedBox(height: 16),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, height: 1.4, letterSpacing: 0.5),
        ),
      ],
    ).animate().fadeIn().moveY(begin: 10);
  }

  Widget _buildScholarOptions(QuizQuestion q) {
    final colors = [const Color(0xFF334155), const Color(0xFF334155), const Color(0xFF334155), const Color(0xFF334155)];
    final icons = [Icons.gavel_rounded, Icons.balance_rounded, Icons.library_books_rounded, Icons.account_balance_rounded];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: q.options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        bool isCorrect = q.options[i] == q.answer;
        bool isSelected = i == selectedAnswer;
        
        Color borderColor = Colors.white12;
        Color bgColor = const Color(0xFF1E293B);
        if (answered) {
          if (isCorrect) {
            borderColor = Colors.greenAccent;
            bgColor = Colors.green.withOpacity(0.2);
          } else if (isSelected) {
            borderColor = Colors.redAccent;
            bgColor = Colors.red.withOpacity(0.2);
          } else {
            bgColor = bgColor.withOpacity(0.3);
          }
        }

        return GestureDetector(
          onTap: () => _onAnswered(i),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Row(
              children: [
                Icon(icons[i % icons.length], color: isCorrect && answered ? Colors.greenAccent : Colors.white38, size: 24),
                const SizedBox(width: 16),
                Expanded(child: Text(q.options[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15))),
                if (answered && isCorrect) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
              ],
            ),
          ),
        ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(0.98, 0.98));
      },
    );
  }

  Widget _buildVerdictOptions(QuizQuestion q) {
    return Row(
      children: [
        Expanded(child: _verdictButton('VALID', Icons.verified_user_rounded, Colors.green, () => _onAnswered('A'), answered && q.answer == 'A', answered && selectedAnswer == 'A' && q.answer != 'A')),
        const SizedBox(width: 16),
        Expanded(child: _verdictButton('INVALID', Icons.gavel_rounded, Colors.redAccent, () => _onAnswered('B'), answered && q.answer == 'B', answered && selectedAnswer == 'B' && q.answer != 'B')),
      ],
    );
  }

  Widget _verdictButton(String label, IconData icon, Color color, VoidCallback onTap, bool isCorrect, bool isWrong) {
    Color activeColor = isCorrect ? Colors.green : (isWrong ? Colors.red : const Color(0xFF1E293B));
    return GestureDetector(
      onTap: answered ? null : onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: activeColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isCorrect ? Colors.greenAccent : (isWrong ? Colors.redAccent : Colors.white12), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isCorrect || isWrong ? Colors.white : color, size: 40),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}
