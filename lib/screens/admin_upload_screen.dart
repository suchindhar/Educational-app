// lib/screens/admin_upload_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../constants/app_theme.dart';
import '../services/supabase_service.dart';
import '../services/github_storage_service.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  String? selectedUnitId;
  String? selectedTopicId;
  File? selectedFile;
  bool uploading = false;
  String? statusMsg;
  bool statusOk = false;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  void _checkAdmin() {
    final user = SupabaseService.currentUser;
    // Keep this consistent with ProfileScreen check
    if (user?.email == 'admin@lexquest.com' || user?.email == 'your-email@gmail.com') {
      setState(() => isAdmin = true);
    }
  }

  // Question form
  final qCtrl = TextEditingController();
  final opt0 = TextEditingController();
  final opt1 = TextEditingController();
  final opt2 = TextEditingController();
  final opt3 = TextEditingController();
  final expCtrl = TextEditingController();
  int correctIdx = 0;
  bool savingQ = false;
  String? qStatus;

  final List<Map<String, dynamic>> units = [
    {
      'id': 'unit1',
      'name': 'Unit 1 – Historical Background',
      'topics': [
        {'id': 't1_1', 'name': 'Regulating Act 1773'},
        {'id': 't1_2', 'name': "Pitt's India Act 1784"},
        {'id': 't1_3', 'name': 'Charter Acts'},
        {'id': 't1_4', 'name': 'Government of India Act 1858'},
        {'id': 't1_5', 'name': 'Indian Councils Acts'},
        {'id': 't1_6', 'name': 'Government of India Act 1935'},
        {'id': 't1_7', 'name': 'Indian Independence Act 1947'},
        {'id': 't1_8', 'name': 'Constituent Assembly'},
      ]
    },
    {
      'id': 'unit2',
      'name': 'Unit 2 – Making of Constitution',
      'topics': [
        {'id': 't2_1', 'name': 'Drafting Committee & Sources'},
        {'id': 't2_2', 'name': 'Preamble'},
        {'id': 't2_3', 'name': 'Salient Features'},
        {'id': 't2_4', 'name': 'Nature of Constitution'},
      ]
    },
    {
      'id': 'unit3',
      'name': 'Unit 3 – Union and Citizenship',
      'topics': [
        {'id': 't3_1', 'name': 'Articles 1–4'},
        {'id': 't3_2', 'name': 'Formation of States'},
        {'id': 't3_3', 'name': 'Citizenship (Art 5–11)'},
        {'id': 't3_4', 'name': 'Citizenship Act 1955'},
      ]
    },
    {
      'id': 'unit4',
      'name': 'Unit 4 – Fundamental Rights',
      'topics': [
        {'id': 't4_1', 'name': 'Right to Equality (Art 14–18)'},
        {'id': 't4_2', 'name': 'Right to Freedom (Art 19–22)'},
        {'id': 't4_3', 'name': 'Right Against Exploitation'},
        {'id': 't4_4', 'name': 'Right to Religion'},
        {'id': 't4_5', 'name': 'Cultural & Educational Rights'},
        {'id': 't4_6', 'name': 'Constitutional Remedies'},
        {'id': 't4_7', 'name': 'Doctrines'},
      ]
    },
    {
      'id': 'unit5',
      'name': 'Unit 5 – DPSP & Fundamental Duties',
      'topics': [
        {'id': 't5_1', 'name': 'DPSP Classification'},
        {'id': 't5_2', 'name': 'FR vs DPSP'},
        {'id': 't5_3', 'name': 'Fundamental Duties (Art 51A)'},
      ]
    },
    {
      'id': 'unit6',
      'name': 'Unit 6 – Amendment & Basic Structure',
      'topics': [
        {'id': 't6_1', 'name': 'Article 368'},
        {'id': 't6_2', 'name': 'Types of Amendment'},
        {'id': 't6_3', 'name': 'Basic Structure Doctrine'},
      ]
    },
  ];

  @override
  void dispose() {
    qCtrl.dispose(); opt0.dispose(); opt1.dispose();
    opt2.dispose(); opt3.dispose(); expCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'pptx'],
    );
    if (res != null) {
      setState(() => selectedFile = File(res.files.single.path!));
    }
  }

  Future<void> _upload() async {
    if (selectedFile == null ||
        selectedUnitId == null ||
        selectedTopicId == null) {
      setState(() {
        statusMsg = 'Please select unit, topic and a file (PDF/PPT).';
        statusOk = false;
      });
      return;
    }
    setState(() { uploading = true; statusMsg = null; });
    
    try {
      // 1. Upload to GitHub (Free & Unlimited Storage)
      final String folder = 'materials/$selectedUnitId';
      final githubUrl = await GitHubStorageService.uploadFile(
          file: selectedFile!, 
          folder: folder
      );

      if (githubUrl != null) {
        // 2. Link the GitHub URL to our Supabase Database
        final dbOk = await SupabaseService.updateTopicFileUrl(selectedTopicId!, githubUrl);
        
        setState(() {
          statusOk = dbOk;
          statusMsg = dbOk 
              ? '✅ Uploaded to GitHub & Linked!' 
              : '⚠️ Uploaded to GitHub, but failed to link to DB.';
          if (dbOk) selectedFile = null;
        });
      } else {
        setState(() {
          statusOk = false;
          statusMsg = '❌ GitHub upload failed. Check token/connection.';
        });
      }
    } catch (e) {
      setState(() {
        statusOk = false;
        statusMsg = '❌ Error: $e';
      });
    } finally {
      setState(() => uploading = false);
    }
  }

  Future<void> _saveQuestion() async {
    if (selectedUnitId == null ||
        qCtrl.text.isEmpty ||
        opt0.text.isEmpty ||
        opt1.text.isEmpty) {
      setState(() => qStatus = 'Fill question, unit, and at least 2 options.');
      return;
    }
    setState(() { savingQ = true; qStatus = null; });
    try {
      await SupabaseService.insertQuestion({
        'unit_id': selectedUnitId,
        'question': qCtrl.text.trim(),
        'options': [opt0.text.trim(), opt1.text.trim(),
          if (opt2.text.isNotEmpty) opt2.text.trim(),
          if (opt3.text.isNotEmpty) opt3.text.trim(),
        ],
        'correct_index': correctIdx,
        'explanation': expCtrl.text.trim(),
        'type': 'mcq',
        'difficulty': 1,
      });
      setState(() {
        savingQ = false;
        qStatus = '✅ Question saved!';
        qCtrl.clear(); opt0.clear(); opt1.clear();
        opt2.clear(); opt3.clear(); expCtrl.clear();
        correctIdx = 0;
      });
    } catch (e) {
      setState(() {
        savingQ = false;
        qStatus = '❌ Error: $e';
      });
    }
  }

  Map<String, dynamic>? get _selectedUnit =>
      units.firstWhere((u) => u['id'] == selectedUnitId,
          orElse: () => {});

  @override
  Widget build(BuildContext context) {
    if (!isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_person_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text('Restricted Access',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Only designated admins can upload content.'),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(title: const Text('Admin: Upload Content')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 Supabase Setup',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary)),
                  SizedBox(height: 6),
                  Text(
                    '1. Go to supabase.com → create free project\n'
                    '2. Run the SQL from the README\n'
                    '3. Create storage bucket named "pdfs"\n'
                    '4. Add your URL & anon key in main.dart\n'
                    '5. Use Table Editor to add content directly',
                    style: TextStyle(
                        color: AppColors.textMedium,
                        fontSize: 12,
                        height: 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionTitle('📄 Upload Study Material (PDF/PPT)'),
            const SizedBox(height: 12),

            // Unit selector
            DropdownButtonFormField<String>(
              value: selectedUnitId,
              decoration: const InputDecoration(labelText: 'Select Unit'),
              items: units
                  .map((u) => DropdownMenuItem(
                      value: u['id'] as String,
                      child: Text(u['name'] as String,
                          style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) => setState(() {
                selectedUnitId = v;
                selectedTopicId = null;
              }),
            ),

            if (selectedUnitId != null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTopicId,
                decoration: const InputDecoration(labelText: 'Select Topic'),
                items: (_selectedUnit?['topics'] as List? ?? [])
                    .map((t) => DropdownMenuItem(
                        value: t['id'] as String,
                        child: Text(t['name'] as String,
                            style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => setState(() => selectedTopicId = v),
              ),
            ],

            const SizedBox(height: 14),

            // File picker
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedFile != null
                        ? AppColors.success
                        : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedFile != null
                          ? (selectedFile!.path.endsWith('.pdf') ? Icons.picture_as_pdf : Icons.slideshow)
                          : Icons.upload_file,
                      color: selectedFile != null
                          ? AppColors.success
                          : AppColors.textMedium,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedFile?.path.split('/').last ??
                            'Tap to select PDF or PPT file',
                        style: TextStyle(
                          color: selectedFile != null
                              ? AppColors.textDark
                              : AppColors.textMedium,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton.icon(
              onPressed: uploading ? null : _upload,
              icon: uploading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload),
              label: Text(uploading ? 'Uploading to GitHub...' : 'Upload to GitHub (Free)'),
            ),

            if (statusMsg != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(statusMsg!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: statusOk
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold)),
              ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            _sectionTitle('❓ Add Question'),
            const SizedBox(height: 12),

            TextField(
              controller: qCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Question *'),
            ),
            const SizedBox(height: 10),
            ...List.generate(4, (i) {
              final ctrlList = [opt0, opt1, opt2, opt3];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(
                      value: i,
                      groupValue: correctIdx,
                      activeColor: AppColors.success,
                      onChanged: (v) =>
                          setState(() => correctIdx = v!),
                    ),
                    Expanded(
                      child: TextField(
                        controller: ctrlList[i],
                        decoration: InputDecoration(
                          labelText:
                              'Option ${i + 1}${i < 2 ? ' *' : ''}',
                          hintText: 'Correct if radio selected',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            TextField(
              controller: expCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Explanation'),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: savingQ ? null : _saveQuestion,
              icon: savingQ
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label:
                  Text(savingQ ? 'Saving...' : 'Save Question'),
            ),
            if (qStatus != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(qStatus!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: qStatus!.contains('✅')
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.bold)),
              ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark));
  }
}
