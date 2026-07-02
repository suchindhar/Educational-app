import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/content_models.dart';

class MatchScreen extends StatefulWidget {
  final QuizSet quizSet;
  final Color unitColor;
  const MatchScreen({super.key, required this.quizSet, required this.unitColor});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  List<QuizQuestion> matchingPairs = [];
  List<String> leftItems = [];
  List<String> rightItems = [];
  String? selectedLeft;
  String? selectedRight;
  Set<int> matchedIndices = {};
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

  void _load() {
    // We assume questions in match mode are formatted as: left :: right
    matchingPairs = widget.quizSet.questions;
    for (var q in matchingPairs) {
      final parts = q.question.split('::');
      if (parts.length == 2) {
        leftItems.add(parts[0].trim());
        rightItems.add(parts[1].trim());
      }
    }
    leftItems.shuffle();
    rightItems.shuffle();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => seconds++));
  }

  void _tryMatch() {
    if (selectedLeft == null || selectedRight == null) return;
    moves++;
    
    int pairIndex = -1;
    for(int i=0; i<matchingPairs.length; i++) {
       final parts = matchingPairs[i].question.split('::');
       if (parts.length == 2 && parts[0].trim() == selectedLeft && parts[1].trim() == selectedRight) {
         pairIndex = i;
         break;
       }
    }

    if (pairIndex != -1) {
      matchedIndices.add(pairIndex);
      if (matchedIndices.length == matchingPairs.length) {
        _timer?.cancel();
        _showResult();
      }
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() { selectedLeft = null; selectedRight = null; });
    });
  }

  void _showResult() {
    final xp = (matchedIndices.length * 20 - moves).clamp(10, 200);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔗', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('All Matched!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Time: ${_formatTime(seconds)}', style: const TextStyle(color: AppColors.textMedium, fontSize: 14)),
            Text('Moves: $moves', style: const TextStyle(color: AppColors.textMedium, fontSize: 14)),
            const SizedBox(height: 8),
            Text('+$xp XP', style: const TextStyle(color: AppColors.gold, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
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
      ),
    );
  }

  String _formatTime(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Match Pairs'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text(_formatTime(seconds), style: const TextStyle(color: AppColors.textMedium, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${matchedIndices.length}/${matchingPairs.length} matched', style: TextStyle(color: widget.unitColor, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Moves: $moves', style: const TextStyle(color: AppColors.textMedium, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: matchingPairs.isEmpty ? 0 : matchedIndices.length / matchingPairs.length,
                minHeight: 6,
                backgroundColor: widget.unitColor.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation(widget.unitColor),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: leftItems.length,
                      itemBuilder: (_, i) {
                        final item = leftItems[i];
                        bool isMatched = false;
                        for(var idx in matchedIndices) {
                           if (matchingPairs[idx].question.startsWith(item)) { isMatched = true; break; }
                        }
                        return _tile(item, selectedLeft == item, isMatched, widget.unitColor, () {
                           if(!isMatched) setState(() { selectedLeft = item; _tryMatch(); });
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rightItems.length,
                      itemBuilder: (_, i) {
                        final item = rightItems[i];
                        bool isMatched = false;
                        for(var idx in matchedIndices) {
                           if (matchingPairs[idx].question.endsWith(item)) { isMatched = true; break; }
                        }
                        return _tile(item, selectedRight == item, isMatched, AppColors.accent, () {
                           if(!isMatched) setState(() { selectedRight = item; _tryMatch(); });
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String text, bool selected, bool matched, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: matched ? AppColors.success.withOpacity(0.1) : (selected ? color.withOpacity(0.1) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: matched ? AppColors.success : (selected ? color : Colors.grey.withOpacity(0.2))),
        ),
        child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: selected || matched ? FontWeight.bold : FontWeight.normal, color: matched ? AppColors.success : AppColors.textDark)),
      ),
    );
  }
}
