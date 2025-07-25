import 'package:flutter/material.dart';

class EnhancedEvent {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final List<String> imageUrls;
  final DateTime startDate;
  final DateTime? endDate;
  final TimeOfDay startTime;
  final TimeOfDay? endTime;
  final String location;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String organizerId;
  final String organizerName;
  final String? organizerImageUrl;
  final int maxParticipants;
  final int currentParticipants;
  final List<EventParticipant> participants;
  final List<String> waitlist;
  final String category;
  final List<String> tags;
  final bool isOnline;
  final String? onlineMeetingUrl;
  final EventStatus status;
  final double price;
  final String currency;
  final bool isRecurring;
  final RecurrencePattern? recurrencePattern;
  final List<EventReview> reviews;
  final double averageRating;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final RSVPStatus? currentUserRSVP;
  final bool isOrganizedByCurrentUser;
  final List<EventReminder> reminders;
  final EventPrivacy privacy;

  EnhancedEvent({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.imageUrls = const [],
    required this.startDate,
    this.endDate,
    required this.startTime,
    this.endTime,
    required this.location,
    this.address,
    this.latitude,
    this.longitude,
    required this.organizerId,
    required this.organizerName,
    this.organizerImageUrl,
    this.maxParticipants = 50,
    this.currentParticipants = 0,
    this.participants = const [],
    this.waitlist = const [],
    this.category = 'Social',
    this.tags = const [],
    this.isOnline = false,
    this.onlineMeetingUrl,
    this.status = EventStatus.published,
    this.price = 0.0,
    this.currency = 'IDR',
    this.isRecurring = false,
    this.recurrencePattern,
    this.reviews = const [],
    this.averageRating = 0.0,
    required this.createdAt,
    this.updatedAt,
    this.currentUserRSVP,
    this.isOrganizedByCurrentUser = false,
    this.reminders = const [],
    this.privacy = EventPrivacy.public,
  });

  factory EnhancedEvent.fromJson(Map<String, dynamic> json) {
    return EnhancedEvent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      startTime: TimeOfDay(
        hour: json['startTime']['hour'],
        minute: json['startTime']['minute'],
      ),
      endTime: json['endTime'] != null
          ? TimeOfDay(
              hour: json['endTime']['hour'],
              minute: json['endTime']['minute'],
            )
          : null,
      location: json['location'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      organizerId: json['organizerId'],
      organizerName: json['organizerName'],
      organizerImageUrl: json['organizerImageUrl'],
      maxParticipants: json['maxParticipants'] ?? 50,
      currentParticipants: json['currentParticipants'] ?? 0,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((p) => EventParticipant.fromJson(p))
          .toList() ?? [],
      waitlist: List<String>.from(json['waitlist'] ?? []),
      category: json['category'] ?? 'Social',
      tags: List<String>.from(json['tags'] ?? []),
      isOnline: json['isOnline'] ?? false,
      onlineMeetingUrl: json['onlineMeetingUrl'],
      status: EventStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => EventStatus.published,
      ),
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'IDR',
      isRecurring: json['isRecurring'] ?? false,
      recurrencePattern: json['recurrencePattern'] != null
          ? RecurrencePattern.fromJson(json['recurrencePattern'])
          : null,
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((r) => EventReview.fromJson(r))
          .toList() ?? [],
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      currentUserRSVP: json['currentUserRSVP'] != null
          ? RSVPStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['currentUserRSVP'],
            )
          : null,
      isOrganizedByCurrentUser: json['isOrganizedByCurrentUser'] ?? false,
      reminders: (json['reminders'] as List<dynamic>?)
          ?.map((r) => EventReminder.fromJson(r))
          .toList() ?? [],
      privacy: EventPrivacy.values.firstWhere(
        (e) => e.toString().split('.').last == json['privacy'],
        orElse: () => EventPrivacy.public,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'startTime': {'hour': startTime.hour, 'minute': startTime.minute},
      'endTime': endTime != null
          ? {'hour': endTime!.hour, 'minute': endTime!.minute}
          : null,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerImageUrl': organizerImageUrl,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'participants': participants.map((p) => p.toJson()).toList(),
      'waitlist': waitlist,
      'category': category,
      'tags': tags,
      'isOnline': isOnline,
      'onlineMeetingUrl': onlineMeetingUrl,
      'status': status.toString().split('.').last,
      'price': price,
      'currency': currency,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern?.toJson(),
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'averageRating': averageRating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'currentUserRSVP': currentUserRSVP?.toString().split('.').last,
      'isOrganizedByCurrentUser': isOrganizedByCurrentUser,
      'reminders': reminders.map((r) => r.toJson()).toList(),
      'privacy': privacy.toString().split('.').last,
    };
  }

  EnhancedEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    String? organizerId,
    String? organizerName,
    String? organizerImageUrl,
    int? maxParticipants,
    int? currentParticipants,
    List<EventParticipant>? participants,
    List<String>? waitlist,
    String? category,
    List<String>? tags,
    bool? isOnline,
    String? onlineMeetingUrl,
    EventStatus? status,
    double? price,
    String? currency,
    bool? isRecurring,
    RecurrencePattern? recurrencePattern,
    List<EventReview>? reviews,
    double? averageRating,
    DateTime? createdAt,
    DateTime? updatedAt,
    RSVPStatus? currentUserRSVP,
    bool? isOrganizedByCurrentUser,
    List<EventReminder>? reminders,
    EventPrivacy? privacy,
  }) {
    return EnhancedEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      organizerImageUrl: organizerImageUrl ?? this.organizerImageUrl,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      participants: participants ?? this.participants,
      waitlist: waitlist ?? this.waitlist,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isOnline: isOnline ?? this.isOnline,
      onlineMeetingUrl: onlineMeetingUrl ?? this.onlineMeetingUrl,
      status: status ?? this.status,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentUserRSVP: currentUserRSVP ?? this.currentUserRSVP,
      isOrganizedByCurrentUser: isOrganizedByCurrentUser ?? this.isOrganizedByCurrentUser,
      reminders: reminders ?? this.reminders,
      privacy: privacy ?? this.privacy,
    );
  }
}

