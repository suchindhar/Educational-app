// lib/screens/games/match_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_theme.dart';
import '../../models/models.dart';
import '../../services/question_generator.dart';
import '../../services/supabase_service.dart';

class MatchScreen extends StatefulWidget {
  final Unit unit;
  const MatchScreen({super.key, required this.unit});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  List<MatchPair> pairs = [];
  List<String> leftItems = [];
  List<String> rightItems = [];
  String? selectedLeft;
  String? selectedRight;
  Set<String> matchedIds = {};
  bool loading = true;
  int moves = 0;
  int seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final qs = await SupabaseService.getRandomQuestions(
        widget.unit.id, count: 8);
    pairs = QuestionGenerator.generateMatchPairs(qs);
    leftItems = pairs.map((p) => p.left).toList()..shuffle();
    rightItems = pairs.map((p) => p.right).toList()..shuffle();
    setState(() => loading = false);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  void _selectLeft(String item) {
    setState(() => selectedLeft = item);
    _tryMatch();
  }

  void _selectRight(String item) {
    setState(() => selectedRight = item);
    _tryMatch();
  }

  void _tryMatch() {
    if (selectedLeft == null || selectedRight == null) return;
    moves++;
    final pair = pairs.firstWhere(
      (p) => p.left == selectedLeft && p.right == selectedRight,
      orElse: () => MatchPair(id: '', left: '', right: ''),
    );

    if (pair.id.isNotEmpty) {
      matchedIds.add(pair.id);
      if (matchedIds.length == pairs.length) {
        _timer?.cancel();
        _showResult();
      }
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          selectedLeft = null;
          selectedRight = null;
        });
      }
    });
  }

  void _showResult() {
    final xp = ((pairs.length * 20) - moves).clamp(10, 200);
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
            const Text('🔗', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('All Matched!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Time: ${_formatTime(seconds)}',
                style: const TextStyle(
                    color: AppColors.textMedium, fontSize: 14)),
            Text('Moves: $moves',
                style: const TextStyle(
                    color: AppColors.textMedium, fontSize: 14)),
            const SizedBox(height: 8),
            Text('+$xp XP',
                style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
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

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final color = AppColors.unitColors[
        (widget.unit.number - 1) % AppColors.unitColors.length];

    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Match Pairs'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined,
                    color: AppColors.textMedium, size: 16),
                const SizedBox(width: 4),
                Text(_formatTime(seconds),
                    style: const TextStyle(
                        color: AppColors.textMedium,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${matchedIds.length}/${pairs.length} matched',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text('Moves: $moves',
                    style: const TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pairs.isEmpty
                    ? 0
                    : matchedIds.length / pairs.length,
                minHeight: 6,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: Text('Question / Concept',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: Text('Answer / Year',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textMedium,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pairs grid
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: leftItems.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final item = leftItems[i];
                        final pairId = pairs
                            .firstWhere((p) => p.left == item,
                                orElse: () =>
                                    MatchPair(id: '', left: '', right: ''))
                            .id;
                        final isMatched = matchedIds.contains(pairId);
                        final isSelected = selectedLeft == item;
                        return _tile(
                          item,
                          isSelected,
                          isMatched,
                          color,
                          () {
                            if (!isMatched) _selectLeft(item);
                          },
                        ).animate().fadeIn(delay: (i * 60).ms);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right column
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: rightItems.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final item = rightItems[i];
                        final pairId = pairs
                            .firstWhere((p) => p.right == item,
                                orElse: () =>
                                    MatchPair(id: '', left: '', right: ''))
                            .id;
                        final isMatched = matchedIds.contains(pairId);
                        final isSelected = selectedRight == item;
                        return _tile(
                          item,
                          isSelected,
                          isMatched,
                          AppColors.accent,
                          () {
                            if (!isMatched) _selectRight(item);
                          },
                        ).animate().fadeIn(delay: (i * 60).ms);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Hint
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Select one from each column to match',
                style: TextStyle(
                    color: AppColors.textLight, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String text, bool selected, bool matched, Color color,
      VoidCallback onTap) {
    Color bg;
    Color border;
    if (matched) {
      bg = AppColors.success.withOpacity(0.15);
      border = AppColors.success;
    } else if (selected) {
      bg = color.withOpacity(0.15);
      border = color;
    } else {
      bg = AppColors.cardLight;
      border = const Color(0xFFE0E0E0);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            if (matched)
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 14)
            else if (selected)
              Icon(Icons.radio_button_checked, color: color, size: 14)
            else
              Icon(Icons.radio_button_off,
                  color: Colors.grey.shade300, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 12,
                      color: matched
                          ? AppColors.success
                          : AppColors.textDark,
                      fontWeight: selected || matched
                          ? FontWeight.bold
                          : FontWeight.normal)),
            ),
          ],
        ),
      ),
    );
  }
}
