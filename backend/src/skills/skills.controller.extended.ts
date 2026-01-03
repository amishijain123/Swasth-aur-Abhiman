import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { SkillsService } from './skills.service';
import { SkillProgressService } from './skill-progress.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@Controller('skills')
export class SkillsController {
  constructor(
    private skillsService: SkillsService,
    private progressService: SkillProgressService,
  ) {}

  // ===== SKILL BROWSING =====

  @Get('categories')
  async getCategories() {
    return this.skillsService.getSkillCategories();
  }

  @Get('categories/:categoryId/content')
  async getCategoryContent(
    @Param('categoryId') categoryId: string,
    @Query('page') page = 1,
    @Query('limit') limit = 10,
  ) {
    return this.skillsService.getSkillContent(categoryId, page, limit);
  }

  @Get('search')
  async searchSkills(@Query('query') query: string) {
    return this.skillsService.searchSkillContent(query);
  }

  @Get('trending')
  async getTrendingSkills() {
    return this.skillsService.getSkillContent('artisan-training', 1, 10);
  }

  @Get(':categoryId/learning-path')
  async getLearningPath(@Param('categoryId') categoryId: string) {
    return this.skillsService.getLearningPath(categoryId);
  }

  // ===== USER PROGRESS & ENROLLMENT =====

  @UseGuards(JwtAuthGuard)
  @Post('enroll/:skillCategory')
  async enrollInSkill(
    @Request() req,
    @Param('skillCategory') skillCategory: string,
  ) {
    return this.progressService.enrollUserInSkill(
      req.user,
      skillCategory,
      20, // Default courses per skill
    );
  }

  @UseGuards(JwtAuthGuard)
  @Get('my-enrollments')
  async getMyEnrollments(@Request() req) {
    return this.progressService.getUserEnrollments(req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Get('enrollment/:enrollmentId/progress')
  async getEnrollmentProgress(@Param('enrollmentId') enrollmentId: string) {
    return this.progressService.getEnrollmentProgress(enrollmentId);
  }

  @UseGuards(JwtAuthGuard)
  @Post('enrollment/:enrollmentId/record-progress')
  async recordCourseProgress(
    @Request() req,
    @Param('enrollmentId') enrollmentId: string,
    @Body()
    body: {
      courseId: string;
      courseTitle: string;
      videoUrl: string;
      watchedDurationSeconds: number;
      totalDurationSeconds: number;
    },
  ) {
    return this.progressService.recordCourseProgress(
      req.user,
      enrollmentId,
      body.courseId,
      body.courseTitle,
      body.videoUrl,
      body.watchedDurationSeconds,
      body.totalDurationSeconds,
    );
  }

  @UseGuards(JwtAuthGuard)
  @Get('my-certificates')
  async getMyCertificates(@Request() req) {
    return this.progressService.getUserCertificates(req.user.id);
  }

  // ===== GAMIFICATION & LEADERBOARDS =====

  @Get(':skillCategory/leaderboard')
  async getSkillLeaderboard(
    @Param('skillCategory') skillCategory: string,
    @Query('limit') limit = 10,
  ) {
    return this.progressService.getSkillLeaderboard(skillCategory, +limit);
  }

  @Get(':skillCategory/stats')
  async getSkillStats(@Param('skillCategory') skillCategory: string) {
    return this.progressService.getSkillStats(skillCategory);
  }

  @UseGuards(JwtAuthGuard)
  @Get('enrollment/:enrollmentId/next-recommended')
  async getNextRecommended(
    @Param('enrollmentId') enrollmentId: string,
  ) {
    return this.progressService.getRecommendedCourseAfter(enrollmentId);
  }

  // ===== TRAINER ENDPOINTS (Add Courses) =====

  @UseGuards(JwtAuthGuard)
  @Post('trainer/:skillCategory/add-course')
  async addCourseByTrainer(
    @Request() req,
    @Param('skillCategory') skillCategory: string,
    @Body()
    body: {
      title: string;
      description: string;
      difficulty: 'BEGINNER' | 'INTERMEDIATE' | 'ADVANCED';
      videoUrl: string;
      durationSeconds: number;
      thumbnailUrl?: string;
    },
  ) {
    // TODO: Implement trainer endpoint for adding courses
    // Check req.user role is TRAINER
    // Create new media content with category=SKILLS, subCategory=skillCategory
    return {
      message: 'Course creation endpoint - requires implementation',
    };
  }
}
