import { IsEnum, IsString, IsOptional, IsUrl } from 'class-validator';
import { MediaCategory } from '../../common/enums/media.enum';

export class CreateMediaDto {
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
  mediaUrl: string;

  @IsUrl()
  @IsOptional()
  thumbnailUrl?: string;
}
