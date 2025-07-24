import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../widgets/post_card.dart';
import '../models/models.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String? _selectedCategory;
  final List<String> _categories = [
    'All',
    'Discussion',
    'Question',
    'Event',
    'Photos',
    'News'
  ];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load more posts when near bottom
      context.read<CommunityProvider>().loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search posts...',
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  context.read<CommunityProvider>().searchPosts(query);
                },
              )
            : const Text('Community'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<CommunityProvider>().searchPosts('');
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == (_selectedCategory ?? 'All');
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category == 'All' ? null : category;
                      });
                      context.read<CommunityProvider>()
                          .filterPostsByCategory(_selectedCategory);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),

          // Posts List
          Expanded(
            child: Consumer<CommunityProvider>(
              builder: (context, provider, child) {
                // Show error message if there's an error
                if (provider.postsError != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            provider.postsError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.clearPostsError();
                            provider.refreshPosts();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                // Show loading indicator for initial load
                if (provider.isLoadingPosts && provider.posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show empty state
                if (provider.posts.isEmpty && !provider.isLoadingPosts) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Be the first to start a conversation!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.refreshPosts,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: provider.posts.length + 
                        (provider.isLoadingMorePosts ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at bottom
                      if (index == provider.posts.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }

                      return PostCard(
                        post: provider.posts[index],
                        onEdit: () => _showEditPostDialog(
                          context, 
                          provider.posts[index],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    final contentController = TextEditingController();
    final tagsController = TextEditingController();
    String selectedCategory = 'Discussion';
    final categories = ['Discussion', 'Question', 'Event', 'Photos', 'News'];
    bool isCreating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'What\'s on your mind?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'japanese, language-exchange, tokyo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isCreating ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isCreating ? null : () async {
                if (contentController.text.trim().isNotEmpty) {
                  setState(() {
                    isCreating = true;
                  });

                  final tags = tagsController.text
                      .split(',')
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .toList();

                  final success = await context.read<CommunityProvider>()
                      .createPost(
                        content: contentController.text.trim(),
                        tags: tags,
                        category: selectedCategory,
                      );

                  if (mounted) {
                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post created successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      setState(() {
                        isCreating = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to create post. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: isCreating 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPostDialog(BuildContext context, Post post) {
    final contentController = TextEditingController(text: post.content);
    final tagsController = TextEditingController(text: post.tags.join(', '));
    String selectedCategory = post.category;
    final categories = ['Discussion', 'Question', 'Event', 'Photos', 'News'];
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Post'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'What\'s on your mind?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    hintText: 'japanese, language-exchange, tokyo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUpdating ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUpdating ? null : () async {
                if (contentController.text.trim().isNotEmpty) {
                  setState(() {
                    isUpdating = true;
                  });

                  final tags = tagsController.text
                      .split(',')
                      .map((tag) => tag.trim())
                      .where((tag) => tag.isNotEmpty)
                      .toList();

                  final success = await context.read<CommunityProvider>()
                      .updatePost(
                        postId: post.id,
                        content: contentController.text.trim(),
                        tags: tags,
                        category: selectedCategory,
                      );

                  if (mounted) {
                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Post updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      setState(() {
                        isUpdating = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update post. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: isUpdating 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}