import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageCtrl = PageController();
  final TextEditingController _nameCtrl = TextEditingController();
  bool _isLoading = true;
  bool _nameError = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('scholar_name');
    if (name != null && name.trim().isNotEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(scholarName: name)),
        );
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _goToNamePage() {
    _pageCtrl.animateToPage(1,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
    setState(() => _currentPage = 1);
  }

  Future<void> _beginLearning() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scholar_name', name);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, b) => HomeScreen(scholarName: name),
          transitionsBuilder: (_, a, b, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFF5C518))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      resizeToAvoidBottomInset: true,
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildSplashPage(),
          _buildNamePage(),
        ],
      ),
    );
  }

  // ── PAGE 1: Splash / Brand Page ─────────────────────────────
  Widget _buildSplashPage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), Color(0xFF1A2E45), Color(0xFF0D1B2A)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF5C518).withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A5F),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Color(0xFFF5C518), size: 60),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 700.ms).scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: 36),
            // App Name
            const Text(
              'LawVexia',
              style: TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
                height: 1.0,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 700.ms).slideY(begin: 0.3),
            const SizedBox(height: 10),
            // Subtitle
            const Text(
              'Learn Law Smarter',
              style: TextStyle(
                color: Color(0xFFF5C518),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 700.ms),
            const Spacer(flex: 2),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(true),
                const SizedBox(width: 8),
                _dot(false),
              ],
            ),
            const SizedBox(height: 32),
            // Next Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _goToNamePage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5C518),
                    foregroundColor: const Color(0xFF0D1B2A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 500.ms).slideY(begin: 0.3),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  // ── PAGE 2: Scholar Name Page ───────────────────────────────
  Widget _buildNamePage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), Color(0xFF1A2E45), Color(0xFF0D1B2A)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5C518).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF5C518).withOpacity(0.4), width: 1.5),
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFFF5C518), size: 32),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 28),
              const Text(
                'What we call you?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
              const SizedBox(height: 36),
              // Name Field
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _nameError
                        ? Colors.red.shade400
                        : const Color(0xFFF5C518).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _nameCtrl,
                  autofocus: false,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [LengthLimitingTextInputFormatter(24)],
                  style: const TextStyle(
                    color: Color(0xFFF5C518),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your name...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFFF5C518), size: 22),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  onChanged: (_) => setState(() => _nameError = false),
                  onSubmitted: (_) => _beginLearning(),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              if (_nameError) ...[
                const SizedBox(height: 8),
                const Text(
                  '⚠ Please enter your name to continue',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],
              const Spacer(flex: 3),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(false),
                  const SizedBox(width: 8),
                  _dot(true),
                ],
              ),
              const SizedBox(height: 24),
              // Begin Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _beginLearning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5C518),
                    foregroundColor: const Color(0xFF0D1B2A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Begin as Scholar',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: active ? 24 : 8,
    height: 8,
    decoration: BoxDecoration(
      color: active ? const Color(0xFFF5C518) : Colors.white24,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
