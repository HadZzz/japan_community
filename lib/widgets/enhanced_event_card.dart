import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event_models.dart';

class EnhancedEventCard extends StatelessWidget {
  final EnhancedEvent event;
  final Function(RSVPStatus) onRSVP;
  final VoidCallback? onTap;

  const EnhancedEventCard({
    super.key,
    required this.event,
    required this.onRSVP,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            if (event.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  event.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 64,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(event.category),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    event.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Date and Time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(event.startDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(
                        event.isOnline ? Icons.computer : Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Participants and Price
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${event.currentParticipants}/${event.maxParticipants}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (event.price > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${event.currency} ${NumberFormat('#,###').format(event.price)}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'FREE',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // RSVP Buttons
                  Row(
                    children: [
                      // Current RSVP Status
                      if (event.currentUserRSVP != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getRSVPColor(event.currentUserRSVP!),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _getRSVPText(event.currentUserRSVP!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      const Spacer(),

                      // RSVP Action Buttons
                      if (event.status == EventStatus.published &&
                          event.startDate.isAfter(DateTime.now()))
                        Row(
                          children: [
                            _buildRSVPButton(
                              context,
                              'Going',
                              Icons.check_circle,
                              Colors.green,
                              () => onRSVP(RSVPStatus.going),
                              event.currentUserRSVP == RSVPStatus.going,
                            ),
                            const SizedBox(width: 8),
                            _buildRSVPButton(
                              context,
                              'Maybe',
                              Icons.help_outline,
                              Colors.orange,
                              () => onRSVP(RSVPStatus.maybe),
                              event.currentUserRSVP == RSVPStatus.maybe,
                            ),
                            const SizedBox(width: 8),
                            _buildRSVPButton(
                              context,
                              'No',
                              Icons.cancel_outlined,
                              Colors.red,
                              () => onRSVP(RSVPStatus.notGoing),
                              event.currentUserRSVP == RSVPStatus.notGoing,
                            ),
                          ],
                        ),
                    ],
                  ),

                  // Event Status
                  if (event.status != EventStatus.published)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(event.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(event.status),
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getStatusText(event.status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRSVPButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    bool isSelected,
  ) {
    return SizedBox(
      height: 32,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : color,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : color,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? color : Colors.white,
          foregroundColor: isSelected ? Colors.white : color,
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          minimumSize: Size.zero,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Language Exchange':
        return Colors.blue;
      case 'Cultural':
        return Colors.purple;
      case 'Social':
        return Colors.green;
      case 'Educational':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getRSVPColor(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.going:
        return Colors.green;
      case RSVPStatus.maybe:
        return Colors.orange;
      case RSVPStatus.notGoing:
        return Colors.red;
      case RSVPStatus.waitlisted:
        return Colors.purple;
      case RSVPStatus.pending:
        return Colors.grey;
    }
  }

  String _getRSVPText(RSVPStatus status) {
    switch (status) {
      case RSVPStatus.going:
        return 'Going';
      case RSVPStatus.maybe:
        return 'Maybe';
      case RSVPStatus.notGoing:
        return 'Not Going';
      case RSVPStatus.waitlisted:
        return 'Waitlisted';
      case RSVPStatus.pending:
        return 'Pending';
    }
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return Colors.grey;
      case EventStatus.published:
        return Colors.green;
      case EventStatus.ongoing:
        return Colors.blue;
      case EventStatus.cancelled:
        return Colors.red;
      case EventStatus.completed:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return Icons.edit;
      case EventStatus.published:
        return Icons.public;
      case EventStatus.ongoing:
        return Icons.play_circle;
      case EventStatus.cancelled:
        return Icons.cancel;
      case EventStatus.completed:
        return Icons.check_circle;
    }
  }

  String _getStatusText(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.published:
        return 'Published';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.cancelled:
        return 'Cancelled';
      case EventStatus.completed:
        return 'Completed';
    }
  }
}