import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_models.dart';

/// Service that communicates with Gemini API for intent extraction
/// and conversational booking orchestration.
/// Falls back to mock responses on rate limiting or errors.
class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;
  bool _useMockFallback = false;

  /// Initialize with API key. If key is empty, uses mock mode.
  Future<void> initialize(String apiKey) async {
    if (apiKey.isEmpty) {
      _useMockFallback = true;
      _isInitialized = true;
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topP: 0.9,
          maxOutputTokens: 1024,
          responseMimeType: 'application/json',
        ),
        systemInstruction: Content.system(_systemPrompt),
      );

      _chatSession = _model!.startChat();
      _isInitialized = true;
      _useMockFallback = false;
    } catch (e) {
      _useMockFallback = true;
      _isInitialized = true;
    }
  }

  /// Send a user message and get a structured AI response.
  /// [userMessage] is what the user typed.
  /// [currentBookingState] is the current extracted booking info.
  Future<AiResponse> sendMessage(
    String userMessage,
    BookingState currentBookingState, {
    String? lastAiMessage,
    Uint8List? audioBytes,
    String? mimeType,
  }) async {
    if (!_isInitialized) {
      return const AiResponse(
        type: AiResponseType.error,
        message: 'AI service not initialized.',
      );
    }

    if (_useMockFallback) {
      return _mockResponse(userMessage, currentBookingState);
    }

    try {
      final prompt = _buildPrompt(userMessage, currentBookingState, lastAiMessage);
      
      late GenerateContentResponse response;
      if (audioBytes != null) {
        response = await _chatSession!.sendMessage(
          Content.multi([
            TextPart(prompt),
            DataPart(mimeType ?? 'audio/webm', audioBytes),
          ]),
        );
      } else {
        response = await _chatSession!.sendMessage(
          Content.text(prompt),
        );
      }

      final text = response.text;
      if (text == null || text.isEmpty) {
        return _mockResponse(userMessage, currentBookingState);
      }

      return _parseGeminiResponse(text);
    } catch (e) {
      // Rate limited or network error → fallback to mock
      _useMockFallback = true;
      return _mockResponse(userMessage, currentBookingState);
    }
  }

  /// Reset the chat session (new conversation).
  void resetConversation() {
    if (_model != null && !_useMockFallback) {
      _chatSession = _model!.startChat();
    }
  }

  bool get isMockMode => _useMockFallback;

  // ─── PRIVATE ─────────────────────────────────────────────

  String _buildPrompt(String userMessage, BookingState state, String? lastAiMessage) {
    return '''
Previous question you asked: "${lastAiMessage ?? 'None'}"
User message: "$userMessage"

Current booking state: ${jsonEncode(state.toJson())}
Missing required fields: ${state.missingRequiredFields.join(', ')}

Instructions:
1. Analyze the user's message to extract any of the missing required fields.
2. If all required fields are now collected, set should_search_providers to true.
3. If fields are still missing, decide what the next most logical question is to ask based on what is missing, and formulate a smooth, conversational response.
4. Respond strictly with the JSON object.
''';
  }

  AiResponse _parseGeminiResponse(String rawText) {
    try {
      // Try to extract JSON from the response
      String jsonStr = rawText.trim();

      // Handle markdown code blocks
      if (jsonStr.contains('```')) {
        final match = RegExp(r'```(?:json)?\s*([\s\S]*?)```').firstMatch(jsonStr);
        if (match != null) {
          jsonStr = match.group(1)!.trim();
        }
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      final message = json['message'] as String? ?? '';
      final extractedFields = json['extracted_fields'] as Map<String, dynamic>?;
      final shouldSearch = json['should_search_providers'] as bool? ?? false;

      AiResponseType type;
      if (shouldSearch) {
        type = AiResponseType.providerCards;
      } else {
        type = AiResponseType.question;
      }

      return AiResponse(
        type: type,
        message: message,
        extractedFields: extractedFields,
        shouldSearchProviders: shouldSearch,
      );
    } catch (e) {
      // If JSON parsing fails, treat the raw text as a simple AI message
      return AiResponse(
        type: AiResponseType.question,
        message: rawText.trim(),
      );
    }
  }

  /// Smart mock response that simulates the AI's behavior.
  AiResponse _mockResponse(String userMessage, BookingState state) {
    final msg = userMessage.toLowerCase();
    final extracted = <String, dynamic>{};

    // ── Extract service type ──
    if (state.service == null) {
      if (msg.contains('plumb')) {
        extracted['service'] = 'Plumbing';
      } else if (msg.contains('clean')) {
        extracted['service'] = 'Cleaning';
      } else if (msg.contains('electri')) {
        extracted['service'] = 'Electrical';
      } else if (msg.contains('repair') || msg.contains('fix')) {
        extracted['service'] = 'Repairing';
      } else if (msg.contains('heat')) {
        extracted['service'] = 'Heating';
      } else if (msg.contains('ac') || msg.contains('air condition')) {
        extracted['service'] = 'Repairing';
        extracted['issueDescription'] = 'AC repair/maintenance';
      }
    }

    // ── Extract location info ──
    if (msg.contains('dha')) {
      extracted['area'] = 'DHA';
      final phaseMatch = RegExp(r'phase\s*(\d+)', caseSensitive: false).firstMatch(msg);
      if (phaseMatch != null) {
        extracted['phase'] = phaseMatch.group(1);
      }
    }
    if (msg.contains('lahore')) {
      extracted['area'] = extracted['area'] ?? 'Lahore';
    }
    if (msg.contains('bogor') || msg.contains('situ')) {
      extracted['area'] = 'Situ Udik, Bogor';
      extracted['fullAddress'] = 'Komplek Situ Udik, Jl. Raya Dramaga, Bogor';
    }

    // ── Extract street ──
    final streetMatch = RegExp(r'street\s*(\d+)', caseSensitive: false).firstMatch(msg);
    if (streetMatch != null) {
      extracted['street'] = streetMatch.group(1);
    }

    // ── Extract phase (standalone) ──
    if (extracted['phase'] == null) {
      final phaseOnly = RegExp(r'phase\s*(\d+)', caseSensitive: false).firstMatch(msg);
      if (phaseOnly != null) {
        extracted['phase'] = phaseOnly.group(1);
      }
      // Also handle just a number if we're expecting a phase
      if (state.area != null && state.phase == null && extracted['phase'] == null) {
        final justNumber = RegExp(r'^(\d+)$').firstMatch(msg.trim());
        if (justNumber != null) {
          extracted['phase'] = justNumber.group(1);
        }
      }
    }

    // ── Extract date/time ──
    if (msg.contains('tomorrow')) {
      extracted['date'] = 'Tomorrow';
    } else if (msg.contains('today')) {
      extracted['date'] = 'Today';
    } else if (msg.contains('monday')) {
      extracted['date'] = 'Monday';
    } else if (msg.contains('tuesday')) {
      extracted['date'] = 'Tuesday';
    }

    final timeMatch = RegExp(r'(\d{1,2})\s*(am|pm|AM|PM)', caseSensitive: false).firstMatch(msg);
    if (timeMatch != null) {
      extracted['time'] = '${timeMatch.group(1)} ${timeMatch.group(2)!.toUpperCase()}';
    }
    if (msg.contains('morning')) {
      extracted['time'] = extracted['time'] ?? '10:00 AM';
    } else if (msg.contains('afternoon')) {
      extracted['time'] = extracted['time'] ?? '2:00 PM';
    } else if (msg.contains('evening')) {
      extracted['time'] = extracted['time'] ?? '6:00 PM';
    }

    // ── Extract issue description ──
    if (msg.contains('leak')) {
      extracted['issueDescription'] = 'Water leakage';
    } else if (msg.contains('broken')) {
      extracted['issueDescription'] = 'Broken fixture';
    } else if (msg.contains('noise') || msg.contains('noisy')) {
      extracted['issueDescription'] = 'Making unusual noise';
    } else if (msg.contains('not working')) {
      extracted['issueDescription'] = 'Not working properly';
    }

    // ── Extract urgency ──
    if (msg.contains('urgent') || msg.contains('asap') || msg.contains('emergency')) {
      extracted['urgency'] = 'urgent';
    }

    // ── Apply extracted fields to a copy of state to check what's missing ──
    final tempState = BookingState(
      service: extracted['service'] as String? ?? state.service,
      area: extracted['area'] as String? ?? state.area,
      phase: extracted['phase'] as String? ?? state.phase,
      street: extracted['street'] as String? ?? state.street,
      fullAddress: extracted['fullAddress'] as String? ?? state.fullAddress,
      date: extracted['date'] as String? ?? state.date,
      time: extracted['time'] as String? ?? state.time,
      issueDescription:
          extracted['issueDescription'] as String? ?? state.issueDescription,
      urgency: extracted['urgency'] as String? ?? state.urgency,
    );

    // ── Generate response based on what's still missing ──
    final missing = tempState.missingRequiredFields;

    if (missing.isEmpty) {
      // All required fields collected → search providers
      final svc = tempState.service ?? 'service';
      return AiResponse(
        type: AiResponseType.providerCards,
        message:
            'I have all the details. Let me find the best $svc providers near you...',
        extractedFields: extracted.isEmpty ? null : extracted,
        shouldSearchProviders: true,
      );
    }

    // Ask for the FIRST missing thing only
    String question;
    if (missing.contains('service type')) {
      question =
          'Hi! I\'m your HelperHive assistant. What service do you need? '
          'For example: plumbing, cleaning, electrical, repair, etc.';
    } else if (missing.contains('complete address')) {
      if (tempState.area != null && tempState.phase == null) {
        question =
            'Which phase/block in ${tempState.area} should the ${tempState.service?.toLowerCase()} visit?';
      } else if (tempState.area != null &&
          tempState.phase != null &&
          tempState.street == null) {
        question =
            'Can you share the street number or house number in ${tempState.area} Phase ${tempState.phase}?';
      } else {
        question =
            'What area/location should the ${tempState.service?.toLowerCase()} visit?';
      }
    } else if (missing.contains('date')) {
      question =
          'When do you need the ${tempState.service?.toLowerCase()}? (e.g., today, tomorrow, Monday)';
    } else if (missing.contains('time')) {
      question =
          'What time works best for you? (e.g., 2 PM, morning, afternoon)';
    } else {
      question = 'Can you provide more details about: ${missing.join(", ")}?';
    }

    return AiResponse(
      type: AiResponseType.question,
      message: question,
      extractedFields: extracted.isEmpty ? null : extracted,
      shouldSearchProviders: false,
    );
  }

  // ─── SYSTEM PROMPT ───────────────────────────────────────

  static const String _systemPrompt = '''
You are HelperHive AI Assistant — an intelligent booking concierge for local home services.

YOUR ROLE:
- You are the conversational "brain" of the app. Analyze the context smoothly.
- Extract booking information from user messages (which may be text or transcribed/recorded speech).
- Ask ONLY for missing information (never ask what you already know).
- Be conversational, friendly, concise, and natural. Don't sound like a robot reading a checklist.
- Guide users to complete their booking logically. If they give partial answers, acknowledge it and ask for the rest.

MULTILINGUAL VOICE & SPEECH EXTRACTION:
- The user may speak or type in multiple languages, including English, Standard Urdu (in Arabic script), Romanized Urdu (e.g., "plumber chahye tomorrow 2 baje", "AC thik krna hai"), or Punjabi.
- Natively auto-detect the user's primary language and dialect (e.g. mixed Roman Urdu-English).
- Extract booking fields accurately from these dialects (e.g., "kal" -> "Tomorrow", "baje" -> time).
- Respond in the user's chosen language style (if they spoke or typed in Roman Urdu, respond naturally in Roman Urdu; if they spoke in English, respond in English, etc.) so they feel completely understood.

REQUIRED BOOKING FIELDS:
1. service (plumbing, cleaning, electrical, repairing, heating)
2. address (area, phase/block, street — OR full address)
3. date (today, tomorrow, specific day)
4. time (specific time or general: morning/afternoon/evening)

OPTIONAL FIELDS:
- issueDescription
- urgency (normal/urgent)

RULES:
- NEVER ask for information already provided
- Ask ONE question at a time for missing info
- When all required fields are collected, set should_search_providers to true
- Be smart about extracting multiple fields from one message

RESPONSE FORMAT (always respond in valid JSON):
{
  "message": "Your conversational response to the user formatted in their dialect/language",
  "extracted_fields": {
    "service": "extracted service or null",
    "area": "extracted area or null",
    "phase": "extracted phase or null",
    "street": "extracted street or null",
    "fullAddress": "full address if provided",
    "date": "extracted date or null",
    "time": "extracted time or null",
    "issueDescription": "extracted issue or null",
    "urgency": "normal or urgent"
  },
  "should_search_providers": false
}

Only include fields in extracted_fields that were actually mentioned in the CURRENT message.
Set should_search_providers to true ONLY when ALL required fields are filled.
''';
}
