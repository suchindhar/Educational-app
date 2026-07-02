import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../models/content_models.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesScreen extends StatefulWidget {
  final UnitContent unit;
  const NotesScreen({super.key, required this.unit});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  int? selectedTopicIndex;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final color = AppColors.unitColors[(widget.unit.number - 1) % AppColors.unitColors.length];
    
    // Filter out Case Laws from the syllabus list to reduce "noise"
    final topics = widget.unit.topics.where((t) {
      final title = t.title.toLowerCase();
      final content = t.content.toLowerCase();
      final isCase = title.contains('⚖️') || title.contains('🧠') || title.contains('case law') || 
                     title.contains(' v. ') || RegExp(r'\bv\.\b').hasMatch(title) ||
                     (content.contains('facts:') && (content.contains('judgment:') || content.contains('significance:')));
      return !isCase;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          _buildHeader(color, topics),
          Expanded(
            child: topics.isEmpty
              ? const Center(child: Text('No study notes available for this section.'))
              : selectedTopicIndex == null 
                ? _buildTopicIndex(topics, color)
                : _buildTopicDetails(topics[selectedTopicIndex!], color),
          ),
        ],
      ),
      floatingActionButton: selectedTopicIndex != null 
        ? FloatingActionButton.extended(
            onPressed: () {
              if (selectedTopicIndex! < topics.length - 1) {
                setState(() => selectedTopicIndex = selectedTopicIndex! + 1);
                _scrollController.animateTo(0, duration: 300.ms, curve: Curves.easeOut);
              } else {
                setState(() => selectedTopicIndex = null);
              }
            },
            backgroundColor: color,
            icon: Icon(selectedTopicIndex! < topics.length - 1 ? Icons.arrow_forward_ios_rounded : Icons.check_circle_rounded, color: Colors.white, size: 16),
            label: Text(selectedTopicIndex! < topics.length - 1 ? 'NEXT' : 'FINISH', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ).animate().scale().fadeIn()
        : null,
    );
  }

  Widget _buildHeader(Color color, List<Topic> filteredTopics) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (selectedTopicIndex != null) {
                setState(() => selectedTopicIndex = null);
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(selectedTopicIndex != null ? Icons.close_rounded : Icons.arrow_back_ios_new_rounded, color: AppColors.textDark, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UNIT ${widget.unit.number} CONTENTS', 
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                Text(
                  selectedTopicIndex == null 
                    ? 'Study Navigator' 
                    : (filteredTopics.isNotEmpty ? filteredTopics[selectedTopicIndex!].title : 'Notes'),
                  style: const TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.w900),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (selectedTopicIndex != null)
            IconButton(
              onPressed: () => setState(() => selectedTopicIndex = null),
              icon: Icon(Icons.format_list_bulleted_rounded, color: color, size: 22),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicIndex(List<Topic> topics, Color color) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => setState(() => selectedTopicIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.1)),
              boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                  child: Center(
                    child: Text('${index + 1}', style: TextStyle(color: color, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    topics[index].title.toUpperCase(),
                    style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: color.withOpacity(0.3), size: 16),
              ],
            ),
          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, curve: Curves.easeOutCubic),
        );
      },
    );
  }

  Widget _buildTopicDetails(Topic topic, Color color) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.textDark.withOpacity(0.05)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (topic.pdfUrl != null && topic.pdfUrl!.isNotEmpty) ...[
                  _buildFileButton(topic.pdfUrl!, color),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                ],
                _buildFullContent(topic, color),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }

  Widget _buildFullContent(Topic topic, Color unitColor) {
    final List<Widget> children = [];
    final sections = topic.content.split('\n\n');

    for (var s in sections) {
      if (s.trim().isEmpty) continue;
      
      if (s.contains('**ILLUSTRATION**') || s.contains('**EXAMPLE**') || s.contains('**CASE LAW**')) {
        children.add(_buildIllustrationCard(s, unitColor));
      } else if (s.startsWith('- ') || s.startsWith('• ')) {
        children.add(_buildBulletList(s));
      } else {
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(s.trim(), textAlign: TextAlign.justify, 
            style: const TextStyle(fontSize: 16, height: 1.7, color: Color(0xFF334155), letterSpacing: 0.3)),
        ));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _buildIllustrationCard(String text, Color color) {
    String title = 'Illustration';
    IconData icon = Icons.auto_awesome_rounded;
    String body = text;

    if (text.startsWith('**')) {
      int endIdx = text.indexOf('**', 2);
      if (endIdx != -1) {
        title = text.substring(2, endIdx).trim();
        body = text.substring(endIdx + 2).trim();
      }
    }

    final bool isCaseLaw = title.toLowerCase().contains('case');
    if (title.toLowerCase().contains('example')) icon = Icons.lightbulb_outline_rounded;
    if (isCaseLaw) icon = Icons.gavel_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isCaseLaw ? Colors.white : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(isCaseLaw ? 0.2 : 0.1)),
        boxShadow: isCaseLaw ? [BoxShadow(color: color.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCaseLaw ? const Color(0xFF1E3A5F) : color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            ),
            child: Row(
              children: [
                Icon(icon, color: isCaseLaw ? AppColors.gold : color, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title.toUpperCase(), 
                    style: TextStyle(color: isCaseLaw ? Colors.white : color, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildSmartContent(body, color),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartContent(String rawText, Color unitColor) {
    final sections = <Widget>[];
    final regExp = RegExp(r'(Facts:|Issue:|Judgment:|Significance:)', caseSensitive: false);
    final matches = regExp.allMatches(rawText).toList();
    
    if (matches.isEmpty) {
      return Text(rawText, textAlign: TextAlign.justify, 
        style: const TextStyle(fontSize: 15, height: 1.7, color: AppColors.textDark));
    }

    int start = 0;
    for (int i = 0; i < matches.length; i++) {
       final match = matches[i];
       if (match.start > start) {
         sections.add(Padding(
           padding: const EdgeInsets.only(bottom: 12),
           child: Text(rawText.substring(start, match.start).trim(), 
             textAlign: TextAlign.justify, style: const TextStyle(fontSize: 14, height: 1.6)),
         ));
       }

       final header = match.group(0)!;
       final end = (i + 1 < matches.length) ? matches[i+1].start : rawText.length;
       final body = rawText.substring(match.end, end).trim();

       Color headColor = const Color(0xFF1E3A5F);
       IconData headIcon = Icons.info_rounded;
       if (header.toLowerCase().contains('judgment')) {
         headColor = const Color(0xFF2E7D32);
         headIcon = Icons.gavel_rounded;
       } else if (header.toLowerCase().contains('significance')) {
         headColor = const Color(0xFFE65100);
         headIcon = Icons.stars_rounded;
       }

       sections.add(
         Container(
           margin: const EdgeInsets.only(bottom: 12),
           padding: const EdgeInsets.all(14),
           decoration: BoxDecoration(color: headColor.withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Row(
                 children: [
                   Icon(headIcon, color: headColor, size: 14),
                   const SizedBox(width: 8),
                   Text(header.toUpperCase(), 
                     style: TextStyle(color: headColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                 ],
               ),
               const SizedBox(height: 6),
               Text(body, textAlign: TextAlign.justify, 
                 style: TextStyle(fontSize: 14, height: 1.6, color: headColor.withOpacity(0.9))),
             ],
           ),
         )
       );
       start = end;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: sections);
  }

  Widget _buildBulletList(String text) {
    final lines = text.split('\n');
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: lines.map((line) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              Expanded(child: Text(line.replaceFirst(RegExp(r'^[-•]\s*'), '').trim(), 
                style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF334155)))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFileButton(String url, Color color) {
    final bool isPdf = url.toLowerCase().contains('.pdf');
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isPdf ? Icons.picture_as_pdf_rounded : Icons.slideshow_rounded,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    isPdf ? 'READ FULL PDF NOTES' : 'VIEW CLASS PRESENTATION',
                    style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                  ),
                  const Text(
                    'Tap to open with external viewer',
                    style: TextStyle(color: AppColors.textMedium, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, color: color.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }
}
