import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';
import 'welcome_screen.dart';
import 'admin_upload_screen.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  final String scholarName;
  const ProfileScreen({super.key, required this.scholarName});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    // You can change this email to your actual admin email
    final bool isAdmin = user?.email == 'admin@lexquest.com' || user?.email == 'your-email@gmail.com';

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, Color(0xFF2E4A6F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.scholarName.isNotEmpty ? widget.scholarName[0].toUpperCase() : 'S',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ).animate().scale(),
            const SizedBox(height: 12),
            Text(widget.scholarName,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const Text('Learning Law Smarter',
                style: TextStyle(color: AppColors.textMedium, fontSize: 13)),

            const SizedBox(height: 24),

            // Options
            _optionTile(
              Icons.help_outline,
              'Help & FAQ',
              'Common legal study questions',
              AppColors.accent,
              () {},
            ),

            if (isAdmin) ...[
              _optionTile(
                Icons.cloud_upload_outlined,
                'Admin: Upload Content',
                'Upload class PPTs & PDF notes',
                Colors.orange.shade800,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUploadScreen())),
              ),
              const SizedBox(height: 12),
            ],

            const Divider(),
            const SizedBox(height: 12),

            ListTile(
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('scholar_name');
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              },
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Exit Profile',
                  style: TextStyle(
                      color: AppColors.error, fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: AppColors.error.withOpacity(0.06),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textMedium, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark)),
      subtitle: Text(subtitle,
          style: const TextStyle(color: AppColors.textMedium, fontSize: 12)),
      trailing: Icon(Icons.arrow_forward_ios, color: color, size: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: AppColors.cardLight,
    );
  }

}
