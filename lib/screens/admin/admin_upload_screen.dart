import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/question_model.dart';
import '../../providers/department_provider.dart';
import '../../services/exam_service.dart';
import '../../services/mcq_generator_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/loading_overlay.dart';

class AdminUploadScreen extends ConsumerStatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  ConsumerState<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends ConsumerState<AdminUploadScreen> {
  PlatformFile? _pickedFile;
  String? _selectedDeptId;
  String _examTitle = '';
  int _questionCount = 40;
  bool _loading = false;
  String _statusMsg = '';
  double _progress = 0;
  List<Map<String, dynamic>> _generatedQuestions = [];

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc', 'txt', 'pptx', 'xlsx'],
      withData: kIsWeb,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _examTitle = result.files.first.name
            .replaceAll(RegExp(r'\.[^.]+$'), '');
      });
    }
  }

  Future<void> _generate() async {
    if (_pickedFile == null) {
      _showSnack('Please pick a file first', AppTheme.wrongRed);
      return;
    }
    if (_selectedDeptId == null) {
      _showSnack('Please select a department', AppTheme.wrongRed);
      return;
    }
    if (_examTitle.trim().isEmpty) {
      _showSnack('Please enter an exam title', AppTheme.wrongRed);
      return;
    }

    setState(() {
      _loading = true;
      _progress = 0.1;
      _statusMsg = 'Extracting text from file...';
      _generatedQuestions = [];
    });

    try {
      // 1. Upload file to Supabase Storage
      setState(() { _progress = 0.2; _statusMsg = 'Uploading file...'; });

      String? fileUrl;
      final ext = _pickedFile!.extension ?? 'pdf';
      final fileName =
          'uploads/${DateTime.now().millisecondsSinceEpoch}_${_pickedFile!.name}';

      if (kIsWeb && _pickedFile!.bytes != null) {
        await SupabaseService.uploadsBucket.uploadBinary(
            fileName, _pickedFile!.bytes!);
      } else if (_pickedFile!.path != null) {
        await SupabaseService.uploadsBucket.upload(
            fileName, File(_pickedFile!.path!));
      }
      fileUrl = SupabaseService.uploadsBucket.getPublicUrl(fileName);

      // 2. Extract text
      setState(() { _progress = 0.4; _statusMsg = 'Extracting text content...'; });

      String text = '';
      if (!kIsWeb && _pickedFile!.path != null) {
        text = await McqGeneratorService.instance.extractText(
          _pickedFile!.path!,
          ext,
        );
      } else if (_pickedFile!.bytes != null) {
        // Web: basic fallback
        text = String.fromCharCodes(_pickedFile!.bytes!.take(8000));
      }

      if (text.trim().isEmpty) {
        text = 'Sample study material for ${_examTitle}. '
            'The AI will generate relevant questions based on the exam topic.';
      }

      // 3. Create exam record
      setState(() { _progress = 0.55; _statusMsg = 'Creating exam record...'; });

      final exam = await ExamService.instance.createExam(
        title: _examTitle.trim(),
        departmentId: _selectedDeptId!,
        description: 'Auto-generated from: ${_pickedFile!.name}',
        durationMinutes: 60,
        passMarkPercent: 50.0,
      );

      // Log upload
      await SupabaseService.uploadsTable.insert({
        'exam_id': exam.id,
        'file_name': _pickedFile!.name,
        'file_url': fileUrl,
        'file_type': ext,
        'uploaded_by': SupabaseService.currentUser?.id,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 4. Generate MCQs via AI
      setState(() { _progress = 0.7; _statusMsg = 'Generating MCQs with AI...'; });

      final mcqs = await McqGeneratorService.instance.generateMcqs(
        text: text,
        examId: exam.id,
        count: _questionCount,
      );

      setState(() {
        _generatedQuestions = mcqs;
        _progress = 0.85;
        _statusMsg = 'Saving ${mcqs.length} questions...';
      });

      // 5. Save questions
      final questions = mcqs.asMap().entries.map((e) {
        final q = e.value;
        return QuestionModel(
          id: 'q_${exam.id}_${e.key}',
          examId: exam.id,
          questionText: q['question_text'] as String,
          optionA: q['option_a'] as String,
          optionB: q['option_b'] as String,
          optionC: q['option_c'] as String,
          optionD: q['option_d'] as String,
          correctOption: q['correct_option'] as String,
          explanation: q['explanation'] as String?,
          orderIndex: e.key,
        );
      }).toList();

      await ExamService.instance.insertQuestions(questions);

      setState(() {
        _progress = 1.0;
        _statusMsg = '✅ Done! ${questions.length} questions generated.';
        _loading = false;
      });

      _showSnack(
        '✅ Exam "${_examTitle}" created with ${questions.length} MCQs!',
        AppTheme.correctGreen,
      );
    } catch (e) {
      setState(() {
        _loading = false;
        _statusMsg = '❌ Error: $e';
      });
      _showSnack('Error: $e', AppTheme.wrongRed);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deptsAsync = ref.watch(departmentsProvider);

    return LoadingOverlay(
      isLoading: _loading,
      loadingText: _statusMsg,
      child: Scaffold(
        appBar: AppBar(title: const Text('Upload & Generate MCQs')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.psychology, color: AppTheme.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Upload PDF, DOCX, PPT, or TXT — AI auto-generates MCQs',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 20),

              // Department selector
              const Text('Department',
                  style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(height: 8),
              deptsAsync.when(
                data: (depts) => DropdownButtonFormField<String>(
                  value: _selectedDeptId,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.school, color: Colors.white54),
                  ),
                  hint: const Text('Select department',
                      style: TextStyle(color: Colors.white38)),
                  items: depts
                      .map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text('${d.year} — ${d.name}'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDeptId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error loading departments: $e',
                    style: const TextStyle(color: AppTheme.wrongRed)),
              ),

              const SizedBox(height: 16),

              // Exam title
              TextField(
                onChanged: (v) => setState(() => _examTitle = v),
                controller: TextEditingController(text: _examTitle),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Exam Title',
                  prefixIcon: const Icon(Icons.quiz, color: Colors.white54),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Question count
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number of Questions: $_questionCount',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  Slider(
                    value: _questionCount.toDouble(),
                    min: 10,
                    max: 60,
                    divisions: 10,
                    activeColor: AppTheme.primary,
                    label: '$_questionCount',
                    onChanged: (v) =>
                        setState(() => _questionCount = v.round()),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // File picker
              GestureDetector(
                onTap: _loading ? null : _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _pickedFile != null
                          ? AppTheme.correctGreen
                          : Colors.white24,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _pickedFile != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppTheme.correctGreen, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              _pickedFile!.name,
                              style: const TextStyle(
                                  color: AppTheme.correctGreen,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${(_pickedFile!.size / 1024).toStringAsFixed(1)} KB',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file,
                                color: Colors.white38, size: 36),
                            SizedBox(height: 8),
                            Text(
                              'Tap to select PDF / DOCX / PPT / TXT',
                              style: TextStyle(color: Colors.white38),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Max 20 MB',
                              style: TextStyle(
                                  color: Colors.white24, fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              // Progress bar (when loading)
              if (_loading || _progress > 0) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusMsg,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white12,
                        valueColor:
                            const AlwaysStoppedAnimation(AppTheme.primary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              ElevatedButton.icon(
                onPressed: _loading ? null : _generate,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate MCQs with AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                  minimumSize: const Size(double.infinity, 54),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ).animate().fadeIn(delay: 200.ms),

              // Preview generated questions
              if (_generatedQuestions.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Preview (${_generatedQuestions.length} questions generated)',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                ..._generatedQuestions.take(3).map((q) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['question_text'] as String,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'A) ${q['option_a']}  ✓ ${q['correct_option']}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    )),
                if (_generatedQuestions.length > 3)
                  Text(
                    '...and ${_generatedQuestions.length - 3} more questions',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                  ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
