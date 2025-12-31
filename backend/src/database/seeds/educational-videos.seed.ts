import { DataSource } from 'typeorm';
import { MediaContent } from '../../media/entities/media-content.entity';

export const educationalVideos = [
  // CLASS 10 - MATHEMATICS
  {
    title: 'Quadratic Equations - Introduction & Basics',
    description: 'Complete introduction to quadratic equations with solved examples',
    source: 'youtube',
    externalUrl: 'https://www.youtube.com/watch?v=ACTUAL_VIDEO_ID_1',
    thumbnailUrl: 'https://img.youtube.com/vi/ACTUAL_VIDEO_ID_1/maxresdefault.jpg',
    category: 'EDUCATION',
    subCategory: 'Mathematics',
    ageGroup: 'Class 10',
    subject: 'Mathematics',
    chapter: 'Quadratic Equations',
    difficulty: 'Beginner',
    durationSeconds: 720,
    language: 'English',
    isFree: true,
    tags: ['ncert', 'cbse', 'class10', 'maths'],
  },
  {
    title: 'Chemical Reactions and Equations',
    description: 'Understanding chemical reactions with real-life examples',
    source: 'youtube',
    externalUrl: 'https://www.youtube.com/watch?v=ACTUAL_VIDEO_ID_2',
    thumbnailUrl: 'https://img.youtube.com/vi/ACTUAL_VIDEO_ID_2/maxresdefault.jpg',
    category: 'EDUCATION',
    subCategory: 'Science',
    ageGroup: 'Class 10',
    subject: 'Science',
    chapter: 'Chemical Reactions',
    difficulty: 'Beginner',
    durationSeconds: 900,
    language: 'Hinglish',
    isFree: true,
    tags: ['ncert', 'cbse', 'class10', 'science'],
  },
  // CLASS 9 - MATHEMATICS (sample entries)
  {
    title: 'Linear Equations - Solving Methods',
    description: 'Methods to solve linear equations with examples',
    source: 'youtube',
    externalUrl: 'https://www.youtube.com/watch?v=ACTUAL_VIDEO_ID_3',
    thumbnailUrl: 'https://img.youtube.com/vi/ACTUAL_VIDEO_ID_3/maxresdefault.jpg',
    category: 'EDUCATION',
    subCategory: 'Mathematics',
    ageGroup: 'Class 9',
    subject: 'Mathematics',
    chapter: 'Linear Equations',
    difficulty: 'Beginner',
    durationSeconds: 600,
    language: 'Hindi',
    isFree: true,
    tags: ['ncert', 'cbse', 'class9', 'maths'],
  },
  {
    title: 'Motion - Basic Concepts',
    description: 'Kinematics basics explained with examples',
    source: 'youtube',
    externalUrl: 'https://www.youtube.com/watch?v=ACTUAL_VIDEO_ID_4',
    thumbnailUrl: 'https://img.youtube.com/vi/ACTUAL_VIDEO_ID_4/maxresdefault.jpg',
    category: 'EDUCATION',
    subCategory: 'Science',
    ageGroup: 'Class 9',
    subject: 'Science',
    chapter: 'Motion',
    difficulty: 'Beginner',
    durationSeconds: 780,
    language: 'English',
    isFree: true,
    tags: ['ncert', 'cbse', 'class9', 'science'],
  },

  // NOTE: Add additional videos for all classes 1-12. This file contains sample entries for demonstration.
  // To fully follow the project spec, populate this array with 100+ curated free educational videos (Khan Academy India, Physics Wallah, Vedantu, Magnet Brains, etc.).
];

export async function seedEducationalVideos(dataSource: DataSource) {
  const repo = dataSource.getRepository(MediaContent);

  for (const v of educationalVideos) {
    const exists = await repo.findOne({ where: { externalUrl: v.externalUrl } });
    if (!exists) {
      const entry = repo.create({
        title: v.title,
        description: v.description,
        source: v.source,
        externalUrl: v.externalUrl,
        // Use externalUrl as mediaUrl for YouTube videos to satisfy non-null constraint
        mediaUrl: v.externalUrl ?? '',
        thumbnailUrl: v.thumbnailUrl,
        category: v.category as any,
        subCategory: v.subCategory,
        ageGroup: v.ageGroup,
        subject: v.subject,
        chapter: v.chapter,
        difficulty: v.difficulty,
        durationSeconds: v.durationSeconds,
        language: v.language,
        isFree: v.isFree,
        viewCount: 0,
        isActive: true,
      });
      await repo.save(entry);
    }
  }
}
