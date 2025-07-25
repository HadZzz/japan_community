import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/chat_models.dart';
import '../services/websocket_service.dart';

enum ChatConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class ChatProvider extends ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  
  // Connection state
  ChatConnectionStatus _connectionStatus = ChatConnectionStatus.disconnected;
  String? _connectionError;

  // Chat rooms
  List<ChatRoom> _chatRooms = [];
  ChatRoom? _currentRoom;
  
  // Messages
  Map<String, List<EnhancedChatMessage>> _roomMessages = {};
  Map<String, int> _unreadCounts = {};
  
  // Online users and typing
  List<UserOnlineStatus> _onlineUsers = [];
  Map<String, List<TypingIndicator>> _typingUsers = {};
  
  // UI state
  bool _isLoading = false;
  String? _error;
  
  // Current user info
  String? _currentUserId;
  String? _currentUserName;

  // Stream subscriptions
  StreamSubscription? _messageSubscription;
  StreamSubscription? _onlineUsersSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _reactionSubscription;
  StreamSubscription? _connectionSubscription;

  // Getters
  ChatConnectionStatus get connectionStatus => _connectionStatus;
  String? get connectionError => _connectionError;
  List<ChatRoom> get chatRooms => _chatRooms;
  ChatRoom? get currentRoom => _currentRoom;
  List<EnhancedChatMessage> get currentMessages => 
      _currentRoom != null ? _roomMessages[_currentRoom!.id] ?? [] : [];
  List<UserOnlineStatus> get onlineUsers => _onlineUsers;
  List<TypingIndicator> get currentRoomTyping => 
      _currentRoom != null ? _typingUsers[_currentRoom!.id] ?? [] : [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  int getTotalUnreadCount() => _unreadCounts.values.fold(0, (a, b) => a + b);
  int getRoomUnreadCount(String roomId) => _unreadCounts[roomId] ?? 0;

  ChatProvider() {
    _initializeMockData();
    _setupWebSocketListeners();
  }

  void _setupWebSocketListeners() {
    _messageSubscription = _webSocketService.messageStream.listen(
      (message) {
        _handleIncomingMessage(message);
      },
    );

    _onlineUsersSubscription = _webSocketService.onlineUsersStream.listen(
      (users) {
        _onlineUsers = users;
        notifyListeners();
      },
    );

    _typingSubscription = _webSocketService.typingStream.listen(
      (typing) {
        _handleTypingIndicator(typing);
      },
    );

    _reactionSubscription = _webSocketService.reactionStream.listen(
      (reaction) {
        _handleMessageReaction(reaction);
      },
    );

    _connectionSubscription = _webSocketService.connectionStatusStream.listen(
      (status) {
        switch (status) {
          case 'connecting':
            _connectionStatus = ChatConnectionStatus.connecting;
            break;
          case 'connected':
            _connectionStatus = ChatConnectionStatus.connected;
            _connectionError = null;
            break;
          case 'disconnected':
            _connectionStatus = ChatConnectionStatus.disconnected;
            break;
          case 'error':
            _connectionStatus = ChatConnectionStatus.error;
            _connectionError = 'Connection failed';
            break;
        }
        notifyListeners();
      },
    );
  }

  Future<void> connectToChat(String userId, String userName, String token) async {
    _currentUserId = userId;
    _currentUserName = userName;
    
    try {
      await _webSocketService.connect(userId, token);
    } catch (e) {
      _connectionError = e.toString();
      _connectionStatus = ChatConnectionStatus.error;
      notifyListeners();
    }
  }

  Future<void> disconnectFromChat() async {
    await _webSocketService.disconnect();
    _currentRoom = null;
    notifyListeners();
  }

  Future<void> joinRoom(ChatRoom room) async {
    if (_currentRoom?.id == room.id) return;
    
    // Leave current room if any
    if (_currentRoom != null) {
      await _webSocketService.leaveRoom(_currentRoom!.id);
    }
    
    // Join new room
    _currentRoom = room;
    await _webSocketService.joinRoom(room.id);
    
    // Mark messages as read
    _unreadCounts[room.id] = 0;
    
    // Initialize messages if not exists
    if (!_roomMessages.containsKey(room.id)) {
      _roomMessages[room.id] = [];
      _loadMockMessagesForRoom(room.id);
    }
    
    notifyListeners();
  }

  Future<void> leaveCurrentRoom() async {
    if (_currentRoom != null) {
      await _webSocketService.leaveRoom(_currentRoom!.id);
      _currentRoom = null;
      notifyListeners();
    }
  }

  Future<bool> sendMessage({
    required String content,
    MessageType type = MessageType.text,
    File? file,
    String? replyToId,
  }) async {
    if (_currentRoom == null || _currentUserId == null) return false;

    try {
      String? fileUrl;
      String? fileName;
      int? fileSize;

      // Handle file upload
      if (file != null && type != MessageType.text) {
        // In production, upload file to server and get URL
        fileUrl = 'https://example.com/files/${file.path.split('/').last}';
        fileName = file.path.split('/').last;
        fileSize = await file.length();
      }

      final message = EnhancedChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        roomId: _currentRoom!.id,
        senderId: _currentUserId!,
        senderName: _currentUserName ?? 'You',
        content: content,
        timestamp: DateTime.now(),
        type: type,
        status: MessageStatus.sending,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
        replyToId: replyToId,
      );

      // Add message optimistically
      _roomMessages[_currentRoom!.id] = [
        ..._roomMessages[_currentRoom!.id] ?? [],
        message,
      ];
      notifyListeners();

      // Send through WebSocket
      await _webSocketService.sendMessage(message);
      
      return true;
    } catch (e) {
      _error = 'Failed to send message: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> sendTypingIndicator(bool isTyping) async {
    if (_currentRoom != null) {
      await _webSocketService.sendTypingIndicator(_currentRoom!.id, isTyping);
    }
  }

  Future<void> addReaction(String messageId, String emoji) async {
    await _webSocketService.sendReaction(messageId, emoji);
  }

  Future<void> pickAndSendFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        MessageType messageType = MessageType.file;
        if (result.files.single.extension?.toLowerCase() == 'jpg' ||
            result.files.single.extension?.toLowerCase() == 'jpeg' ||
            result.files.single.extension?.toLowerCase() == 'png' ||
            result.files.single.extension?.toLowerCase() == 'gif') {
          messageType = MessageType.image;
        }

        await sendMessage(
          content: fileName,
          type: messageType,
          file: file,
        );
      }
    } catch (e) {
      _error = 'Failed to pick file: ${e.toString()}';
      notifyListeners();
    }
  }

  void _handleIncomingMessage(EnhancedChatMessage message) {
    // Add message to room
    if (!_roomMessages.containsKey(message.roomId)) {
      _roomMessages[message.roomId] = [];
    }
    
    // Check if message already exists (avoid duplicates)
    final existingIndex = _roomMessages[message.roomId]!
        .indexWhere((m) => m.id == message.id);
    
    if (existingIndex != -1) {
      // Update existing message (for status updates)
      _roomMessages[message.roomId]![existingIndex] = message;
    } else {
      // Add new message
      _roomMessages[message.roomId]!.add(message);
      
      // Increment unread count if not in current room
      if (_currentRoom?.id != message.roomId) {
        _unreadCounts[message.roomId] = (_unreadCounts[message.roomId] ?? 0) + 1;
      }
    }
    
    // Update room's last message
    final roomIndex = _chatRooms.indexWhere((r) => r.id == message.roomId);
    if (roomIndex != -1) {
      _chatRooms[roomIndex] = _chatRooms[roomIndex].copyWith(
        lastMessage: ChatMessage(
          id: message.id,
          senderId: message.senderId,
          senderName: message.senderName,
          content: message.content,
          timestamp: message.timestamp,
        ),
      );
    }
    
    notifyListeners();
  }

  void _handleTypingIndicator(TypingIndicator typing) {
    if (!_typingUsers.containsKey(typing.roomId)) {
      _typingUsers[typing.roomId] = [];
    }
    
    // Remove existing typing indicator for this user
    _typingUsers[typing.roomId]!.removeWhere((t) => t.userId == typing.userId);
    
    // Add new typing indicator
    _typingUsers[typing.roomId]!.add(typing);
    
    // Remove typing indicator after 3 seconds
    Timer(const Duration(seconds: 3), () {
      _typingUsers[typing.roomId]?.removeWhere((t) => t.userId == typing.userId);
      notifyListeners();
    });
    
    notifyListeners();
  }

  void _handleMessageReaction(MessageReaction reaction) {
    // Find and update message with reaction
    for (final roomMessages in _roomMessages.values) {
      for (int i = 0; i < roomMessages.length; i++) {
        if (roomMessages[i].id == reaction.userId) { // This should be messageId
          final message = roomMessages[i];
          final updatedReactions = [...message.reactions];
          
          // Check if user already reacted with this emoji
          final existingIndex = updatedReactions.indexWhere(
            (r) => r.userId == reaction.userId && r.emoji == reaction.emoji,
          );
          
          if (existingIndex != -1) {
            // Remove existing reaction
            updatedReactions.removeAt(existingIndex);
          } else {
            // Add new reaction
            updatedReactions.add(reaction);
          }
          
          // Update message (would need to create a copyWith method for EnhancedChatMessage)
          // For now, we'll just notify listeners
          break;
        }
      }
    }
    notifyListeners();
  }

  void _initializeMockData() {
    _chatRooms = [
      ChatRoom(
        id: 'general',
        name: 'General Chat',
        description: 'General discussion for all community members',
        category: 'General',
        participants: ['1', '2', '3', '4'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ChatRoom(
        id: 'beginner',
        name: 'Beginner Japanese',
        description: 'For those just starting their Japanese journey',
        category: 'Beginner',
        participants: ['1', '2', '3'],
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      ChatRoom(
        id: 'advanced',
        name: 'Advanced Japanese',
        description: 'Advanced learners and native speakers',
        category: 'Advanced',
        participants: ['1', '4'],
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      ChatRoom(
        id: 'culture',
        name: 'Japanese Culture',
        description: 'Discuss Japanese culture, traditions, and customs',
        category: 'Culture',
        participants: ['1', '2', '3', '4'],
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      ChatRoom(
        id: 'events',
        name: 'Event Planning',
        description: 'Plan and discuss upcoming community events',
        category: 'Events',
        participants: ['1', '2'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];

    // Initialize unread counts
    for (final room in _chatRooms) {
      _unreadCounts[room.id] = 0;
    }
  }

  void _loadMockMessagesForRoom(String roomId) {
    final mockMessages = <EnhancedChatMessage>[];
    
    switch (roomId) {
      case 'general':
        mockMessages.addAll([
          EnhancedChatMessage(
            id: '1',
            roomId: roomId,
            senderId: '2',
            senderName: 'Sakura',
            senderImageUrl: 'https://i.pravatar.cc/150?img=2',
            content: 'みなさん、こんにちは！今日はいい天気ですね。',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            status: MessageStatus.read,
          ),
          EnhancedChatMessage(
            id: '2',
            roomId: roomId,
            senderId: '3',
            senderName: 'Mike',
            senderImageUrl: 'https://i.pravatar.cc/150?img=3',
            content: 'Hello everyone! The weather is really nice today.',
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
            status: MessageStatus.read,
          ),
        ]);
        break;
      case 'beginner':
        mockMessages.addAll([
          EnhancedChatMessage(
            id: '3',
            roomId: roomId,
            senderId: '3',
            senderName: 'Mike',
            senderImageUrl: 'https://i.pravatar.cc/150?img=3',
            content: 'How do you say "good morning" in Japanese?',
            timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
            status: MessageStatus.read,
          ),
          EnhancedChatMessage(
            id: '4',
            roomId: roomId,
            senderId: '2',
            senderName: 'Sakura',
            senderImageUrl: 'https://i.pravatar.cc/150?img=2',
            content: 'おはようございます (Ohayou gozaimasu) - formal\nおはよう (Ohayou) - casual',
            timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
            status: MessageStatus.read,
          ),
        ]);
        break;
    }
    
    _roomMessages[roomId] = mockMessages;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _onlineUsersSubscription?.cancel();
    _typingSubscription?.cancel();
    _reactionSubscription?.cancel();
    _connectionSubscription?.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}