import { IsEnum, IsOptional, IsInt } from 'class-validator';

export enum MediaType {
  IMAGE = 'image',
  AUDIO = 'audio',
  DOCUMENT = 'document',
  VIDEO = 'video',
}

export class UploadMediaDto {
  @IsEnum(MediaType)
  type: MediaType;

  @IsOptional()
  @IsInt()
  duration?: number; // For audio/video in seconds
}
