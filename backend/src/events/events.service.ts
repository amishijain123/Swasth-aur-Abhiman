import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThanOrEqual } from 'typeorm';
import { Event } from './entities/event.entity';
import { CreateEventDto } from './dto/create-event.dto';
import { User } from '../users/entities/user.entity';

@Injectable()
export class EventsService {
  constructor(
    @InjectRepository(Event)
    private eventRepository: Repository<Event>,
  ) {}

  async createEvent(createEventDto: CreateEventDto, user: User) {
    const event = this.eventRepository.create({
      ...createEventDto,
      createdBy: user,
    });

    return this.eventRepository.save(event);
  }

  async getAllEvents() {
    return this.eventRepository.find({
      where: { isActive: true },
      order: { dateTime: 'ASC' },
    });
  }

  async getUpcomingEvents() {
    return this.eventRepository.find({
      where: {
        isActive: true,
        dateTime: MoreThanOrEqual(new Date()),
      },
      order: { dateTime: 'ASC' },
    });
  }

  async getEventById(id: string) {
    return this.eventRepository.findOne({
      where: { id },
      relations: ['createdBy'],
    });
  }
}
