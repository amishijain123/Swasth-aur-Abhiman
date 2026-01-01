import { IsString, IsOptional, IsArray, IsEnum, IsNumber } from 'class-validator';

export class CreateChatRoomDto {
  @IsArray()
  participantIds: string[];

  @IsString()
  @IsOptional()
  name?: string;

  // Optional type to allow DIRECT/GROUP without failing the whitelist validation
  @IsString()
  @IsOptional()
  type?: string;
}

export class SendMessageDto {
  @IsString()
  roomId: string;

  @IsString()
  content: string;

  @IsEnum(['TEXT', 'IMAGE', 'AUDIO', 'FILE'])
  @IsOptional()
  type?: string;

  @IsString()
  @IsOptional()
  mediaUrl?: string;

  @IsNumber()
  @IsOptional()
  audioDuration?: number;
}
