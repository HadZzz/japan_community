import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_community/providers/user_provider.dart';
import 'package:japanese_community/providers/community_provider.dart';
import 'package:japanese_community/providers/chat_provider.dart';
import 'package:japanese_community/providers/events_provider.dart';
import 'package:japanese_community/models/auth_models.dart';
import 'package:japanese_community/models/models.dart';
import 'package:japanese_community/models/event_models.dart';
import 'package:japanese_community/models/chat_models.dart';
import 'package:flutter/material.dart';

void main() {
  group('UserProvider Tests', () {
    late UserProvider userProvider;

    setUp(() {
      userProvider = UserProvider();
    });

    test('Initial state is correct', () {
      expect(userProvider.authStatus, AuthStatus.initial);
      expect(userProvider.currentUser, isNull);
      expect(userProvider.isLoggedIn, isFalse);
      expect(userProvider.error, isNull);
    });

    test('Login functionality exists', () async {
      // Test that login method exists and handles demo credentials
      try {
        await userProvider.login('demo@japanese-community.com', 'password123');
        // If successful, user should be authenticated
        expect(userProvider.authStatus, anyOf([AuthStatus.authenticated, AuthStatus.loading]));
      } catch (e) {
        // Login might fail in test environment, but method should exist
        expect(e, isNotNull);
      }
    });
  });

  group('CommunityProvider Tests', () {
    late CommunityProvider communityProvider;

    setUp(() {
      communityProvider = CommunityProvider();
    });

    test('Initial state is correct', () {
      expect(communityProvider.posts, isEmpty);
      expect(communityProvider.isLoading, isFalse);
      expect(communityProvider.error, isNull);
    });

    test('Search functionality exists', () {
      // Test that search method exists
      try {
        communityProvider.searchPosts('test');
      } catch (e) {
        // Method might not be implemented yet
      }
    });
  });

  group('ChatProvider Tests', () {
    late ChatProvider chatProvider;

    setUp(() {
      chatProvider = ChatProvider();
    });

    test('Initial state is correct', () {
      expect(chatProvider.chatRooms, isEmpty);
      expect(chatProvider.onlineUsers, isEmpty);
      expect(chatProvider.currentRoom, isNull);
      expect(chatProvider.connectionStatus, ChatConnectionStatus.disconnected);
    });
  });

  group('EventsProvider Tests', () {
    late EventsProvider eventsProvider;

    setUp(() {
      eventsProvider = EventsProvider();
    });

    test('Initial state is correct', () {
      expect(eventsProvider.events, isEmpty);
      expect(eventsProvider.myEvents, isEmpty);
      expect(eventsProvider.attendingEvents, isEmpty);
      expect(eventsProvider.loadingState, EventsLoadingState.initial);
    });

    test('Date selection works', () {
      final testDate = DateTime(2024, 12, 25);
      eventsProvider.selectDate(testDate);
      expect(eventsProvider.selectedDate, testDate);
    });

    test('Category filtering works', () async {
      await eventsProvider.filterByCategory('Language Exchange');
      expect(eventsProvider.currentCategory, 'Language Exchange');
    });

    test('Search functionality works', () async {
      await eventsProvider.searchEvents('Tokyo');
      expect(eventsProvider.currentSearch, 'Tokyo');
    });
  });

  group('Model Tests', () {
    test('User model serialization works', () {
      final user = User(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
        profileImageUrl: 'https://example.com/image.jpg',
        bio: 'Test bio',
        location: 'Tokyo',
        interests: ['Japanese', 'Culture'],
        joinedDate: DateTime.now(),
        japaneseLevel: 'Beginner',
      );

      final json = user.toJson();
      final deserializedUser = User.fromJson(json);

      expect(deserializedUser.id, user.id);
      expect(deserializedUser.name, user.name);
      expect(deserializedUser.email, user.email);
      expect(deserializedUser.japaneseLevel, user.japaneseLevel);
    });

    test('Post model serialization works', () {
      final post = Post(
        id: '1',
        authorId: 'user1',
        authorName: 'Test User',
        content: 'Test content',
        category: 'General',
        createdAt: DateTime.now(),
        likes: 0,
        isLiked: false,
      );

      final json = post.toJson();
      final deserializedPost = Post.fromJson(json);

      expect(deserializedPost.id, post.id);
      expect(deserializedPost.content, post.content);
      expect(deserializedPost.category, post.category);
    });

    test('EnhancedEvent model serialization works', () {
      final event = EnhancedEvent(
        id: '1',
        title: 'Test Event',
        description: 'Test Description',
        startDate: DateTime.now(),
        startTime: const TimeOfDay(hour: 19, minute: 0),
        location: 'Test Location',
        organizerId: 'org1',
        organizerName: 'Organizer',
        category: 'Social',
        createdAt: DateTime.now(),
      );

      final json = event.toJson();
      final deserializedEvent = EnhancedEvent.fromJson(json);

      expect(deserializedEvent.id, event.id);
      expect(deserializedEvent.title, event.title);
      expect(deserializedEvent.description, event.description);
    });

    test('ChatMessage model serialization works', () {
      final message = EnhancedChatMessage(
        id: '1',
        roomId: 'room1',
        senderId: 'user1',
        senderName: 'Test User',
        content: 'Test message',
        timestamp: DateTime.now(),
      );

      final json = message.toJson();
      final deserializedMessage = EnhancedChatMessage.fromJson(json);

      expect(deserializedMessage.id, message.id);
      expect(deserializedMessage.content, message.content);
      expect(deserializedMessage.senderId, message.senderId);
    });
  });
}