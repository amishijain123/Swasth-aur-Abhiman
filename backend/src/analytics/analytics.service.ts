import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MediaAnalytics } from './entities/media-analytics.entity';
import { VideoBookmark } from './entities/video-bookmark.entity';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(MediaAnalytics)
    private analyticsRepo: Repository<MediaAnalytics>,

    @InjectRepository(VideoBookmark)
    private bookmarkRepo: Repository<VideoBookmark>,
  ) {}

  async trackWatch(mediaId: number, userId: number, watchTimeSeconds: number, completed = false) {
    const entry = this.analyticsRepo.create({
      media: { id: mediaId } as any,
      user: { id: userId } as any,
      watchTimeSeconds,
      completed,
      lastWatchedAt: new Date(),
    });

    return this.analyticsRepo.save(entry);
  }

  async addBookmark(userId: number, mediaId: number, timestampSeconds: number, note?: string) {
    const entry = this.bookmarkRepo.create({
      user: { id: userId } as any,
      media: { id: mediaId } as any,
      timestampSeconds,
      note,
    });

    return this.bookmarkRepo.save(entry);
  }

  async getBookmarksForUserMedia(userId: number, mediaId: number) {
    return this.bookmarkRepo.find({ where: { user: { id: userId } as any, media: { id: mediaId } as any } });
  }
}
