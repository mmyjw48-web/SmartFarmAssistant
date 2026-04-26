import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../models/message_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// ─────────────────────────────────────────────────────────────────────────
// Chat Bubble  (user right / AI left)
// ─────────────────────────────────────────────────────────────────────────

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 64 : 0,
        right: isUser ? 0 : 64,
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // ── AI avatar ─────────────────────────────────────
          if (!isUser) ...[
            _AiAvatar(),
            const SizedBox(width: 8),
          ],

          // ── Bubble ────────────────────────────────────────
          Flexible(
            child: GestureDetector(
              onLongPress: () => _copyToClipboard(context),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: message.isError
                          ? AppColors.error.withOpacity(0.1)
                          : isUser
                              ? AppColors.userBubble
                              : AppColors.aiBubble,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 20),
                      ),
                      border: message.isError
                          ? Border.all(
                              color: AppColors.error.withOpacity(0.3))
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: MarkdownBody(
                      
                     data: message.content,
                     styleSheet: MarkdownStyleSheet(

                      p: TextStyle(
                        color: message.isError
                            ? AppColors.error
                            : isUser
                                ? AppColors.userBubbleText
                                : AppColors.aiBubbleText,
                        fontSize: 14.5,
                        height: 1.5,
                      ),
                      
    //                   strong: TextStyle(
    //   fontWeight: FontWeight.bold,
    //   color: isUser
    //       ? AppColors.userBubbleText
    //       : AppColors.aiBubbleText,
    // ),

    // listBullet: TextStyle(r
    //   color: isUser
    //       ? AppColors.userBubbleText
    //       : AppColors.aiBubbleText,

                     ),
                    ),
                  ),

                  // ── Timestamp ────────────────────────────
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── User avatar ───────────────────────────────────
          if (isUser) ...[
            const SizedBox(width: 8),
            _UserAvatar(),
          ],
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Message copied'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// AI Avatar
// ─────────────────────────────────────────────────────────────────────────
class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.smart_toy_rounded,
          color: AppColors.white, size: 18),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// User Avatar
// ─────────────────────────────────────────────────────────────────────────
class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.2),
        shape: BoxShape.circle,
        border:
            Border.all(color: AppColors.primaryLight, width: 1.5),
      ),
      child: const Icon(Icons.person_rounded,
          color: AppColors.primary, size: 18),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Typing Indicator  (animated 3 dots)
// ─────────────────────────────────────────────────────────────────────────
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<Animation<double>> _anims = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      final anim = Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
      _controllers.add(ctrl);
      _anims.add(anim);

      // Stagger each dot by 150ms
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _AiAvatar(),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.aiBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _anims[i],
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _anims[i].value),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 3),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Chat Input Bar
// ─────────────────────────────────────────────────────────────────────────
class ChatInputBar extends StatefulWidget {
  final void Function(String) onSend;
  final bool isEnabled;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.isEnabled = true,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (!_hasText || !widget.isEnabled) return;
    final text = _ctrl.text.trim();
    _ctrl.clear();
    setState(() => _hasText = false);
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── Text field ─────────────────────────────────
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  enabled: widget.isEnabled,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _handleSend(),
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything about farming...',
                    hintStyle: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ── Send Button ────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (_hasText && widget.isEnabled)
                    ? AppColors.primary
                    : AppColors.grey200,
                shape: BoxShape.circle,
                boxShadow: (_hasText && widget.isEnabled)
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: IconButton(
                onPressed: (_hasText && widget.isEnabled)
                    ? _handleSend
                    : null,
                icon: Icon(
                  Icons.send_rounded,
                  color: (_hasText && widget.isEnabled)
                      ? AppColors.white
                      : AppColors.grey400,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Suggested Question Chips
// ─────────────────────────────────────────────────────────────────────────
class SuggestedQuestionsBar extends StatelessWidget {
  final void Function(String) onTap;

  const SuggestedQuestionsBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 10),
          child: Text(
            'Suggested questions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: kSuggestedQuestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => onTap(kSuggestedQuestions[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPale,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Text(
                  kSuggestedQuestions[i],
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
