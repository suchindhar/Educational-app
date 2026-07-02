// lib/screens/material_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/github_content_service.dart';
import '../models/content_models.dart';
import 'package:url_launcher/url_launcher.dart';

class MaterialListScreen extends StatelessWidget {
  const MaterialListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Class Materials'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      body: Consumer<GitHubContentService>(
        builder: (context, svc, child) {
          final materials = svc.materials;

          return RefreshIndicator(
            onRefresh: svc.refresh,
            color: AppColors.secondary,
            child: _buildContent(context, svc, materials),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, GitHubContentService svc, List<ClassMaterial> materials) {
    if (svc.isLoading && materials.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
    }

    if (materials.isEmpty) {
      return ListView( // Use ListView to allow pull-to-refresh even when empty
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(child: Icon(Icons.folder_open_rounded, size: 64, color: Color(0xFFE0E0E0))),
          const SizedBox(height: 16),
          const Center(child: Text('No materials found in GitHub folder.', style: TextStyle(color: AppColors.textMedium))),
          const SizedBox(height: 8),
          const Center(child: Text('Pull down to refresh', style: TextStyle(color: AppColors.textLight, fontSize: 12))),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        final material = materials[index];
              final isPdf = material.fileType == 'pdf';
              final color = material.unitNumber > 0 
                  ? AppColors.unitColors[(material.unitNumber - 1) % AppColors.unitColors.length]
                  : AppColors.primary;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isPdf ? Icons.picture_as_pdf_rounded : Icons.slideshow_rounded,
                      color: color,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    material.title, 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)
                  ),
                  subtitle: Text(
                    material.unitNumber > 0 ? 'Unit ${material.unitNumber} Material' : 'Class Material',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMedium)
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.download_rounded, size: 18, color: AppColors.textLight),
                  ),
                onTap: () async {
                    // Use Google Docs Viewer to 'view' the document instead of just downloading
                    final viewerUrl = 'https://docs.google.com/viewer?url=${Uri.encodeComponent(material.url)}&embedded=true';
                    final uri = Uri.parse(viewerUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      // Fallback to direct URL if viewer fails
                      final directUri = Uri.parse(material.url);
                      if (await canLaunchUrl(directUri)) {
                        await launchUrl(directUri, mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                ),
              ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
            },
          );
  }
}
