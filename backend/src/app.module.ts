import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { MediaModule } from './media/media.module';
import { EventsModule } from './events/events.module';
import { PrescriptionsModule } from './prescriptions/prescriptions.module';
import { ChatModule } from './chat/chat.module';
import { YoutubeModule } from './youtube/youtube.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { AdminModule } from './admin/admin.module';
import { HealthModule } from './health/health.module';
import { DoctorModule } from './doctor/doctor.module';
import { SkillsModule } from './skills/skills.module';
import { NutritionModule } from './nutrition/nutrition.module';
import { NotificationModule } from './notifications/notifications.module';

@Module({
  imports: [
    // Configuration Module
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // Database Module
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST'),
        port: configService.get<number>('DB_PORT'),
        username: configService.get('DB_USERNAME'),
        password: configService.get('DB_PASSWORD'),
        database: configService.get('DB_DATABASE'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: configService.get('NODE_ENV') === 'development', // Set to false in production
        logging: configService.get('NODE_ENV') === 'development',
      }),
    }),

    // Feature Modules
    AuthModule,
    UsersModule,
    MediaModule,
    EventsModule,
    PrescriptionsModule,
    ChatModule,
    YoutubeModule,
    AnalyticsModule,
    AdminModule,
    HealthModule,
    DoctorModule,
    SkillsModule,
    NutritionModule,
    NotificationModule,
  ],
})
export class AppModule {}
