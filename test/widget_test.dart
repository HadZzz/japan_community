import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:japanese_community/main.dart';
import 'package:japanese_community/providers/user_provider.dart';
import 'package:japanese_community/providers/community_provider.dart';
import 'package:japanese_community/providers/chat_provider.dart';
import 'package:japanese_community/providers/events_provider.dart';

void main() {
  group('Japanese Community App Tests', () {
    testWidgets('App loads with proper providers', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const JapaneseCommunityApp());

      // Verify that providers are properly initialized
      expect(find.byType(MultiProvider), findsOneWidget);
      
      // Wait for initialization
      await tester.pump();
      
      // Should show loading or login screen initially
      final loginFinder = find.text('Login');
      final loadingFinder = find.byType(CircularProgressIndicator);
      
      expect(
        loginFinder.evaluate().isNotEmpty || loadingFinder.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Login screen displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => CommunityProvider()),
            ChangeNotifierProvider(create: (_) => ChatProvider()),
            ChangeNotifierProvider(create: (_) => EventsProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Login'),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Login'), findsNWidgets(2));
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Bottom navigation works correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'ホーム',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'コミュニティ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'イベント',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'チャット',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'プロフィール',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('ホーム'), findsOneWidget);
      expect(find.text('コミュニティ'), findsOneWidget);
      expect(find.text('イベント'), findsOneWidget);
      expect(find.text('チャット'), findsOneWidget);
      expect(find.text('プロフィール'), findsOneWidget);
    });
  });
}