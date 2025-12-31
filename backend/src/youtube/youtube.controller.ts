import { Controller, Get, Query } from '@nestjs/common';
import { YoutubeService } from './youtube.service';

@Controller('youtube')
export class YoutubeController {
  constructor(private youtubeService: YoutubeService) {}

  @Get('search')
  async searchVideos(
    @Query('q') query: string,
    @Query('maxResults') maxResults = 10,
  ) {
    return this.youtubeService.searchVideos(query, Number(maxResults));
  }
}
