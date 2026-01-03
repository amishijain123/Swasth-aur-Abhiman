import { IsEnum, IsString, IsOptional, IsNumber, IsBoolean, IsUrl } from 'class-validator';
import { MediaCategory } from '../../common/enums/media.enum';
import { Type } from 'class-transformer';

export class CreateMediaWithUploadDto {
  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsEnum(MediaCategory)
  category: MediaCategory;

  @IsString()
  @IsOptional()
  subCategory?: string;

  @IsUrl()
  @IsOptional()
  mediaUrl?: string; // Optional if file is uploaded

  @IsUrl()
  @IsOptional()
  thumbnailUrl?: string;

  @IsString()
  @IsOptional()
  source?: string; // 'youtube', 'internal', 'vimeo'

  @IsString()
  @IsOptional()
  externalUrl?: string; // YouTube URL

  @IsString()
  @IsOptional()
  difficulty?: string; // 'Beginner', 'Intermediate', 'Advanced'

  @IsString()
  @IsOptional()
  ageGroup?: string; // 'Class 1', 'Class 2', etc.

  @IsString()
  @IsOptional()
  subject?: string; // 'Mathematics', 'Science', etc.

  @IsString()
  @IsOptional()
  chapter?: string;

  @IsString()
  @IsOptional()
  language?: string; // 'Hindi', 'English', 'Hinglish'

  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  durationSeconds?: number;

  @Type(() => Number)
  @IsNumber()
  @IsOptional()
  rating?: number; // 1.0 to 5.0

  @IsBoolean()
  @IsOptional()
  isFree?: boolean;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
