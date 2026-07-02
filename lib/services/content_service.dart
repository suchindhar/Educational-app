// lib/services/content_service.dart
import 'dart:convert';
import '../models/models.dart';
import '../data/local_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ContentService {
  // Now tracks your personal repository for daily updates!
  static const String _remoteUrl = 'https://github.com/suchindhar/Lex-Learn/tree/main';
  static const String _cacheKey = 'cached_content';

  static List<Unit> _currentUnits = [];

  static List<Unit> get units => _currentUnits.isEmpty ? LocalContent.units : _currentUnits;

  /// Loads content from cache then tries to update from remote
  static Future<void> loadContent() async {
    // Start with local/bundled content
    _currentUnits = LocalContent.units;

    // Force an update from GitHub immediately
    bool success = await updateContent();
    if (success) {
      print("SUCCESS: Content updated from GitHub!");
    } else {
      print("ERROR: Could not fetch from GitHub. Using built-in content.");
    }
  }

  /// Fetches new content from the remote JSON file
  static Future<bool> updateContent() async {
    try {
      // Add a timestamp to the URL so GitHub does not show an old version
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final freshUrl = '$_remoteUrl?t=$timestamp';
      
      final response = await http.get(Uri.parse(freshUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        
        if (list.isNotEmpty) {
           _currentUnits = list.map((u) => Unit.fromMap(u)).toList();
           return true;
        }
      }
    } catch (e) {
      print('CONNECTION ERROR: $e');
    }
    return false;
  }

  static Unit getUnitById(String id) {
    return units.firstWhere((u) => u.id == id, orElse: () => units.first);
  }
}
