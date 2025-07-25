import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/chat_models.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  io.Socket? _socket;
  String? _currentUserId;
  String? _currentRoomId;
  
  // Stream controllers for real-time events
  final StreamController<EnhancedChatMessage> _messageController = 
      StreamController<EnhancedChatMessage>.broadcast();
  final StreamController<List<UserOnlineStatus>> _onlineUsersController = 
      StreamController<List<UserOnlineStatus>>.broadcast();
  final StreamController<TypingIndicator> _typingController = 
      StreamController<TypingIndicator>.broadcast();
  final StreamController<MessageReaction> _reactionController = 
      StreamController<MessageReaction>.broadcast();
  final StreamController<String> _connectionStatusController = 
      StreamController<String>.broadcast();

  // Getters for streams
  Stream<EnhancedChatMessage> get messageStream => _messageController.stream;
  Stream<List<UserOnlineStatus>> get onlineUsersStream => _onlineUsersController.stream;
  Stream<TypingIndicator> get typingStream => _typingController.stream;
  Stream<MessageReaction> get reactionStream => _reactionController.stream;
  Stream<String> get connectionStatusStream => _connectionStatusController.stream;

  bool get isConnected => _socket?.connected ?? false;

  // For demo purposes, we'll simulate a WebSocket connection
  // In production, this would connect to your actual WebSocket server
  Future<void> connect(String userId, String token) async {
    _currentUserId = userId;
    
    try {
      // Simulate connection for demo
      _connectionStatusController.add('connecting');
      
      // In production, uncomment and configure this:
      /*
      _socket = io.io('ws://your-server.com:3000', 
        io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token, 'userId': userId})
          .build()
      );

      _socket!.onConnect((_) {
        print('Connected to WebSocket server');
        _connectionStatusController.add('connected');
      });

      _socket!.onDisconnect((_) {
        print('Disconnected from WebSocket server');
        _connectionStatusController.add('disconnected');
      });

      _socket!.on('message', (data) {
        final message = EnhancedChatMessage.fromJson(data);
        _messageController.add(message);
      });

      _socket!.on('online_users', (data) {
        final users = (data as List)
            .map((user) => UserOnlineStatus.fromJson(user))
            .toList();
        _onlineUsersController.add(users);
      });

      _socket!.on('typing', (data) {
        final typing = TypingIndicator.fromJson(data);
        _typingController.add(typing);
      });

      _socket!.on('reaction', (data) {
        final reaction = MessageReaction.fromJson(data);
        _reactionController.add(reaction);
      });

      _socket!.connect();
      */

      // Demo simulation
      await Future.delayed(const Duration(seconds: 1));
      _connectionStatusController.add('connected');
      
      // Simulate some online users
      _simulateOnlineUsers();
      
    } catch (e) {
      print('WebSocket connection error: $e');
      _connectionStatusController.add('error');
    }
  }

  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentUserId = null;
    _currentRoomId = null;
    _connectionStatusController.add('disconnected');
  }

  Future<void> joinRoom(String roomId) async {
    _currentRoomId = roomId;
    
    if (_socket?.connected == true) {
      _socket!.emit('join_room', {'roomId': roomId, 'userId': _currentUserId});
    } else {
      // Demo simulation
      print('Joined room: $roomId');
    }
  }

  Future<void> leaveRoom(String roomId) async {
    if (_socket?.connected == true) {
      _socket!.emit('leave_room', {'roomId': roomId, 'userId': _currentUserId});
    } else {
      // Demo simulation
      print('Left room: $roomId');
    }
    
    if (_currentRoomId == roomId) {
      _currentRoomId = null;
    }
  }

  Future<void> sendMessage(EnhancedChatMessage message) async {
    if (_socket?.connected == true) {
      _socket!.emit('message', message.toJson());
    } else {
      // Demo simulation - add message to stream after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Simulate message delivery status updates
      Timer(const Duration(seconds: 1), () {
        // Simulate delivered status
        final deliveredMessage = EnhancedChatMessage(
          id: message.id,
          roomId: message.roomId,
          senderId: message.senderId,
          senderName: message.senderName,
          senderImageUrl: message.senderImageUrl,
          content: message.content,
          timestamp: message.timestamp,
          type: message.type,
          status: MessageStatus.delivered,
          fileUrl: message.fileUrl,
          fileName: message.fileName,
          fileSize: message.fileSize,
        );
        _messageController.add(deliveredMessage);
      });
    }
  }

  Future<void> sendTypingIndicator(String roomId, bool isTyping) async {
    if (_socket?.connected == true) {
      _socket!.emit('typing', {
        'roomId': roomId,
        'userId': _currentUserId,
        'isTyping': isTyping,
      });
    } else {
      // Demo simulation
      if (isTyping) {
        print('User is typing in room: $roomId');
      }
    }
  }

  Future<void> sendReaction(String messageId, String emoji) async {
    if (_socket?.connected == true) {
      _socket!.emit('reaction', {
        'messageId': messageId,
        'emoji': emoji,
        'userId': _currentUserId,
      });
    } else {
      // Demo simulation
      final reaction = MessageReaction(
        emoji: emoji,
        userId: _currentUserId!,
        userName: 'You',
        timestamp: DateTime.now(),
      );
      _reactionController.add(reaction);
    }
  }

  // Demo simulation methods
  void _simulateOnlineUsers() {
    final users = [
      UserOnlineStatus(
        userId: '2',
        isOnline: true,
        lastSeen: DateTime.now(),
        currentRoom: 'general',
      ),
      UserOnlineStatus(
        userId: '3',
        isOnline: true,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
        currentRoom: 'beginner',
      ),
      UserOnlineStatus(
        userId: '4',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
    _onlineUsersController.add(users);
  }

  void simulateIncomingMessage(EnhancedChatMessage message) {
    _messageController.add(message);
  }

  void simulateTyping(TypingIndicator typing) {
    _typingController.add(typing);
  }

  void dispose() {
    _messageController.close();
    _onlineUsersController.close();
    _typingController.close();
    _reactionController.close();
    _connectionStatusController.close();
    disconnect();
  }
}