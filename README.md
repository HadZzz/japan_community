# 🇯🇵 Japanese Community Mobile App

Aplikasi mobile Flutter untuk komunitas pembelajar bahasa Jepang di Indonesia. Platform ini menghubungkan native speakers Jepang dengan pembelajar Indonesia untuk saling berbagi pengalaman, belajar bersama, dan membangun komunitas yang solid.

## 📱 Tentang Aplikasi

**Japanese Community** adalah aplikasi mobile yang dirancang khusus untuk memfasilitasi interaksi antara:
- 🎌 Native speakers bahasa Jepang yang tinggal di Indonesia
- 🇮🇩 Orang Indonesia yang sedang belajar bahasa Jepang
- 👥 Komunitas yang tertarik dengan budaya Jepang

### 🎯 Tujuan Utama
- Memudahkan language exchange antara native speakers dan learners
- Menyediakan platform untuk berbagi pengalaman dan tips belajar
- Mengorganisir event dan meetup komunitas
- Membangun jaringan sosial yang supportive untuk pembelajaran bahasa

## ✅ Fitur yang Sudah Dikembangkan

### 🔐 **Phase A: Authentication System (COMPLETED)**
- **Login/Register** dengan validasi form yang lengkap
- **JWT token-based authentication** untuk keamanan
- **Session persistence** menggunakan SharedPreferences
- **Demo login** untuk testing cepat
- **Form validation** dan error handling yang comprehensive
- **User profile management** dasar

**Demo Credentials:**
- Email: `demo@japanese-community.com` 
- Password: `password123`
- Atau gunakan tombol "Try Demo Login"

### 📝 **Phase B: Posts Management System (COMPLETED)**
- **CRUD Operations** - Create, Read, Update, Delete posts
- **Real-time Search** - Pencarian instant saat mengetik
- **Category Filtering** - Filter posts berdasarkan kategori
- **Like System** dengan optimistic updates
- **Infinite Scroll Pagination** untuk performa optimal
- **Image Upload Support** (API ready)
- **Comprehensive Error Handling** dengan retry options
- **Responsive UI** dengan loading states

### 💬 **Phase C: Real-time Chat System (COMPLETED)**
**Target: 1-2 minggu ke depan** ✅ **SELESAI**

**Fitur yang telah dikembangkan:**
- 💬 **Real-time Messaging** dengan WebSocket simulation
- 🏠 **Chat Rooms** untuk topik berbeda (Beginner, Advanced, Culture, General, Events)
- 👥 **Online Status Indicators** dan user presence
- 📁 **File/Image Sharing** dalam chat dengan attachment picker
- 🟢 **Connection Status** monitoring dengan reconnection
- 😊 **Message Reactions** dengan emoji picker
- ⌨️ **Typing Indicators** real-time
- 🎌 **Japanese Phrase Suggestions** untuk pembelajaran
- 📱 **Responsive Chat UI** dengan message bubbles
- 🔄 **Message Status** (sending, sent, delivered, read)
- 📋 **Room Categories** dengan color coding dan icons
- 🔔 **Unread Message Counters** per room
- 💾 **Optimistic Updates** untuk UX yang smooth

**Technical Implementation:**
- ✅ WebSocket service dengan fallback simulation
- ✅ Enhanced chat models dengan reactions dan file support
- ✅ Dedicated ChatProvider untuk state management
- ✅ Real-time message synchronization
- ✅ File picker integration untuk images dan documents
- ✅ Typing indicator system
- ✅ Connection status monitoring
- ✅ Message encryption ready (untuk production)
- ✅ Offline message queuing support

**Chat Features Detail:**
- **5 Chat Rooms**: General, Beginner Japanese, Advanced Japanese, Japanese Culture, Event Planning
- **Message Types**: Text, Image, File, System messages
- **Japanese Learning**: Built-in phrase suggestions dan emoji reactions
- **File Sharing**: Support untuk images (gallery/camera) dan files
- **Real-time Features**: Typing indicators, online status, message reactions
- **UI/UX**: Modern chat interface dengan message bubbles, timestamps, status indicators

### 🎨 **UI/UX Features (COMPLETED)**
- **Minimalist Design** terinspirasi estetika Jepang
- **Bottom Navigation** dengan label bahasa Jepang
- **Responsive Layouts** untuk berbagai ukuran layar
- **Loading Indicators** dan feedback visual
- **Error States** dengan opsi retry
- **Card-based Layout** untuk konten yang clean
- **Chat Interface** dengan modern message bubbles
- **Real-time Indicators** untuk typing dan online status

## 🚧 Roadmap Pengembangan Selanjutnya

### 📅 **Phase D: Events Management System (NEXT - PLANNED)**
**Target: 2-3 minggu ke depan**

**Fitur yang akan dikembangkan:**
- 📝 **Event Creation** - Buat dan kelola event
- ✅ **RSVP System** - Registration dan attendance tracking
- 📅 **Calendar Integration** - View events dalam calendar
- 🗺️ **Location-based Discovery** - Temukan event terdekat
- 🏷️ **Event Categories**:
  - Language Exchange
  - Cultural Events
  - Social Meetups
  - Study Groups
- 🔔 **Event Reminders** dan notifications
- 📸 **Photo Sharing** dari event
- ⭐ **Event Reviews** dan ratings
- 🔄 **Recurring Events** support

**Technical Implementation:**
- Events API service
- Calendar widget integration
- Geolocation services
- Push notifications system

### 💬 **Phase C+: Advanced Chat Features (PLANNED)**
**Target: Parallel dengan Phase D**

