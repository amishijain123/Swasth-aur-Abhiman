import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MediaContent } from './entities/media-content.entity';
import { CreateMediaDto } from './dto/create-media.dto';
import { MediaCategory } from '../common/enums/media.enum';
import { User } from '../users/entities/user.entity';

@Injectable()
export class MediaService {
  constructor(
    @InjectRepository(MediaContent)
    private mediaRepository: Repository<MediaContent>,
  ) {}

  async createMedia(createMediaDto: CreateMediaDto, user: User) {
    const media = this.mediaRepository.create({
      ...createMediaDto,
      uploadedBy: user,
    });

    return this.mediaRepository.save(media);
  }

  async getAllMedia(category?: MediaCategory) {
    const query = this.mediaRepository.createQueryBuilder('media')
      .where('media.isActive = :isActive', { isActive: true })
      .orderBy('media.createdAt', 'DESC');

    if (category) {
      query.andWhere('media.category = :category', { category });
    }

    return query.getMany();
  }

  async getMediaBySubCategory(category: MediaCategory, subCategory: string) {
    return this.mediaRepository.find({
      where: { category, subCategory, isActive: true },
      order: { createdAt: 'DESC' },
    });
  }

  async incrementViewCount(mediaId: string) {
    const media = await this.mediaRepository.findOne({ where: { id: mediaId } });
    if (media) {
      media.viewCount += 1;
      return this.mediaRepository.save(media);
    }
    return null;
  }
}
