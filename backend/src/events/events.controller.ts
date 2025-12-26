import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
} from '@nestjs/common';
import { EventsService } from './events.service';
import { CreateEventDto } from './dto/create-event.dto';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { GetUser } from '../common/decorators/get-user.decorator';
import { UserRole } from '../common/enums/user.enum';
import { User } from '../users/entities/user.entity';

@Controller('events')
@UseGuards(JwtAuthGuard, RolesGuard)
export class EventsController {
  constructor(private eventsService: EventsService) {}

  @Post()
  @Roles(UserRole.ADMIN)
  async createEvent(
    @Body() createEventDto: CreateEventDto,
    @GetUser() user: User,
  ) {
    return this.eventsService.createEvent(createEventDto, user);
  }

  @Get()
  async getAllEvents() {
    return this.eventsService.getAllEvents();
  }

  @Get('upcoming')
  async getUpcomingEvents() {
    return this.eventsService.getUpcomingEvents();
  }

  @Get(':id')
  async getEventById(@Param('id') id: string) {
    return this.eventsService.getEventById(id);
  }
}
