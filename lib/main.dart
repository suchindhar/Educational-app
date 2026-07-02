import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/github_content_service.dart';
import 'screens/welcome_screen.dart';
import 'constants/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => GitHubContentService()..fetchAll(),
      child: const LawVexiaApp(),
    ),
  );
}

class LawVexiaApp extends StatelessWidget {
  const LawVexiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LawVexia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const WelcomeScreen(),
    );
  }
}
