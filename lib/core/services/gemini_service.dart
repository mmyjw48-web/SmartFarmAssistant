import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../features/livestock/models/livestock_model.dart';

/// Central service for all Gemini AI interactions.
/// Used by both livestock diagnosis and crop recommendation features.
class GeminiService {
  // ── Replace with your actual Gemini API key ───────────────────────
  // Best practice: store in --dart-define or environment config,
  // never commit the raw key to version control.
 static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
 
  static final GenerativeModel _model = GenerativeModel(
    // model: 'gemini-1.5-flash',

    model: 'gemini-2.5-flash',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.2,       // balanced accuracy vs creativity
      maxOutputTokens: 2048,
    ),
  );

  // ── Livestock Disease Diagnosis ────────────────────────────────────
  /// Sends structured livestock data to Gemini and parses the result.
  /// Returns a [Map] with keys: condition, risk, actions, info.
  static Future<Map<String, dynamic>> diagnoseLivestock(
      LivestockInput input) async {
    final prompt = _buildLivestockPrompt(input);

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      final text = response.text ?? '';
print("🔥 RAW AI RESPONSE:");
print(text);
      return _parseLivestockResponse(text);
    } catch (e) {
      throw Exception('AI diagnosis failed: $e');
    }
  }

  // ── Crop Recommendation ────────────────────────────────────────────
  /// Sends farm conditions to Gemini and returns crop recommendations.
  static Future<Map<String, dynamic>> recommendCrops({
    required String soilType,
    required String season,
    required String location,
    required String landSize,
  }) async {
    final prompt = _buildCropPrompt(
      soilType: soilType,
      season: season,
      location: location,
      landSize: landSize,
    );

    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);


      
      final text = response.text ?? '';
      print("🌱 CROP RAW AI RESPONSE:");
