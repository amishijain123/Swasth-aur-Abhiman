import { Module } from '@nestjs/common';
import { ThrottlerModule } from '@nestjs/throttler';
import { CacheModule } from '@nestjs/cache-manager';
import { TerminusModule } from '@nestjs/terminus';
import { HealthCheckController } from '../health/health-check.controller';
import { LoggerService } from './logger/logger.service';

@Module({
  imports: [
    // Rate limiting
    ThrottlerModule.forRoot([
      {
        name: 'short',
        ttl: 1000,
        limit: 10, // 10 requests per second
      },
      {
        name: 'medium',
        ttl: 10000,
        limit: 100, // 100 requests per 10 seconds
      },
      {
        name: 'long',
        ttl: 60000,
        limit: 500, // 500 requests per minute
      },
    ]),

    // Caching Module (Memory-based, compatible with @nestjs/cache-manager)
    CacheModule.register({
      isGlobal: true,
      ttl: 300, // 5 minutes default
      max: 100, // maximum number of items in cache
    }),

    // Health checks
    TerminusModule,
  ],
  controllers: [HealthCheckController],
  providers: [LoggerService],
  exports: [LoggerService],
})
export class CommonModule {}
