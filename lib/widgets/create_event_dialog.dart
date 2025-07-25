import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/events_provider.dart';
import '../models/event_models.dart';

class CreateEventDialog extends StatefulWidget {
  final Function(EnhancedEvent)? onEventCreated;

  const CreateEventDialog({
    super.key,
    this.onEventCreated,
  });

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _addressController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '50');
  final _priceController = TextEditingController(text: '0');
  final _onlineMeetingUrlController = TextEditingController();

  String _selectedCategory = 'Social';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay? _endTime;
  bool _isOnline = false;
  bool _isAllDay = false;
  EventPrivacy _privacy = EventPrivacy.public;
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _categories = [
    'Social',
    'Language Exchange',
    'Cultural',
    'Educational',
    'Business',
    'Sports',
    'Food & Drink',
    'Arts & Crafts',
    'Music',
    'Technology',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _maxParticipantsController.dispose();
    _priceController.dispose();
    _onlineMeetingUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Create New Event',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Image
                      _buildImageSection(),
                      const SizedBox(height: 16),

                      // Basic Information
                      _buildBasicInfoSection(),
                      const SizedBox(height: 16),

                      // Date and Time
                      _buildDateTimeSection(),
                      const SizedBox(height: 16),

                      // Location
                      _buildLocationSection(),
                      const SizedBox(height: 16),

                      // Event Details
                      _buildEventDetailsSection(),
                      const SizedBox(height: 16),

                      // Privacy Settings
                      _buildPrivacySection(),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createEvent,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Event'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Image',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add event image',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Event Title *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter event title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Description *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter event description';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: Text('Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}'),
          trailing: const Icon(Icons.calendar_today),
          onTap: _selectDate,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: const Text('All Day Event'),
          value: _isAllDay,
          onChanged: (value) {
            setState(() {
              _isAllDay = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        if (!_isAllDay) ...[
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text('Start: ${_startTime.format(context)}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(true),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ListTile(
                  title: Text('End: ${_endTime?.format(context) ?? 'Not set'}'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(false),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('Online Event'),
          value: _isOnline,
          onChanged: (value) {
            setState(() {
              _isOnline = value!;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        if (_isOnline) ...[
          TextFormField(
            controller: _onlineMeetingUrlController,
            decoration: const InputDecoration(
              labelText: 'Meeting URL',
              border: OutlineInputBorder(),
              hintText: 'https://zoom.us/j/...',
            ),
          ),
        ] else ...[
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Venue Name *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (!_isOnline && (value == null || value.trim().isEmpty)) {
                return 'Please enter venue name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEventDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Participants',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final number = int.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (IDR)',
                  border: OutlineInputBorder(),
                  hintText: '0 for free',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  final number = double.tryParse(value);
                  if (number == null || number < 0) {
                    return 'Invalid price';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Privacy',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<EventPrivacy>(
          value: _privacy,
          decoration: const InputDecoration(
            labelText: 'Event Privacy',
            border: OutlineInputBorder(),
          ),
          items: EventPrivacy.values.map((privacy) {
            return DropdownMenuItem(
              value: privacy,
              child: Text(_getPrivacyText(privacy)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _privacy = value!;
            });
          },
        ),
      ],
    );
  }

  String _getPrivacyText(EventPrivacy privacy) {
    switch (privacy) {
      case EventPrivacy.public:
        return 'Public - Anyone can see and join';
      case EventPrivacy.private:
        return 'Private - Invite only';
      case EventPrivacy.friendsOnly:
        return 'Friends Only - Only friends can see and join';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : (_endTime ?? _startTime),
    );
    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<EventsProvider>();
      
      // Combine date and time
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _isAllDay ? 0 : _startTime.hour,
        _isAllDay ? 0 : _startTime.minute,
      );

      DateTime? endDateTime;
      if (!_isAllDay && _endTime != null) {
        endDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }

      final success = await provider.createEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startDate: startDateTime,
        endDate: endDateTime,
        startTime: _startTime,
        endTime: _endTime,
        location: _isOnline ? 'Online' : _locationController.text.trim(),
        address: _isOnline ? null : _addressController.text.trim(),
        maxParticipants: int.parse(_maxParticipantsController.text),
        category: _selectedCategory,
        isOnline: _isOnline,
        onlineMeetingUrl: _isOnline ? _onlineMeetingUrlController.text.trim() : null,
        price: double.parse(_priceController.text),
        privacy: _privacy,
        imageFile: _imageFile,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        if (widget.onEventCreated != null) {
          // Get the newly created event from provider
          final events = provider.events;
          if (events.isNotEmpty) {
            widget.onEventCreated!(events.first);
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: ${provider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}