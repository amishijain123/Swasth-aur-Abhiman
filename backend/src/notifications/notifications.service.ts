import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from './entities/notification.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class NotificationService {
  constructor(
    @InjectRepository(Notification)
    private notifRepo: Repository<Notification>,
  ) {}

  async createNotification(
    recipient: User,
    data: {
      title: string;
      message: string;
      type:
        | 'MESSAGE'
        | 'HEALTH_ALERT'
        | 'PRESCRIPTION'
        | 'ASSIGNMENT'
        | 'SKILL_CERTIFICATION'
        | 'APPOINTMENT'
        | 'GENERAL';
      imageUrl?: string;
      actionUrl?: string;
      metadata?: Record<string, any>;
      expiresAt?: Date;
    },
  ): Promise<Notification> {
    const notification = this.notifRepo.create({
      recipient,
      ...data,
    });
    return this.notifRepo.save(notification);
  }

  async getUserNotifications(
    userId: string,
    limit: number = 20,
    offset: number = 0,
  ): Promise<{
    notifications: Notification[];
    unreadCount: number;
    total: number;
  }> {
    const [notifications, total] = await this.notifRepo.findAndCount({
      where: { recipient: { id: userId } },
      order: { createdAt: 'DESC' },
      take: limit,
      skip: offset,
    });

    const unreadCount = await this.notifRepo.count({
      where: {
        recipient: { id: userId },
        isRead: false,
      },
    });

    return { notifications, unreadCount, total };
  }

  async markAsRead(notificationId: string): Promise<void> {
    await this.notifRepo.update(notificationId, {
      isRead: true,
      readAt: new Date(),
    });
  }

  async markAllAsRead(userId: string): Promise<void> {
    await this.notifRepo.update(
      { recipient: { id: userId }, isRead: false },
      {
        isRead: true,
        readAt: new Date(),
      },
    );
  }

  async deleteNotification(notificationId: string): Promise<void> {
    await this.notifRepo.delete(notificationId);
  }

  async getUnreadCount(userId: string): Promise<number> {
    return this.notifRepo.count({
      where: {
        recipient: { id: userId },
        isRead: false,
      },
    });
  }

  async getNotificationsByType(
    userId: string,
    type: string,
    limit: number = 10,
  ): Promise<Notification[]> {
    return this.notifRepo.find({
      where: {
        recipient: { id: userId },
        type: type as any,
      },
      order: { createdAt: 'DESC' },
      take: limit,
    });
  }

  // ===== EVENT TRIGGERS =====

  async notifyNewMessage(
    recipientUser: User,
    senderName: string,
    messagePreview: string,
    chatRoomId: string,
  ): Promise<Notification> {
    return this.createNotification(recipientUser, {
      title: `New message from ${senderName}`,
      message: messagePreview,
      type: 'MESSAGE',
      actionUrl: `/chat/${chatRoomId}`,
      metadata: { chatRoomId, senderName },
    });
  }

  async notifyHealthAlert(
    user: User,
    metricType: string,
    condition: string,
    value: number,
  ): Promise<Notification> {
    const messages: Record<string, string> = {
      HIGH_BP: '⚠️ Your blood pressure is elevated',
      CRITICAL_BP: '🚨 Your blood pressure is critically high',
      HIGH_SUGAR: '⚠️ Your blood sugar level is elevated',
      CRITICAL_SUGAR: '🚨 Your blood sugar level is critically high',
      HIGH_BMI: '⚠️ Your BMI indicates overweight',
    };

    const message = messages[condition] || `Health alert: ${condition}`;

    return this.createNotification(user, {
      title: 'Health Alert',
      message: `${message} (${value})`,
      type: 'HEALTH_ALERT',
      actionUrl: '/health',
      metadata: { metricType, condition, value },
    });
  }

  async notifyPrescriptionUpdate(
    user: User,
    doctorName: string,
    prescriptionId: string,
    status: string,
  ): Promise<Notification> {
    const messages: Record<string, string> = {
      PENDING: 'Your prescription is pending review',
      REVIEWED: 'Your prescription has been reviewed',
      NEEDS_FOLLOWUP: 'Your doctor needs a follow-up appointment',
    };

    return this.createNotification(user, {
      title: `Prescription Update from ${doctorName}`,
      message: messages[status] || `Prescription status: ${status}`,
      type: 'PRESCRIPTION',
      actionUrl: `/prescriptions/${prescriptionId}`,
      metadata: { prescriptionId, doctorName, status },
    });
  }

  async notifySkillCertification(
    user: User,
    skillCategory: string,
  ): Promise<Notification> {
    return this.createNotification(user, {
      title: '🎓 Certification Completed!',
      message: `Congratulations! You have completed the ${skillCategory} training`,
      type: 'SKILL_CERTIFICATION',
      actionUrl: `/skills/${skillCategory}/certificate`,
      metadata: { skillCategory },
    });
  }

  async notifyAssignment(
    user: User,
    teacherName: string,
    assignmentTitle: string,
    dueDate: Date,
  ): Promise<Notification> {
    return this.createNotification(user, {
      title: `New Assignment from ${teacherName}`,
      message: `${assignmentTitle} - Due: ${dueDate.toLocaleDateString()}`,
      type: 'ASSIGNMENT',
      actionUrl: '/assignments',
      metadata: { teacherName, assignmentTitle, dueDate },
    });
  }

  async notifyAppointment(
    user: User,
    doctorName: string,
    appointmentTime: Date,
  ): Promise<Notification> {
    return this.createNotification(user, {
      title: 'Appointment Reminder',
      message: `You have an appointment with ${doctorName} at ${appointmentTime.toLocaleTimeString()}`,
      type: 'APPOINTMENT',
      actionUrl: '/appointments',
      metadata: { doctorName, appointmentTime },
    });
  }

  async broadcastNotification(
    users: User[],
    data: {
      title: string;
      message: string;
      type:
        | 'MESSAGE'
        | 'HEALTH_ALERT'
        | 'PRESCRIPTION'
        | 'ASSIGNMENT'
        | 'SKILL_CERTIFICATION'
        | 'APPOINTMENT'
        | 'GENERAL';
      metadata?: Record<string, any>;
    },
  ): Promise<Notification[]> {
    const notifications = users.map((user) =>
      this.notifRepo.create({
        recipient: user,
        ...data,
      }),
    );
    return this.notifRepo.save(notifications);
  }
}
