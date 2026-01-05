import '../models/event_models.dart';

/// Historical ASHA Worker Training Events
/// These events are hardcoded to always appear in the Past Events section
class HistoricalEvents {
  static final List<Event> ashaTrainingEvents = [
    // Event 1: ASHA Worker Training - Doiwala Block
    Event(
      id: 'historical_doiwala_asha_2023',
      title: 'ASHA Worker Training - Doiwala Block',
      description: '''Community Covid Resilience Resource Centre (CCRRC) by UPES conducted a comprehensive training session for ASHA workers in Doiwala Block.

Key Highlights:
• Total Participants: 22 ASHA Workers
• Focus: Community health and Covid resilience
• Training on health awareness and community outreach
• Resource distribution and capacity building

This initiative aimed to strengthen the community health infrastructure and empower ASHA workers with knowledge and resources to serve their communities better.''',
      eventDate: DateTime(2023, 8, 15), // Historical date
      eventTime: '10:00 AM - 4:00 PM',
      location: 'Doiwala Community Health Center',
      block: 'DOIWALA',
      eventType: EventType.training,
      organizerName: 'Community Covid Resilience Resource Centre (CCRRC) by UPES',
      organizerContact: '+91-XXXXXXXXXX',
      imageUrl: 'assets/ad.png', // Primary event image
      expectedAttendees: 22,
      isActive: true,
      createdAt: DateTime(2023, 8, 1),
    ),

    // Event 2: ASHA Worker Training - Vikasnagar Block
    Event(
      id: 'historical_vikasnagar_asha_2023',
      title: 'ASHA Worker Training - Vikasnagar Block',
      description: '''CCRRC by UPES, in collaboration with the Department of Science and Technology, organized a specialized training program for ASHA workers in Vikasnagar Block.

Key Highlights:
• Total Participants: 12 ASHA Workers
• Supported by: Department of Science and Technology
• Resource distribution and health kits
• Community health training modules
• Covid resilience strategies

This program focused on equipping ASHA workers with essential skills and resources to enhance healthcare delivery in rural communities.''',
      eventDate: DateTime(2023, 9, 20), // Historical date
      eventTime: '9:00 AM - 3:00 PM',
      location: 'Vikasnagar Block Primary Health Centre',
      block: 'VIKASNAGAR',
      eventType: EventType.training,
      organizerName: 'CCRRC by UPES (Supported by Dept. of Science and Technology)',
      organizerContact: '+91-XXXXXXXXXX',
      imageUrl: 'assets/av.png', // Primary event image
      expectedAttendees: 12,
      isActive: true,
      createdAt: DateTime(2023, 9, 1),
    ),
  ];

  /// Additional images for historical events
  /// These can be used in the event detail screen for gallery view
  static final Map<String, List<String>> eventGallery = {
    'historical_doiwala_asha_2023': [
      'assets/ad.png',
      'assets/ad1.png',
      'assets/ad2.png',
    ],
    'historical_vikasnagar_asha_2023': [
      'assets/av.png',
      'assets/av1.png',
      'assets/av2.png',
    ],
  };

  /// Get all historical events
  static List<Event> getAllHistoricalEvents() {
    return ashaTrainingEvents;
  }

  /// Get historical events by block
  static List<Event> getHistoricalEventsByBlock(String block) {
    return ashaTrainingEvents.where((event) => event.block == block).toList();
  }

  /// Get gallery images for a specific event
  static List<String>? getEventGallery(String eventId) {
    return eventGallery[eventId];
  }

  /// Check if an event has a gallery
  static bool hasGallery(String eventId) {
    return eventGallery.containsKey(eventId) && 
           eventGallery[eventId]!.isNotEmpty;
  }
}