class EventParticipant {
  final String userId;
  final String userName;
  final String? userImageUrl;
  final RSVPStatus rsvpStatus;
  final DateTime rsvpDate;
  final String? note;

  EventParticipant({
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rsvpStatus,
    required this.rsvpDate,
    this.note,
  });

  factory EventParticipant.fromJson(Map<String, dynamic> json) {
    return EventParticipant(
      userId: json['userId'],
      userName: json['userName'],
      userImageUrl: json['userImageUrl'],
      rsvpStatus: RSVPStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['rsvpStatus'],
      ),
      rsvpDate: DateTime.parse(json['rsvpDate']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rsvpStatus': rsvpStatus.toString().split('.').last,
      'rsvpDate': rsvpDate.toIso8601String(),
      'note': note,
    };
  }
}

class EventReview {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final int rating;
  final String comment;
  final List<String> imageUrls;
  final DateTime createdAt;

  EventReview({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    required this.createdAt,
  });

  factory EventReview.fromJson(Map<String, dynamic> json) {
    return EventReview(
      id: json['id'],
      eventId: json['eventId'],
      userId: json['userId'],
      userName: json['userName'],
      userImageUrl: json['userImageUrl'],
      rating: json['rating'],
      comment: json['comment'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userImageUrl': userImageUrl,
      'rating': rating,
      'comment': comment,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class EventReminder {
  final String id;
  final String eventId;
  final String userId;
  final DateTime reminderTime;
  final ReminderType type;
  final bool isActive;

  EventReminder({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.reminderTime,
    required this.type,
    this.isActive = true,
  });

  factory EventReminder.fromJson(Map<String, dynamic> json) {
    return EventReminder(
      id: json['id'],
      eventId: json['eventId'],
      userId: json['userId'],
      reminderTime: DateTime.parse(json['reminderTime']),
      type: ReminderType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'reminderTime': reminderTime.toIso8601String(),
      'type': type.toString().split('.').last,
      'isActive': isActive,
    };
  }
}

class RecurrencePattern {
  final RecurrenceType type;
  final int interval;
  final List<int>? daysOfWeek;
  final int? dayOfMonth;
  final DateTime? endDate;
  final int? occurrences;

  RecurrencePattern({
    required this.type,
    this.interval = 1,
    this.daysOfWeek,
    this.dayOfMonth,
    this.endDate,
    this.occurrences,
  });

  factory RecurrencePattern.fromJson(Map<String, dynamic> json) {
    return RecurrencePattern(
      type: RecurrenceType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      interval: json['interval'] ?? 1,
      daysOfWeek: json['daysOfWeek'] != null
          ? List<int>.from(json['daysOfWeek'])
          : null,
      dayOfMonth: json['dayOfMonth'],
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      occurrences: json['occurrences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'interval': interval,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'endDate': endDate?.toIso8601String(),
      'occurrences': occurrences,
    };
  }
}

enum RSVPStatus {
  going,
  maybe,
  notGoing,
  waitlisted,
  pending,
}

enum EventStatus {
  draft,
  published,
  ongoing,
  completed,
  cancelled,
}

enum EventPrivacy {
  public,
  private,
  friendsOnly,
}

enum RecurrenceType {
  daily,
  weekly,
  monthly,
  yearly,
}

enum ReminderType {
  notification,
  email,
  sms,
}

// TimeOfDay extension for JSON serialization
extension TimeOfDayExtension on TimeOfDay {
  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  static TimeOfDay fromJson(Map<String, dynamic> json) {
    return TimeOfDay(
      hour: json['hour'],
      minute: json['minute'],
    );
  }
}
