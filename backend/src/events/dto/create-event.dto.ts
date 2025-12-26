import { IsString, IsDateString, IsOptional, IsUrl } from 'class-validator';

export class CreateEventDto {
  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsDateString()
  dateTime: Date;

  @IsString()
  location: string;

  @IsUrl()
  @IsOptional()
  imageUrl?: string;
}
