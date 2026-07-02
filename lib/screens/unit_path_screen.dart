// lib/screens/unit_path_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/github_content_service.dart';
import 'unit_screen.dart';

class UnitPathScreen extends StatelessWidget {
  const UnitPathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Learning Path'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<GitHubContentService>(
        builder: (context, svc, child) {
          if (svc.isLoading && svc.units.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: 6,
            itemBuilder: (context, index) {
              final unitNumber = index + 1;
              final available = svc.units.any((u) => u.number == unitNumber);
              final unit = available ? svc.units.firstWhere((u) => u.number == unitNumber) : null;
              final color = AppColors.unitColors[(unitNumber - 1) % AppColors.unitColors.length];

              return _buildUnitCard(context, unitNumber, unit, available, color)
                .animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
            },
          );
        },
      ),
    );
  }

  Widget _buildUnitCard(BuildContext context, int num, dynamic unit, bool available, Color color) {
    return GestureDetector(
      onTap: available 
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => UnitScreen(unit: unit!))) 
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: available ? color.withOpacity(0.1) : Colors.transparent),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: available ? color.withOpacity(0.1) : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: available ? color : Colors.grey.shade300, width: 2),
              ),
              child: Center(
                child: available 
                  ? Text('$num', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18))
                  : const Icon(Icons.lock, size: 20, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('UNIT $num', style: TextStyle(color: color.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                   const SizedBox(height: 4),
                   Text(unit?.title ?? _getDefaultTitle(num), 
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: available ? AppColors.textDark : Colors.grey)),
                ],
              ),
            ),
            if (available) const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _getDefaultTitle(int n) {
      switch (n) {
        case 1: return 'Historical Background';
        case 2: return 'Making of Constitution';
        case 3: return 'Union and Citizenship';
        case 4: return 'Fundamental Rights';
        case 5: return 'DPSP & Duties';
        case 6: return 'Union Executive';
        default: return 'Legal Framework';
      }
  }
}
