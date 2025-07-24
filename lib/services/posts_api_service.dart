import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../services/auth_service.dart';

class PostsApiService {
  static const String _baseUrl = 'https://api.japanese-community.com'; // Replace with actual API
  static const bool _useMockApi = true; // Set to false for real API
  
  final AuthService _authService = AuthService();

  // Singleton pattern
  static final PostsApiService _instance = PostsApiService._internal();
  factory PostsApiService() => _instance;
  PostsApiService._internal();

  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all posts with pagination
  Future<ApiResponse<List<Post>>> getPosts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    if (_useMockApi) {
      return _mockGetPosts(page: page, limit: limit, category: category, search: search);
    }

    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (category != null) 'category': category,
        if (search != null) 'search': search,
      };

      final uri = Uri.parse('$_baseUrl/posts').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final posts = (data['data'] as List)
            .map((json) => Post.fromJson(json))
            .toList();

        return ApiResponse.success(
          data: posts,
          message: 'Posts retrieved successfully',
          pagination: PaginationInfo.fromJson(data['pagination']),
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
          message: error['message'] ?? 'Failed to fetch posts',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Create a new post
  Future<ApiResponse<Post>> createPost({
    required String content,
    List<String>? imageUrls,
    List<String>? tags,
    String category = 'Discussion',
  }) async {
    if (_useMockApi) {
      return _mockCreatePost(
        content: content,
        imageUrls: imageUrls,
        tags: tags,
        category: category,
      );
    }

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'content': content,
        'imageUrls': imageUrls ?? [],
        'tags': tags ?? [],
        'category': category,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/posts'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final post = Post.fromJson(data['data']);
        
        return ApiResponse.success(
          data: post,
          message: 'Post created successfully',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
          message: error['message'] ?? 'Failed to create post',
          statusCode: response.statusCode,
          errors: error['errors'],
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Update a post
  Future<ApiResponse<Post>> updatePost({
    required String postId,
    required String content,
    List<String>? imageUrls,
    List<String>? tags,
    String? category,
  }) async {
    if (_useMockApi) {
      return _mockUpdatePost(
        postId: postId,
        content: content,
        imageUrls: imageUrls,
        tags: tags,
        category: category,
      );
    }

    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'content': content,
        if (imageUrls != null) 'imageUrls': imageUrls,
        if (tags != null) 'tags': tags,
        if (category != null) 'category': category,
      });

      final response = await http.put(
        Uri.parse('$_baseUrl/posts/$postId'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final post = Post.fromJson(data['data']);
        
        return ApiResponse.success(
          data: post,
          message: 'Post updated successfully',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
          message: error['message'] ?? 'Failed to update post',
          statusCode: response.statusCode,
          errors: error['errors'],
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Delete a post
  Future<ApiResponse<void>> deletePost(String postId) async {
    if (_useMockApi) {
      return _mockDeletePost(postId);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/posts/$postId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: null,
          message: 'Post deleted successfully',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
          message: error['message'] ?? 'Failed to delete post',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Like/Unlike a post
  Future<ApiResponse<Post>> toggleLike(String postId) async {
    if (_useMockApi) {
      return _mockToggleLike(postId);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/posts/$postId/like'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final post = Post.fromJson(data['data']);
        
        return ApiResponse.success(
          data: post,
          message: data['message'] ?? 'Like toggled successfully',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
          message: error['message'] ?? 'Failed to toggle like',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Upload image
  Future<ApiResponse<String>> uploadImage(File imageFile) async {
    if (_useMockApi) {
      return _mockUploadImage(imageFile);
    }

    try {
      final headers = await _getHeaders();
      headers.remove('Content-Type'); // Let http handle multipart content type

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload/image'),
      );

      request.headers.addAll(headers);
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(
          data: data['imageUrl'],
          message: 'Image uploaded successfully',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse.error(
          message: error['message'] ?? 'Failed to upload image',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Mock implementations for demo
  Future<ApiResponse<List<Post>>> _mockGetPosts({
    int page = 1,
    int limit = 10,
    String? category,
    String? search,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final allPosts = _getMockPosts();
    var filteredPosts = allPosts;

    // Apply category filter
    if (category != null && category != 'All') {
      filteredPosts = filteredPosts.where((post) => post.category == category).toList();
    }

    // Apply search filter
    if (search != null && search.isNotEmpty) {
      filteredPosts = filteredPosts.where((post) =>
          post.content.toLowerCase().contains(search.toLowerCase()) ||
          post.authorName.toLowerCase().contains(search.toLowerCase()) ||
          post.tags.any((tag) => tag.toLowerCase().contains(search.toLowerCase()))
      ).toList();
    }

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = (startIndex + limit).clamp(0, filteredPosts.length);
    final paginatedPosts = filteredPosts.sublist(
      startIndex.clamp(0, filteredPosts.length),
      endIndex,
    );

    return ApiResponse.success(
      data: paginatedPosts,
      message: 'Posts retrieved successfully',
      pagination: PaginationInfo(
        currentPage: page,
        totalPages: (filteredPosts.length / limit).ceil(),
        totalItems: filteredPosts.length,
        itemsPerPage: limit,
        hasNextPage: endIndex < filteredPosts.length,
        hasPreviousPage: page > 1,
      ),
    );
  }

  Future<ApiResponse<Post>> _mockCreatePost({
    required String content,
    List<String>? imageUrls,
    List<String>? tags,
    String category = 'Discussion',
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: '1', // Current user ID
      authorName: 'Tanaka Hiroshi',
      authorImageUrl: 'https://i.pravatar.cc/150?img=1',
      content: content,
      imageUrls: imageUrls ?? [],
      createdAt: DateTime.now(),
      likes: 0,
      comments: 0,
      tags: tags ?? [],
      category: category,
    );

    return ApiResponse.success(
      data: newPost,
      message: 'Post created successfully',
    );
  }

  Future<ApiResponse<Post>> _mockUpdatePost({
    required String postId,
    required String content,
    List<String>? imageUrls,
    List<String>? tags,
    String? category,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Find existing post and update it
    final existingPost = _getMockPosts().firstWhere((post) => post.id == postId);
    
    final updatedPost = Post(
      id: existingPost.id,
      authorId: existingPost.authorId,
      authorName: existingPost.authorName,
      authorImageUrl: existingPost.authorImageUrl,
      content: content,
      imageUrls: imageUrls ?? existingPost.imageUrls,
      createdAt: existingPost.createdAt,
      likes: existingPost.likes,
      comments: existingPost.comments,
      tags: tags ?? existingPost.tags,
      category: category ?? existingPost.category,
    );

    return ApiResponse.success(
      data: updatedPost,
      message: 'Post updated successfully',
    );
  }

  Future<ApiResponse<void>> _mockDeletePost(String postId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return ApiResponse.success(
      data: null,
      message: 'Post deleted successfully',
    );
  }

  Future<ApiResponse<Post>> _mockToggleLike(String postId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final existingPost = _getMockPosts().firstWhere((post) => post.id == postId);
    
    final updatedPost = Post(
      id: existingPost.id,
      authorId: existingPost.authorId,
      authorName: existingPost.authorName,
      authorImageUrl: existingPost.authorImageUrl,
      content: existingPost.content,
      imageUrls: existingPost.imageUrls,
      createdAt: existingPost.createdAt,
      likes: existingPost.likes + 1, // Simplified - in real app, track user likes
      comments: existingPost.comments,
      tags: existingPost.tags,
      category: existingPost.category,
    );

    return ApiResponse.success(
      data: updatedPost,
      message: 'Post liked successfully',
    );
  }

  Future<ApiResponse<String>> _mockUploadImage(File imageFile) async {
    await Future.delayed(const Duration(seconds: 2));

    // Mock image URL
    final mockImageUrl = 'https://images.unsplash.com/photo-${DateTime.now().millisecondsSinceEpoch}?w=400';

    return ApiResponse.success(
      data: mockImageUrl,
      message: 'Image uploaded successfully',
    );
  }

  List<Post> _getMockPosts() {
    return [
      Post(
        id: '1',
        authorId: '2',
        authorName: 'Sakura Yamamoto',
        authorImageUrl: 'https://i.pravatar.cc/150?img=2',
        content: 'こんにちは！今日は渋谷で日本語交換会があります。参加したい人いませんか？ Hello! There\'s a Japanese language exchange in Shibuya today. Anyone want to join?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 15,
        comments: 8,
        tags: ['language-exchange', 'shibuya', 'japanese'],
        category: 'Event',
      ),
      Post(
        id: '2',
        authorId: '3',
        authorName: 'Mike Johnson',
        authorImageUrl: 'https://i.pravatar.cc/150?img=3',
        content: 'Just watched "Your Name" for the 10th time and I still cry every time! 😭 What\'s your favorite anime movie?',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 32,
        comments: 12,
        tags: ['anime', 'your-name', 'movies'],
        category: 'Discussion',
      ),
      Post(
        id: '3',
        authorId: '4',
        authorName: 'Kenji Nakamura',
        authorImageUrl: 'https://i.pravatar.cc/150?img=4',
        content: 'Sharing some photos from the cherry blossom festival last weekend! 🌸 The weather was perfect.',
        imageUrls: [
          'https://images.unsplash.com/photo-1522383225653-ed111181a951?w=400',
          'https://images.unsplash.com/photo-1554072675-66db59dba46f?w=400',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        likes: 45,
        comments: 18,
        tags: ['sakura', 'festival', 'spring'],
        category: 'Photos',
      ),
    ];
  }
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;
  final PaginationInfo? pagination;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
    this.errors,
    this.pagination,
  });

  factory ApiResponse.success({
    required T? data,
    required String message,
    PaginationInfo? pagination,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      pagination: pagination,
    );
  }

  factory ApiResponse.error({
    required String message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}

// Pagination information
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
      itemsPerPage: json['itemsPerPage'],
      hasNextPage: json['hasNextPage'],
      hasPreviousPage: json['hasPreviousPage'],
    );
  }
}