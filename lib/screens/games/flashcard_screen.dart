// lib/screens/games/flashcard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_theme.dart';
import '../../models/models.dart';
import '../../services/question_generator.dart';
import '../../services/supabase_service.dart';

class FlashcardScreen extends StatefulWidget {
  final Unit unit;
  const FlashcardScreen({super.key, required this.unit});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, String>> cards = [];
  int current = 0;
  bool flipped = false;
  bool loading = true;
  int known = 0;
  int unknown = 0;
  late AnimationController _animCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
    _load();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final qs = await SupabaseService.getRandomQuestions(
        widget.unit.id, count: 15);
    setState(() {
      cards = QuestionGenerator.generateFlashcards(qs);
      loading = false;
    });
  }

  void _flip() {
    if (!flipped) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
    setState(() => flipped = !flipped);
  }

  void _next(bool wasKnown) {
    if (wasKnown) known++;
    else unknown++;

    if (_animCtrl.isCompleted) _animCtrl.reverse();

    if (current < cards.length - 1) {
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          current++;
          flipped = false;
        });
      });
    } else {
      _showSummary();
    }
  }

  void _showSummary() {
    final xp = known * 10;
    SupabaseService.saveProgress(widget.unit.id, xp, false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardLight,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            const Text('Session Complete!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _resultChip('✅ Known', known, AppColors.success),
                _resultChip('❌ Review', unknown, AppColors.error),
              ],
            ),
            const SizedBox(height: 16),
            Text('+$xp XP earned',
                style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        current = 0;
                        flipped = false;
                        known = 0;
                        unknown = 0;
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultChip(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.unitColors[
        (widget.unit.number - 1) % AppColors.unitColors.length];

    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final card = cards[current];
    final progress = (current + 1) / cards.length;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text('Flashcards – Unit ${widget.unit.number}'),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${current + 1}/${cards.length}',
                  style: const TextStyle(
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.textLight.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statBadge('✅ $known', AppColors.success),
                const Text('Tap card to flip',
                    style: TextStyle(
                        color: AppColors.textMedium, fontSize: 12)),
                _statBadge('❌ $unknown', AppColors.error),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (_, __) {
                    final isBack = _flipAnim.value > 0.5;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(
                            _flipAnim.value * 3.14159),
                      alignment: Alignment.center,
                      child: isBack
                          ? Transform(
                              transform: Matrix4.identity()
                                ..rotateY(3.14159),
                              alignment: Alignment.center,
                              child: _backCard(card, color),
                            )
                          : _frontCard(card, color),
                    );
                  },
                ),
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _next(false),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Review',
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _next(true),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('Got it!',
                              style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _frontCard(Map<String, String> card, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, color: Colors.white54, size: 36),
            const SizedBox(height: 20),
            Text(
              card['front'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.4),
            ),
            const Spacer(),
            const Text('Tap to reveal answer',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _backCard(Map<String, String> card, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, color: color, size: 36),
            const SizedBox(height: 16),
            Text(
              card['back'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              card['detail'] ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 13,
                  height: 1.5),
            ),
            if ((card['case'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('📌 ${card['case']}',
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
