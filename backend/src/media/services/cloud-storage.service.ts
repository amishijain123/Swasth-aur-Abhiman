import { Injectable, BadRequestException, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as AWS from 'aws-sdk';
import { v4 as uuid } from 'uuid';

@Injectable()
export class CloudStorageService {
  private s3: AWS.S3;
  private bucketName: string;
  private region: string;
  private enableCloudStorage: boolean;

  constructor(private configService: ConfigService) {
    this.enableCloudStorage = this.configService.get('ENABLE_CLOUD_STORAGE') === 'true';
    this.bucketName = this.configService.get('S3_BUCKET_NAME');
    this.region = this.configService.get('AWS_REGION', 'us-east-1');

    if (this.enableCloudStorage) {
      // Initialize AWS S3
      this.s3 = new AWS.S3({
        accessKeyId: this.configService.get('AWS_ACCESS_KEY_ID'),
        secretAccessKey: this.configService.get('AWS_SECRET_ACCESS_KEY'),
        region: this.region,
      });

      // Or for MinIO compatible storage
      if (this.configService.get('USE_MINIO') === 'true') {
        this.s3 = new AWS.S3({
          endpoint: this.configService.get('MINIO_ENDPOINT'),
          accessKeyId: this.configService.get('MINIO_ACCESS_KEY'),
          secretAccessKey: this.configService.get('MINIO_SECRET_KEY'),
          s3ForcePathStyle: true,
          signatureVersion: 'v4',
        });
      }
    }
  }

  /**
   * Upload file to cloud storage
   */
  async uploadFile(
    file: Express.Multer.File,
    category: string,
  ): Promise<{ fileUrl: string; fileName: string; key: string }> {
    if (!file) {
      throw new BadRequestException('No file provided');
    }

    if (!this.enableCloudStorage) {
      throw new InternalServerErrorException('Cloud storage is not enabled');
    }

    // Validate file size (500MB max)
    const maxSize = 500 * 1024 * 1024;
    if (file.size > maxSize) {
      throw new BadRequestException('File size exceeds maximum limit of 500MB');
    }

    try {
      const fileName = `${uuid()}${this.getFileExtension(file.originalname)}`;
      const key = `${category.toLowerCase()}/${new Date().getFullYear()}/${new Date().getMonth() + 1}/${fileName}`;

      const params = {
        Bucket: this.bucketName,
        Key: key,
        Body: file.buffer,
        ContentType: file.mimetype,
        Metadata: {
          'original-name': file.originalname,
          'upload-date': new Date().toISOString(),
        },
        // Public read access for CDN
        ACL: 'public-read' as any,
      };

      const result = await this.s3.upload(params).promise();

      return {
        fileUrl: result.Location,
        fileName,
        key,
      };
    } catch (error) {
      console.error('Cloud storage upload error:', error);
      throw new InternalServerErrorException('Failed to upload file to cloud storage');
    }
  }

  /**
   * Upload thumbnail to cloud storage
   */
  async uploadThumbnail(
    file: Express.Multer.File,
    category: string,
  ): Promise<{ thumbnailUrl: string; key: string }> {
    if (!file) {
      throw new BadRequestException('No thumbnail file provided');
    }

    if (!this.enableCloudStorage) {
      throw new InternalServerErrorException('Cloud storage is not enabled');
    }

    // Validate image type
    const allowedMimes = ['image/jpeg', 'image/png', 'image/webp'];
    if (!allowedMimes.includes(file.mimetype)) {
      throw new BadRequestException('Only JPEG, PNG, and WebP images are allowed');
    }

    // Validate file size (10MB)
    const maxSize = 10 * 1024 * 1024;
    if (file.size > maxSize) {
      throw new BadRequestException('Thumbnail size exceeds maximum limit of 10MB');
    }

    try {
      const fileName = `${uuid()}${this.getFileExtension(file.originalname)}`;
      const key = `${category.toLowerCase()}-thumbnails/${new Date().getFullYear()}/${new Date().getMonth() + 1}/${fileName}`;

      const params = {
        Bucket: this.bucketName,
        Key: key,
        Body: file.buffer,
        ContentType: file.mimetype,
        ACL: 'public-read' as any,
        Metadata: {
          'original-name': file.originalname,
        },
      };

      const result = await this.s3.upload(params).promise();

      return {
        thumbnailUrl: result.Location,
        key,
      };
    } catch (error) {
      console.error('Cloud thumbnail upload error:', error);
      throw new InternalServerErrorException('Failed to upload thumbnail to cloud storage');
    }
  }

  /**
   * Delete file from cloud storage
   */
  async deleteFile(key: string): Promise<boolean> {
    if (!this.enableCloudStorage) {
      return false;
    }

    try {
      const params = {
        Bucket: this.bucketName,
        Key: key,
      };

      await this.s3.deleteObject(params).promise();
      return true;
    } catch (error) {
      console.error('Cloud storage delete error:', error);
      return false;
    }
  }

  /**
   * Generate signed URL for private file access
   */
  async getSignedUrl(key: string, expirySeconds: number = 3600): Promise<string> {
    if (!this.enableCloudStorage) {
      return null;
    }

    try {
      const params = {
        Bucket: this.bucketName,
        Key: key,
        Expires: expirySeconds,
      };

      return this.s3.getSignedUrl('getObject', params);
    } catch (error) {
      console.error('Error generating signed URL:', error);
      return null;
    }
  }

  /**
   * Get file stats from cloud storage
   */
  async getFileStats(key: string): Promise<any> {
    if (!this.enableCloudStorage) {
      return null;
    }

    try {
      const params = {
        Bucket: this.bucketName,
        Key: key,
      };

      const metadata = await this.s3.headObject(params).promise();

      return {
        size: metadata.ContentLength,
        lastModified: metadata.LastModified,
        contentType: metadata.ContentType,
      };
    } catch (error) {
      console.error('Error getting file stats:', error);
      return null;
    }
  }

  /**
   * List files in a directory
   */
  async listFiles(prefix: string, maxKeys: number = 100): Promise<string[]> {
    if (!this.enableCloudStorage) {
      return [];
    }

    try {
      const params = {
        Bucket: this.bucketName,
        Prefix: prefix,
        MaxKeys: maxKeys,
      };

      const result = await this.s3.listObjectsV2(params).promise();

      return result.Contents?.map((obj) => obj.Key) || [];
    } catch (error) {
      console.error('Error listing files:', error);
      return [];
    }
  }

  /**
   * Get storage usage statistics
   */
  async getStorageStats(): Promise<{ totalSize: number; fileCount: number }> {
    if (!this.enableCloudStorage) {
      return { totalSize: 0, fileCount: 0 };
    }

    try {
      let totalSize = 0;
      let fileCount = 0;
      let continuationToken: string;

      do {
        const params = {
          Bucket: this.bucketName,
          ContinuationToken: continuationToken,
        };

        const result = await this.s3.listObjectsV2(params as any).promise();

        if (result.Contents) {
          fileCount += result.Contents.length;
          totalSize += result.Contents.reduce((sum, obj) => sum + obj.Size, 0);
        }

        continuationToken = result.NextContinuationToken;
      } while (continuationToken);

      return { totalSize, fileCount };
    } catch (error) {
      console.error('Error getting storage stats:', error);
      return { totalSize: 0, fileCount: 0 };
    }
  }

  /**
   * Create CloudFront distribution URL (if configured)
   */
  getDistributionUrl(key: string): string {
    const distributionDomain = this.configService.get('CLOUDFRONT_DOMAIN');
    if (distributionDomain) {
      return `https://${distributionDomain}/${key}`;
    }
    return null;
  }

  private getFileExtension(originalName: string): string {
    const parts = originalName.split('.');
    return parts.length > 1 ? `.${parts[parts.length - 1]}` : '';
  }
}
