import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../users/entities/user.entity';
import { Prescription } from '../prescriptions/entities/prescription.entity';
import { HealthMetric, HealthMetricSession } from '../health/entities/health-metric.entity';
import { ChatRoom } from '../chat/entities/chat-room.entity';
import { Message } from '../chat/entities/message.entity';
import { UserRole } from '../common/enums/user.enum';
import { PrescriptionStatus } from '../common/enums/media.enum';

@Injectable()
export class DoctorService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Prescription)
    private prescriptionRepository: Repository<Prescription>,
    @InjectRepository(HealthMetric)
    private healthMetricRepository: Repository<HealthMetric>,
    @InjectRepository(HealthMetricSession)
    private healthSessionRepository: Repository<HealthMetricSession>,
    @InjectRepository(ChatRoom)
    private chatRoomRepository: Repository<ChatRoom>,
    @InjectRepository(Message)
    private messageRepository: Repository<Message>,
  ) {}

  // ==================== PATIENT MANAGEMENT ====================

  /**
   * Get all patients for a doctor
   * In a real app, this would be based on doctor-patient relationships
   */
  async getPatients(doctorId: string, page: number = 1, limit: number = 20) {
    const skip = (page - 1) * limit;

    // Get all users with PATIENT role (excluding self)
    const [patients, total] = await this.userRepository.findAndCount({
      where: {
        role: UserRole.USER,
      },
      skip,
      take: limit,
      order: { createdAt: 'DESC' },
    });

    return {
      data: patients.map(p => ({
        id: p.id,
        email: p.email,
        fullName: p.fullName,
        gender: p.gender,
        createdAt: p.createdAt,
      })),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  /**
   * Get patient details including health metrics and prescriptions
   */
  async getPatientDetails(doctorId: string, patientId: string) {
    const patient = await this.userRepository.findOne({
      where: { id: patientId },
    });

    if (!patient) {
      throw new NotFoundException(`Patient with ID ${patientId} not found`);
    }

    // Get patient's recent health metrics
    const healthMetrics = await this.healthMetricRepository.find({
      where: { user: patient },
      order: { recordedAt: 'DESC' },
      take: 20,
    });

    // Get patient's prescriptions
    const prescriptions = await this.prescriptionRepository.find({
      where: { user: patient },
      order: { createdAt: 'DESC' },
      take: 10,
    });

    // Get patient's health sessions
    const healthSessions = await this.healthSessionRepository.find({
      where: { user: patient },
      order: { date: 'DESC' },
      take: 10,
    });

    return {
      patient: {
        id: patient.id,
        email: patient.email,
        fullName: patient.fullName,
        gender: patient.gender,
        createdAt: patient.createdAt,
      },
      healthMetrics,
      prescriptions,
      healthSessions,
      summary: {
        totalPrescriptions: prescriptions.length,
        totalHealthRecords: healthMetrics.length,
        lastVisit: prescriptions[0]?.createdAt || null,
      },
    };
  }

  // ==================== PRESCRIPTION MANAGEMENT ====================

  /**
   * Get all prescriptions (optionally filtered by patient)
   */
  async getPrescriptions(
    doctorId: string,
    patientId?: string,
    status?: string,
    page: number = 1,
    limit: number = 20,
  ) {
    const query = this.prescriptionRepository.createQueryBuilder('prescription')
      .leftJoinAndSelect('prescription.user', 'user')
      .orderBy('prescription.createdAt', 'DESC');

    if (patientId) {
      query.andWhere('prescription.userId = :patientId', { patientId });
    }

    if (status) {
      query.andWhere('prescription.status = :status', { status });
    }

    const skip = (page - 1) * limit;
    const [data, total] = await query
      .skip(skip)
      .take(limit)
      .getManyAndCount();

    return {
      data: data.map(p => ({
        id: p.id,
        patientName: p.user?.fullName,
        patientId: p.user?.id,
        imageUrl: p.imageUrl,
        description: p.description,
        status: p.status,
        createdAt: p.createdAt,
        doctorNotes: p.doctorNotes,
      })),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  /**
   * Get prescription details
   */
  async getPrescriptionDetails(doctorId: string, prescriptionId: string) {
    const prescription = await this.prescriptionRepository.findOne({
      where: { id: prescriptionId },
      relations: ['user'],
    });

    if (!prescription) {
      throw new NotFoundException(`Prescription with ID ${prescriptionId} not found`);
    }

    return {
      id: prescription.id,
      patientName: prescription.user.fullName,
      patientId: prescription.user.id,
      patientEmail: prescription.user.email,
      imageUrl: prescription.imageUrl,
      description: prescription.description,
      status: prescription.status,
      doctorNotes: prescription.doctorNotes,
      createdAt: prescription.createdAt,
      reviewedAt: prescription.reviewedAt,
    };
  }

  /**
   * Add notes to a prescription
   */
  async addPrescriptionNotes(
    doctorId: string,
    prescriptionId: string,
    notes: string,
  ) {
    const prescription = await this.prescriptionRepository.findOne({
      where: { id: prescriptionId },
    });

    if (!prescription) {
      throw new NotFoundException(`Prescription with ID ${prescriptionId} not found`);
    }

    prescription.doctorNotes = notes;
    prescription.status = PrescriptionStatus.REVIEWED;

    return this.prescriptionRepository.save(prescription);
  }

  /**
   * Update prescription status
   */
  async updatePrescriptionStatus(
    doctorId: string,
    prescriptionId: string,
    status: PrescriptionStatus,
  ) {
    const prescription = await this.prescriptionRepository.findOne({
      where: { id: prescriptionId },
    });

    if (!prescription) {
      throw new NotFoundException(`Prescription with ID ${prescriptionId} not found`);
    }

    prescription.status = status;
    return this.prescriptionRepository.save(prescription);
  }

  // ==================== PATIENT HEALTH MONITORING ====================

  /**
   * Get patient's health summary
   */
  async getPatientHealthSummary(doctorId: string, patientId: string) {
    const patient = await this.userRepository.findOne({
      where: { id: patientId },
    });

    if (!patient) {
      throw new NotFoundException(`Patient with ID ${patientId} not found`);
    }

    // Get latest metrics
    const latestMetrics = {};
    const metricTypes = [
      'BP_SYSTOLIC',
      'BP_DIASTOLIC',
      'BLOOD_SUGAR',
      'BMI',
      'WEIGHT',
      'TEMPERATURE',
      'PULSE',
    ];

    for (const type of metricTypes) {
      const metric = await this.healthMetricRepository.findOne({
        where: { user: patient, metricType: type },
        order: { recordedAt: 'DESC' },
      });

      if (metric) {
        latestMetrics[type] = {
          value: metric.value,
          unit: metric.unit,
          condition: metric.condition,
          recordedAt: metric.recordedAt,
        };
      }
    }

    // Get metrics trend (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const recentMetrics = await this.healthMetricRepository.find({
      where: {
        user: patient,
        recordedAt: new Date(thirtyDaysAgo),
      },
      order: { recordedAt: 'DESC' },
    });

    return {
      patient: {
        id: patient.id,
        fullName: patient.fullName,
        email: patient.email,
      },
      latestMetrics,
      metricsCount: recentMetrics.length,
      healthRisk: this.calculateHealthRisk(latestMetrics),
    };
  }

  /**
   * Get patient's health metrics for a specific period
   */
  async getPatientMetricsHistory(
    doctorId: string,
    patientId: string,
    metricType: string,
    days: number = 30,
  ) {
    const patient = await this.userRepository.findOne({
      where: { id: patientId },
    });

    if (!patient) {
      throw new NotFoundException(`Patient with ID ${patientId} not found`);
    }

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const metrics = await this.healthMetricRepository.find({
      where: {
        user: patient,
        metricType,
        recordedAt: new Date(startDate),
      },
      order: { recordedAt: 'ASC' },
    });

    return {
      patientId,
      metricType,
      period: `Last ${days} days`,
      dataPoints: metrics.map(m => ({
        value: m.value,
        condition: m.condition,
        recordedAt: m.recordedAt,
      })),
    };
  }

  // ==================== COMMUNICATION ====================

  /**
   * Get chat history with a patient
   */
  async getChatHistory(doctorId: string, patientId: string, limit: number = 50) {
    const messages = await this.messageRepository
      .createQueryBuilder('message')
      .leftJoinAndSelect('message.room', 'room')
      .leftJoinAndSelect('message.sender', 'sender')
      .where(
        '(message.senderId = :doctorId AND message.recipientId = :patientId) OR ' +
          '(message.senderId = :patientId AND message.recipientId = :doctorId)',
        { doctorId, patientId },
      )
      .orderBy('message.createdAt', 'DESC')
      .take(limit)
      .getMany();

    return messages.reverse();
  }

  /**
   * Get all patients with recent activity
   */
  async getPatientActivityFeed(doctorId: string, limit: number = 20) {
    const patients = await this.userRepository
      .createQueryBuilder('user')
      .where('user.role = :role', { role: UserRole.USER })
      .orderBy('user.createdAt', 'DESC')
      .take(limit)
      .getMany();

    const withActivity = await Promise.all(
      patients.map(async (patient) => {
        const lastPrescription = await this.prescriptionRepository.findOne({
          where: { user: patient },
          order: { createdAt: 'DESC' },
        });

        const lastMetric = await this.healthMetricRepository.findOne({
          where: { user: patient },
          order: { recordedAt: 'DESC' },
        });

        const lastMessage = await this.messageRepository.findOne({
          where: [
            { sender: patient },
          ],
          order: { createdAt: 'DESC' },
        });

        return {
          patientId: patient.id,
          patientName: patient.fullName,
          lastPrescription: lastPrescription?.createdAt,
          lastHealthUpdate: lastMetric?.recordedAt,
          lastMessage: lastMessage?.createdAt,
          lastActivity: new Date(
            Math.max(
              lastPrescription?.createdAt?.getTime() || 0,
              lastMetric?.recordedAt?.getTime() || 0,
              lastMessage?.createdAt?.getTime() || 0,
            ),
          ),
        };
      }),
    );

    return withActivity.sort(
      (a, b) => b.lastActivity.getTime() - a.lastActivity.getTime(),
    );
  }

  // ==================== HELPER METHODS ====================

  private calculateHealthRisk(metrics: any): string {
    let riskScore = 0;

    if (metrics['BP_SYSTOLIC']?.condition === 'high') riskScore += 2;
    if (metrics['BLOOD_SUGAR']?.condition === 'high') riskScore += 2;
    if (metrics['BMI']?.condition === 'obese') riskScore += 1;

    if (riskScore >= 4) return 'HIGH';
    if (riskScore >= 2) return 'MEDIUM';
    return 'LOW';
  }
}
