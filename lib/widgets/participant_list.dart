import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/event_models.dart';

class ParticipantList extends StatefulWidget {
  final String eventId;

  const ParticipantList({
    super.key,
    required this.eventId,
  });

  @override
  State<ParticipantList> createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {
  List<EventParticipant> _participants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    // In a real app, this would fetch from API
    // For now, we'll simulate participant data
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _participants = _generateMockParticipants();
        _isLoading = false;
      });
    }
  }

  List<EventParticipant> _generateMockParticipants() {
    return [
      EventParticipant(
        id: '1',
        userId: 'user1',
        userName: 'Yuki Tanaka',
        userImageUrl: null,
        rsvpStatus: RSVPStatus.going,
        joinedAt: DateTime.now().subtract(const Duration(days: 2)),
        japaneseLevel: 'Intermediate',
      ),
      EventParticipant(
        id: '2',
        userId: 'user2',
        userName: 'Sarah Johnson',
        userImageUrl: null,
        rsvpStatus: RSVPStatus.going,
        joinedAt: DateTime.now().subtract(const Duration(days: 1)),
        japaneseLevel: 'Beginner',
      ),
      EventParticipant(
        id: '3',
        userId: 'user3',
        userName: 'Hiroshi Sato',
        userImageUrl: null,
        rsvpStatus: RSVPStatus.maybe,
        joinedAt: DateTime.now().subtract(const Duration(hours: 12)),
        japaneseLevel: 'Native',
      ),
      EventParticipant(
        id: '4',
        userId: 'user4',
        userName: 'Emma Wilson',
        userImageUrl: null,
        rsvpStatus: RSVPStatus.going,
        joinedAt: DateTime.now().subtract(const Duration(hours: 6)),
        japaneseLevel: 'Advanced',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_participants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No participants yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Be the first to join this event!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Group participants by RSVP status
    final going = _participants.where((p) => p.rsvpStatus == RSVPStatus.going).toList();
    final maybe = _participants.where((p) => p.rsvpStatus == RSVPStatus.maybe).toList();
    final waitlisted = _participants.where((p) => p.rsvpStatus == RSVPStatus.waitlisted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          _buildParticipantSummary(),
          const SizedBox(height: 24),

          // Going
          if (going.isNotEmpty) ...[
            _buildSectionHeader('Going (${going.length})', Colors.green),
            const SizedBox(height: 8),
            ...going.map((participant) => _buildParticipantTile(participant)),
            const SizedBox(height: 16),
          ],

          // Maybe
          if (maybe.isNotEmpty) ...[
            _buildSectionHeader('Maybe (${maybe.length})', Colors.orange),
            const SizedBox(height: 8),
            ...maybe.map((participant) => _buildParticipantTile(participant)),
            const SizedBox(height: 16),
          ],

          // Waitlisted
          if (waitlisted.isNotEmpty) ...[
            _buildSectionHeader('Waitlisted (${waitlisted.length})', Colors.purple),
            const SizedBox(height: 8),
            ...waitlisted.map((participant) => _buildParticipantTile(participant)),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantSummary() {
    final totalGoing = _participants.where((p) => p.rsvpStatus == RSVPStatus.going).length;
    final totalMaybe = _participants.where((p) => p.rsvpStatus == RSVPStatus.maybe).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Going', totalGoing.toString(), Colors.green),
              _buildSummaryItem('Maybe', totalMaybe.toString(), Colors.orange),
              _buildSummaryItem('Total', _participants.length.toString(), Colors.blue),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Japanese Level Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildJapaneseLevelChart(),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildJapaneseLevelChart() {
    final levelCounts = <String, int>{};
    for (final participant in _participants) {
      levelCounts[participant.japaneseLevel] = 
          (levelCounts[participant.japaneseLevel] ?? 0) + 1;
    }

    return Wrap(
      spacing: 8,
      children: levelCounts.entries.map((entry) {
        return Chip(
          label: Text('${entry.key}: ${entry.value}'),
          backgroundColor: _getLevelColor(entry.key),
          labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        );
      }).toList(),
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      case 'Native':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantTile(EventParticipant participant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: participant.userImageUrl != null
              ? CachedNetworkImageProvider(participant.userImageUrl!)
              : null,
          child: participant.userImageUrl == null
              ? Text(participant.userName[0].toUpperCase())
              : null,
        ),
        title: Text(participant.userName),
        subtitle: Text('Japanese Level: ${participant.japaneseLevel}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildRSVPBadge(participant.rsvpStatus),
            const SizedBox(height: 4),
            Text(
              _formatJoinTime(participant.joinedAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _showParticipantProfile(participant),
      ),
    );
  }

  Widget _buildRSVPBadge(RSVPStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case RSVPStatus.going:
        color = Colors.green;
        text = 'Going';
        break;
      case RSVPStatus.maybe:
        color = Colors.orange;
        text = 'Maybe';
        break;
      case RSVPStatus.waitlisted:
        color = Colors.purple;
        text = 'Waitlisted';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatJoinTime(DateTime joinedAt) {
    final now = DateTime.now();
    final difference = now.difference(joinedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _showParticipantProfile(EventParticipant participant) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: participant.userImageUrl != null
                  ? CachedNetworkImageProvider(participant.userImageUrl!)
                  : null,
              child: participant.userImageUrl == null
                  ? Text(
                      participant.userName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              participant.userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Japanese Level: ${participant.japaneseLevel}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            _buildRSVPBadge(participant.rsvpStatus),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Navigate to user profile
                    },
                    icon: const Icon(Icons.person),
                    label: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Start chat with user
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for event participants
class EventParticipant {
  final String id;
  final String userId;
  final String userName;
  final String? userImageUrl;
  final RSVPStatus rsvpStatus;
  final DateTime joinedAt;
  final String japaneseLevel;

  EventParticipant({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rsvpStatus,
    required this.joinedAt,
    required this.japaneseLevel,
  });
}