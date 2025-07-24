import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/posts_api_service.dart';

enum PostsLoadingState {
  initial,
  loading,
  loadingMore,
  loaded,
  error,
}

class CommunityProvider extends ChangeNotifier {
  final PostsApiService _postsApiService = PostsApiService();

  // Posts state
  List<Post> _posts = [];
  PostsLoadingState _postsLoadingState = PostsLoadingState.initial;
  String? _postsError;
  PaginationInfo? _postsPagination;
  int _currentPage = 1;
  String? _currentCategory;
  String? _currentSearch;

  // Events and messages (keeping mock for now)
  List<Event> _events = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Post> get posts => _posts;
  PostsLoadingState get postsLoadingState => _postsLoadingState;
  String? get postsError => _postsError;
  PaginationInfo? get postsPagination => _postsPagination;
  bool get hasMorePosts => _postsPagination?.hasNextPage ?? false;
  bool get isLoadingPosts => _postsLoadingState == PostsLoadingState.loading;
  bool get isLoadingMorePosts => _postsLoadingState == PostsLoadingState.loadingMore;

  List<Event> get events => _events;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CommunityProvider() {
    _loadMockEventsAndMessages();
    // Load posts asynchronously to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadPosts();
    });
  }

  // Posts API Integration
  Future<void> loadPosts({
    String? category,
    String? search,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _posts.clear();
    }

    _currentCategory = category;
    _currentSearch = search;
    _postsLoadingState = _posts.isEmpty 
        ? PostsLoadingState.loading 
        : PostsLoadingState.loadingMore;
    _postsError = null;
    notifyListeners();

    try {
      final response = await _postsApiService.getPosts(
        page: _currentPage,
        limit: 10,
        category: category,
        search: search,
      );

      if (response.success && response.data != null) {
        if (refresh || _currentPage == 1) {
          _posts = response.data!;
        } else {
          _posts.addAll(response.data!);
        }
        
        _postsPagination = response.pagination;
        _postsLoadingState = PostsLoadingState.loaded;
        _currentPage++;
      } else {
        _postsError = response.message;
        _postsLoadingState = PostsLoadingState.error;
      }
    } catch (e) {
      _postsError = 'Failed to load posts: ${e.toString()}';
      _postsLoadingState = PostsLoadingState.error;
    }

    notifyListeners();
  }

  Future<void> loadMorePosts() async {
    if (!hasMorePosts || isLoadingMorePosts) return;

    await loadPosts(
      category: _currentCategory,
      search: _currentSearch,
      refresh: false,
    );
  }

  Future<void> refreshPosts() async {
    await loadPosts(
      category: _currentCategory,
      search: _currentSearch,
      refresh: true,
    );
  }

  Future<void> searchPosts(String query) async {
    await loadPosts(
      category: _currentCategory,
      search: query.isEmpty ? null : query,
      refresh: true,
    );
  }

  Future<void> filterPostsByCategory(String? category) async {
    await loadPosts(
      category: category,
      search: _currentSearch,
      refresh: true,
    );
  }

  Future<bool> createPost({
    required String content,
    List<String>? imageUrls,
    List<String>? tags,
    String category = 'Discussion',
  }) async {
    // Optimistic update - add pending post immediately
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final pendingPost = Post(
      id: tempId,
      authorId: '1', // Current user ID
      authorName: 'You', // Current user name
      content: content,
      imageUrls: imageUrls ?? [],
      createdAt: DateTime.now(),
      tags: tags ?? [],
      category: category,
      isPending: true,
    );

    _posts.insert(0, pendingPost);
    notifyListeners();

    try {
      final response = await _postsApiService.createPost(
        content: content,
        imageUrls: imageUrls,
        tags: tags,
        category: category,
      );

      // Remove pending post
      _posts.removeWhere((post) => post.id == tempId);

      if (response.success && response.data != null) {
        // Add real post at the beginning
        _posts.insert(0, response.data!);
        notifyListeners();
        return true;
      } else {
        _postsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Remove pending post on error
      _posts.removeWhere((post) => post.id == tempId);
      _postsError = 'Failed to create post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePost({
    required String postId,
    required String content,
    List<String>? imageUrls,
    List<String>? tags,
    String? category,
  }) async {
    try {
      final response = await _postsApiService.updatePost(
        postId: postId,
        content: content,
        imageUrls: imageUrls,
        tags: tags,
        category: category,
      );

      if (response.success && response.data != null) {
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          _posts[postIndex] = response.data!;
          notifyListeners();
        }
        return true;
      } else {
        _postsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _postsError = 'Failed to update post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    // Optimistic update - hide post immediately
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return false;

    final originalPost = _posts[postIndex];
    _posts.removeAt(postIndex);
    notifyListeners();

    try {
      final response = await _postsApiService.deletePost(postId);

      if (response.success) {
        return true;
      } else {
        // Restore post on error
        _posts.insert(postIndex, originalPost);
        _postsError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Restore post on error
      _posts.insert(postIndex, originalPost);
      _postsError = 'Failed to delete post: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleLike(String postId) async {
    // Optimistic update
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    final originalPost = _posts[postIndex];
    final optimisticPost = originalPost.copyWith(
      isLiked: !originalPost.isLiked,
      likes: originalPost.isLiked 
          ? originalPost.likes - 1 
          : originalPost.likes + 1,
    );

    _posts[postIndex] = optimisticPost;
    notifyListeners();

    try {
      final response = await _postsApiService.toggleLike(postId);

      if (response.success && response.data != null) {
        _posts[postIndex] = response.data!;
        notifyListeners();
      } else {
        // Revert on error
        _posts[postIndex] = originalPost;
        _postsError = response.message;
        notifyListeners();
      }
    } catch (e) {
      // Revert on error
      _posts[postIndex] = originalPost;
      _postsError = 'Failed to toggle like: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearPostsError() {
    _postsError = null;
    notifyListeners();
  }

  // Events and Messages (keeping existing mock implementation)
  void _loadMockEventsAndMessages() {
    // Mock events data
    _events = [
      Event(
        id: '1',
        title: 'Tokyo Language Exchange Meetup',
        description: 'Join us for a fun language exchange session in Shibuya! Perfect for practicing Japanese and meeting new friends.',
        imageUrl: 'https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=400&h=300&fit=crop',
        startDate: DateTime.now().add(const Duration(days: 3)),
        location: 'Shibuya, Tokyo',
        organizerId: '2',
        organizerName: 'Sakura Yamamoto',
        maxParticipants: 30,
        currentParticipants: 15,
        participants: ['1', '3', '4'],
        category: 'Language Exchange',
      ),
      Event(
        id: '2',
        title: 'Anime Movie Night',
        description: 'Let\'s watch Studio Ghibli movies together! Snacks and drinks provided.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
        startDate: DateTime.now().add(const Duration(days: 7)),
        location: 'Harajuku Community Center',
        organizerId: '3',
        organizerName: 'Mike Johnson',
        maxParticipants: 20,
        currentParticipants: 8,
        participants: ['1', '2'],
        category: 'Cultural',
      ),
      Event(
        id: '3',
        title: 'Online Japanese Cooking Class',
        description: 'Learn to make authentic ramen from scratch! All ingredients list will be provided beforehand.',
        imageUrl: 'https://images.unsplash.com/photo-1617196034796-73dfa7b1fd56?w=400&h=300&fit=crop',
        startDate: DateTime.now().add(const Duration(days: 10)),
        location: 'Online (Zoom)',
        organizerId: '4',
        organizerName: 'Kenji Nakamura',
        maxParticipants: 15,
        currentParticipants: 12,
        participants: ['1', '2', '3'],
        category: 'Educational',
        isOnline: true,
      ),
    ];

    // Mock chat messages
    _messages = [
      ChatMessage(
        id: '1',
        senderId: '2',
        senderName: 'Sakura',
        senderImageUrl: 'https://i.pravatar.cc/150?img=2',
        content: 'みなさん、こんにちは！',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      ChatMessage(
        id: '2',
        senderId: '3',
        senderName: 'Mike',
        senderImageUrl: 'https://i.pravatar.cc/150?img=3',
        content: 'Hello everyone! こんにちは！',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      ChatMessage(
        id: '3',
        senderId: '4',
        senderName: 'Kenji',
        senderImageUrl: 'https://i.pravatar.cc/150?img=4',
        content: 'Has anyone been to the new ramen shop in Shibuya?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ];
  }

  Future<void> joinEvent(String eventId) async {
    try {
      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        final event = _events[eventIndex];
        if (!event.participants.contains('1') && 
            event.currentParticipants < event.maxParticipants) {
          
          final updatedEvent = Event(
            id: event.id,
            title: event.title,
            description: event.description,
            imageUrl: event.imageUrl,
            startDate: event.startDate,
            endDate: event.endDate,
            location: event.location,
            organizerId: event.organizerId,
            organizerName: event.organizerName,
            maxParticipants: event.maxParticipants,
            currentParticipants: event.currentParticipants + 1,
            participants: [...event.participants, '1'],
            category: event.category,
            isOnline: event.isOnline,
          );
          
          _events[eventIndex] = updatedEvent;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: '1',
        senderName: 'Tanaka Hiroshi',
        senderImageUrl: 'https://i.pravatar.cc/150?img=1',
        content: content,
        timestamp: DateTime.now(),
      );
      
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}