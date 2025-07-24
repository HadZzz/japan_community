class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final String? location;
  final List<String> interests;
  final DateTime joinedDate;
  final String japaneseLevel; // Beginner, Intermediate, Advanced, Native

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.location,
    this.interests = const [],
    required this.joinedDate,
    this.japaneseLevel = 'Beginner',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      location: json['location'],
      interests: List<String>.from(json['interests'] ?? []),
      joinedDate: DateTime.parse(json['joinedDate']),
      japaneseLevel: json['japaneseLevel'] ?? 'Beginner',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'location': location,
      'interests': interests,
      'joinedDate': joinedDate.toIso8601String(),
      'japaneseLevel': japaneseLevel,
    };
  }
}

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorImageUrl;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likes;
  final int comments;
  final List<String> tags;
  final String category; // Discussion, Question, Event, News, etc.
  final bool isLiked; // Whether current user liked this post
  final bool isOwned; // Whether current user owns this post
  final bool isPending; // For optimistic updates

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorImageUrl,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    this.updatedAt,
    this.likes = 0,
    this.comments = 0,
    this.tags = const [],
    this.category = 'Discussion',
    this.isLiked = false,
    this.isOwned = false,
    this.isPending = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      authorImageUrl: json['authorImageUrl'],
      content: json['content'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? 'Discussion',
      isLiked: json['isLiked'] ?? false,
      isOwned: json['isOwned'] ?? false,
      isPending: false, // Never comes from API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'tags': tags,
      'category': category,
      'isLiked': isLiked,
      'isOwned': isOwned,
    };
  }

  // Helper method to create a copy with updated fields
  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorImageUrl,
    String? content,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    int? comments,
    List<String>? tags,
    String? category,
    bool? isLiked,
    bool? isOwned,
    bool? isPending,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      isLiked: isLiked ?? this.isLiked,
      isOwned: isOwned ?? this.isOwned,
      isPending: isPending ?? this.isPending,
    );
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String organizerId;
  final String organizerName;
  final int maxParticipants;
  final int currentParticipants;
  final List<String> participants;
  final String category; // Language Exchange, Cultural, Social, Educational
  final bool isOnline;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.startDate,
    this.endDate,
    required this.location,
    required this.organizerId,
    required this.organizerName,
    this.maxParticipants = 50,
    this.currentParticipants = 0,
    this.participants = const [],
    this.category = 'Social',
    this.isOnline = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      location: json['location'],
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      maxParticipants: json['maxParticipants'] ?? 50,
      currentParticipants: json['currentParticipants'] ?? 0,
      participants: List<String>.from(json['participants'] ?? []),
      category: json['category'] ?? 'Social',
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'location': location,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'participants': participants,
      'category': category,
      'isOnline': isOnline,
    };
  }
}

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