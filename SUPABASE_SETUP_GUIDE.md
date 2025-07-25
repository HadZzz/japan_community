# 🚀 STEP-BY-STEP SUPABASE SETUP GUIDE

## 📋 **LANGKAH 1: BUAT AKUN SUPABASE (5 menit)**

1. **Buka browser** dan pergi ke: https://supabase.com
2. **Klik "Start your project"** 
3. **Sign up dengan GitHub** (recommended) atau email
4. **Verifikasi email** jika menggunakan email signup
5. **Login ke dashboard** Supabase

## 🏗️ **LANGKAH 2: BUAT PROJECT BARU (5 menit)**

1. **Klik "New Project"** di dashboard
2. **Isi data project:**
   - **Name**: `japanese-community`
   - **Database Password**: Buat password yang kuat (simpan baik-baik!)
   - **Region**: Singapore (terdekat dengan Indonesia)
   - **Pricing Plan**: Free (sudah terpilih)
3. **Klik "Create new project"**
4. **Tunggu ~2 menit** sampai project ready

## 🗄️ **LANGKAH 3: SETUP DATABASE SCHEMA (10 menit)**

1. **Di dashboard project**, klik **"SQL Editor"** di sidebar kiri
2. **Klik "New Query"**
3. **Copy-paste SQL schema berikut:**

```sql
-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  profile_image_url TEXT,
  bio TEXT,
  location TEXT,
  interests TEXT[] DEFAULT '{}',
  japanese_level TEXT DEFAULT 'Beginner',
  joined_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Posts table
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  author_id UUID REFERENCES users(id) ON DELETE CASCADE,
  author_name TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'General',
  image_url TEXT,
  likes INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Post likes table
CREATE TABLE post_likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- Events table
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  organizer_id UUID REFERENCES users(id) ON DELETE CASCADE,
  organizer_name TEXT NOT NULL,
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
  category TEXT NOT NULL DEFAULT 'Social',
  tags TEXT[] DEFAULT '{}',
  is_online BOOLEAN DEFAULT FALSE,
  online_meeting_url TEXT,
  price DECIMAL(10,2) DEFAULT 0.00,
  currency TEXT DEFAULT 'IDR',
  status TEXT DEFAULT 'published',
  privacy TEXT DEFAULT 'public',
  average_rating DECIMAL(3,2) DEFAULT 0.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Event RSVPs table
CREATE TABLE event_rsvps (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('going', 'maybe', 'not_going', 'waitlisted')),
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- Event reviews table
CREATE TABLE event_reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_image_url TEXT,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT NOT NULL,
  image_urls TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Chat rooms table
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

-- Chat messages table
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
  sender_name TEXT NOT NULL,
  sender_image_url TEXT,
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

-- Message reactions table
CREATE TABLE message_reactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  message_id UUID REFERENCES chat_messages(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  emoji TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(message_id, user_id, emoji)
);

-- Insert default chat rooms
INSERT INTO chat_rooms (id, name, description, category) VALUES
  ('00000000-0000-0000-0000-000000000001', 'General Discussion', 'Main chat room for general conversations', 'General'),
  ('00000000-0000-0000-0000-000000000002', 'Beginner Japanese', 'For those starting to learn Japanese', 'Learning'),
  ('00000000-0000-0000-0000-000000000003', 'Advanced Japanese', 'For advanced Japanese learners and native speakers', 'Learning'),
  ('00000000-0000-0000-0000-000000000004', 'Japanese Culture', 'Discuss Japanese culture, traditions, and customs', 'Culture'),
  ('00000000-0000-0000-0000-000000000005', 'Event Planning', 'Plan and organize community events', 'Events');

-- Create functions to update updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_event_rsvps_updated_at BEFORE UPDATE ON event_rsvps FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_reactions ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Users can view all profiles" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- Create policies for posts table
CREATE POLICY "Anyone can view posts" ON posts FOR SELECT USING (true);
CREATE POLICY "Users can create posts" ON posts FOR INSERT WITH CHECK (auth.uid() = author_id::uuid);
CREATE POLICY "Users can update own posts" ON posts FOR UPDATE USING (auth.uid() = author_id::uuid);
CREATE POLICY "Users can delete own posts" ON posts FOR DELETE USING (auth.uid() = author_id::uuid);

-- Create policies for post_likes table
CREATE POLICY "Anyone can view post likes" ON post_likes FOR SELECT USING (true);
CREATE POLICY "Users can manage own likes" ON post_likes FOR ALL USING (auth.uid() = user_id);

-- Create policies for events table
CREATE POLICY "Anyone can view published events" ON events FOR SELECT USING (status = 'published' OR auth.uid() = organizer_id::uuid);
CREATE POLICY "Users can create events" ON events FOR INSERT WITH CHECK (auth.uid() = organizer_id::uuid);
CREATE POLICY "Users can update own events" ON events FOR UPDATE USING (auth.uid() = organizer_id::uuid);
CREATE POLICY "Users can delete own events" ON events FOR DELETE USING (auth.uid() = organizer_id::uuid);

-- Create policies for event_rsvps table
CREATE POLICY "Anyone can view RSVPs" ON event_rsvps FOR SELECT USING (true);
CREATE POLICY "Users can manage own RSVPs" ON event_rsvps FOR ALL USING (auth.uid() = user_id);

-- Create policies for event_reviews table
CREATE POLICY "Anyone can view reviews" ON event_reviews FOR SELECT USING (true);
CREATE POLICY "Users can create reviews" ON event_reviews FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reviews" ON event_reviews FOR UPDATE USING (auth.uid() = user_id);

-- Create policies for chat_messages table
CREATE POLICY "Anyone can view chat messages" ON chat_messages FOR SELECT USING (true);
CREATE POLICY "Users can create messages" ON chat_messages FOR INSERT WITH CHECK (auth.uid() = sender_id::uuid);
CREATE POLICY "Users can update own messages" ON chat_messages FOR UPDATE USING (auth.uid() = sender_id::uuid);

-- Create policies for message_reactions table
CREATE POLICY "Anyone can view reactions" ON message_reactions FOR SELECT USING (true);
CREATE POLICY "Users can manage own reactions" ON message_reactions FOR ALL USING (auth.uid() = user_id);

-- Chat rooms are public, no RLS needed
```

