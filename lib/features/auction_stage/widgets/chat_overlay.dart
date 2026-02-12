import 'package:flutter/material.dart';
import '../../../cores/constants/colors.dart';
import '../model/auction_room_state.dart';

/// Chat message item widget
class ChatMessageItem extends StatelessWidget {
  final ChatMessageModel message;

  const ChatMessageItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == ChatMessageType.system) {
      return _buildSystemMessage();
    } else if (message.type == ChatMessageType.bid) {
      return _buildBidNotification();
    } else {
      return _buildUserMessage();
    }
  }

  /// System message
  Widget _buildSystemMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surfaceDark.withOpacity(0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bid notification
  Widget _buildBidNotification() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(bottom: 6, top: 4),
      decoration: BoxDecoration(
        color: colors.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on, size: 14, color: colors.accent),
          const SizedBox(width: 6),
          Text(
            message.message,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.accent,
            ),
          ),
        ],
      ),
    );
  }

  /// User message
  Widget _buildUserMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 12,
            backgroundColor: colors.primary,
            backgroundImage: message.avatarUrl != null
                ? NetworkImage(message.avatarUrl!)
                : null,
            child: message.avatarUrl == null
                ? Text(
                    message.username[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.username,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colors.slate300,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chat overlay widget - displays scrolling chat messages
class ChatOverlay extends StatefulWidget {
  final List<ChatMessageModel> messages;
  final double height;
  final EdgeInsetsGeometry padding;

  const ChatOverlay({
    super.key,
    required this.messages,
    this.height = 220,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ChatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll to bottom when new messages arrive
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          return ChatMessageItem(message: widget.messages[index]);
        },
      ),
    );
  }
}
