import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { DoctorService } from './doctor.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { GetUser } from '../common/decorators/get-user.decorator';
import { UserRole } from '../common/enums/user.enum';
import { User } from '../users/entities/user.entity';

@Controller('doctor')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.DOCTOR)
export class DoctorController {
  constructor(private doctorService: DoctorService) {}

  // ==================== PATIENT MANAGEMENT ====================

  /**
   * Get list of patients
   * GET /doctor/patients?page=1&limit=20
   */
  @Get('patients')
  async getPatients(
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 20,
    @GetUser() user: User,
  ) {
    return this.doctorService.getPatients(user.id, page, limit);
  }

  /**
   * Get patient details with health records and prescriptions
   * GET /doctor/patients/:patientId
   */
  @Get('patients/:patientId')
  async getPatientDetails(
    @Param('patientId') patientId: string,
    @GetUser() user: User,
  ) {
    return this.doctorService.getPatientDetails(user.id, patientId);
  }

  /**
   * Get patient health summary
   * GET /doctor/patients/:patientId/health-summary
   */
  @Get('patients/:patientId/health-summary')
  async getPatientHealthSummary(
    @Param('patientId') patientId: string,
    @GetUser() user: User,
  ) {
    return this.doctorService.getPatientHealthSummary(user.id, patientId);
  }

  /**
   * Get patient's health metrics history
   * GET /doctor/patients/:patientId/metrics?metricType=BLOOD_SUGAR&days=30
   */
  @Get('patients/:patientId/metrics')
  async getPatientMetricsHistory(
    @Param('patientId') patientId: string,
    @Query('metricType') metricType: string = 'BLOOD_SUGAR',
    @Query('days') days: number = 30,
    @GetUser() user: User,
  ) {
    return this.doctorService.getPatientMetricsHistory(
      user.id,
      patientId,
      metricType,
      days,
    );
  }

  /**
   * Get all patients with recent activity
   * GET /doctor/activity-feed?limit=20
   */
  @Get('activity-feed')
  async getActivityFeed(
    @Query('limit') limit: number = 20,
    @GetUser() user: User,
  ) {
    return this.doctorService.getPatientActivityFeed(user.id, limit);
  }

  // ==================== PRESCRIPTION MANAGEMENT ====================

  /**
   * Get all prescriptions
   * GET /doctor/prescriptions?patientId=xxx&status=PENDING&page=1&limit=20
   */
  @Get('prescriptions')
  async getPrescriptions(
    @GetUser() user: User,
    @Query('patientId') patientId?: string,
    @Query('status') status?: string,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 20,
  ) {
    return this.doctorService.getPrescriptions(user.id, patientId, status, page, limit);
  }

  /**
   * Get prescription details
   * GET /doctor/prescriptions/:prescriptionId
   */
  @Get('prescriptions/:prescriptionId')
  async getPrescriptionDetails(
    @Param('prescriptionId') prescriptionId: string,
    @GetUser() user: User,
  ) {
    return this.doctorService.getPrescriptionDetails(user.id, prescriptionId);
  }

  /**
   * Add notes to prescription
   * POST /doctor/prescriptions/:prescriptionId/notes
   */
  @Post('prescriptions/:prescriptionId/notes')
  async addPrescriptionNotes(
    @Param('prescriptionId') prescriptionId: string,
    @Body() { notes }: { notes: string },
    @GetUser() user: User,
  ) {
    return this.doctorService.addPrescriptionNotes(user.id, prescriptionId, notes);
  }

  /**
   * Update prescription status
   * PUT /doctor/prescriptions/:prescriptionId/status
   */
  @Put('prescriptions/:prescriptionId/status')
  async updatePrescriptionStatus(
    @Param('prescriptionId') prescriptionId: string,
    @Body() { status }: { status: string },
    @GetUser() user: User,
  ) {
    return this.doctorService.updatePrescriptionStatus(user.id, prescriptionId, status as any);
  }

  // ==================== COMMUNICATION ====================

  /**
   * Get chat history with a patient
   * GET /doctor/patients/:patientId/chat?limit=50
   */
  @Get('patients/:patientId/chat')
  async getChatHistory(
    @Param('patientId') patientId: string,
    @Query('limit') limit: number = 50,
    @GetUser() user: User,
  ) {
    return this.doctorService.getChatHistory(user.id, patientId, limit);
  }

  // ==================== DASHBOARD ====================

  /**
   * Get doctor dashboard overview
   * GET /doctor/dashboard
   */
  @Get('dashboard')
  async getDashboardOverview(@GetUser() user: User) {
    const patients = await this.doctorService.getPatients(user.id, 1, 5);
    const prescriptions = await this.doctorService.getPrescriptions(user.id, undefined, 'PENDING', 1, 10);
    const activityFeed = await this.doctorService.getPatientActivityFeed(user.id, 10);

    return {
      doctor: {
        id: user.id,
        name: user.fullName,
        email: user.email,
      },
      statistics: {
        totalPatients: patients.total,
        pendingPrescriptions: prescriptions.total,
      },
      recentPatients: patients.data.slice(0, 5),
      recentPrescriptions: prescriptions.data.slice(0, 5),
      activityFeed: activityFeed.slice(0, 10),
    };
  }
}