print(text);

    //   final text = response.candidates.isNotEmpty &&
    //     response.candidates.first.content.parts.isNotEmpty &&
    //     response.candidates.first.content.parts.first is TextPart
    // ? (response.candidates.first.content.parts.first as TextPart).text
    // : '';

      return _parseCropResponse(text);
    } catch (e) {
      throw Exception('Crop recommendation failed: $e');
    }
  }

  // ── AI Chat ────────────────────────────────────────────────────────
  /// Sends a user message with farming context and returns AI reply.
  
  // static Future<String> chat({
  //   required String userMessage,
  //   required List<Map<String, String>> history,
  // }) async {
  //   // Build conversation history for context
  //   final contents = <Content>[];

  //   // System context as first user message
  //   contents.add(Content.text(_chatSystemPrompt()));

  //   // Add prior messages
  //   for (final msg in history) {
  //     if (msg['role'] == 'user') {
  //       contents.add(Content.text(msg['content'] ?? ''));
  //     } else {
  //       contents.add(Content.model([TextPart(msg['content'] ?? '')]));
  //     }
  //   }

  //   // Add current user message
  //   contents.add(Content.text(userMessage));

  //   try {
  //     final response = await _model.generateContent(contents);
  //     return response.text ?? 'I could not generate a response. Please try again.';
  //   } catch (e) {
  //     throw Exception('Chat failed: $e');
  //   }
  // }

  static Future<String> chat({
  required String userMessage,
  required List<Map<String, String>> history,
}) async {
  final contents = <Content>[];

  // System prompt
  contents.add(Content.text(_chatSystemPrompt()));

  // History
  for (final msg in history) {
    if (msg['role'] == 'user') {
      contents.add(Content.text(msg['content'] ?? ''));
    } else {
      contents.add(Content.model([TextPart(msg['content'] ?? '')]));
    }
  }

  // Current message
  contents.add(Content.text(userMessage));

  int retries = 3;

  for (int attempt = 0; attempt < retries; attempt++) {
    try {
      final response = await _model.generateContent(contents);
      return response.text ?? 'No response from AI.';
    } catch (e) {
      if (attempt == retries - 1) {
        throw Exception('Chat failed after retries: $e');
      }

      await Future.delayed(Duration(seconds: 2 + attempt));
    }
  }

  throw Exception('Unexpected error');
}

  // ──────────────────────────────────────────────────────────────────
  // PRIVATE: Prompt Builders
  // ──────────────────────────────────────────────────────────────────

  static String _buildLivestockPrompt(LivestockInput input) {
    final symptomList =
        input.symptoms.map((s) => s.label).join(', ');

    return '''
You are a professional veterinary AI assistant specializing in livestock health.
A farmer has reported the following about their animal:

- Animal Type: ${input.animalType.label}
- Symptoms: $symptomList
- Animal Age: ${input.ageRange.label}
- Duration of Symptoms: ${input.onset.label}

Based on this information, provide a diagnosis in the following EXACT JSON format.
Return ONLY the JSON object, no other text, no markdown, no explanation:

{
  "condition": "Name of the most likely disease or condition",
  "risk": "High | Medium | Low",
  "actions": [
    "First immediate action the farmer should take",
    "Second action",
    "Third action"
  ],
  "info": "One sentence of additional context or warning"
}

Rules:
- Be specific with the condition name
- Risk must be exactly one of: High, Medium, Low
- Provide 3 to 5 practical actions
- Keep each action short and actionable
- If symptoms are unclear, suggest veterinary consultation
''';
  }

  static String _buildCropPrompt({
    required String soilType,
    required String season,
    required String location,
    required String landSize,
  }) {
    return '''
You are an expert agricultural AI assistant.
A farmer has provided the following farm conditions:

- Soil Type: $soilType
- Current Season: $season
- Location / Region: $location
- Land Size: $landSize hectares

Provide crop recommendations in the following EXACT JSON format.
Return ONLY valid JSON. Do not include explanations, markdown, or any text outside the JSON.
Ensure "crops" is always a JSON array of objects, even if empty.

{
  "crops": [
    {
      "name": "Crop name",
      "suitability": "High | Medium",
      "reason": "Why this crop suits the conditions",
      "tips": "Key planting or care tip"
    }
  ],
  "general_advice": "One overall farming advice for these conditions",
  "risks": "Main risk or challenge to watch for"
}

Rules:
- Recommend ONLY 3 crops
- Keep "reason" VERY short (max 12 words)
- Keep "tips" VERY short (max 12 words)
- Be specific and practical
- Tailor advice to the given region and season
If you cannot complete full JSON, return an empty crops array:
{
  "crops": [],
  "general_advice": "",
  "risks": ""
}
IMPORTANT: Keep the entire JSON under 300 words
''';

  }

  static String _chatSystemPrompt() {
    return '''
You are Smart Farm Assistant, an AI-powered agricultural advisor.
Your role is to help farmers with:
- Livestock health and disease prevention
- Crop selection, planting, and care
- Pest and disease management
- Soil and weather considerations
- General farming best practices

Guidelines:
- Give practical, simple, actionable advice
- Use clear language suitable for farmers
- Keep responses concise (3-5 sentences unless more detail is needed)
- If asked about a specific disease or crop issue, be specific
- Always recommend consulting a local expert for serious issues
- Be friendly and encouraging

Use markdown formatting like:
- **bold** for important actions
- bullet points when needed

Now respond to the farmer's question:
''';
  }

  // ──────────────────────────────────────────────────────────────────
  // PRIVATE: Response Parsers
  // ──────────────────────────────────────────────────────────────────

  static Map<String, dynamic> _parseLivestockResponse(String raw) {
    try {
      // Clean up any markdown code fences Gemini might add
      String cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Find JSON object boundaries
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start == -1 || end == -1) throw const FormatException('No JSON found');

      final jsonStr = cleaned.substring(start, end + 1);
      if (!cleaned.trim().endsWith('}')) {
  cleaned = cleaned + '}';
}
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      return {
        'condition': parsed['condition'] ?? 'Unknown condition',
        'risk': parsed['risk'] ?? 'Unknown',
        'actions': List<String>.from(parsed['actions'] ?? []),
        'info': parsed['info'],
      };
    } 
    // catch (_) {
      // // Return safe fallback if parsing fails
      // return {
      //   'condition': 'Unable to determine',
      //   'risk': 'Unknown',
      //   'actions': [
      //     'Isolate the animal immediately.',
      //     'Consult a local veterinarian.',
      //     'Monitor other animals for similar symptoms.',
      //   ],
      //   'info': 'AI could not parse a clear diagnosis. Please seek expert advice.',
      // };
    // }

    catch (e) {
  throw Exception('Failed to parse AI response: $e\nRaw: $raw');
}
  }

  static Map<String, dynamic> _parseCropResponse(String raw) {
    try {
      String cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
if (!cleaned.trim().endsWith('}')) {
  throw Exception("Truncated JSON detected");
}
      final start = cleaned.indexOf('{');
      final end = cleaned.lastIndexOf('}');
      if (start == -1 || end == -1) throw const FormatException('No JSON found');

 final jsonStr = cleaned.substring(start, end + 1);

      if (!cleaned.trim().endsWith('}')) {
  cleaned = cleaned + '}';
}
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      return {
        // 'crops': parsed['crops'] ?? [],
        'crops': (parsed['crops'] is List)
    ? List<Map<String, dynamic>>.from(parsed['crops'])
    : [],
        'general_advice': parsed['general_advice'] ?? '',
        'risks': parsed['risks'] ?? '',
      };
    } 
    // catch (_) {
    //   return {
    //     'crops': [],
    //     'general_advice': 'Please consult a local agricultural officer.',
    //     'risks': 'Unable to assess risks without more data.',
    //   };
    // }

    catch (e) {
  print("❌ CROP PARSE ERROR:");
  print(e);
  print("RAW:");
  print(raw);

  throw Exception("Crop parsing failed");
}
  }
}
// #########################################################################################################################################
