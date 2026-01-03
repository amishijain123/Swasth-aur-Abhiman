import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Res,
} from '@nestjs/common';
import { Response } from 'express';
import { TrainerDashboardService } from './trainer-dashboard.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { GetUser } from '../common/decorators/get-user.decorator';
import { UserRole } from '../common/enums/user.enum';
import { User } from '../users/entities/user.entity';

@Controller('trainer')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.TRAINER)
export class TrainerDashboardController {
  constructor(private trainerDashboardService: TrainerDashboardService) {}

  /**
   * Get trainer dashboard overview
   * GET /trainer/dashboard
   */
  @Get('dashboard')
  async getDashboardOverview(@GetUser() user: User) {
    return this.trainerDashboardService.getDashboardOverview(user.id);
  }

  /**
   * Get all courses created by trainer
   * GET /trainer/courses
   */
  @Get('courses')
  async getCourses(
    @GetUser() user: User,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 20,
    @Query('difficulty') difficulty?: string,
    @Query('isActive') isActive?: boolean,
  ) {
    return this.trainerDashboardService.getCourses(user.id, page, limit, {
      difficulty,
      isActive,
    });
  }

  /**
   * Get course categories
   * GET /trainer/courses/categories
   */
  @Get('courses/categories')
  async getCourseCategories(@GetUser() user: User) {
    return {
      categories: await this.trainerDashboardService.getCourseCategories(user.id),
    };
  }

  /**
   * Get difficulty levels
   * GET /trainer/difficulty-levels
   */
  @Get('difficulty-levels')
  async getDifficultyLevels(
    @GetUser() user: User,
    @Query('category') category?: string,
  ) {
    return {
      levels: await this.trainerDashboardService.getDifficultyLevels(user.id, category),
    };
  }

  /**
   * Get enrollments for a course
   * GET /trainer/courses/:courseId/enrollments
   */
  @Get('courses/:courseId/enrollments')
  async getCourseEnrollments(
    @GetUser() user: User,
    @Param('courseId') courseId: string,
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 20,
  ) {
    return this.trainerDashboardService.getCourseEnrollments(
      user.id,
      courseId,
      page,
      limit,
    );
  }

  /**
   * Get student progress in a course
   * GET /trainer/courses/:courseId/students/:studentId/progress
   */
  @Get('courses/:courseId/students/:studentId/progress')
  async getStudentProgress(
    @GetUser() user: User,
    @Param('courseId') courseId: string,
    @Param('studentId') studentId: string,
  ) {
    return this.trainerDashboardService.getStudentProgress(user.id, courseId, studentId);
  }

  /**
   * Get course performance metrics
   * GET /trainer/courses/:courseId/metrics
   */
  @Get('courses/:courseId/metrics')
  async getCourseMetrics(
    @GetUser() user: User,
    @Param('courseId') courseId: string,
  ) {
    return this.trainerDashboardService.getCourseMetrics(user.id, courseId);
  }

  /**
   * Get analytics for date range
   * GET /trainer/analytics
   */
  @Get('analytics')
  async getAnalytics(
    @GetUser() user: User,
    @Query('startDate') startDate: string,
    @Query('endDate') endDate: string,
  ) {
    const start = startDate ? new Date(startDate) : new Date(new Date().setDate(new Date().getDate() - 30));
    const end = endDate ? new Date(endDate) : new Date();

    return this.trainerDashboardService.getAnalytics(user.id, start, end);
  }

  /**
   * Export courses data as CSV
   * GET /trainer/export/csv
   */
  @Get('export/csv')
  async exportCourses(@GetUser() user: User, @Res() res: Response) {
    const csv = await this.trainerDashboardService.exportCourses(user.id);

    res.header('Content-Type', 'text/csv');
    res.header('Content-Disposition', 'attachment; filename="trainer_courses_export.csv"');
    res.send(csv);
  }
}
