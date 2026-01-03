import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FileUploadService } from './file-upload.service';
import { CloudStorageService } from './cloud-storage.service';

@Injectable()
export class StorageService {
  private useCloudStorage: boolean;

  constructor(
    private fileUploadService: FileUploadService,
    private cloudStorageService: CloudStorageService,
    private configService: ConfigService,
  ) {
    this.useCloudStorage = this.configService.get('ENABLE_CLOUD_STORAGE') === 'true';
  }

  /**
   * Upload file using configured storage backend
   */
  async uploadFile(
    file: Express.Multer.File,
    category: string,
  ): Promise<{ fileUrl: string; fileName: string; key?: string }> {
    if (this.useCloudStorage) {
      return this.cloudStorageService.uploadFile(file, category);
    } else {
      return this.fileUploadService.uploadFile(file, category);
    }
  }

  /**
   * Upload thumbnail using configured storage backend
   */
  async uploadThumbnail(
    file: Express.Multer.File,
    category: string,
  ): Promise<{ thumbnailUrl: string; fileName?: string; key?: string }> {
    if (this.useCloudStorage) {
      return this.cloudStorageService.uploadThumbnail(file, category);
    } else {
      return this.fileUploadService.uploadThumbnail(file, category);
    }
  }

  /**
   * Delete file from storage
   */
  async deleteFile(fileUrl: string, key?: string): Promise<boolean> {
    if (this.useCloudStorage && key) {
      return this.cloudStorageService.deleteFile(key);
    } else {
      return this.fileUploadService.deleteFile(fileUrl);
    }
  }

  /**
   * Get file stats
   */
  async getFileStats(fileUrl: string, key?: string): Promise<any> {
    if (this.useCloudStorage && key) {
      return this.cloudStorageService.getFileStats(key);
    } else {
      return this.fileUploadService.getFileStats(fileUrl);
    }
  }

  /**
   * Get storage statistics
   */
  async getStorageStats(): Promise<{ totalSize: number; fileCount: number }> {
    if (this.useCloudStorage) {
      return this.cloudStorageService.getStorageStats();
    }
    return { totalSize: 0, fileCount: 0 };
  }

  /**
   * Switch storage backend at runtime
   */
  switchStorageBackend(useCloud: boolean): void {
    this.useCloudStorage = useCloud;
  }

  /**
   * Get current storage backend
   */
  getStorageBackend(): string {
    return this.useCloudStorage ? 'cloud' : 'local';
  }
}
