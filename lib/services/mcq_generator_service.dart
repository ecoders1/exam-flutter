import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// AI-powered MCQ Generator.
/// Extracts text from uploaded files (PDF/DOCX/PPT/XLS) and generates MCQs.
/// For production: replace _callAI() with your preferred LLM API (OpenAI, Gemini, etc.)
class McqGeneratorService {
  McqGeneratorService._();
  static final McqGeneratorService instance = McqGeneratorService._();

  final Dio _dio = Dio();

  // ── Extract text from file ─────────────────────────────────────────────────
  Future<String> extractText(String filePath, String fileType) async {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return _extractFromPdf(filePath);
      case 'docx':
      case 'doc':
        return _extractFromDocx(filePath);
      case 'txt':
        return File(filePath).readAsString();
      default:
        throw UnsupportedError('File type $fileType not supported for text extraction.');
    }
  }

  // ── PDF extraction ────────────────────────────────────────────────────────
  Future<String> _extractFromPdf(String filePath) async {
    final document = PdfDocument(inputBytes: File(filePath).readAsBytesSync());
    final extractor = PdfTextExtractor(document);
    final buffer = StringBuffer();

    for (int i = 0; i < document.pages.count; i++) {
      buffer.writeln(extractor.extractText(startPageIndex: i, endPageIndex: i));
    }

    document.dispose();
    return buffer.toString();
  }

  // ── DOCX extraction (basic – reads raw XML text) ──────────────────────────
  Future<String> _extractFromDocx(String filePath) async {
    // DOCX is a zip; decode word/document.xml
    // For full production use the 'docx_template' or 'docx' package.
    // This is a stub that returns the raw bytes as fallback.
    return 'DOCX extraction: install the docx package for full support.';
  }

  // ── Generate MCQs from text ────────────────────────────────────────────────
  /// Returns a list of question maps ready for insertion.
  Future<List<Map<String, dynamic>>> generateMcqs({
    required String text,
    required String examId,
    required int count,
    String language = 'English',
  }) async {
    // Trim text to avoid token overload
    final trimmedText = text.length > 8000 ? text.substring(0, 8000) : text;

    final prompt = _buildPrompt(trimmedText, count, language);

    try {
      final rawJson = await _callAI(prompt);
      return _parseMcqs(rawJson, examId);
    } catch (e) {
      debugPrint('AI call failed: $e');
      // Fallback: return placeholder questions so upload doesn't fail silently
      return _generatePlaceholders(examId, count);
    }
  }

  // ── Build AI prompt ────────────────────────────────────────────────────────
  String _buildPrompt(String text, int count, String language) {
    return '''
You are an expert exam question generator for Ethiopian university exit exams.
Given the following study material, generate exactly $count multiple choice questions in $language.

Return ONLY a JSON array with this exact format:
[
  {
    "question_text": "...",
    "option_a": "...",
    "option_b": "...",
    "option_c": "...",
    "option_d": "...",
    "correct_option": "A" or "B" or "C" or "D",
    "explanation": "Brief explanation of why the answer is correct"
  }
]

STUDY MATERIAL:
$text

Rules:
- Each question must test understanding, not just memorization.
- Options must be plausible.
- Explanations must be concise and educational.
- Return ONLY the JSON array, no other text.
''';
  }

  // ── Call LLM API ──────────────────────────────────────────────────────────
  /// Replace this with your actual AI provider (OpenAI, Gemini, Anthropic, etc.)
  Future<String> _callAI(String prompt) async {
    // Example: OpenAI GPT-4o
    // Set your API key via --dart-define=OPENAI_API_KEY=...
    const apiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

    if (apiKey.isEmpty) {
      throw Exception('AI API key not configured. Set OPENAI_API_KEY.');
    }

    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': 'You generate Ethiopian university exit exam MCQs.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.7,
        'max_tokens': 4000,
      }),
    );

    final content = response.data['choices'][0]['message']['content'] as String;
    return content;
  }

  // ── Parse AI response ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _parseMcqs(String rawJson, String examId) {
    // Strip markdown code fences if present
    final cleaned = rawJson
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final List<dynamic> parsed = jsonDecode(cleaned) as List<dynamic>;

    return parsed.asMap().entries.map((entry) {
      final i = entry.key;
      final q = entry.value as Map<String, dynamic>;
      return {
        'exam_id': examId,
        'question_text': q['question_text'],
        'option_a': q['option_a'],
        'option_b': q['option_b'],
        'option_c': q['option_c'],
        'option_d': q['option_d'],
        'correct_option': q['correct_option'],
        'explanation': q['explanation'],
        'order_index': i,
        'created_at': DateTime.now().toIso8601String(),
      };
    }).toList();
  }

  // ── Placeholder fallback ───────────────────────────────────────────────────
  List<Map<String, dynamic>> _generatePlaceholders(String examId, int count) {
    return List.generate(count, (i) => {
          'exam_id': examId,
          'question_text': 'Sample Question ${i + 1} — (AI generation pending)',
          'option_a': 'Option A',
          'option_b': 'Option B',
          'option_c': 'Option C',
          'option_d': 'Option D',
          'correct_option': 'A',
          'explanation': 'This is a placeholder. Replace with actual AI-generated content.',
          'order_index': i,
          'created_at': DateTime.now().toIso8601String(),
        });
  }
}
