import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DoctorController } from './doctor.controller';
import { DoctorService } from './doctor.service';
import { User } from '../users/entities/user.entity';
import { Prescription } from '../prescriptions/entities/prescription.entity';
import { HealthMetric, HealthMetricSession } from '../health/entities/health-metric.entity';
import { ChatRoom } from '../chat/entities/chat-room.entity';
import { Message } from '../chat/entities/message.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      Prescription,
      HealthMetric,
      HealthMetricSession,
      ChatRoom,
      Message,
    ]),
  ],
  controllers: [DoctorController],
  providers: [DoctorService],
  exports: [DoctorService],
})
export class DoctorModule {}
