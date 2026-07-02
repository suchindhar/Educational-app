// lib/services/github_storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GitHubStorageService {
  static const String _token = String.fromEnvironment('GITHUB_TOKEN', defaultValue: '');
  static const String _owner = 'karinafathima2002-del';
  static const String _repo = 'LEX-LEARN';
  static const String _branch = 'main';

  /// Uploads a file to the GitHub repository and returns the Raw Content URL.
  static Future<String?> uploadFile({
    required File file,
    required String folder,
    String? customFileName,
  }) async {
    try {
      final String fileName = customFileName ?? file.path.split('/').last;
      // We encode the filename to handle spaces/special chars
      final String encodedFileName = Uri.encodeComponent(fileName);
      final String endpoint = 'https://api.github.com/repos/$_owner/$_repo/contents/$folder/$encodedFileName';
      
      final bytes = await file.readAsBytes();
      final content = base64Encode(bytes);

      // 1. Check if file already exists to get its SHA (required for updating)
      String? sha;
      final checkRes = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'token $_token',
        },
      );

      if (checkRes.statusCode == 200) {
        final data = jsonDecode(checkRes.body);
        sha = data['sha'];
      }

      // 2. Upload/Update the file
      final response = await http.put(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'token $_token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': '📚 Uploaded class material: $fileName via LawVexia App',
          'content': content,
          'branch': _branch,
          if (sha != null) 'sha': sha, // Include SHA if we are overwriting
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final String rawUrl = 'https://raw.githubusercontent.com/$_owner/$_repo/$_branch/$folder/$fileName';
        debugPrint('✅ GitHub Upload Success: $rawUrl');
        return rawUrl;
      } else {
        debugPrint('❌ GitHub Upload Failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ GitHub Storage Error: $e');
      return null;
    }
  }
}
