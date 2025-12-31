import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, CreateDateColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { MediaContent } from '../../media/entities/media-content.entity';

@Entity('media_analytics')
export class MediaAnalytics {
  @PrimaryGeneratedColumn()
  id: number;

  @ManyToOne(() => MediaContent, { onDelete: 'CASCADE' })
  media: MediaContent;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  user: User;

  @Column({ type: 'integer' })
  watchTimeSeconds: number;

  @Column({ type: 'boolean', default: false })
  completed: boolean;

  @Column({ type: 'timestamp', nullable: true })
  lastWatchedAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}
