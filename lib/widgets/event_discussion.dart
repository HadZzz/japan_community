import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';

class EventDiscussion extends StatefulWidget {
  final String eventId;

  const EventDiscussion({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDiscussion> createState() => _EventDiscussionState();
}

class _EventDiscussionState extends State<EventDiscussion> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<DiscussionMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    // In a real app, this would fetch from API
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _messages = _generateMockMessages();
        _isLoading = false;
      });
      
      // Scroll to bottom
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

  List<DiscussionMessage> _generateMockMessages() {
    return [
      DiscussionMessage(
        id: '1',
        userId: 'user1',
        userName: 'Yuki Tanaka',
        userImageUrl: null,
        message: 'Looking forward to this event! What should I bring?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isOrganizer: false,
      ),
      DiscussionMessage(
        id: '2',
        userId: 'organizer',
        userName: 'Event Organizer',
        userImageUrl: null,
        message: 'Hi everyone! Just bring yourself and a positive attitude. We\'ll provide all materials needed.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        isOrganizer: true,
      ),
      DiscussionMessage(
        id: '3',
        userId: 'user2',
        userName: 'Sarah Johnson',
        userImageUrl: null,
        message: 'Is there parking available at the venue?',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isOrganizer: false,
      ),
      DiscussionMessage(
        id: '4',
        userId: 'organizer',
        userName: 'Event Organizer',
        userImageUrl: null,
        message: 'Yes, there\'s free parking available. The entrance is on the south side of the building.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        isOrganizer: true,
      ),
      DiscussionMessage(
        id: '5',
        userId: 'user3',
        userName: 'Hiroshi Sato',
        userImageUrl: null,
        message: 'Can\'t wait to practice my English! See you all there 😊',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isOrganizer: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Discussion Header
        _buildDiscussionHeader(),
        
        // Messages List
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isCurrentUser = _isCurrentUser(message.userId);
                    
                    return _buildMessageBubble(message, isCurrentUser);
                  },
                ),
        ),
        
        // Message Input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildDiscussionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.forum,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Event Discussion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Ask questions and connect with other participants',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_messages.length} messages',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forum_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
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

  Widget _buildMessageBubble(DiscussionMessage message, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message.userImageUrl != null
                  ? CachedNetworkImageProvider(message.userImageUrl!)
                  : null,
              child: message.userImageUrl == null
                  ? Text(
                      message.userName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          
          Expanded(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // User name and time
                Row(
                  mainAxisAlignment: isCurrentUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!isCurrentUser) ...[
                      Text(
                        message.userName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: message.isOrganizer 
                              ? Theme.of(context).primaryColor
                              : Colors.grey[700],
                        ),
                      ),
                      if (message.isOrganizer) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ORG',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                    ],
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Message bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCurrentUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: message.userImageUrl != null
                  ? CachedNetworkImageProvider(message.userImageUrl!)
                  : null,
              child: message.userImageUrl == null
                  ? Text(
                      message.userName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentUser(String userId) {
    final userProvider = context.read<UserProvider>();
    return userProvider.currentUser?.id == userId;
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    final userProvider = context.read<UserProvider>();
    final newMessage = DiscussionMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userProvider.currentUser?.id ?? 'unknown',
      userName: userProvider.currentUser?.name ?? 'Anonymous',
      userImageUrl: userProvider.currentUser?.profileImageUrl,
      message: messageText,
      timestamp: DateTime.now(),
      isOrganizer: false, // TODO: Check if user is organizer
    );

    setState(() {
      _messages.add(newMessage);
      _messageController.clear();
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // TODO: Send message to API
  }
}

// Model class for discussion messages
class DiscussionMessage {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final String message;
  final DateTime timestamp;
  final bool isOrganizer;

  DiscussionMessage({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.message,
    required this.timestamp,
    required this.isOrganizer,
  });
}