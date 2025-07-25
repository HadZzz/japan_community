import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../models/chat_models.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoom room;

  const ChatRoomScreen({super.key, required this.room});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onTyping() {
    if (!_isTyping) {
      _isTyping = true;
      context.read<ChatProvider>().sendTypingIndicator(true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _isTyping = false;
      context.read<ChatProvider>().sendTypingIndicator(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.room.name),
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final typingUsers = chatProvider.currentRoomTyping;
                if (typingUsers.isNotEmpty) {
                  final typingNames = typingUsers
                      .map((t) => t.userName)
                      .take(2)
                      .join(', ');
                  final moreCount = typingUsers.length - 2;
                  
                  return Text(
                    typingUsers.length == 1
                        ? '$typingNames is typing...'
                        : moreCount > 0
                            ? '$typingNames and $moreCount others are typing...'
                            : '$typingNames are typing...',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  );
                }
                
                return Text(
                  '${widget.room.participants.length} members',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              context.read<ChatProvider>().pickAndSendFile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showRoomInfo(context),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<ChatProvider>().leaveCurrentRoom();
          },
        ),
      ),
      body: Column(
        children: [
          // Room info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: _getCategoryColor(widget.room.category).withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(widget.room.category),
                  color: _getCategoryColor(widget.room.category),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.room.description,
                    style: TextStyle(
                      color: _getCategoryColor(widget.room.category),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.currentMessages;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(widget.room.category),
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet in ${widget.room.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start the conversation!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.senderId == '1'; // Current user ID
                    final showAvatar = index == 0 || 
                        messages[index - 1].senderId != message.senderId;
                    final showTimestamp = index == messages.length - 1 ||
                        messages[index + 1].senderId != message.senderId ||
                        messages[index + 1].timestamp.difference(message.timestamp).inMinutes > 5;

                    return MessageBubble(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      showAvatar: showAvatar,
                      showTimestamp: showTimestamp,
                      onReaction: (emoji) {
                        chatProvider.addReaction(message.id, emoji);
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          MessageInput(
            onSendMessage: (content, type, file) async {
              final success = await context.read<ChatProvider>().sendMessage(
                content: content,
                type: type,
                file: file,
              );
              
              if (success) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }
            },
            onTyping: _onTyping,
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'advanced':
        return Colors.red;
      case 'culture':
        return Colors.purple;
      case 'events':
        return Colors.orange;
      case 'general':
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'beginner':
        return Icons.school;
      case 'advanced':
        return Icons.star;
      case 'culture':
        return Icons.temple_buddhist;
      case 'events':
        return Icons.event;
      case 'general':
      default:
        return Icons.chat;
    }
  }

  void _showRoomInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.room.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.room.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _getCategoryIcon(widget.room.category),
                  size: 16,
                  color: _getCategoryColor(widget.room.category),
                ),
                const SizedBox(width: 8),
                Text(
                  'Category: ${widget.room.category}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Members: ${widget.room.participants.length}/${widget.room.maxParticipants}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Created: ${DateFormat('MMM dd, yyyy').format(widget.room.createdAt)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}