import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { MediaCategory } from '../../common/enums/media.enum';

@Entity('media_content')
export class MediaContent {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ type: 'text' })
  description: string;

  @Column({
    type: 'enum',
    enum: MediaCategory,
  })
  category: MediaCategory;

  @Column({ nullable: true })
  subCategory: string;

  @Column()
  mediaUrl: string;

  @Column({ nullable: true })
  thumbnailUrl: string;

  @Column({ default: 0 })
  viewCount: number;

  @Column({ default: true })
  isActive: boolean;

  @ManyToOne(() => User)
  @JoinColumn()
  uploadedBy: User;

  @CreateDateColumn()
  createdAt: Date;
}
