import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { MediaContent } from '../../media/entities/media-content.entity';

@Entity('video_bookmarks')
export class VideoBookmark {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  user: User;

  @ManyToOne(() => MediaContent, { onDelete: 'CASCADE' })
  media: MediaContent;

  @Column({ type: 'integer' })
  timestampSeconds: number;

  @Column({ type: 'text', nullable: true })
  note: string;

  @CreateDateColumn()
  createdAt: Date;
}
