import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/content_models.dart';

class CaseLawScreen extends StatelessWidget {
  final List<Topic> topics;
  final Color unitColor;

  const CaseLawScreen({
    super.key, 
    required this.topics, 
    required this.unitColor
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCaseCard(topics[index], index),
                childCount: topics.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF4A6FA5),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: const Text(
          'Historical Case Laws',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF4A6FA5), const Color(0xFF4A6FA5).withOpacity(0.8)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCaseCard(Topic topic, int index) {
    // Clean up title
    final title = topic.title
        .replaceFirst('🧠', '')
        .replaceFirst('Case Law – ', '')
        .replaceFirst('Case Law:', '')
        .replaceAll(RegExp(r'^\d+\.\s*'), '')
        .trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A5F), Color(0xFF2E4A7A)],
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: Color(0xFFFFD700), size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Facts Section
                  _buildSectionHeader('CASE SUMMARY & FACTS', Icons.info_outline),
                  const SizedBox(height: 12),
                  _buildSmartContent(topic.content),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 150).ms).slideY(begin: 0.1, curve: Curves.easeOutCirc);
  }

  Widget _buildSmartContent(String rawText) {
    final sections = <Widget>[];
    final regExp = RegExp(r'(Facts:|Issue:|Judgment:|Significance:)', caseSensitive: false);
    final matches = regExp.allMatches(rawText).toList();
    
    if (matches.isEmpty) {
      return _renderDeepSmartBody(rawText, const Color(0xFF1565C0));
    }

    int start = 0;
    for (int i = 0; i < matches.length; i++) {
       final match = matches[i];
       if (match.start > start) {
         sections.add(Padding(
           padding: const EdgeInsets.only(bottom: 12),
           child: _renderDeepSmartBody(rawText.substring(start, match.start).trim(), const Color(0xFF455A64)),
         ));
       }

       final header = match.group(0)!;
       final end = (i + 1 < matches.length) ? matches[i+1].start : rawText.length;
       final body = rawText.substring(match.end, end).trim();

       Color headColor = const Color(0xFF1E3A5F);
       IconData headIcon = Icons.info;
       if (header.toLowerCase().contains('judgment')) {
          headColor = const Color(0xFF2E7D32);
          headIcon = Icons.gavel_rounded;
       } else if (header.toLowerCase().contains('significance')) {
          headColor = const Color(0xFFE65100);
          headIcon = Icons.stars_rounded;
       } else if (header.toLowerCase().contains('issue')) {
          headColor = const Color(0xFF1565C0);
          headIcon = Icons.help_outline_rounded;
       }

       sections.add(
         Container(
           margin: const EdgeInsets.only(bottom: 16),
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: headColor.withOpacity(0.04),
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: headColor.withOpacity(0.1)),
           ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   Icon(headIcon, color: headColor, size: 16),
                   const SizedBox(width: 8),
                   Text(header.toUpperCase(), style: TextStyle(color: headColor, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                 ],
               ),
               const SizedBox(height: 8),
               _renderDeepSmartBody(body, headColor),
             ],
           ),
         )
       );
       start = end;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: sections);
  }

  Widget _renderDeepSmartBody(String text, Color baseColor) {
    if (text.contains('**ILLUSTRATION**') || text.contains('**EXAMPLE**')) {
       final parts = text.split(RegExp(r'(\*\*ILLUSTRATION\*\*|\*\*EXAMPLE\*\*)', caseSensitive: false));
       final matches = RegExp(r'(\*\*ILLUSTRATION\*\*|\*\*EXAMPLE\*\*)', caseSensitive: false).allMatches(text).toList();
       
       final List<Widget> children = [];
       for (int i = 0; i < parts.length; i++) {
         if (parts[i].trim().isNotEmpty) {
           children.add(Text(parts[i].trim(), textAlign: TextAlign.justify, style: TextStyle(fontSize: 14, height: 1.6, color: baseColor.withOpacity(0.9))));
         }
         if (i < matches.length) {
           final type = matches[i].group(0)!.toUpperCase();
           final isIll = type.contains('ILLUSTRATION');
           children.add(Container(
             margin: const EdgeInsets.symmetric(vertical: 10),
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.5),
               borderRadius: BorderRadius.circular(8),
               border: Border.all(color: baseColor.withOpacity(0.2)),
             ),
             child: Row(
               children: [
                 Icon(isIll ? Icons.auto_awesome : Icons.lightbulb, size: 14, color: baseColor),
                 const SizedBox(width: 8),
                 Text(type.replaceAll('*', ''), style: TextStyle(color: baseColor, fontWeight: FontWeight.bold, fontSize: 10)),
               ],
             ),
           ));
         }
       }
       return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
    }
    return Text(text, textAlign: TextAlign.justify, style: TextStyle(fontSize: 14, height: 1.6, color: baseColor.withOpacity(0.9)));
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1E3A5F).withOpacity(0.5)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1E3A5F).withOpacity(0.6),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
