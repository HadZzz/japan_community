import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/community_screen.dart';
import 'screens/events_screen.dart';
import 'screens/event_details_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'providers/user_provider.dart';
import 'providers/community_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/events_provider.dart';
import 'theme/app_theme.dart';
import 'models/auth_models.dart';
import 'services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const JapaneseCommunityApp());
}

class JapaneseCommunityApp extends StatelessWidget {
  const JapaneseCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..initializeAuth()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp.router(
            title: 'Japanese Community',
            theme: AppTheme.lightTheme,
            routerConfig: _createRouter(userProvider),
          );
        },
      ),
    );
  }
}

GoRouter _createRouter(UserProvider userProvider) {
  return GoRouter(
    redirect: (context, state) {
      final isLoggedIn = userProvider.isLoggedIn;
      final isLoading = userProvider.authStatus == AuthStatus.loading || 
                       userProvider.authStatus == AuthStatus.initial;
      final isLoginPage = state.uri.path == '/login';

      // Don't redirect while loading to prevent navigation interruption
      if (isLoading) {
        return null;
      }

      // Only redirect if not authenticated and not already on login page
      if (!isLoggedIn && !isLoginPage) {
        return '/login';
      }

      // Only redirect to home if logged in and on login page (after successful login)
      if (isLoggedIn && isLoginPage && userProvider.authStatus == AuthStatus.authenticated) {
        return '/';
      }

      return null; // No redirect needed
    },
    refreshListenable: userProvider,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              // Show loading screen while initializing
              if (userProvider.authStatus == AuthStatus.loading || 
                  userProvider.authStatus == AuthStatus.initial) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Initializing...'),
                      ],
                    ),
                  ),
                );
              }

              // Show login screen if not authenticated
              if (!userProvider.isLoggedIn) {
                return const LoginScreen();
              }

              // Show main app if authenticated
              return MainScreen(child: child);
            },
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/events/:eventId',
            builder: (context, state) {
              final eventId = state.pathParameters['eventId']!;
              return EventDetailsScreen(eventId: eventId);
            },
          ),
        ],
      ),
    ],
  );
}

class MainScreen extends StatefulWidget {
  final Widget child;
  
  const MainScreen({super.key, required this.child});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/community');
        break;
      case 2:
        context.go('/events');
        break;
      case 3:
        context.go('/chat');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'ホーム', // Home in Japanese
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'コミュニティ', // Community in Japanese
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'イベント', // Events in Japanese
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'チャット', // Chat in Japanese
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール', // Profile in Japanese
          ),
        ],
      ),
    );
  }
}