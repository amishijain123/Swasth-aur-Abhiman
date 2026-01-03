import {
  Column,
  CreateDateColumn,
  Entity,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  recipient: User;

  @Column()
  title: string;

  @Column('text')
  message: string;

  @Column({ nullable: true })
  imageUrl: string;

  @Column()
  type:
    | 'MESSAGE'
    | 'HEALTH_ALERT'
    | 'PRESCRIPTION'
    | 'ASSIGNMENT'
    | 'SKILL_CERTIFICATION'
    | 'APPOINTMENT'
    | 'GENERAL';

  @Column({ nullable: true })
  actionUrl: string;

  @Column({ default: false })
  isRead: boolean;

  @Column({ nullable: true })
  readAt: Date;

  @Column({ default: false })
  isPinned: boolean;

  @Column({ nullable: true })
  expiresAt: Date;

  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn()
  createdAt: Date;
}
