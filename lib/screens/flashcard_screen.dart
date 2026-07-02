import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/content_models.dart';

class FlashcardScreen extends StatefulWidget {
  final FlashcardSet flashcardSet;
  final Color unitColor;
  const FlashcardScreen({super.key, required this.flashcardSet, required this.unitColor});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  int current = 0;
  bool flipped = false;
  int known = 0;
  int unknown = 0;
  late AnimationController _animCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
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

    if (current < widget.flashcardSet.cards.length - 1) {
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            const Text('Session Complete!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _resultChip('✅ Known', known, AppColors.success),
                _resultChip('❌ Review', unknown, AppColors.error),
              ],
            ),
            const SizedBox(height: 16),
            Text('+$xp XP earned', style: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Back to Unit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultChip(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcardSet.cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(child: Text('No flashcards available.')),
      );
    }

    final card = widget.flashcardSet.cards[current];
    final progress = (current + 1) / widget.flashcardSet.cards.length;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text('Practice Flashcards'),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('${current + 1}/${widget.flashcardSet.cards.length}', style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.textLight.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(widget.unitColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statBadge('✅ $known', AppColors.success),
                const Text('Tap card to reveal', style: TextStyle(color: AppColors.textMedium, fontSize: 12)),
                _statBadge('❌ $unknown', AppColors.error),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
                      transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(_flipAnim.value * 3.14159),
                      alignment: Alignment.center,
                      child: isBack
                          ? Transform(transform: Matrix4.identity()..rotateY(3.14159), alignment: Alignment.center, child: _backCard(card))
                          : _frontCard(card),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _next(false),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.error.withOpacity(0.4))),
                      child: const Center(child: Text('Review', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _next(true),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.success.withOpacity(0.4))),
                      child: const Center(child: Text('Got it!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))),
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

  Widget _frontCard(Flashcard card) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [widget.unitColor, widget.unitColor.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: widget.unitColor.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, color: Colors.white54, size: 36),
            const SizedBox(height: 20),
            Text(card.front, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
            const Spacer(),
            const Text('Tap to reveal answer', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _backCard(Flashcard card) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.unitColor.withOpacity(0.4), width: 2),
        boxShadow: [BoxShadow(color: widget.unitColor.withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, color: widget.unitColor, size: 36),
            const SizedBox(height: 16),
            Text(card.back, textAlign: TextAlign.center, style: TextStyle(color: widget.unitColor, fontSize: 20, fontWeight: FontWeight.bold, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
