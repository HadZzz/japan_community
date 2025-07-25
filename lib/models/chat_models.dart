class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String content;
  final DateTime timestamp;
  final String type; // text, image, file

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.content,
    required this.timestamp,
    this.type = 'text',
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderImageUrl: json['senderImageUrl'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}

class ChatRoom {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String type; // public, private, group
  final String category; // Beginner, Advanced, Culture, General, etc.
  final List<String> participants;
  final int maxParticipants;
  final DateTime createdAt;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final bool isOnline;

  ChatRoom({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.type = 'public',
    this.category = 'General',
    this.participants = const [],
    this.maxParticipants = 100,
    required this.createdAt,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = true,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      type: json['type'] ?? 'public',
      category: json['category'] ?? 'General',
      participants: List<String>.from(json['participants'] ?? []),
      maxParticipants: json['maxParticipants'] ?? 100,
      createdAt: DateTime.parse(json['createdAt']),
      lastMessage: json['lastMessage'] != null 
          ? ChatMessage.fromJson(json['lastMessage']) 
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'type': type,
      'category': category,
      'participants': participants,
      'maxParticipants': maxParticipants,
      'createdAt': createdAt.toIso8601String(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'isOnline': isOnline,
    };
  }

  ChatRoom copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? type,
    String? category,
    List<String>? participants,
    int? maxParticipants,
    DateTime? createdAt,
    ChatMessage? lastMessage,
    int? unreadCount,
    bool? isOnline,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      category: category ?? this.category,
      participants: participants ?? this.participants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class EnhancedChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String? senderImageUrl;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final String? replyToId;
  final EnhancedChatMessage? replyToMessage;
  final List<MessageReaction> reactions;
  final bool isEdited;
  final DateTime? editedAt;

  EnhancedChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.senderImageUrl,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.replyToId,
    this.replyToMessage,
    this.reactions = const [],
    this.isEdited = false,
    this.editedAt,
  });

  factory EnhancedChatMessage.fromJson(Map<String, dynamic> json) {
    return EnhancedChatMessage(
      id: json['id'],
      roomId: json['roomId'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderImageUrl: json['senderImageUrl'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      replyToId: json['replyToId'],
      replyToMessage: json['replyToMessage'] != null
          ? EnhancedChatMessage.fromJson(json['replyToMessage'])
          : null,
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((r) => MessageReaction.fromJson(r))
          .toList() ?? [],
      isEdited: json['isEdited'] ?? false,
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImageUrl': senderImageUrl,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'replyToId': replyToId,
      'replyToMessage': replyToMessage?.toJson(),
      'reactions': reactions.map((r) => r.toJson()).toList(),
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
    };
  }
}

enum MessageType {
  text,
  image,
  file,
  system,
  voice,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class MessageReaction {
  final String emoji;
  final String userId;
  final String userName;
  final DateTime timestamp;

  MessageReaction({
    required this.emoji,
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: json['emoji'],
      userId: json['userId'],
      userName: json['userName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class UserOnlineStatus {
  final String userId;
  final bool isOnline;
  final DateTime lastSeen;
  final String? currentRoom;

  UserOnlineStatus({
    required this.userId,
    required this.isOnline,
    required this.lastSeen,
    this.currentRoom,
  });

  factory UserOnlineStatus.fromJson(Map<String, dynamic> json) {
    return UserOnlineStatus(
      userId: json['userId'],
      isOnline: json['isOnline'],
      lastSeen: DateTime.parse(json['lastSeen']),
      currentRoom: json['currentRoom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'isOnline': isOnline,
      'lastSeen': lastSeen.toIso8601String(),
      'currentRoom': currentRoom,
    };
  }
}

class TypingIndicator {
  final String userId;
  final String userName;
  final String roomId;
  final DateTime timestamp;

  TypingIndicator({
    required this.userId,
    required this.userName,
    required this.roomId,
    required this.timestamp,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      userId: json['userId'],
      userName: json['userName'],
      roomId: json['roomId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'roomId': roomId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}