import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  // Auto-scroll to bottom when new message arrives
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(String text) async {
    await ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _handleSuggestion(String text) {
    _handleSend(text);
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Chat'),
        content: const Text(
            'This will delete all messages. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(chatProvider.notifier).clearChat();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Scroll when messages change
    ref.listen(chatProvider, (prev, next) {
      if (next.messages.length != prev?.messages.length ||
          next.isTyping != prev?.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,

      // ── AppBar ──────────────────────────────────────────────
      appBar: _buildAppBar(context, chatState),

      // ── Body ────────────────────────────────────────────────
      body: Column(
        children: [
          // ── Message list ─────────────────────────────────
          Expanded(
            child: _buildMessageList(chatState),
          ),

          // ── Suggested questions (only when empty/start) ──
          if (chatState.messages.length <= 1 && !chatState.isTyping)
            SuggestedQuestionsBar(onTap: _handleSuggestion),

          const SizedBox(height: 8),

          // ── Input bar ─────────────────────────────────────
          ChatInputBar(
            onSend: _handleSend,
            isEnabled: !chatState.isTyping,
          ),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, ChatState state) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          const SizedBox(width: 16),
          // AI avatar
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_rounded,
                color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.chatTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.riskLow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    state.isTyping ? 'Typing...' : 'Online',
                    style: TextStyle(
                      fontSize: 11,
                      color: state.isTyping
                          ? AppColors.textSecondary
                          : AppColors.riskLow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Clear chat button
        if (state.messages.length > 1)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.grey600),
            onPressed: _showClearDialog,
            tooltip: 'Clear chat',
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Message list ───────────────────────────────────────────────────
  Widget _buildMessageList(ChatState state) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: state.messages.length + (state.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // Show typing indicator as last item
        if (index == state.messages.length && state.isTyping) {
          return const TypingIndicator();
        }

        final message = state.messages[index];
        return _AnimatedBubble(
          key: ValueKey(message.id),
          message: message,
          index: index,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Animated bubble wrapper — slides in from bottom
// ─────────────────────────────────────────────────────────────────────────
class _AnimatedBubble extends StatefulWidget {
  final message;
  final int index;

  const _AnimatedBubble({
    super.key,
    required this.message,
    required this.index,
  });

  @override
  State<_AnimatedBubble> createState() => _AnimatedBubbleState();
}

class _AnimatedBubbleState extends State<_AnimatedBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ChatBubble(message: widget.message),
      ),
    );
  }
}
