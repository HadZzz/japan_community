# 🚀 Backend Integration Guide for Japanese Community App

## 🎯 Recommended Free Backend Solutions

After analyzing the requirements for authentication, real-time chat, and events management, here are the best free backend options:

### 1. 🥇 **SUPABASE** (Highly Recommended)
**Why it's the best choice for our app:**

✅ **Advantages:**
- **Completely FREE** tier with generous limits:
  - 500MB database storage
  - 2GB bandwidth per month
  - 50,000 monthly active users
  - Real-time subscriptions
  - 100MB file storage
- **Built-in Authentication** with JWT tokens
- **Real-time Database** with PostgreSQL
- **Real-time subscriptions** for chat
- **File Storage** for images/attachments
- **Row Level Security** for data protection
- **REST API** auto-generated
- **Dashboard** for easy management
- **Edge Functions** for serverless logic

✅ **Perfect for our features:**
- ✅ User registration/login
- ✅ Real-time chat with WebSocket-like subscriptions
- ✅ Events management with complex queries
- ✅ File uploads for chat attachments and event images
- ✅ User profiles and social features

**Setup Time:** ~2-3 hours
**Learning Curve:** Easy to moderate

---

### 2. 🥈 **FIREBASE** (Google)
**Good alternative but with limitations:**

✅ **Advantages:**
- **FREE** Spark plan:
  - 1GB storage
  - 10GB/month bandwidth
  - 100 simultaneous connections
  - Authentication included
- **Real-time Database** or **Firestore**
- **Cloud Functions** for serverless logic
- **Firebase Auth** for authentication
- **Cloud Storage** for files

❌ **Disadvantages:**
- More expensive when scaling
- Complex pricing structure
- Limited offline capabilities
- Vendor lock-in

---

### 3. 🥉 **POCKETBASE** (Self-hosted)
**Best for full control:**

✅ **Advantages:**
- **Completely FREE** (self-hosted)
- **Single binary** - easy deployment
- **Built-in admin UI**
- **Real-time subscriptions**
- **File uploads**
- **Authentication**

❌ **Disadvantages:**
- Requires server management
- Need to handle scaling yourself
- Limited free hosting options

---

## 🎯 **RECOMMENDATION: SUPABASE**

Based on our app's requirements, **Supabase is the clear winner** because:

1. **Free tier is generous** and perfect for development and early production
2. **Real-time features** work perfectly for chat
3. **PostgreSQL** is powerful for complex event queries
4. **Authentication** is built-in and secure
5. **File storage** for images and attachments
6. **Easy integration** with Flutter

---

## 🛠️ Implementation Plan

### Phase 1: Supabase Setup (1-2 hours)
1. Create Supabase account
2. Create new project
3. Setup database tables
4. Configure authentication
5. Setup file storage buckets

### Phase 2: Flutter Integration (3-4 hours)
1. Add Supabase Flutter package
2. Replace mock services with real API calls
3. Implement authentication
4. Setup real-time chat subscriptions
5. Configure file uploads

### Phase 3: Testing & Polish (2-3 hours)
1. Test all features with real backend
2. Handle error cases
3. Optimize performance
4. Add loading states

---

## 📋 Database Schema Design

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  image_url TEXT,
  bio TEXT,
  location TEXT,
  native_language TEXT,
  learning_languages TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Posts Table
```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  likes_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Events Table
```sql
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organizer_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE,
  start_time TIME NOT NULL,
  end_time TIME,
  location TEXT NOT NULL,
  address TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  max_participants INTEGER DEFAULT 50,
  current_participants INTEGER DEFAULT 0,
  category TEXT NOT NULL,
  tags TEXT[],
  is_online BOOLEAN DEFAULT FALSE,
  online_meeting_url TEXT,
  price DECIMAL(10,2) DEFAULT 0.00,
  currency TEXT DEFAULT 'IDR',
  status TEXT DEFAULT 'published',
  privacy TEXT DEFAULT 'public',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Chat Rooms Table
```sql
CREATE TABLE chat_rooms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  type TEXT DEFAULT 'public',
  category TEXT DEFAULT 'General',
  max_participants INTEGER DEFAULT 100,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Chat Messages Table
```sql
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text',
  file_url TEXT,
  file_name TEXT,
  file_size INTEGER,
  reply_to_id UUID REFERENCES chat_messages(id),
  is_edited BOOLEAN DEFAULT FALSE,
  edited_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Event RSVPs Table
```sql
CREATE TABLE event_rsvps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL, -- 'going', 'maybe', 'not_going'
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);
```

---

## 🔧 Flutter Integration Code

### 1. Add Dependencies
```yaml
dependencies:
  supabase_flutter: ^2.5.6
  # ... other dependencies
```

### 2. Initialize Supabase
```dart
// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
}
```

### 3. Real Authentication Service
```dart
// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password, String name) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    
    if (response.user != null) {
      // Create user profile
      await _client.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'name': name,
      });
    }
    
    return response;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
```

### 4. Real-time Chat Service
```dart
// lib/services/chat_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getChatMessages(String roomId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at');
  }

  Future<void> sendMessage({
    required String roomId,
    required String content,
    String messageType = 'text',
    String? fileUrl,
    String? fileName,
  }) async {
    await _client.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': _client.auth.currentUser!.id,
      'content': content,
      'message_type': messageType,
      'file_url': fileUrl,
      'file_name': fileName,
    });
  }
}
```

---

## 🚀 Next Steps

1. **Create Supabase Account**: Go to [supabase.com](https://supabase.com) and create free account
2. **Setup Project**: Create new project and note down URL and anon key
3. **Run Database Setup**: Execute the SQL schema above in Supabase SQL editor
4. **Update Flutter Code**: Replace mock services with real Supabase integration
5. **Test Everything**: Ensure all features work with real backend
6. **Deploy**: App is ready for production!

**Total Setup Time: ~6-8 hours**
**Cost: FREE for development and small-scale production**

This setup will give you a production-ready backend that can handle thousands of users without any cost!