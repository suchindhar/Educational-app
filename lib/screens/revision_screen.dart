import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/content_models.dart';

class RevisionScreen extends StatelessWidget {
  final UnitContent unit;
  const RevisionScreen({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.unitColors[(unit.number - 1) % AppColors.unitColors.length];
    
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, color),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final topic = unit.topics[index];
                  if (topic.keyPoints.isEmpty) return const SizedBox.shrink();
                  
                  return _buildTopicRevisionCard(topic, color, index);
                },
                childCount: unit.topics.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Color color) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: color,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          'Quick Revision',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withOpacity(0.8)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicRevisionCard(Topic topic, Color color, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: 14,
                  child: Text('${index + 1}', 
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    topic.title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color.darken(0.2)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              children: topic.keyPoints.map((point) => _buildKeyPointItem(point, color)).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, curve: Curves.easeOutQuad);
  }

  Widget _buildKeyPointItem(String point, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle_outline_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              point,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension ColorDarken on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
