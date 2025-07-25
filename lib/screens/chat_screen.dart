import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chat_models.dart';
import '../widgets/chat_room_list.dart';
import '../widgets/chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();
    
    if (userProvider.currentUser != null && !_isInitialized) {
      await chatProvider.connectToChat(
        userProvider.currentUser!.id,
        userProvider.currentUser!.name,
        'demo_token', // In production, use actual JWT token
      );
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      _getConnectionIcon(chatProvider.connectionStatus),
                      color: _getConnectionColor(chatProvider.connectionStatus),
                    ),
                    onPressed: () => _showConnectionInfo(context, chatProvider),
                  ),
                  if (chatProvider.getTotalUnreadCount() > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${chatProvider.getTotalUnreadCount()}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showChatInfo(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.chat_bubble_outline),
              text: 'Rooms',
            ),
            Tab(
              icon: Icon(Icons.people_outline),
              text: 'Online',
            ),
          ],
        ),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.currentRoom != null) {
            return ChatRoomScreen(room: chatProvider.currentRoom!);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Chat Rooms Tab
              const ChatRoomList(),
              
              // Online Users Tab
              _buildOnlineUsersTab(chatProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOnlineUsersTab(ChatProvider chatProvider) {
    final onlineUsers = chatProvider.onlineUsers;

    if (onlineUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No users online',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: onlineUsers.length,
      itemBuilder: (context, index) {
        final user = onlineUsers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  child: Text(user.userId[0].toUpperCase()),
                ),
                if (user.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text('User ${user.userId}'),
            subtitle: Text(
              user.isOnline 
                  ? user.currentRoom != null 
                      ? 'In ${user.currentRoom}'
                      : 'Online'
                  : 'Last seen ${_formatLastSeen(user.lastSeen)}',
            ),
            trailing: user.isOnline
                ? const Icon(Icons.circle, color: Colors.green, size: 12)
                : const Icon(Icons.circle, color: Colors.grey, size: 12),
            onTap: () {
              // TODO: Implement private messaging
              _showPrivateMessageDialog(context, user);
            },
          ),
        );
      },
    );
  }

  IconData _getConnectionIcon(ChatConnectionStatus status) {
    switch (status) {
      case ChatConnectionStatus.connected:
        return Icons.wifi;
      case ChatConnectionStatus.connecting:
        return Icons.wifi_off;
      case ChatConnectionStatus.disconnected:
        return Icons.wifi_off;
      case ChatConnectionStatus.error:
        return Icons.error;
    }
  }

  Color _getConnectionColor(ChatConnectionStatus status) {
    switch (status) {
      case ChatConnectionStatus.connected:
        return Colors.green;
      case ChatConnectionStatus.connecting:
        return Colors.orange;
      case ChatConnectionStatus.disconnected:
        return Colors.grey;
      case ChatConnectionStatus.error:
        return Colors.red;
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showConnectionInfo(BuildContext context, ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getConnectionIcon(chatProvider.connectionStatus),
                  color: _getConnectionColor(chatProvider.connectionStatus),
                ),
                const SizedBox(width: 8),
                Text(_getConnectionStatusText(chatProvider.connectionStatus)),
              ],
            ),
            if (chatProvider.connectionError != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: ${chatProvider.connectionError}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            Text('Online Users: ${chatProvider.onlineUsers.length}'),
            Text('Total Unread: ${chatProvider.getTotalUnreadCount()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (chatProvider.connectionStatus != ChatConnectionStatus.connected)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeChat();
              },
              child: const Text('Reconnect'),
            ),
        ],
      ),
    );
  }

  String _getConnectionStatusText(ChatConnectionStatus status) {
    switch (status) {
      case ChatConnectionStatus.connected:
        return 'Connected';
      case ChatConnectionStatus.connecting:
        return 'Connecting...';
      case ChatConnectionStatus.disconnected:
        return 'Disconnected';
      case ChatConnectionStatus.error:
        return 'Connection Error';
    }
  }

  void _showPrivateMessageDialog(BuildContext context, UserOnlineStatus user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message User ${user.userId}'),
        content: const Text(
          'Private messaging will be available in the next update!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChatInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Guidelines'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎌 Welcome to Japanese Community Chat!'),
            SizedBox(height: 12),
            Text('• Be respectful to all community members'),
            Text('• Help others learn Japanese and about Japanese culture'),
            Text('• Keep conversations appropriate and family-friendly'),
            Text('• No spam or self-promotion'),
            Text('• Use both Japanese and English to help everyone learn'),
            Text('• Share files and images to enhance learning'),
            SizedBox(height: 12),
            Text('Features:'),
            Text('• Real-time messaging'),
            Text('• Multiple chat rooms'),
            Text('• File and image sharing'),
            Text('• Message reactions'),
            Text('• Online status indicators'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}