import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  Patch,
  Query,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { ChatService } from './chat.service';
import { CreateChatRoomDto, SendMessageDto } from './dto/chat.dto';
import { UploadMediaDto } from './dto/upload-media.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';
import { User } from '../users/entities/user.entity';

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private chatService: ChatService) {}

  @Get('contacts')
  async getAvailableContacts(
    @GetUser() user: User,
    @Query('role') role?: string,
  ) {
    return this.chatService.getAvailableContacts(user.id, role);
  }

  @Post('rooms')
  async createChatRoom(
    @Body() createChatRoomDto: CreateChatRoomDto,
    @GetUser() user: User,
  ) {
    return this.chatService.createChatRoom(createChatRoomDto, user);
  }

  @Get('rooms')
  async getUserChatRooms(@GetUser() user: User) {
    return this.chatService.getUserChatRooms(user.id);
  }

  @Post('rooms/:roomId/messages')
  async sendMessage(
    @Param('roomId') roomId: string,
    @Body() body: { content: string; type?: string },
    @GetUser() user: User,
  ) {
    const sendMessageDto: SendMessageDto = {
      roomId,
      content: body.content,
      type: body.type,
    };
    return this.chatService.sendMessageToRoom(sendMessageDto, user);
  }

  @Get('rooms/:roomId/messages')
  async getRoomMessages(
    @Param('roomId') roomId: string,
    @GetUser() user: User,
  ) {
    return this.chatService.getRoomMessages(roomId, user.id);
  }

  @Patch('rooms/:roomId/read')
  async markMessagesAsRead(
    @Param('roomId') roomId: string,
    @GetUser() user: User,
  ) {
    await this.chatService.markMessagesAsRead(roomId, user.id);
    return { status: 'success' };
  }

  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/chat',
        filename: (req, file, callback) => {
          const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
          const ext = extname(file.originalname);
          callback(null, `${file.fieldname}-${uniqueSuffix}${ext}`);
        },
      }),
      limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
      },
    }),
  )
  async uploadMedia(
    @UploadedFile() file: Express.Multer.File,
    @Body() body: Record<string, any>,
  ) {
    if (!file) {
      throw new Error('No file uploaded');
    }

    // Return file URL and metadata
    return {
      url: `/uploads/chat/${file.filename}`,
      originalName: file.originalname,
      size: file.size,
      mimeType: file.mimetype,
      type: body.type,
      duration: body.duration ? parseInt(body.duration, 10) : undefined,
    };
  }
}
