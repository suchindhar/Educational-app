// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_theme.dart';
import '../../services/supabase_service.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool loading = false;
  String? error;

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  Future<void> _submit() async {
    setState(() { loading = true; error = null; });
    try {
      if (isLogin) {
        await SupabaseService.signIn(emailCtrl.text.trim(), passCtrl.text);
      } else {
        await SupabaseService.signUp(
            emailCtrl.text.trim(), passCtrl.text, nameCtrl.text.trim());
      }
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() { error = e.toString(); });
    } finally {
      if (mounted) setState(() { loading = false; });
    }
  }

  // Skip auth – go directly to home (useful during dev)
  void _skipAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Logo / App Name
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('⚖️', style: TextStyle(fontSize: 40)),
                ),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 24),
              Text(
                isLogin ? 'Welcome back,\nScholar!' : 'Start your\nJourney!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  height: 1.2,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: 8),
              Text(
                isLogin
                    ? 'Master Constitutional Law one unit at a time'
                    : 'Create an account to track your progress',
                style: const TextStyle(color: AppColors.textMedium),
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 40),

              if (!isLogin) ...[
                _field('Full Name', nameCtrl, Icons.person_outline),
                const SizedBox(height: 16),
              ],
              _field('Email', emailCtrl, Icons.email_outlined,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _field('Password', passCtrl, Icons.lock_outline, obscure: true),

              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error!,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 13)),
              ],

              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(isLogin ? 'Login' : 'Create Account',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() { isLogin = !isLogin; }),
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign up"
                      : 'Already have an account? Login',
                  style: const TextStyle(color: AppColors.secondary),
                ),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _skipAuth,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Continue without login',
                    style: TextStyle(color: AppColors.secondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {bool obscure = false,
      TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textMedium),
      ),
    );
  }
}
