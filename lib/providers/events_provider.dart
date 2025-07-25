import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/event_models.dart';
import '../services/events_api_service.dart';

enum EventsLoadingState {
  initial,
  loading,
  loadingMore,
  loaded,
  error,
}

class EventsProvider extends ChangeNotifier {
  final EventsApiService _eventsApiService = EventsApiService();

  // Events state
  List<EnhancedEvent> _events = [];
  List<EnhancedEvent> _myEvents = [];
  List<EnhancedEvent> _attendingEvents = [];
  EventsLoadingState _loadingState = EventsLoadingState.initial;
  String? _error;
  
  // Filters and search
  String? _currentCategory;
  String? _currentSearch;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  EventStatus? _filterStatus;
  
  // Location
  Position? _currentPosition;
  bool _locationPermissionGranted = false;
  
  // Calendar
  DateTime _selectedDate = DateTime.now();
  Map<DateTime, List<EnhancedEvent>> _eventsByDate = {};
  
  // UI state
  bool _isCalendarView = false;

  // Getters
  List<EnhancedEvent> get events => _events;
  List<EnhancedEvent> get myEvents => _myEvents;
  List<EnhancedEvent> get attendingEvents => _attendingEvents;
  EventsLoadingState get loadingState => _loadingState;
  String? get error => _error;
  bool get isLoading => _loadingState == EventsLoadingState.loading;
  bool get isLoadingMore => _loadingState == EventsLoadingState.loadingMore;
  Position? get currentPosition => _currentPosition;
  bool get locationPermissionGranted => _locationPermissionGranted;
  DateTime get selectedDate => _selectedDate;
  Map<DateTime, List<EnhancedEvent>> get eventsByDate => _eventsByDate;
  bool get isCalendarView => _isCalendarView;

  // Filter getters
  String? get currentCategory => _currentCategory;
  String? get currentSearch => _currentSearch;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  EventStatus? get filterStatus => _filterStatus;

  EventsProvider() {
    _initializeLocation();
    _loadEvents();
  }

  Future<void> _initializeLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        _locationPermissionGranted = requestedPermission == LocationPermission.whileInUse ||
            requestedPermission == LocationPermission.always;
      } else {
        _locationPermissionGranted = permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always;
      }

      if (_locationPermissionGranted) {
        _currentPosition = await Geolocator.getCurrentPosition();
        notifyListeners();
      }
    } catch (e) {
      print('Location error: $e');
    }
  }

  Future<void> _loadEvents({bool refresh = false}) async {
    if (refresh) {
      _events.clear();
      _eventsByDate.clear();
    }

    _loadingState = _events.isEmpty 
        ? EventsLoadingState.loading 
        : EventsLoadingState.loadingMore;
    _error = null;
    notifyListeners();

    try {
      final response = await _eventsApiService.getEvents(
        category: _currentCategory,
        search: _currentSearch,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
        status: _filterStatus,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _events = response.data!;
        } else {
          _events.addAll(response.data!);
        }
        
        _organizeEventsByDate();
        _loadingState = EventsLoadingState.loaded;
      } else {
        _error = response.message;
        _loadingState = EventsLoadingState.error;
      }
    } catch (e) {
      _error = 'Failed to load events: ${e.toString()}';
      _loadingState = EventsLoadingState.error;
    }

    notifyListeners();
  }

  void _organizeEventsByDate() {
    _eventsByDate.clear();
    
    for (final event in _events) {
      final date = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      
      if (!_eventsByDate.containsKey(date)) {
        _eventsByDate[date] = [];
      }
      _eventsByDate[date]!.add(event);
    }
  }

  Future<void> refreshEvents() async {
    await _loadEvents(refresh: true);
  }

  Future<void> loadMoreEvents() async {
    if (!isLoadingMore) {
      await _loadEvents(refresh: false);
    }
  }

  Future<void> searchEvents(String query) async {
    _currentSearch = query.isEmpty ? null : query;
    await _loadEvents(refresh: true);
  }

  Future<void> filterByCategory(String? category) async {
    _currentCategory = category;
    await _loadEvents(refresh: true);
  }

  Future<void> filterByDateRange(DateTime? startDate, DateTime? endDate) async {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    await _loadEvents(refresh: true);
  }

  Future<void> filterByStatus(EventStatus? status) async {
    _filterStatus = status;
    await _loadEvents(refresh: true);
  }

  void clearFilters() {
    _currentCategory = null;
    _currentSearch = null;
    _filterStartDate = null;
    _filterEndDate = null;
    _filterStatus = null;
    _loadEvents(refresh: true);
  }

  void toggleCalendarView() {
    _isCalendarView = !_isCalendarView;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<EnhancedEvent> getEventsForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return _eventsByDate[normalizedDate] ?? [];
  }

  Future<bool> createEvent({
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
      final response = await _eventsApiService.createEvent(
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
        imageFile: imageFile,
      );

      if (response.success && response.data != null) {
        _events.insert(0, response.data!);
        _myEvents.insert(0, response.data!);
        _organizeEventsByDate();
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to create event: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateRSVP(String eventId, RSVPStatus status, {String? note}) async {
    try {
      final response = await _eventsApiService.updateRSVP(
        eventId: eventId,
        status: status,
        note: note,
      );

      if (response.success) {
        // Update local event
        final eventIndex = _events.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          final event = _events[eventIndex];
          final updatedEvent = event.copyWith(currentUserRSVP: status);
          _events[eventIndex] = updatedEvent;
          
          // Update attending events list
          _attendingEvents.removeWhere((e) => e.id == eventId);
          if (status == RSVPStatus.going) {
            _attendingEvents.add(updatedEvent);
          }
          
          _organizeEventsByDate();
          notifyListeners();
        }
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update RSVP: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> addReview({
    required String eventId,
    required int rating,
    required String comment,
    List<File>? imageFiles,
  }) async {
    try {
      final response = await _eventsApiService.addReview(
        eventId: eventId,
        rating: rating,
        comment: comment,
        imageFiles: imageFiles,
      );

      if (response.success && response.data != null) {
        // Update local event with new review
        final eventIndex = _events.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          final event = _events[eventIndex];
          final updatedReviews = [...event.reviews, response.data!];
          final newAverageRating = updatedReviews
              .map((r) => r.rating)
              .reduce((a, b) => a + b) / updatedReviews.length;
          
          final updatedEvent = event.copyWith(
            reviews: updatedReviews,
            averageRating: newAverageRating,
          );
          
          _events[eventIndex] = updatedEvent;
          notifyListeners();
        }
        return true;
      } else {
        _error = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to add review: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.country}';
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    return null;
  }

  double? calculateDistance(double? eventLat, double? eventLng) {
    if (_currentPosition == null || eventLat == null || eventLng == null) {
      return null;
    }
    
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      eventLat,
      eventLng,
    ) / 1000; // Convert to kilometers
  }

  List<EnhancedEvent> getNearbyEvents({double radiusKm = 10.0}) {
    if (_currentPosition == null) return [];
    
    return _events.where((event) {
      final distance = calculateDistance(event.latitude, event.longitude);
      return distance != null && distance <= radiusKm;
    }).toList();
  }

  List<EnhancedEvent> getUpcomingEvents() {
    final now = DateTime.now();
    return _events
        .where((event) => event.startDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  List<EnhancedEvent> getEventsByCategory(String category) {
    return _events.where((event) => event.category == category).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}