**Fitur tambahan untuk chat:**
- 👤 **Private Messaging** antar user
- 🛡️ **Chat Moderation Tools**
- 📱 **Push Notifications** untuk pesan baru (background)
- 🔍 **Message Search** dalam chat history
- 📋 **Message Forwarding** dan reply chains
- 🌐 **Translation Integration** untuk pesan
- 📊 **Chat Analytics** untuk admin

### 🎯 **Phase E: Advanced Community Features (PLANNED)**
**Target: 1-2 bulan ke depan**

**Fitur yang akan dikembangkan:**
- 🏆 **User Reputation System** - Badge dan point system
- 🤝 **Mentorship Matching** - Pair native speakers dengan learners
- 📚 **Study Groups** dan learning circles
- 📖 **Resource Sharing** - Books, videos, articles
- 🎮 **Gamification** - Achievement badges dan leaderboard
- 🔍 **Advanced Search** dengan multiple filters
- 🚫 **User Blocking** dan reporting system
- 🛡️ **Content Moderation** tools
- 🌐 **Multi-language Support** (ID/JP/EN)
- 🌙 **Dark Mode Theme**

**Technical Implementation:**
- Advanced recommendation algorithms
- Content filtering dan moderation
- Analytics dan user behavior tracking
- Internationalization (i18n)
- Advanced state management

## 🛠️ Tech Stack

### **Frontend (Mobile)**
- **Flutter 3.x** - Cross-platform mobile development
- **Dart** - Programming language
- **Provider** - State management
- **GoRouter** - Navigation dan routing
- **SharedPreferences** - Local storage
- **HTTP** - API communication
- **Socket.IO Client** - Real-time WebSocket communication
- **File Picker** - File dan image selection
- **Image Picker** - Camera dan gallery access
- **Emoji Picker** - Emoji reactions dan input
- **Local Notifications** - Push notification support

### **Backend (Planned)**
- **Node.js** dengan Express.js
- **Socket.io** untuk real-time chat
- **MongoDB** untuk database
- **JWT** untuk authentication
- **Cloudinary** untuk image storage

### **Architecture**
- **MVVM Pattern** dengan Provider
- **Repository Pattern** untuk data layer
- **Clean Architecture** principles
- **Responsive Design** untuk multiple screen sizes
- **Real-time State Management** untuk chat features

## 📂 Project Structure

```
lib/
├── models/           # Data models (User, Post, Event, Chat, Enhanced Chat)
│   ├── models.dart           # Core models (User, Post, Event)
│   ├── auth_models.dart      # Authentication models
│   └── chat_models.dart      # Chat models (ChatRoom, EnhancedChatMessage, etc.)
├── services/         # API services dan business logic
│   ├── auth_service.dart     # Authentication service
│   ├── posts_api_service.dart # Posts API integration
│   └── websocket_service.dart # Real-time WebSocket service
├── providers/        # State management dengan Provider
│   ├── user_provider.dart    # User authentication state
│   ├── community_provider.dart # Posts dan community state
│   └── chat_provider.dart    # Real-time chat state management
├── screens/          # UI screens (Home, Community, Events, Chat, Profile)
│   ├── home_screen.dart      # Dashboard dan overview
│   ├── community_screen.dart # Posts dan community features
│   ├── events_screen.dart    # Events management
│   ├── chat_screen.dart      # Real-time chat interface
│   ├── profile_screen.dart   # User profile
│   └── login_screen.dart     # Authentication
├── widgets/          # Reusable UI components
│   ├── post_card.dart        # Post display widget
│   ├── event_card.dart       # Event display widget
│   ├── chat_room_list.dart   # Chat rooms list
│   ├── chat_room_screen.dart # Individual chat room
│   ├── message_bubble.dart   # Chat message display
│   └── message_input.dart    # Chat message input dengan attachments
├── theme/           # App theme dan styling
│   └── app_theme.dart        # Material theme configuration
└── main.dart        # App entry point dengan providers
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device atau emulator

### Installation

1. **Clone repository**
```bash
git clone [repository-url]
cd japanese_community
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run aplikasi**
```bash
flutter run
```

### 🧪 Testing

**Login Test:**
- Gunakan demo credentials atau klik "Try Demo Login"
- Test session persistence dengan logout/login

**Posts Test:**
- Create, edit, delete posts
- Test like/unlike functionality
- Test search dan filtering
- Test infinite scroll

**Chat Test:**
- Navigate ke Chat tab untuk mengakses real-time chat
- Join different chat rooms (General, Beginner, Advanced, Culture, Events)
- Send text messages dan test real-time updates
- Test file/image sharing dengan attachment picker
- Try message reactions dengan long press pada message
- Test typing indicators saat mengetik
- Check online status indicators
- Test Japanese phrase suggestions
- Verify unread message counters
- Test connection status monitoring

## 📱 Screenshots

*Screenshots akan ditambahkan setelah UI finalization*

## 🤝 Contributing

Aplikasi ini dikembangkan untuk komunitas, kontribusi sangat welcome!

### Development Priorities:
1. **Phase C** - Real-time Chat (Next)
2. **Phase D** - Events Management
3. **Phase E** - Advanced Features

## 📄 License

Open source - bebas digunakan dan dikembangkan

## 📞 Contact & Support

Untuk pertanyaan, saran, atau kontribusi:
- 💬 Gunakan fitur chat dalam aplikasi (setelah Phase C selesai)
- 📝 Create issue di repository ini
- 📧 Contact developer

---

## 🎌 Untuk Komunitas Jepang Indonesia

Aplikasi ini dibuat khusus untuk memperkuat hubungan antara Jepang dan Indonesia melalui pembelajaran bahasa dan pertukaran budaya. Mari bersama-sama membangun komunitas yang supportive dan inclusive!

**頑張って！(Ganbatte!) - Let's do our best together!** 🇯🇵🇮🇩