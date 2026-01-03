/**
 * NOTIFICATION INTEGRATION GUIDE
 * 
 * This file demonstrates how to integrate notifications across all modules
 * for real-time alerts and event triggers.
 */

// ===== 1. HEALTH MODULE - CRITICAL ALERT NOTIFICATIONS =====
// File: backend/src/health/health.service.ts

/*
import { NotificationService } from '../notifications/notifications.service';

export class HealthService {
  constructor(
    private notificationService: NotificationService,
  ) {}

  async recordMetric(user: User, createHealthMetricDto: CreateHealthMetricDto) {
    const metric = this.healthMetricRepository.create({...});
    const saved = await this.healthMetricRepository.save(metric);

    // ✓ TRIGGER: Send health alert if condition is elevated/critical
    if (saved.condition === 'ELEVATED' || saved.condition === 'CRITICAL') {
      const conditionType = `${saved.condition}_${saved.metricType}`;
      await this.notificationService.notifyHealthAlert(
        user,
        saved.metricType,
        conditionType,
        saved.value,
      );
    }

    return saved;
  }
}
*/

// ===== 2. DOCTOR MODULE - PRESCRIPTION UPDATE NOTIFICATIONS =====
// File: backend/src/doctor/doctor.service.ts

/*
import { NotificationService } from '../notifications/notifications.service';

export class DoctorService {
  constructor(
    private notificationService: NotificationService,
  ) {}

  async addPrescriptionNotes(
    prescriptionId: string,
    doctorId: string,
    notes: string,
    status: string,
  ) {
    const prescription = await this.prescriptionRepository.findOne({
      where: { id: prescriptionId },
      relations: ['patient', 'doctor'],
    });

    prescription.notes = notes;
    prescription.status = status;
    const updated = await this.prescriptionRepository.save(prescription);

    // ✓ TRIGGER: Notify patient of prescription update
    await this.notificationService.notifyPrescriptionUpdate(
      prescription.patient,
      prescription.doctor.name,
      prescriptionId,
      status,
    );

    return updated;
  }
}
*/

// ===== 3. SKILLS MODULE - CERTIFICATION COMPLETION =====
// File: backend/src/skills/skill-progress.service.ts

/*
import { NotificationService } from '../notifications/notifications.service';

export class SkillProgressService {
  constructor(
    private notificationService: NotificationService,
  ) {}

  private async updateEnrollmentProgress(enrollmentId: string) {
    const enrollment = await this.enrollmentRepo.findOne({
      where: { id: enrollmentId },
      relations: ['user'],
    });

    const completedCourses = await this.progressRepo.count({...});
    const totalCourses = enrollment.totalCoursesCount;
    const completionPercentage = 
      totalCourses > 0 ? Math.round((completedCourses / totalCourses) * 100) : 0;

    enrollment.completionPercentage = completionPercentage;

    // ✓ TRIGGER: Notify user when skill certification is complete
    if (completionPercentage === 100 && !enrollment.certificateIssuedDate) {
      enrollment.certificateIssuedDate = new Date();
      enrollment.status = 'COMPLETED';

      await this.notificationService.notifySkillCertification(
        enrollment.user,
        enrollment.skillCategory,
      );
    }

    await this.enrollmentRepo.save(enrollment);
  }
}
*/

// ===== 4. CHAT MODULE - NEW MESSAGE NOTIFICATIONS =====
// File: backend/src/chat/chat.gateway.ts or chat.service.ts

/*
import { NotificationService } from '../notifications/notifications.service';

export class ChatService {
  constructor(
    private notificationService: NotificationService,
  ) {}

  async sendMessage(
    senderId: string,
    chatRoomId: string,
    content: string,
    mediaUrls?: string[],
  ) {
    const message = await this.messageRepository.create({
      sender: { id: senderId },
      chatRoom: { id: chatRoomId },
      content,
      mediaUrls,
    }).save();

    const chatRoom = await this.chatRoomRepository.findOne({
      where: { id: chatRoomId },
      relations: ['participants'],
    });

    // ✓ TRIGGER: Notify all other participants
    const sender = await this.userRepository.findOne({ 
      where: { id: senderId } 
    });

    for (const participant of chatRoom.participants) {
      if (participant.id !== senderId) {
        await this.notificationService.notifyNewMessage(
          participant,
          sender.name,
          content.substring(0, 50) + '...',
          chatRoomId,
        );
      }
    }

    return message;
  }
}
*/

