import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MediaContent } from '../media/entities/media-content.entity';
import { MediaCategory } from '../common/enums/media.enum';
import { User } from '../users/entities/user.entity';

@Injectable()
export class SkillsService {
  constructor(
    @InjectRepository(MediaContent)
    private mediaRepository: Repository<MediaContent>,
  ) {}

  // ==================== SKILL CATEGORIES ====================

  /**
   * Get all available skill categories
   */
  async getSkillCategories() {
    const categories = [
      {
        id: 'bamboo-training',
        name: 'Bamboo Training',
        description: 'Learn bamboo craft and sustainable practices',
        icon: 'bamboo',
      },
      {
        id: 'honeybee-farming',
        name: 'Honeybee Farming',
        description: 'Complete guide to beekeeping and honey production',
        icon: 'bee',
      },
      {
        id: 'artisan-training',
        name: 'Artisan Training',
        description: 'Traditional crafts and artisanal skills development',
        icon: 'palette',
      },
      {
        id: 'jutework',
        name: 'Jutework',
        description: 'Master the art of jute crafting',
        icon: 'work',
      },
      {
        id: 'macrame-work',
        name: 'Macrame Work',
        description: 'Learn decorative knot tying and macrame techniques',
        icon: 'workspaces',
      },
    ];

    return categories;
  }

  /**
   * Get skill category by ID
   */
  async getSkillCategoryById(categoryId: string) {
    const categories = await this.getSkillCategories();
    return categories.find(c => c.id === categoryId);
  }

  // ==================== SKILL CONTENT ====================

  /**
   * Get all content for a specific skill category
   */
  async getSkillContent(categoryId: string, page: number = 1, limit: number = 20) {
    const query = this.mediaRepository.createQueryBuilder('media')
      .where('media.category = :category', { category: MediaCategory.SKILL })
      .andWhere('media.subCategory = :subCategory', { subCategory: this.mapCategoryIdToName(categoryId) })
      .andWhere('media.isActive = :isActive', { isActive: true })
      .orderBy('media.createdAt', 'DESC');

    const skip = (page - 1) * limit;
    const [data, total] = await query
      .skip(skip)
      .take(limit)
      .getManyAndCount();

    return {
      category: categoryId,
      data: data.map(m => ({
        id: m.id,
        title: m.title,
        description: m.description,
        thumbnailUrl: m.thumbnailUrl,
        mediaUrl: m.mediaUrl,
        durationSeconds: m.durationSeconds,
        viewCount: m.viewCount,
        difficulty: m.difficulty,
        language: m.language,
      })),
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  /**
   * Search skill content
   */
  async searchSkillContent(query: string, categoryId?: string) {
    const queryBuilder = this.mediaRepository.createQueryBuilder('media')
      .where('media.category = :category', { category: MediaCategory.SKILL })
      .andWhere(
        '(media.title ILIKE :query OR media.description ILIKE :query)',
        { query: `%${query}%` },
      )
      .andWhere('media.isActive = :isActive', { isActive: true });

    if (categoryId) {
      queryBuilder.andWhere('media.subCategory = :subCategory', {
        subCategory: this.mapCategoryIdToName(categoryId),
      });
    }

    return queryBuilder
      .orderBy('media.viewCount', 'DESC')
      .take(20)
      .getMany();
  }

  /**
   * Get trending skill content
   */
  async getTrendingSkillContent(limit: number = 10) {
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    return this.mediaRepository.find({
      where: {
        category: MediaCategory.SKILL,
        isActive: true,
        createdAt: new Date(thirtyDaysAgo),
      },
      order: { viewCount: 'DESC' },
      take: limit,
    });
  }

  /**
   * Get featured skill courses
   */
  async getFeaturedSkills() {
    const categories = await this.getSkillCategories();
    const featured = [];

    for (const category of categories) {
      const topContent = await this.mediaRepository.findOne({
        where: {
          category: MediaCategory.SKILL,
          subCategory: this.mapCategoryIdToName(category.id),
          isActive: true,
        },
        order: { viewCount: 'DESC' },
      });

      if (topContent) {
        featured.push({
          ...category,
          topCourse: topContent,
        });
      }
    }

    return featured;
  }

  // ==================== DIFFICULTY LEVELS ====================

  /**
   * Get content by difficulty level
   */
  async getContentByDifficulty(
    categoryId: string,
    difficulty: string,
    page: number = 1,
    limit: number = 20,
  ) {
    const query = this.mediaRepository.createQueryBuilder('media')
      .where('media.category = :category', { category: MediaCategory.SKILL })
      .andWhere('media.subCategory = :subCategory', { subCategory: this.mapCategoryIdToName(categoryId) })
      .andWhere('media.difficulty = :difficulty', { difficulty })
      .andWhere('media.isActive = :isActive', { isActive: true });

    const skip = (page - 1) * limit;
    const [data, total] = await query
      .skip(skip)
      .take(limit)
      .getManyAndCount();

    return {
      category: categoryId,
      difficulty,
      data,
      total,
      page,
      limit,
    };
  }

  /**
   * Get difficulty levels for a category
   */
  async getDifficultyLevels(categoryId: string) {
    const content = await this.mediaRepository.find({
      where: {
        category: MediaCategory.SKILL,
        subCategory: this.mapCategoryIdToName(categoryId),
        isActive: true,
      },
    });

    const difficulties = new Set(
      content.map(c => c.difficulty).filter(d => d !== null),
    );

    return Array.from(difficulties).sort();
  }

  // ==================== LEARNING PATHS ====================

  /**
   * Get recommended learning path for a skill category
   */
  async getLearningPath(categoryId: string) {
    const difficulty = ['Beginner', 'Intermediate', 'Advanced'];
    const path = [];

    for (const level of difficulty) {
      const content = await this.mediaRepository.find({
        where: {
          category: MediaCategory.SKILL,
          subCategory: this.mapCategoryIdToName(categoryId),
          difficulty: level,
          isActive: true,
        },
        order: { createdAt: 'ASC' },
        take: 5,
      });

      if (content.length > 0) {
        path.push({
          level,
          courses: content.map(c => ({
            id: c.id,
            title: c.title,
            description: c.description,
            durationSeconds: c.durationSeconds,
            sequenceOrder: difficulty.indexOf(level),
          })),
        });
      }
    }

    return path;
  }

  /**
   * Get next recommended course
   */
  async getNextRecommendedCourse(categoryId: string, completedVideoIds: string[]) {
    const allContent = await this.mediaRepository.find({
      where: {
        category: MediaCategory.SKILL,
        subCategory: this.mapCategoryIdToName(categoryId),
        isActive: true,
      },
      order: { createdAt: 'ASC' },
    });

    // Find the first uncompleted video
    const nextCourse = allContent.find(c => !completedVideoIds.includes(c.id));

    return nextCourse || null;
  }

  // ==================== HELPER METHODS ====================

  private mapCategoryIdToName(categoryId: string): string {
    const mapping = {
      'bamboo-training': 'Bamboo Training',
      'honeybee-farming': 'Honeybee Farming',
      'artisan-training': 'Artisan Training',
      'jutework': 'Jutework',
      'macrame-work': 'Macrame Work',
    };

    return mapping[categoryId] || categoryId;
  }
}
