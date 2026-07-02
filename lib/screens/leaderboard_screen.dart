// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_theme.dart';
import '../services/supabase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool loading = true;
  List<Map<String, dynamic>> topUsers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // In a real app, this fetches from your 'profiles' table in Supabase
    // Sorting by XP earned
    final data = await SupabaseService.getGlobalLeaderboard();
    if (mounted) {
      setState(() {
        topUsers = data;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          _header(),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : _list(),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2B5280)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 48)
              .animate()
              .scale()
              .shake(),
          const SizedBox(height: 12),
          const Text(
            'Global Leaderboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'See how you rank against other Scholars',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _list() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_clock_rounded, 
            size: 80, 
            color: Colors.white.withOpacity(0.15)
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          const SizedBox(height: 24),
          Text(
            'Rankings are Locked',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Complete your live challenge to reveal your position on the leaderboard!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                height: 1.5
              ),
            ),
          ),
        ],
      ),
    );
  }
}
