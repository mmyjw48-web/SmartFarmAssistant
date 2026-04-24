import 'package:uuid/uuid.dart';

// ── Message Role ───────────────────────────────────────────────────────
enum MessageRole { user, ai }

// ── Chat Message ───────────────────────────────────────────────────────
class ChatMessage {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isError;

  ChatMessage({
    String? id,
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.isError = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == MessageRole.user;
  bool get isAI   => role == MessageRole.ai;

  /// Convert to the format GeminiService expects for history
  Map<String, String> toHistoryMap() => {
        'role': role == MessageRole.user ? 'user' : 'assistant',
        'content': content,
      };

  ChatMessage copyWith({String? content}) {
    return ChatMessage(
      id: id,
      content: content ?? this.content,
      role: role,
      timestamp: timestamp,
      isError: isError,
    );
  }
}

// ── Suggested Questions ────────────────────────────────────────────────
/// Quick-tap suggestions shown before the user types anything
const List<String> kSuggestedQuestions = [
  'How do I treat foot and mouth disease in cattle?',
  'What crops grow best in clay soil?',
  'How can I improve my soil fertility naturally?',
  'What are signs of Newcastle disease in hens?',
  'Best practices for rainy season farming?',
];
