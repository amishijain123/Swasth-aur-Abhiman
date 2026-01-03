import { Injectable, BadRequestException } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';
import { v4 as uuid } from 'uuid';

@Injectable()
export class FileUploadService {
  private readonly uploadDir = path.join(process.cwd(), 'uploads');

  constructor() {
    // Create uploads directory if it doesn't exist
    if (!fs.existsSync(this.uploadDir)) {
      fs.mkdirSync(this.uploadDir, { recursive: true });
    }
  }

  /**
   * Upload file to local storage
   */
  async uploadFile(
    file: Express.Multer.File,
    category: string,
  ): Promise<{ fileUrl: string; fileName: string; originalName: string }> {
    if (!file) {
      throw new BadRequestException('No file provided');
    }

    // Validate file size (max 500MB for video content)
    const maxSize = 500 * 1024 * 1024; // 500MB
    if (file.size > maxSize) {
      throw new BadRequestException('File size exceeds maximum limit of 500MB');
    }

    // Create category-specific directory
    const categoryDir = path.join(this.uploadDir, category.toLowerCase());
    if (!fs.existsSync(categoryDir)) {
      fs.mkdirSync(categoryDir, { recursive: true });
    }

    // Generate unique filename
    const fileExt = path.extname(file.originalname);
    const fileName = `${uuid()}${fileExt}`;
    const filePath = path.join(categoryDir, fileName);

    // Save file
    fs.writeFileSync(filePath, file.buffer);

    // Return relative URL
    const fileUrl = `/uploads/${category.toLowerCase()}/${fileName}`;

    return {
      fileUrl,
      fileName,
      originalName: file.originalname,
    };
  }

  /**
   * Upload thumbnail image
   */
  async uploadThumbnail(
    file: Express.Multer.File,
    category: string,
  ): Promise<{ thumbnailUrl: string; fileName: string }> {
    if (!file) {
      throw new BadRequestException('No thumbnail file provided');
    }

    // Validate file is an image
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedMimes.includes(file.mimetype)) {
      throw new BadRequestException('Only JPEG, PNG, and WebP images are allowed for thumbnails');
    }

    // Validate file size (max 10MB for images)
    const maxSize = 10 * 1024 * 1024; // 10MB
    if (file.size > maxSize) {
      throw new BadRequestException('Thumbnail size exceeds maximum limit of 10MB');
    }

    const categoryDir = path.join(this.uploadDir, `${category.toLowerCase()}-thumbnails`);
    if (!fs.existsSync(categoryDir)) {
      fs.mkdirSync(categoryDir, { recursive: true });
    }

    const fileExt = path.extname(file.originalname);
    const fileName = `${uuid()}${fileExt}`;
    const filePath = path.join(categoryDir, fileName);

    fs.writeFileSync(filePath, file.buffer);

    const thumbnailUrl = `/uploads/${category.toLowerCase()}-thumbnails/${fileName}`;

    return {
      thumbnailUrl,
      fileName,
    };
  }

  /**
   * Delete file from local storage
   */
  deleteFile(fileUrl: string): boolean {
    try {
      const filePath = path.join(process.cwd(), fileUrl);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
        return true;
      }
      return false;
    } catch (error) {
      console.error('Error deleting file:', error);
      return false;
    }
  }

  /**
   * Get file stats
   */
  getFileStats(fileUrl: string): any {
    try {
      const filePath = path.join(process.cwd(), fileUrl);
      if (fs.existsSync(filePath)) {
        const stats = fs.statSync(filePath);
        return {
          size: stats.size,
          createdAt: stats.birthtime,
          modifiedAt: stats.mtime,
        };
      }
      return null;
    } catch (error) {
      console.error('Error getting file stats:', error);
      return null;
    }
  }
}
