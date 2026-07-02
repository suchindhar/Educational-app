import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/content_models.dart';

class TopicScreen extends StatelessWidget {
  final Topic topic;
  final Color unitColor;
  const TopicScreen({super.key, required this.topic, required this.unitColor});

  @override
  Widget build(BuildContext context) {
    // Split content into paragraphs to apply smart styling
    final paragraphs = topic.content.split('\n\n');

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...paragraphs.map((p) => _renderSmartParagraph(p.trim())),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: unitColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          topic.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [unitColor, unitColor.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.menu_book, size: 100, color: Colors.white.withOpacity(0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// THE "BYJU'S STYLE" RENDERER: Detects keywords and wraps them in cards
  Widget _renderSmartParagraph(String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    final lower = text.toLowerCase();
    
    // 1. ILLUSTRATION / EXAMPLE BOX (Unacademy Style Blue)
    if (lower.startsWith('illustration') || lower.startsWith('example')) {
      return _buildCalloutCard(
        text, 
        icon: Icons.lightbulb_outline_rounded,
        color: Colors.blue.shade700,
        label: lower.startsWith('illustration') ? 'ILLUSTRATION' : 'EXAMPLE',
      );
    }

    // 2. CASE LAW / IMPORTANCE BOX (Byju's Style Purple)
    if (lower.startsWith('case law') || lower.startsWith('significance') || lower.startsWith('key features')) {
      return _buildCalloutCard(
        text, 
        icon: Icons.gavel_rounded,
        color: Colors.deepPurple.shade600,
        label: 'CONCEPTUAL IMPORTANCE',
      );
    }

    // 3. REGULAR NOTES (Premium Typography)
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.7,
          color: Colors.grey.shade900,
          letterSpacing: 0.2,
          fontFamily: 'Inter', // Note: User should add Google Fonts Inter
        ),
      ),
    );
  }

  Widget _buildCalloutCard(String text, {required IconData icon, required Color color, required String label}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(19), bottomRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 14),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              text,
              style: TextStyle(fontSize: 15, height: 1.6, color: color.withOpacity(0.9), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