// ===== 5. EVENTS MODULE - ASSIGNMENT & CLASS NOTIFICATIONS =====
// File: backend/src/events/events.service.ts

/*
import { NotificationService } from '../notifications/notifications.service';

export class EventsService {
  constructor(
    private notificationService: NotificationService,
  ) {}

  async createAssignment(
    teacherId: string,
    eventData: CreateEventDto,
  ) {
    const event = await this.eventRepository.create({
      organizer: { id: teacherId },
      ...eventData,
    }).save();

    // ✓ TRIGGER: Notify all enrolled students about new assignment
    const students = await this.eventRepository
      .createQueryBuilder('event')
      .leftJoinAndSelect('event.participants', 'participants')
      .where('event.id = :eventId', { eventId: event.id })
      .getOne();

    const teacher = await this.userRepository.findOne({ 
      where: { id: teacherId } 
    });

    for (const student of students.participants) {
      await this.notificationService.notifyAssignment(
        student,
        teacher.name,
        event.title,
        event.eventDate,
      );
    }

    return event;
  }
}
*/

// ===== 6. DOCTOR MODULE - APPOINTMENT REMINDERS =====
// File: backend/src/doctor/doctor.service.ts

/*
async scheduleAppointmentReminder(appointmentId: string, appointmentTime: Date) {
  // Schedule reminder 24 hours before
  const reminderTime = new Date(appointmentTime.getTime() - 24 * 60 * 60 * 1000);
  
  setTimeout(async () => {
    const appointment = await this.appointmentRepository.findOne({
      where: { id: appointmentId },
      relations: ['patient', 'doctor'],
    });

    // ✓ TRIGGER: Send appointment reminder notification
    await this.notificationService.notifyAppointment(
      appointment.patient,
      appointment.doctor.name,
      appointment.appointmentTime,
    );
  }, reminderTime.getTime() - Date.now());
}
*/

// ===== 7. BROADCAST NOTIFICATIONS (System-wide alerts) =====
// Example: Health advisory, maintenance notifications

/*
async broadcastHealthAdvisory(title: string, message: string) {
  // Get all active users
  const allUsers = await this.userRepository.find({
    where: { isActive: true },
  });

  await this.notificationService.broadcastNotification(allUsers, {
    title,
    message,
    type: 'GENERAL',
    metadata: {
      severity: 'HIGH',
      requiresAck: true,
    },
  });
}
*/

// ===== WEBSOCKET/SSE INTEGRATION =====
/*
// frontend/lib/providers/notification_provider.dart
// Setup WebSocket listener for real-time notifications

import 'package:web_socket_channel/web_socket_channel.dart';

final webSocketProvider = StateProvider<WebSocketChannel?>((ref) {
  final token = ref.watch(authTokenProvider);
  if (token != null) {
    return WebSocketChannel.connect(
      Uri.parse('ws://localhost:3000/notifications/socket'),
    );
  }
  return null;
});

final notificationStreamProvider = StreamProvider<NotificationItem>((ref) {
  final channel = ref.watch(webSocketProvider);
  if (channel != null) {
    return channel.stream.map((message) {
      final json = jsonDecode(message);
      return NotificationItem.fromJson(json);
    });
  }
  return Stream.empty();
});

// In widget, listen to stream:
ref.listen(notificationStreamProvider, (_, notification) {
  notification.whenData((notif) {
    showNotificationToast(context, notif);
    // Optionally play sound/vibrate
  });
});
*/

// ===== NOTIFICATION HISTORY =====
// All notifications are persisted in database for:
// - 30-day retention (configurable)
// - User can view/delete from UI
// - Search by type/date
// - Mark as read for tracking user engagement

// ===== DEPLOYMENT CHECKLIST =====
/*
✓ Create Notification entity and module
✓ Add NotificationService to all relevant modules
✓ Integrate triggers in each service (Health, Doctor, Skills, Chat, Events)
✓ Create NotificationController with REST endpoints
✓ Create Flutter NotificationsScreen UI
✓ Setup WebSocket/SSE for real-time updates
✓ Add NotificationBadge widget to main navigation
✓ Configure notification retention policy
✓ Setup Firebase Cloud Messaging (FCM) for push notifications (OPTIONAL)
✓ Add notification preferences/settings for users
✓ Setup email notifications (OPTIONAL)
✓ Test all notification triggers end-to-end
✓ Monitor notification queue and performance
*/
