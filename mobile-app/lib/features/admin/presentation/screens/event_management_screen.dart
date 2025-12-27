import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../../events/models/event_models.dart';
import '../widgets/event_form_dialog.dart';

class EventManagementScreen extends ConsumerStatefulWidget {
  const EventManagementScreen({super.key});

  @override
  ConsumerState<EventManagementScreen> createState() =>
      _EventManagementScreenState();
}

class _EventManagementScreenState
    extends ConsumerState<EventManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final events = adminState.eventsList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
      ),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? _buildEmptyState()
              : _buildEventsList(events),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No events created yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first event to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateEventDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<Event> events) {
    // Sort by date
    final sortedEvents = List<Event>.from(events)
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));

    return RefreshIndicator(
      onRefresh: () => ref.read(adminProvider.notifier).loadEvents(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedEvents.length,
        itemBuilder: (context, index) {
          final event = sortedEvents[index];
          return _EventManageCard(
            event: event,
            onEdit: () => _editEvent(event),
            onDelete: () => _deleteEvent(event),
          );
        },
      ),
    );
  }

  void _showCreateEventDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => EventFormDialog(
        onSubmit: (event) async {
          final success =
              await ref.read(adminProvider.notifier).createEvent(event);
          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Event created successfully')),
            );
          }
        },
      ),
    );
  }

  void _editEvent(Event event) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  void _deleteEvent(Event event) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await ref.read(adminProvider.notifier).deleteEvent(event.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EventManageCard extends StatelessWidget {
  final Event event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventManageCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = event.eventDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPast ? Colors.grey : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isPast ? 'Past' : 'Upcoming',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${event.eventDate.day}/${event.eventDate.month}/${event.eventDate.year}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
