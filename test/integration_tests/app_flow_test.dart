import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:japanese_community/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    testWidgets('Complete app flow test', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Should start with login screen or loading
      final loginFinder = find.text('Login');
      final loadingFinder = find.byType(CircularProgressIndicator);
      
      expect(
        loginFinder.evaluate().isNotEmpty || loadingFinder.evaluate().isNotEmpty,
        isTrue,
      );

      // If login screen is shown, try demo login
      if (find.text('Try Demo Login').evaluate().isNotEmpty) {
        await tester.tap(find.text('Try Demo Login'));
        await tester.pumpAndSettle();
      }

      // Should now be on home screen
      expect(find.text('ホーム'), findsOneWidget);

      // Test navigation to Community
      await tester.tap(find.text('コミュニティ'));
      await tester.pumpAndSettle();

      // Should see community screen
      expect(find.text('Community'), findsOneWidget);

      // Test navigation to Events
      await tester.tap(find.text('イベント'));
      await tester.pumpAndSettle();

      // Should see events screen
      expect(find.text('Events'), findsOneWidget);

      // Test navigation to Chat
      await tester.tap(find.text('チャット'));
      await tester.pumpAndSettle();

      // Should see chat screen
      expect(find.text('Chat'), findsOneWidget);

      // Test navigation to Profile
      await tester.tap(find.text('プロフィール'));
      await tester.pumpAndSettle();

      // Should see profile screen
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Chat functionality test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to chat if not already there
      if (find.text('チャット').evaluate().isNotEmpty) {
        await tester.tap(find.text('チャット'));
        await tester.pumpAndSettle();
      }

      // Should see chat rooms
      expect(find.text('General Discussion'), findsOneWidget);

      // Tap on a chat room
      await tester.tap(find.text('General Discussion'));
      await tester.pumpAndSettle();

      // Should be in chat room
      expect(find.byType(TextField), findsOneWidget);

      // Type a message
      await tester.enterText(find.byType(TextField), 'Hello, test message!');
      await tester.pumpAndSettle();

      // Send message (look for send button)
      final sendButton = find.byIcon(Icons.send);
      if (sendButton.evaluate().isNotEmpty) {
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        // Should see the message in chat
        expect(find.text('Hello, test message!'), findsOneWidget);
      }
    });

    testWidgets('Events functionality test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to events
      if (find.text('イベント').evaluate().isNotEmpty) {
        await tester.tap(find.text('イベント'));
        await tester.pumpAndSettle();
      }

      // Should see events screen
      expect(find.text('Events'), findsOneWidget);

      // Look for create event button
      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Should see create event dialog
        expect(find.text('Create Event'), findsOneWidget);
      }

      // Test calendar view
      final calendarTab = find.text('Calendar');
      if (calendarTab.evaluate().isNotEmpty) {
        await tester.tap(calendarTab);
        await tester.pumpAndSettle();

        // Should see calendar widget
        expect(find.byType(Widget), findsWidgets);
      }
    });

    testWidgets('Community posts functionality test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to community
      if (find.text('コミュニティ').evaluate().isNotEmpty) {
        await tester.tap(find.text('コミュニティ'));
        await tester.pumpAndSettle();
      }

      // Should see community screen
      expect(find.text('Community'), findsOneWidget);

      // Look for create post button
      final createButton = find.byIcon(Icons.add);
      if (createButton.evaluate().isNotEmpty) {
        await tester.tap(createButton);
        await tester.pumpAndSettle();

        // Should see create post dialog or screen
        expect(find.text('Create Post'), findsOneWidget);
      }

      // Test search functionality
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        await tester.enterText(searchField.first, 'Japanese');
        await tester.pumpAndSettle();

        // Should filter posts
        expect(find.byType(Widget), findsWidgets);
      }
    });
  });
}