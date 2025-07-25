import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/event_models.dart';
import 'supabase_config.dart';

class SupabaseEventsService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Get all events with filters
  Future<List<EnhancedEvent>> getEvents({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    EventStatus? status,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    try {
      var query = _client
          .from('events')
          .select('''
            *,
            event_rsvps(user_id, status),
            event_reviews(rating)
          ''');

      // Apply filters using where conditions
      if (category != null) {
        query = query.eq('category', category);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('title.ilike.%$search%,description.ilike.%$search%');
      }

      if (startDate != null) {
        query = query.gte('start_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('start_date', endDate.toIso8601String());
      }

      if (status != null) {
        query = query.eq('status', status.toString().split('.').last);
      }

      // Apply pagination and ordering
      final offset = (page - 1) * limit;
      final response = await query
          .order('start_date', ascending: true)
          .range(offset, offset + limit - 1);

      return response.map<EnhancedEvent>((eventData) => 
          _mapToEnhancedEvent(eventData)).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  // Get single event by ID
  Future<EnhancedEvent?> getEvent(String eventId) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            event_rsvps(*),
            event_reviews(*)
          ''')
          .eq('id', eventId)
          .single();

      return _mapToEnhancedEvent(response);
    } catch (e) {
      print('Error fetching event: $e');
      return null;
    }
  }

  // Create new event
  Future<EnhancedEvent?> createEvent({
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
    EventPrivacy privacy = EventPrivacy.public,
    File? imageFile,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Get user profile for organizer info
      final userProfile = await _client
          .from('users')
          .select('name')
          .eq('id', user.id)
          .single();

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _uploadEventImage(imageFile);
      }

      final eventData = {
        'organizer_id': user.id,
        'organizer_name': userProfile['name'] ?? 'Unknown User',
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        'end_time': endTime != null 
            ? '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}'
            : null,
        'location': location,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'max_participants': maxParticipants,
        'category': category,
        'tags': tags,
        'is_online': isOnline,
        'online_meeting_url': onlineMeetingUrl,
        'price': price,
        'currency': currency,
        'privacy': privacy.toString().split('.').last,
        'status': 'published',
      };

      final response = await _client
          .from('events')
          .insert(eventData)
          .select()
          .single();

      return _mapToEnhancedEvent(response);
    } catch (e) {
      print('Error creating event: $e');
      return null;
    }
  }

  // Update RSVP status
  Future<bool> updateRSVP({
    required String eventId,
    required RSVPStatus status,
    String? note,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      // Get user profile
      final userProfile = await _client
          .from('users')
          .select('name')
          .eq('id', user.id)
          .single();

      await _client.from('event_rsvps').upsert({
        'event_id': eventId,
        'user_id': user.id,
        'user_name': userProfile['name'] ?? 'Unknown User',
        'status': status.toString().split('.').last,
        'note': note,
      });

      // Update event participant count
      await _updateEventParticipantCount(eventId);

      return true;
    } catch (e) {
      print('Error updating RSVP: $e');
      return false;
    }
  }

  // Add event review
  Future<EventReview?> addReview({
    required String eventId,
    required int rating,
    required String comment,
    List<File>? imageFiles,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Get user profile
      final userProfile = await _client
          .from('users')
          .select('name, profile_image_url')
          .eq('id', user.id)
          .single();

      List<String> imageUrls = [];
      if (imageFiles != null) {
        for (final file in imageFiles) {
          final url = await _uploadReviewImage(file);
          if (url != null) imageUrls.add(url);
        }
      }

      final reviewData = {
        'event_id': eventId,
        'user_id': user.id,
        'user_name': userProfile['name'] ?? 'Unknown User',
        'user_image_url': userProfile['profile_image_url'],
        'rating': rating,
        'comment': comment,
        'image_urls': imageUrls,
      };

      final response = await _client
          .from('event_reviews')
          .insert(reviewData)
          .select()
          .single();

      // Update event average rating
      await _updateEventAverageRating(eventId);

      return EventReview(
        id: response['id'],
        eventId: eventId,
        userId: user.id,
        userName: response['user_name'],
        userImageUrl: response['user_image_url'],
        rating: rating,
        comment: comment,
        imageUrls: List<String>.from(response['image_urls'] ?? []),
        createdAt: DateTime.parse(response['created_at']),
      );
    } catch (e) {
      print('Error adding review: $e');
      return null;
    }
  }

  // Get events by user (created by user)
  Future<List<EnhancedEvent>> getUserEvents(String userId) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            event_rsvps(user_id, status),
            event_reviews(rating)
          ''')
          .eq('organizer_id', userId)
          .order('created_at', ascending: false);

      return response.map<EnhancedEvent>((eventData) => 
          _mapToEnhancedEvent(eventData)).toList();
    } catch (e) {
      print('Error fetching user events: $e');
      return [];
    }
  }

  // Get events user is attending
  Future<List<EnhancedEvent>> getAttendingEvents(String userId) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            event_rsvps!inner(user_id, status),
            event_reviews(rating)
          ''')
          .eq('event_rsvps.user_id', userId)
          .eq('event_rsvps.status', 'going')
          .order('start_date', ascending: true);

      return response.map<EnhancedEvent>((eventData) => 
          _mapToEnhancedEvent(eventData)).toList();
    } catch (e) {
      print('Error fetching attending events: $e');
      return [];
    }
  }

  // Helper method to upload event image
  Future<String?> _uploadEventImage(File imageFile) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'event_${user.id}_$timestamp.jpg';

      await _client.storage
          .from('event-images')
          .upload(fileName, imageFile);

      return _client.storage
          .from('event-images')
          .getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading event image: $e');
      return null;
    }
  }

  // Helper method to upload review image
  Future<String?> _uploadReviewImage(File imageFile) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'review_${user.id}_$timestamp.jpg';

      await _client.storage
          .from('review-images')
          .upload(fileName, imageFile);

      return _client.storage
          .from('review-images')
          .getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading review image: $e');
      return null;
    }
  }

  // Update event participant count
  Future<void> _updateEventParticipantCount(String eventId) async {
    try {
      final rsvpCount = await _client
          .from('event_rsvps')
          .select()
          .eq('event_id', eventId)
          .eq('status', 'going')
          .count();

      await _client
          .from('events')
          .update({'current_participants': rsvpCount.count})
          .eq('id', eventId);
    } catch (e) {
      print('Error updating participant count: $e');
    }
  }

  // Update event average rating
  Future<void> _updateEventAverageRating(String eventId) async {
    try {
      final reviews = await _client
          .from('event_reviews')
          .select('rating')
          .eq('event_id', eventId);

      if (reviews.isNotEmpty) {
        final totalRating = reviews.fold<int>(0, (sum, review) => sum + (review['rating'] as int));
        final averageRating = totalRating / reviews.length;

        await _client
            .from('events')
            .update({'average_rating': averageRating})
            .eq('id', eventId);
      }
    } catch (e) {
      print('Error updating average rating: $e');
    }
  }

  // Helper method to map database record to EnhancedEvent
  EnhancedEvent _mapToEnhancedEvent(Map<String, dynamic> eventData) {
    final currentUser = _client.auth.currentUser;
    
    // Parse time strings
    final startTimeParts = eventData['start_time'].split(':');
    final startTime = TimeOfDay(
      hour: int.parse(startTimeParts[0]),
      minute: int.parse(startTimeParts[1]),
    );

    TimeOfDay? endTime;
    if (eventData['end_time'] != null) {
      final endTimeParts = eventData['end_time'].split(':');
      endTime = TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      );
    }

    // Process RSVPs
    final rsvps = eventData['event_rsvps'] as List<dynamic>? ?? [];
    final participants = rsvps.map((rsvp) => EventParticipant(
      userId: rsvp['user_id'],
      userName: rsvp['user_name'] ?? 'Unknown User',
      rsvpStatus: RSVPStatus.values.firstWhere(
        (e) => e.toString().split('.').last == rsvp['status'],
        orElse: () => RSVPStatus.pending,
      ),
      rsvpDate: DateTime.parse(rsvp['created_at'] ?? DateTime.now().toIso8601String()),
      note: rsvp['note'],
    )).toList();

    // Process reviews
    final reviewsData = eventData['event_reviews'] as List<dynamic>? ?? [];
    final reviews = reviewsData.map((review) => EventReview(
      id: review['id'],
      eventId: eventData['id'],
      userId: review['user_id'],
      userName: review['user_name'],
      userImageUrl: review['user_image_url'],
      rating: review['rating'],
      comment: review['comment'],
      imageUrls: List<String>.from(review['image_urls'] ?? []),
      createdAt: DateTime.parse(review['created_at']),
    )).toList();

    // Calculate current user RSVP status
    RSVPStatus? currentUserRSVP;
    if (currentUser != null) {
      final userRSVP = rsvps.firstWhere(
        (rsvp) => rsvp['user_id'] == currentUser.id,
        orElse: () => null,
      );
      if (userRSVP != null) {
        currentUserRSVP = RSVPStatus.values.firstWhere(
          (e) => e.toString().split('.').last == userRSVP['status'],
          orElse: () => RSVPStatus.pending,
        );
      }
    }

    return EnhancedEvent(
      id: eventData['id'],
      title: eventData['title'],
      description: eventData['description'],
      imageUrl: eventData['image_url'],
      startDate: DateTime.parse(eventData['start_date']),
      endDate: eventData['end_date'] != null 
          ? DateTime.parse(eventData['end_date']) 
          : null,
      startTime: startTime,
      endTime: endTime,
      location: eventData['location'],
      address: eventData['address'],
      latitude: eventData['latitude']?.toDouble(),
      longitude: eventData['longitude']?.toDouble(),
      organizerId: eventData['organizer_id'],
      organizerName: eventData['organizer_name'],
      maxParticipants: eventData['max_participants'] ?? 50,
      currentParticipants: eventData['current_participants'] ?? 0,
      participants: participants,
      category: eventData['category'] ?? 'Social',
      tags: List<String>.from(eventData['tags'] ?? []),
      isOnline: eventData['is_online'] ?? false,
      onlineMeetingUrl: eventData['online_meeting_url'],
      status: EventStatus.values.firstWhere(
        (e) => e.toString().split('.').last == eventData['status'],
        orElse: () => EventStatus.published,
      ),
      price: (eventData['price'] ?? 0.0).toDouble(),
      currency: eventData['currency'] ?? 'IDR',
      privacy: EventPrivacy.values.firstWhere(
        (e) => e.toString().split('.').last == eventData['privacy'],
        orElse: () => EventPrivacy.public,
      ),
      reviews: reviews,
      averageRating: (eventData['average_rating'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(eventData['created_at']),
      updatedAt: eventData['updated_at'] != null 
          ? DateTime.parse(eventData['updated_at']) 
          : null,
      currentUserRSVP: currentUserRSVP,
      isOrganizedByCurrentUser: currentUser?.id == eventData['organizer_id'],
    );
  }
}