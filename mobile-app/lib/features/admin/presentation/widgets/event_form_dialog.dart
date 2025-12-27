import 'package:flutter/material.dart';
import '../../../events/models/event_models.dart';

class EventFormDialog extends StatefulWidget {
  final Event? event;
  final Function(Event) onSubmit;

  const EventFormDialog({
    super.key,
    this.event,
    required this.onSubmit,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _organizerController = TextEditingController();
  final _contactController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedBlock = 'VIKASNAGAR';
  String _selectedEventType = 'MEDICAL_CAMP';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _timeController.text = widget.event!.eventTime ?? '';
      _organizerController.text = widget.event!.organizerName ?? '';
      _contactController.text = widget.event!.organizerContact ?? '';
      _selectedDate = widget.event!.eventDate;
      _selectedBlock = widget.event!.block;
      _selectedEventType = widget.event!.eventType;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    _organizerController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      widget.event != null ? 'Edit Event' : 'Create Event',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Event Title *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description *',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Event Type
                        DropdownButtonFormField<String>(
                          value: _selectedEventType,
                          decoration: const InputDecoration(
                            labelText: 'Event Type *',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'MEDICAL_CAMP', child: Text('Medical Camp')),
                            DropdownMenuItem(
                                value: 'TRAINING', child: Text('Training Session')),
                            DropdownMenuItem(
                                value: 'AWARENESS', child: Text('Awareness Program')),
                            DropdownMenuItem(
                                value: 'VACCINATION', child: Text('Vaccination Drive')),
                            DropdownMenuItem(
                                value: 'OTHER', child: Text('Other Event')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedEventType = value!);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Date
                        InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Event Date *',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Time
                        TextFormField(
                          controller: _timeController,
                          decoration: const InputDecoration(
                            labelText: 'Event Time (optional)',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 10:00 AM - 4:00 PM',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Block
                        DropdownButtonFormField<String>(
                          value: _selectedBlock,
                          decoration: const InputDecoration(
                            labelText: 'Block *',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'VIKASNAGAR', child: Text('Vikasnagar')),
                            DropdownMenuItem(
                                value: 'DOIWALA', child: Text('Doiwala')),
                            DropdownMenuItem(
                                value: 'SAHASPUR', child: Text('Sahaspur')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedBlock = value!);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Organizer
                        TextFormField(
                          controller: _organizerController,
                          decoration: const InputDecoration(
                            labelText: 'Organizer Name (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Contact
                        TextFormField(
                          controller: _contactController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Number (optional)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(widget.event != null
                                    ? 'Update Event'
                                    : 'Create Event'),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final event = Event(
        id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        eventDate: _selectedDate,
        eventTime: _timeController.text.isEmpty ? null : _timeController.text,
        location: _locationController.text,
        block: _selectedBlock,
        eventType: _selectedEventType,
        organizerName:
            _organizerController.text.isEmpty ? null : _organizerController.text,
        organizerContact:
            _contactController.text.isEmpty ? null : _contactController.text,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
      );

      widget.onSubmit(event);
    }
  }
}
