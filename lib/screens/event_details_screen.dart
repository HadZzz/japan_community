import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/event_models.dart';
import '../providers/events_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/event_review_card.dart';
import '../widgets/participant_list.dart';
import '../widgets/event_discussion.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  EnhancedEvent? _event;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadEventDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEventDetails() async {
    // In a real app, this would fetch from API
    // For now, we'll get from the events provider
    final eventsProvider = context.read<EventsProvider>();
    final event = eventsProvider.events
        .where((e) => e.id == widget.eventId)
        .firstOrNull;

    if (mounted) {
      setState(() {
        _event = event;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Event not found'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareEvent,
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag),
                          SizedBox(width: 8),
                          Text('Report Event'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _event!.title,
                  style: const TextStyle(
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                background: _buildEventImage(),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Event Info Summary
            _buildEventSummary(),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Details', icon: Icon(Icons.info)),
                Tab(text: 'Participants', icon: Icon(Icons.people)),
                Tab(text: 'Reviews', icon: Icon(Icons.star)),
                Tab(text: 'Discussion', icon: Icon(Icons.chat)),
              ],
            ),
            
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDetailsTab(),
                  _buildParticipantsTab(),
                  _buildReviewsTab(),
                  _buildDiscussionTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildEventImage() {
    if (_event!.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: _event!.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, size: 64),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
            Theme.of(context).primaryColor,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.event,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEventSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Time
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMM dd, yyyy • HH:mm').format(_event!.startDate),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Location
          Row(
            children: [
              Icon(
                _event!.isOnline ? Icons.computer : Icons.location_on,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _event!.location,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (!_event!.isOnline)
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _openInMaps,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Organizer
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: _event!.organizerImageUrl != null
                    ? CachedNetworkImageProvider(_event!.organizerImageUrl!)
                    : null,
                child: _event!.organizerImageUrl == null
                    ? Text(_event!.organizerName[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Organized by ${_event!.organizerName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Participants and Price
          Row(
            children: [
              Icon(Icons.people, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                '${_event!.currentParticipants}/${_event!.maxParticipants} participants',
                style: const TextStyle(fontSize: 14),
              ),
              const Spacer(),
              if (_event!.price > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_event!.currency} ${NumberFormat('#,###').format(_event!.price)}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'FREE',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          const Text(
            'About this event',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _event!.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Tags
          if (_event!.tags.isNotEmpty) ...[
            const Text(
              'Tags',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _event!.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Event Guidelines
          const Text(
            'Event Guidelines',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '• Please arrive on time\n'
            '• Bring a positive attitude\n'
            '• Respect other participants\n'
            '• Follow community guidelines\n'
            '• Have fun and learn!',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Contact Info
          if (_event!.isOnline && _event!.onlineMeetingUrl != null) ...[
            const Text(
              'Meeting Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Online Meeting Link:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _launchUrl(_event!.onlineMeetingUrl!),
                    child: Text(
                      _event!.onlineMeetingUrl!,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Note: Meeting link will be available 15 minutes before the event starts.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildParticipantsTab() {
    return ParticipantList(eventId: widget.eventId);
  }

  Widget _buildReviewsTab() {
    return EventReviewsList(eventId: widget.eventId);
  }

  Widget _buildDiscussionTab() {
    return EventDiscussion(eventId: widget.eventId);
  }

  Widget _buildBottomActions() {
    final userProvider = context.watch<UserProvider>();
    final isOrganizer = userProvider.currentUser?.id == _event!.organizerId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isOrganizer) ...[
            Expanded(
              child: Consumer<EventsProvider>(
                builder: (context, provider, child) {
                  final currentRSVP = _event!.currentUserRSVP;
                  
                  return ElevatedButton.icon(
                    onPressed: () => _handleRSVP(),
                    icon: Icon(_getRSVPIcon(currentRSVP)),
                    label: Text(_getRSVPText(currentRSVP)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getRSVPColor(currentRSVP),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _editEvent,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Event'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          const SizedBox(width: 12),
          IconButton(
            onPressed: _shareEvent,
            icon: const Icon(Icons.share),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey[200],
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRSVPIcon(RSVPStatus? status) {
    switch (status) {
      case RSVPStatus.going:
        return Icons.check_circle;
      case RSVPStatus.maybe:
        return Icons.help_outline;
      case RSVPStatus.notGoing:
        return Icons.cancel_outlined;
      default:
        return Icons.add_circle_outline;
    }
  }

  String _getRSVPText(RSVPStatus? status) {
    switch (status) {
      case RSVPStatus.going:
        return 'Going';
      case RSVPStatus.maybe:
        return 'Maybe';
      case RSVPStatus.notGoing:
        return 'Not Going';
      default:
        return 'Join Event';
    }
  }

  Color _getRSVPColor(RSVPStatus? status) {
    switch (status) {
      case RSVPStatus.going:
        return Colors.green;
      case RSVPStatus.maybe:
        return Colors.orange;
      case RSVPStatus.notGoing:
        return Colors.red;
      default:
        return Theme.of(context).primaryColor;
    }
  }

  void _handleRSVP() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'RSVP to this event',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Going'),
              subtitle: const Text('I will attend this event'),
              onTap: () {
                _updateRSVP(RSVPStatus.going);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.orange),
              title: const Text('Maybe'),
              subtitle: const Text('I might attend this event'),
              onTap: () {
                _updateRSVP(RSVPStatus.maybe);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined, color: Colors.red),
              title: const Text('Can\'t Go'),
              subtitle: const Text('I won\'t attend this event'),
              onTap: () {
                _updateRSVP(RSVPStatus.notGoing);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateRSVP(RSVPStatus status) async {
    final provider = context.read<EventsProvider>();
    final success = await provider.updateRSVP(widget.eventId, status);
    
    if (success && mounted) {
      setState(() {
        // Update local event data
        _loadEventDetails();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('RSVP updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareEvent() {
    Share.share(
      'Check out this event: ${_event!.title}\n\n'
      '📅 ${DateFormat('MMM dd, yyyy • HH:mm').format(_event!.startDate)}\n'
      '📍 ${_event!.location}\n\n'
      '${_event!.description}\n\n'
      'Join the Japanese Community app to RSVP!',
      subject: _event!.title,
    );
  }

  void _openInMaps() async {
    if (_event!.latitude != null && _event!.longitude != null) {
      final url = 'https://maps.google.com/?q=${_event!.latitude},${_event!.longitude}';
      _launchUrl(url);
    } else if (_event!.address != null) {
      final url = 'https://maps.google.com/?q=${Uri.encodeComponent(_event!.address!)}';
      _launchUrl(url);
    }
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri);
    }
  }

  void _editEvent() {
    // TODO: Navigate to edit event screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit event feature coming soon!')),
    );
  }
}