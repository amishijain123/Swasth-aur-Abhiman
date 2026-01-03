import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { MediaContent } from '../../media/entities/media-content.entity';
import { User } from '../../users/entities/user.entity';

@Entity('skill_enrollments')
export class SkillEnrollment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('uuid')
  courseId: string;

  @ManyToOne(() => MediaContent, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'courseId' })
  course: MediaContent;

  @Column('uuid')
  studentId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'studentId' })
  student: User;

  @Column('decimal', { precision: 5, scale: 2, default: 0 })
  completionPercentage: number;

  @Column('varchar', { length: 50, default: 'in-progress' })
  status: 'in-progress' | 'completed' | 'dropped';

  @Column('integer', { default: 0 })
  watchDurationMinutes: number;

  @CreateDateColumn()
  enrolledAt: Date;

  @UpdateDateColumn()
  lastAccessedAt: Date;

  @Column('timestamp', { nullable: true })
  completedAt: Date | null;
}
