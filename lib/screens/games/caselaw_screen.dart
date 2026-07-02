// lib/screens/games/caselaw_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_theme.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

enum _CaseMode { browse, quiz, memorize }

class CaseLawScreen extends StatefulWidget {
  final Unit unit;
  const CaseLawScreen({super.key, required this.unit});

  @override
  State<CaseLawScreen> createState() => _CaseLawScreenState();
}

class _CaseLawScreenState extends State<CaseLawScreen>
    with SingleTickerProviderStateMixin {
  List<CaseLaw> cases = [];
  bool loading = true;
  _CaseMode mode = _CaseMode.browse;
  int current = 0;
  int score = 0;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final loaded = await SupabaseService.getCaseLaws(widget.unit.id);
    setState(() {
      cases = loaded.isEmpty ? widget.unit.caseLaws : loaded;
      loading = false;
    });
  }

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

    if (cases.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(title: const Text('Case Law Memory')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('⚖️', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text('No case laws uploaded yet.',
                  style: TextStyle(
                      color: AppColors.textMedium, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF4A6FA5),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white),
                        ),
                        const Expanded(
                          child: Text('Case Law Memory',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Text('${cases.length} cases',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabCtrl,
                    indicatorColor: AppColors.gold,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    tabs: const [
                      Tab(text: '📖 Browse'),
                      Tab(text: '🧪 Quiz Me'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _BrowseView(cases: cases),
                _QuizView(cases: cases, unitId: widget.unit.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BROWSE VIEW ───────────────────────────────────────────────
class _BrowseView extends StatelessWidget {
  final List<CaseLaw> cases;
  const _BrowseView({required this.cases});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cases.length,
      itemBuilder: (_, i) => _CaseCard(caseLaw: cases[i], index: i)
          .animate()
          .fadeIn(delay: (i * 70).ms)
          .slideY(begin: 0.05),
    );
  }
}

class _CaseCard extends StatefulWidget {
  final CaseLaw caseLaw;
  final int index;
  const _CaseCard({required this.caseLaw, required this.index});

  @override
  State<_CaseCard> createState() => _CaseCardState();
}

class _CaseCardState extends State<_CaseCard> {
  bool expanded = false;
  final color = const Color(0xFF4A6FA5);

  @override
  Widget build(BuildContext context) {
    final c = widget.caseLaw;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => expanded = !expanded),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('${widget.index + 1}',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
            title: Text(c.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textDark)),
            subtitle: Text('${c.year} • ${c.court}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMedium)),
            trailing: Icon(
              expanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: color,
            ),
          ),
          if (expanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  _row('📋 Facts', c.facts, color),
                  const SizedBox(height: 10),
                  _row('🔨 Held', c.held, Colors.green.shade700),
                  const SizedBox(height: 10),
                  _row('⭐ Significance', c.significance,
                      AppColors.accent),
                  if (c.relatedArticles.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: c.relatedArticles
                          .map((a) => Chip(
                                label: Text(a,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.secondary)),
                                backgroundColor:
                                    AppColors.secondary.withOpacity(0.08),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: AppColors.textDark, fontSize: 13, height: 1.4)),
      ],
    );
  }
}

// ─── QUIZ VIEW ─────────────────────────────────────────────────
class _QuizView extends StatefulWidget {
  final List<CaseLaw> cases;
  final String unitId;
  const _QuizView({required this.cases, required this.unitId});

  @override
  State<_QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<_QuizView> {
  List<_CaseQuestion> questions = [];
  int current = 0;
  int? selected;
  bool answered = false;
  int correct = 0;
  bool done = false;

  @override
  void initState() {
    super.initState();
    _buildQuestions();
  }

  void _buildQuestions() {
    if (widget.cases.isEmpty) return;
    final qs = <_CaseQuestion>[];
    for (final c in widget.cases) {
      // Q1: What did this case hold?
      final others = widget.cases.where((x) => x.id != c.id).toList();
      if (others.length >= 3) {
        final wrongOpts = (others..shuffle()).take(3).map((x) => x.held).toList();
        final opts = [c.held, ...wrongOpts]..shuffle();
        qs.add(_CaseQuestion(
          stem: '${c.name} (${c.year}): What was held?',
          correctAnswer: c.held,
          options: opts,
          explanation: c.significance,
        ));
      }
      // Q2: Which case is about?
      if (others.length >= 3) {
        final wrongOpts = (others..shuffle()).take(3).map((x) => x.name).toList();
        final opts = [c.name, ...wrongOpts]..shuffle();
        qs.add(_CaseQuestion(
          stem: 'Which case deals with: "${c.facts.substring(0, c.facts.length.clamp(0, 100))}..."',
          correctAnswer: c.name,
          options: opts,
          explanation: '${c.name} (${c.year}): ${c.held}',
        ));
      }
    }
    qs.shuffle();
    setState(() => questions = qs.take(10).toList());
  }

  void _answer(int idx) {
    if (answered) return;
    final isCorrect =
        questions[current].options[idx] ==
            questions[current].correctAnswer;
    if (isCorrect) correct++;
    setState(() {
      selected = idx;
      answered = true;
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (current < questions.length - 1) {
        setState(() {
          current++;
          selected = null;
          answered = false;
        });
      } else {
        final xp = correct * 15;
        SupabaseService.saveProgress(widget.unitId, xp, false);
        setState(() => done = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(
        child: Text('Need at least 4 cases for the quiz.',
            style: TextStyle(color: AppColors.textMedium)),
      );
    }

    if (done) {
      return _ResultView(
        correct: correct,
        total: questions.length,
        onRetry: () {
          _buildQuestions();
          setState(() {
            current = 0;
            selected = null;
            answered = false;
            correct = 0;
            done = false;
          });
        },
      );
    }

    final q = questions[current];
    final progress = (current + 1) / questions.length;
    const caseColor = Color(0xFF4A6FA5);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${current + 1} / ${questions.length}',
                  style: const TextStyle(
                      color: AppColors.textMedium, fontSize: 13)),
              Text('✅ $correct correct',
                  style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: caseColor.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation(caseColor),
            ),
          ),
          const SizedBox(height: 16),

          // Question
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: caseColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.gavel, color: Colors.white, size: 28),
                const SizedBox(height: 12),
                Text(
                  q.stem,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4),
                ),
              ],
            ),
          ).animate().fadeIn(),
          const SizedBox(height: 14),

          // Options
          ...q.options.asMap().entries.map((entry) {
            final i = entry.key;
            final opt = entry.value;
            final isCorrect = opt == q.correctAnswer;
            Color bg = AppColors.cardLight;
            Color border = const Color(0xFFE0E0E0);
            if (answered) {
              if (isCorrect) {
                bg = AppColors.success.withOpacity(0.12);
                border = AppColors.success;
              } else if (i == selected) {
                bg = AppColors.error.withOpacity(0.1);
                border = AppColors.error;
              }
            } else if (i == selected) {
              bg = caseColor.withOpacity(0.1);
              border = caseColor;
            }

            return GestureDetector(
              onTap: answered ? null : () => _answer(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: answered && isCorrect
                            ? AppColors.success
                            : answered && i == selected && !isCorrect
                                ? AppColors.error
                                : caseColor.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          answered && isCorrect
                              ? '✓'
                              : answered && i == selected && !isCorrect
                                  ? '✗'
                                  : String.fromCharCode(65 + i),
                          style: TextStyle(
                              color: answered
                                  ? Colors.white
                                  : caseColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(opt,
                          style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 13,
                              height: 1.3)),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (i * 60).ms);
          }),

          if (answered) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardCream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(q.explanation,
                        style: const TextStyle(
                            color: AppColors.textDark,
                            fontSize: 13,
                            height: 1.4)),
                  ),
                ],
              ),
            ).animate().fadeIn(),
          ],
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final int correct;
  final int total;
  final VoidCallback onRetry;
  const _ResultView(
      {required this.correct,
      required this.total,
      required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final pct = correct / total;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              pct >= 0.8
                  ? '🏆'
                  : pct >= 0.5
                      ? '⚖️'
                      : '📚',
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              pct >= 0.8
                  ? 'Excellent!\nCase Law Master!'
                  : pct >= 0.5
                      ? 'Good effort!\nKeep reviewing!'
                      : 'Keep studying!\nYou\'ll get there!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  height: 1.3),
            ),
            const SizedBox(height: 20),
            Text(
              '$correct / $total',
              style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary),
            ),
            const SizedBox(height: 4),
            const Text('questions correct',
                style: TextStyle(
                    color: AppColors.textMedium, fontSize: 14)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Unit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseQuestion {
  final String stem;
  final String correctAnswer;
  final List<String> options;
  final String explanation;
  _CaseQuestion({
    required this.stem,
    required this.correctAnswer,
    required this.options,
    required this.explanation,
  });
}
