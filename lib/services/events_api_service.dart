import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/event_models.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
  });
}

class EventsApiService {
  static const String baseUrl = 'https://api.japanese-community.com'; // Demo URL
  static const String eventsEndpoint = '/api/events';
  
  // For demo purposes, we'll simulate API calls
  static const bool _useSimulation = true;

  Future<ApiResponse<List<EnhancedEvent>>> getEvents({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    double? latitude,
    double? longitude,
    double? radius,
    EventStatus? status,
  }) async {
    try {
      if (_useSimulation) {
        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));
        
        final mockEvents = _generateMockEvents();
        
        // Apply filters
        var filteredEvents = mockEvents.where((event) {
          if (category != null && event.category != category) return false;
          if (search != null && search.isNotEmpty) {
            final searchLower = search.toLowerCase();
            if (!event.title.toLowerCase().contains(searchLower) &&
                !event.description.toLowerCase().contains(searchLower)) {
              return false;
            }
          }
          if (startDate != null && event.startDate.isBefore(startDate)) return false;
          if (endDate != null && event.startDate.isAfter(endDate)) return false;
          if (status != null && event.status != status) return false;
          return true;
        }).toList();

        // Sort by date
        filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));

        // Paginate
        final startIndex = (page - 1) * limit;
        final endIndex = startIndex + limit;
        final paginatedEvents = filteredEvents.length > startIndex
            ? filteredEvents.sublist(
                startIndex,
                endIndex > filteredEvents.length ? filteredEvents.length : endIndex,
              )
            : <EnhancedEvent>[];

        return ApiResponse(
          success: true,
          data: paginatedEvents,
          message: 'Events retrieved successfully',
        );
      }

      // Real API implementation would go here
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null) 'category': category,
        if (search != null) 'search': search,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
        if (radius != null) 'radius': radius.toString(),
        if (status != null) 'status': status.toString().split('.').last,
      };

      final uri = Uri.parse('$baseUrl$eventsEndpoint').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = (data['events'] as List)
            .map((eventJson) => EnhancedEvent.fromJson(eventJson))
            .toList();

        return ApiResponse(
          success: true,
          data: events,
          message: 'Events retrieved successfully',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to load events',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<EnhancedEvent>> getEvent(String eventId) async {
    try {
      if (_useSimulation) {
        await Future.delayed(const Duration(milliseconds: 300));
        
        final mockEvents = _generateMockEvents();
        final event = mockEvents.firstWhere(
          (e) => e.id == eventId,
          orElse: () => throw Exception('Event not found'),
        );

        return ApiResponse(
          success: true,
          data: event,
          message: 'Event retrieved successfully',
        );
      }

      final response = await http.get(Uri.parse('$baseUrl$eventsEndpoint/$eventId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final event = EnhancedEvent.fromJson(data['event']);

        return ApiResponse(
          success: true,
          data: event,
          message: 'Event retrieved successfully',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to load event',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<EnhancedEvent>> createEvent({
    required String title,
    required String description,
    required DateTime startDate,
    DateTime? endDate,
    required TimeOfDay startTime,
    TimeOfDay? endTime,
    required String location,
    String? address,
    double? latitude,
    double? longitude,
    int maxParticipants = 50,
    String category = 'Social',
    List<String> tags = const [],
    bool isOnline = false,
    String? onlineMeetingUrl,
    double price = 0.0,
    String currency = 'IDR',
    bool isRecurring = false,
    RecurrencePattern? recurrencePattern,
    EventPrivacy privacy = EventPrivacy.public,
    File? imageFile,
  }) async {
    try {
      if (_useSimulation) {
        await Future.delayed(const Duration(milliseconds: 800));

        final newEvent = EnhancedEvent(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          description: description,
          startDate: startDate,
          endDate: endDate,
          startTime: startTime,
          endTime: endTime,
          location: location,
          address: address,
          latitude: latitude,
          longitude: longitude,
          organizerId: '1', // Current user
          organizerName: 'You',
          maxParticipants: maxParticipants,
          category: category,
          tags: tags,
          isOnline: isOnline,
          onlineMeetingUrl: onlineMeetingUrl,
          price: price,
          currency: currency,
          isRecurring: isRecurring,
          recurrencePattern: recurrencePattern,
          privacy: privacy,
          createdAt: DateTime.now(),
          isOrganizedByCurrentUser: true,
        );

        return ApiResponse(
          success: true,
          data: newEvent,
          message: 'Event created successfully',
        );
      }

      // Real API implementation
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$eventsEndpoint'));
      
      request.fields.addAll({
        'title': title,
        'description': description,
        'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        'startTime': json.encode({'hour': startTime.hour, 'minute': startTime.minute}),
        if (endTime != null) 'endTime': json.encode({'hour': endTime.hour, 'minute': endTime.minute}),
        'location': location,
        if (address != null) 'address': address,
        if (latitude != null) 'latitude': latitude.toString(),
        if (longitude != null) 'longitude': longitude.toString(),
        'maxParticipants': maxParticipants.toString(),
        'category': category,
        'tags': json.encode(tags),
        'isOnline': isOnline.toString(),
        if (onlineMeetingUrl != null) 'onlineMeetingUrl': onlineMeetingUrl,
        'price': price.toString(),
        'currency': currency,
        'isRecurring': isRecurring.toString(),
        if (recurrencePattern != null) 'recurrencePattern': json.encode(recurrencePattern.toJson()),
        'privacy': privacy.toString().split('.').last,
      });

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        final event = EnhancedEvent.fromJson(data['event']);

        return ApiResponse(
          success: true,
          data: event,
          message: 'Event created successfully',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to create event',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<EnhancedEvent>> updateRSVP({
    required String eventId,
    required RSVPStatus status,
    String? note,
  }) async {
    try {
      if (_useSimulation) {
        await Future.delayed(const Duration(milliseconds: 400));

        return ApiResponse(
          success: true,
          data: null, // Would return updated event
          message: 'RSVP updated successfully',
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl$eventsEndpoint/$eventId/rsvp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status.toString().split('.').last,
          if (note != null) 'note': note,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final event = EnhancedEvent.fromJson(data['event']);

        return ApiResponse(
          success: true,
          data: event,
          message: 'RSVP updated successfully',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to update RSVP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<EventReview>> addReview({
    required String eventId,
    required int rating,
    required String comment,
    List<File>? imageFiles,
  }) async {
    try {
      if (_useSimulation) {
        await Future.delayed(const Duration(milliseconds: 600));

        final review = EventReview(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          eventId: eventId,
          userId: '1',
          userName: 'You',
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
        );

        return ApiResponse(
          success: true,
          data: review,
          message: 'Review added successfully',
        );
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$eventsEndpoint/$eventId/reviews'),
      );

      request.fields.addAll({
        'rating': rating.toString(),
        'comment': comment,
      });

      if (imageFiles != null) {
        for (int i = 0; i < imageFiles.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath('images', imageFiles[i].path),
          );
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        final review = EventReview.fromJson(data['review']);

        return ApiResponse(
          success: true,
          data: review,
          message: 'Review added successfully',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Failed to add review',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  List<EnhancedEvent> _generateMockEvents() {
    final now = DateTime.now();
    
    return [
      EnhancedEvent(
        id: '1',
        title: 'Tokyo Language Exchange Meetup',
        description: 'Join us for a fun language exchange session in Shibuya! Perfect for practicing Japanese and meeting new friends. We\'ll have structured conversation practice, games, and cultural exchange activities.',
        imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400&h=300&fit=crop',
        startDate: now.add(const Duration(days: 3)),
        startTime: const TimeOfDay(hour: 19, minute: 0),
        endTime: const TimeOfDay(hour: 21, minute: 0),
        location: 'Shibuya Community Center',
        address: '1-1-1 Shibuya, Shibuya City, Tokyo',
        latitude: 35.6594,
        longitude: 139.7006,
        organizerId: '2',
        organizerName: 'Sakura Yamamoto',
        organizerImageUrl: 'https://i.pravatar.cc/150?img=2',
        maxParticipants: 30,
        currentParticipants: 15,
        category: 'Language Exchange',
        tags: ['Japanese', 'English', 'Conversation', 'Beginner-friendly'],
        price: 500.0,
        currency: 'JPY',
        averageRating: 4.8,
        createdAt: now.subtract(const Duration(days: 10)),
        participants: [
          EventParticipant(
            userId: '1',
            userName: 'You',
            rsvpStatus: RSVPStatus.going,
            rsvpDate: now.subtract(const Duration(days: 2)),
          ),
        ],
        reviews: [
          EventReview(
            id: '1',
            eventId: '1',
            userId: '3',
            userName: 'Mike Johnson',
            rating: 5,
            comment: 'Amazing event! Met so many friendly people and improved my Japanese a lot.',
            createdAt: now.subtract(const Duration(days: 5)),
          ),
        ],
      ),
      
      EnhancedEvent(
        id: '2',
        title: 'Anime Movie Night: Studio Ghibli Marathon',
        description: 'Let\'s watch classic Studio Ghibli movies together! We\'ll be screening Spirited Away, My Neighbor Totoro, and Princess Mononoke with Japanese audio and subtitles.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
        startDate: now.add(const Duration(days: 7)),
        startTime: const TimeOfDay(hour: 18, minute: 0),
        endTime: const TimeOfDay(hour: 23, minute: 0),
        location: 'Harajuku Community Center',
        address: '2-2-2 Harajuku, Shibuya City, Tokyo',
        latitude: 35.6702,
        longitude: 139.7026,
        organizerId: '3',
        organizerName: 'Mike Johnson',
        organizerImageUrl: 'https://i.pravatar.cc/150?img=3',
        maxParticipants: 20,
        currentParticipants: 8,
        category: 'Cultural',
        tags: ['Anime', 'Movies', 'Studio Ghibli', 'Japanese Culture'],
        averageRating: 4.6,
        createdAt: now.subtract(const Duration(days: 8)),
      ),

      EnhancedEvent(
        id: '3',
        title: 'Online Japanese Cooking Class: Authentic Ramen',
        description: 'Learn to make authentic tonkotsu ramen from scratch! Chef Kenji will guide you through the entire process, from preparing the broth to making fresh noodles.',
        imageUrl: 'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=400&h=300&fit=crop',
        startDate: now.add(const Duration(days: 10)),
        startTime: const TimeOfDay(hour: 15, minute: 0),
        endTime: const TimeOfDay(hour: 18, minute: 0),
        location: 'Online (Zoom)',
        organizerId: '4',
        organizerName: 'Kenji Nakamura',
        organizerImageUrl: 'https://i.pravatar.cc/150?img=4',
        maxParticipants: 15,
        currentParticipants: 12,
        category: 'Educational',
        tags: ['Cooking', 'Ramen', 'Japanese Cuisine', 'Online'],
        isOnline: true,
        onlineMeetingUrl: 'https://zoom.us/j/123456789',
        price: 2500.0,
        currency: 'JPY',
        averageRating: 4.9,
        createdAt: now.subtract(const Duration(days: 15)),
      ),

      EnhancedEvent(
        id: '4',
        title: 'Cherry Blossom Viewing Picnic',
        description: 'Join us for hanami (cherry blossom viewing) at Ueno Park! Bring your own food and drinks, and let\'s enjoy the beautiful sakura together.',
        imageUrl: 'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=400&h=300&fit=crop',
        startDate: now.add(const Duration(days: 14)),
        startTime: const TimeOfDay(hour: 11, minute: 0),
        endTime: const TimeOfDay(hour: 16, minute: 0),
        location: 'Ueno Park',
        address: 'Ueno Park, Taito City, Tokyo',
        latitude: 35.7148,
        longitude: 139.7731,
        organizerId: '2',
        organizerName: 'Sakura Yamamoto',
        organizerImageUrl: 'https://i.pravatar.cc/150?img=2',
        maxParticipants: 50,
        currentParticipants: 25,
        category: 'Social',
        tags: ['Hanami', 'Cherry Blossoms', 'Picnic', 'Outdoor'],
        averageRating: 4.7,
        createdAt: now.subtract(const Duration(days: 20)),
      ),

      EnhancedEvent(
        id: '5',
        title: 'Japanese Calligraphy Workshop',
        description: 'Learn the art of Japanese calligraphy (shodō) with master calligrapher Tanaka-sensei. All materials provided. Suitable for beginners.',
        imageUrl: 'https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?w=400&h=300&fit=crop',
        startDate: now.add(const Duration(days: 21)),
        startTime: const TimeOfDay(hour: 14, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
        location: 'Traditional Arts Center',
        address: '3-3-3 Asakusa, Taito City, Tokyo',
        latitude: 35.7143,
        longitude: 139.7967,
        organizerId: '5',
        organizerName: 'Hiroshi Tanaka',
        organizerImageUrl: 'https://i.pravatar.cc/150?img=5',
        maxParticipants: 12,
        currentParticipants: 6,
        category: 'Educational',
        tags: ['Calligraphy', 'Traditional Arts', 'Japanese Culture', 'Workshop'],
        price: 3000.0,
        currency: 'JPY',
        averageRating: 4.8,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ];
  }
}