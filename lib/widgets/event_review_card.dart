import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/event_models.dart';
import '../providers/user_provider.dart';

class EventReviewsList extends StatefulWidget {
  final String eventId;

  const EventReviewsList({
    super.key,
    required this.eventId,
  });

  @override
  State<EventReviewsList> createState() => _EventReviewsListState();
}

class _EventReviewsListState extends State<EventReviewsList> {
  List<EventReview> _reviews = [];
  bool _isLoading = true;
  double _averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    // In a real app, this would fetch from API
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _reviews = _generateMockReviews();
        _averageRating = _calculateAverageRating();
        _isLoading = false;
      });
    }
  }

  List<EventReview> _generateMockReviews() {
    return [
      EventReview(
        id: '1',
        eventId: widget.eventId,
        userId: 'user1',
        userName: 'Yuki Tanaka',
        userImageUrl: null,
        rating: 5,
        comment: 'Amazing event! I learned so much about Japanese culture and made great friends. The organizer was very knowledgeable and friendly.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        imageUrls: [],
      ),
      EventReview(
        id: '2',
        eventId: widget.eventId,
        userId: 'user2',
        userName: 'Sarah Johnson',
        userImageUrl: null,
        rating: 4,
        comment: 'Great language exchange session. Would love to see more beginner-friendly activities in the future.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        imageUrls: [],
      ),
      EventReview(
        id: '3',
        eventId: widget.eventId,
        userId: 'user3',
        userName: 'Hiroshi Sato',
        userImageUrl: null,
        rating: 5,
        comment: 'Perfect organization and timing. The venue was great and everyone was very welcoming.',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        imageUrls: [],
      ),
    ];
  }

  double _calculateAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.map((r) => r.rating).reduce((a, b) => a + b);
    return total / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Rating Summary
        _buildRatingSummary(),
        
        // Reviews List
        Expanded(
          child: _reviews.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    return EventReviewCard(
                      review: _reviews[index],
                      onLike: () => _likeReview(_reviews[index].id),
                      onReport: () => _reportReview(_reviews[index].id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Average Rating
              Column(
                children: [
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStarRating(_averageRating),
                  const SizedBox(height: 4),
                  Text(
                    '${_reviews.length} reviews',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              
              // Rating Breakdown
              Expanded(
                child: Column(
                  children: [
                    for (int i = 5; i >= 1; i--)
                      _buildRatingBar(i),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Add Review Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddReviewDialog,
              icon: const Icon(Icons.rate_review),
              label: const Text('Write a Review'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget _buildRatingBar(int stars) {
    final count = _reviews.where((r) => r.rating == stars).length;
    final percentage = _reviews.isEmpty ? 0.0 : count / _reviews.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars', style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Icon(Icons.star, color: Colors.amber, size: 12),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to review this event!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddReviewDialog,
            icon: const Icon(Icons.rate_review),
            label: const Text('Write a Review'),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        eventId: widget.eventId,
        onReviewAdded: (review) {
          setState(() {
            _reviews.insert(0, review);
            _averageRating = _calculateAverageRating();
          });
        },
      ),
    );
  }

  void _likeReview(String reviewId) {
    // TODO: Implement review like functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review liked!')),
    );
  }

  void _reportReview(String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Review'),
        content: const Text('Are you sure you want to report this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review reported')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}

class EventReviewCard extends StatelessWidget {
  final EventReview review;
  final VoidCallback onLike;
  final VoidCallback onReport;

  const EventReviewCard({
    super.key,
    required this.review,
    required this.onLike,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info and Rating
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: review.userImageUrl != null
                      ? CachedNetworkImageProvider(review.userImageUrl!)
                      : null,
                  child: review.userImageUrl == null
                      ? Text(review.userName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          _buildStarRating(review.rating),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(review.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, size: 16),
                          SizedBox(width: 8),
                          Text('Report'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'report') {
                      onReport();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Review Comment
            Text(
              review.comment,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),

            // Review Images
            if (review.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: review.imageUrls[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                TextButton.icon(
                  onPressed: onLike,
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: const Text('Helpful'),
                ),
                const Spacer(),
                Text(
                  _formatTimeAgo(review.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 14,
        );
      }),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inMinutes} minutes ago';
    }
  }
}

class AddReviewDialog extends StatefulWidget {
  final String eventId;
  final Function(EventReview) onReviewAdded;

  const AddReviewDialog({
    super.key,
    required this.eventId,
    required this.onReviewAdded,
  });

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Write a Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Rating
            const Text('Rating'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Comment
            const Text('Comment'),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Share your experience...',
              ),
            ),
            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final userProvider = context.read<UserProvider>();
    final review = EventReview(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: widget.eventId,
      userId: userProvider.currentUser?.id ?? 'unknown',
      userName: userProvider.currentUser?.name ?? 'Anonymous',
      userImageUrl: userProvider.currentUser?.profileImageUrl,
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
      imageUrls: [],
    );

    widget.onReviewAdded(review);
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added successfully!')),
      );
    }
  }
}