4. **Klik "Run"** untuk execute schema
5. **Pastikan semua berhasil** (akan ada checkmark hijau)

## 🔑 **LANGKAH 4: DAPATKAN API KEYS (2 menit)**

1. **Klik "Settings"** di sidebar kiri
2. **Klik "API"**
3. **Copy dan simpan:**
   - **Project URL** (contoh: https://xxxxx.supabase.co)
   - **anon public key** (key yang panjang)

## ⚙️ **LANGKAH 5: KONFIGURASI FLUTTER APP**

Sekarang saya akan buat konfigurasi untuk connect Flutter app ke Supabase:

**Apakah sudah selesai setup Supabase project dan dapat API keys?** 
Jika ya, berikan:
1. **Project URL** 
2. **Anon Key**

Atau jika belum, saya bisa lanjutkan dengan demo configuration dulu untuk testing.

## 💰 **KONFIRMASI BIAYA: 100% GRATIS!**

✅ **Tidak ada biaya sama sekali untuk:**
- Setup account
- Database usage (sampai 500MB)
- Real-time subscriptions
- Authentication
- File storage (sampai 100MB)
- API calls

✅ **Batas free tier yang sangat generous:**
- **50,000 monthly active users** (lebih dari cukup!)
- **2GB bandwidth/month** (cukup untuk app yang aktif)
- **Unlimited** database queries
- **Unlimited** real-time connections

**Mau lanjut setup atau ada pertanyaan dulu?**