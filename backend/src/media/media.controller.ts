import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { MediaService } from './media.service';
import { CreateMediaDto } from './dto/create-media.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { GetUser } from '../common/decorators/get-user.decorator';
import { UserRole } from '../common/enums/user.enum';
import { MediaCategory } from '../common/enums/media.enum';
import { User } from '../users/entities/user.entity';

@Controller('media')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MediaController {
  constructor(private mediaService: MediaService) {}

  @Post()
  @Roles(UserRole.ADMIN)
  async createMedia(
    @Body() createMediaDto: CreateMediaDto,
    @GetUser() user: User,
  ) {
    return this.mediaService.createMedia(createMediaDto, user);
  }

  @Get()
  async getAllMedia(@Query('category') category?: MediaCategory) {
    return this.mediaService.getAllMedia(category);
  }

  @Get(':category/:subCategory')
  async getMediaBySubCategory(
    @Param('category') category: MediaCategory,
    @Param('subCategory') subCategory: string,
  ) {
    return this.mediaService.getMediaBySubCategory(category, subCategory);
  }

  @Post(':id/view')
  async incrementViewCount(@Param('id') id: string) {
    return this.mediaService.incrementViewCount(id);
  }
}
