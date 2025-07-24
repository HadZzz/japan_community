import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../providers/community_provider.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key, 
    required this.post,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Pending overlay
          if (post.isPending)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: post.authorImageUrl != null
                          ? NetworkImage(post.authorImageUrl!)
                          : null,
                      child: post.authorImageUrl == null
                          ? Text(post.authorName[0])
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                post.authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (post.isOwned) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6, 
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'You',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            _formatTimeAgo(post.createdAt),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(post.category).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getCategoryColor(post.category).withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        post.category,
                        style: TextStyle(
                          color: _getCategoryColor(post.category),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // More options for owned posts
                    if (post.isOwned && !post.isPending)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              _showDeleteConfirmation(context);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Post Content
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),

                // Images (if any)
                if (post.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: post.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(post.imageUrls[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Tags
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: post.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 12),

                // Action Buttons
                Row(
                  children: [
                    _buildLikeButton(context),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      icon: Icons.comment_outlined,
                      label: '${post.comments}',
                      onTap: () {
                        // TODO: Navigate to comments
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comments feature coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _buildActionButton(
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: () {
                        // TODO: Implement share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share feature coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        return InkWell(
          onTap: post.isPending ? null : () {
            provider.toggleLike(post.id);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: post.isLiked ? AppColors.error : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likes}',
                  style: TextStyle(
                    color: post.isLiked ? AppColors.error : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: post.isLiked ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: post.isPending ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              size: 18, 
              color: post.isPending ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: post.isPending ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<CommunityProvider>().deletePost(post.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Discussion':
        return AppColors.categoryDiscussion;
      case 'Question':
        return AppColors.categoryQuestion;
      case 'Event':
        return AppColors.categoryEvent;
      case 'Photos':
        return AppColors.categoryPhotos;
      case 'News':
        return AppColors.categoryNews;
      default:
        return AppColors.onSurfaceVariant;
    }
  }
}