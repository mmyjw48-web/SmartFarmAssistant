import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../../../core/services/gemini_service.dart';

// ── Chat State ─────────────────────────────────────────────────────────
class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;       // AI is generating a response
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.errorMessage,
  });

  bool get isEmpty => messages.isEmpty;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ── Chat Notifier ──────────────────────────────────────────────────────
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState()) {
    _addWelcomeMessage();
  }

  // ── Add the welcome message when chat opens ─────────────────────
  void _addWelcomeMessage() {
    final welcome = ChatMessage(
      content: kChatWelcomeMessage,
      role: MessageRole.ai,
    );
    state = state.copyWith(messages: [welcome]);
  }

  // ── Send a message ──────────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add user message immediately
    final userMsg = ChatMessage(
      content: text.trim(),
      role: MessageRole.user,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
      clearError: true,
    );

    try {
      // 2. Build history for context (exclude welcome message)
      final history = state.messages
          .where((m) => !_isWelcomeMessage(m))
          .map((m) => m.toHistoryMap())
          .toList();

      // 3. Call Gemini
      final reply = await GeminiService.chat(
        userMessage: text.trim(),
        history: history,
      );

      // 4. Add AI reply
      final aiMsg = ChatMessage(
        content: reply,
        role: MessageRole.ai,
      );

      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isTyping: false,
      );
    } catch (e) {
      // 5. Add error message as an AI bubble
      final errorMsg = ChatMessage(
        content: 'Sorry, I could not respond right now. '
            'Please check your connection and try again.',
        role: MessageRole.ai,
        isError: true,
      );

      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isTyping: false,
        errorMessage: 'Connection error. Please try again.',
      );
    }
  }

  // ── Clear conversation ──────────────────────────────────────────
  void clearChat() {
    state = const ChatState();
    _addWelcomeMessage();
  }

  void clearError() => state = state.copyWith(clearError: true);

  bool _isWelcomeMessage(ChatMessage m) =>
      m.content == kChatWelcomeMessage && m.isAI;
}

// ── Welcome message constant ───────────────────────────────────────────
const String kChatWelcomeMessage =
    "Hello! I'm your Smart Farm Assistant 🌱\n\n"
    "I can help you with:\n"
    "• Livestock health & disease prevention\n"
    "• Crop selection & planting advice\n"
    "• Soil & weather tips\n"
    "• General farming best practices\n\n"
    "What would you like to know today?";

// ── Provider ───────────────────────────────────────────────────────────
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>(
  (ref) => ChatNotifier(),
);
