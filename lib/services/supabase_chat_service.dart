import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_models.dart';
import 'supabase_config.dart';

class SupabaseChatService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Get all chat rooms
  Future<List<ChatRoom>> getChatRooms() async {
    try {
      final response = await _client
          .from('chat_rooms')
          .select()
          .order('created_at', ascending: true);

      return response.map<ChatRoom>((room) => ChatRoom(
        id: room['id'],
        name: room['name'],
        description: room['description'] ?? '',
        imageUrl: room['image_url'],
        type: room['type'] ?? 'public',
        category: room['category'] ?? 'General',
        maxParticipants: room['max_participants'] ?? 100,
        createdAt: DateTime.parse(room['created_at']),
        participants: [], // Will be populated separately
        unreadCount: 0, // Will be calculated separately
        isOnline: true,
      )).toList();
    } catch (e) {
      print('Error fetching chat rooms: $e');
      return [];
    }
  }

  // Get messages for a specific room
  Stream<List<EnhancedChatMessage>> getMessagesStream(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((data) => data.map<EnhancedChatMessage>((message) => 
            _mapToEnhancedChatMessage(message)).toList());
  }

  // Send a message
  Future<bool> sendMessage({
    required String roomId,
    required String content,
    MessageType type = MessageType.text,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? replyToId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Get user profile for sender info
      final userProfile = await _client
          .from('users')
          .select('name, profile_image_url')
          .eq('id', user.id)
          .single();

      await _client.from('chat_messages').insert({
        'room_id': roomId,
        'sender_id': user.id,
        'sender_name': userProfile['name'] ?? 'Unknown User',
        'sender_image_url': userProfile['profile_image_url'],
        'content': content,
        'message_type': type.toString().split('.').last,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': fileSize,
        'reply_to_id': replyToId,
      });

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // Add reaction to message
  Future<bool> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Get user profile for reaction info
      final userProfile = await _client
          .from('users')
          .select('name')
          .eq('id', user.id)
          .single();

      await _client.from('message_reactions').upsert({
        'message_id': messageId,
        'user_id': user.id,
        'user_name': userProfile['name'] ?? 'Unknown User',
        'emoji': emoji,
      });

      return true;
    } catch (e) {
      print('Error adding reaction: $e');
      return false;
    }
  }

  // Remove reaction from message
  Future<bool> removeReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('message_reactions')
          .delete()
          .eq('message_id', messageId)
          .eq('user_id', user.id)
          .eq('emoji', emoji);

      return true;
    } catch (e) {
      print('Error removing reaction: $e');
      return false;
    }
  }

  // Get reactions for a message
  Future<List<MessageReaction>> getMessageReactions(String messageId) async {
    try {
      final response = await _client
          .from('message_reactions')
          .select()
          .eq('message_id', messageId)
          .order('created_at', ascending: true);

      return response.map<MessageReaction>((reaction) => MessageReaction(
        emoji: reaction['emoji'],
        userId: reaction['user_id'],
        userName: reaction['user_name'],
        timestamp: DateTime.parse(reaction['created_at']),
      )).toList();
    } catch (e) {
      print('Error fetching reactions: $e');
      return [];
    }
  }

  // Edit message
  Future<bool> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('chat_messages')
          .update({
            'content': newContent,
            'is_edited': true,
            'edited_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId)
          .eq('sender_id', user.id); // Only allow editing own messages

      return true;
    } catch (e) {
      print('Error editing message: $e');
      return false;
    }
  }

  // Delete message
  Future<bool> deleteMessage(String messageId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      await _client
          .from('chat_messages')
          .delete()
          .eq('id', messageId)
          .eq('sender_id', user.id); // Only allow deleting own messages

      return true;
    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }

  // Get online users (simplified - in real app you'd track this with presence)
  Future<List<UserOnlineStatus>> getOnlineUsers() async {
    try {
      // For now, just get recent active users
      final response = await _client
          .from('users')
          .select('id, name, profile_image_url')
          .order('updated_at', ascending: false)
          .limit(50);

      return response.map<UserOnlineStatus>((user) => UserOnlineStatus(
        userId: user['id'],
        isOnline: true, // Simplified - in real app track actual presence
        lastSeen: DateTime.now().subtract(Duration(minutes: 5)),
        currentRoom: null,
      )).toList();
    } catch (e) {
      print('Error fetching online users: $e');
      return [];
    }
  }

  // Upload file to Supabase Storage
  Future<String?> uploadFile({
    required String filePath,
    required String fileName,
    required String bucket,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = fileName.split('.').last;
      final uniqueFileName = '${user.id}_${timestamp}.$fileExtension';

      await _client.storage
          .from(bucket)
          .uploadBinary(uniqueFileName, await File(filePath).readAsBytes());

      final publicUrl = _client.storage
          .from(bucket)
          .getPublicUrl(uniqueFileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Helper method to map database record to EnhancedChatMessage
  EnhancedChatMessage _mapToEnhancedChatMessage(Map<String, dynamic> message) {
    return EnhancedChatMessage(
      id: message['id'],
      roomId: message['room_id'],
      senderId: message['sender_id'],
      senderName: message['sender_name'] ?? 'Unknown User',
      senderImageUrl: message['sender_image_url'],
      content: message['content'],
      timestamp: DateTime.parse(message['created_at']),
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == message['message_type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.delivered, // Simplified
      fileUrl: message['file_url'],
      fileName: message['file_name'],
      fileSize: message['file_size'],
      replyToId: message['reply_to_id'],
      reactions: [], // Will be populated separately if needed
      isEdited: message['is_edited'] ?? false,
      editedAt: message['edited_at'] != null 
          ? DateTime.parse(message['edited_at']) 
          : null,
    );
  }
}