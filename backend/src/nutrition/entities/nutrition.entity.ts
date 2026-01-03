import {
  Column,
  CreateDateColumn,
  Entity,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('nutrition_plans')
export class NutritionPlan {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  user: User;

  @Column()
  title: string;

  @Column('text')
  description: string;

  @Column()
  dietType: 'VEGETARIAN' | 'NON_VEGETARIAN' | 'VEGAN' | 'DIABETIC' | 'LOW_CALORIE';

  @Column()
  goal: 'WEIGHT_LOSS' | 'WEIGHT_GAIN' | 'MUSCLE_BUILDING' | 'RECOVERY' | 'MAINTENANCE';

  @Column({ nullable: true })
  targetCalories: number;

  @Column({ nullable: true })
  targetProteinGrams: number;

  @Column({ nullable: true })
  targetCarbsGrams: number;

  @Column({ nullable: true })
  targetFatsGrams: number;

  @Column({ default: 'ACTIVE' })
  status: 'ACTIVE' | 'COMPLETED' | 'PAUSED';

  @Column({ nullable: true })
  startDate: Date;

  @Column({ nullable: true })
  endDate: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('meal_plans')
export class MealPlan {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => NutritionPlan, { onDelete: 'CASCADE' })
  nutritionPlan: NutritionPlan;

  @Column()
  dayNumber: number; // 1-7 for weekly plan

  @Column()
  mealType: 'BREAKFAST' | 'LUNCH' | 'SNACK' | 'DINNER';

  @Column('simple-array')
  foods: string[];

  @Column({ nullable: true })
  recipeUrl: string;

  @Column({ nullable: true })
  estimatedCalories: number;

  @Column('text', { nullable: true })
  nutritionInfo: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('nutrition_logs')
export class NutritionLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  user: User;

  @Column()
  mealType: 'BREAKFAST' | 'LUNCH' | 'SNACK' | 'DINNER';

  @Column()
  foodItem: string;

  @Column({ nullable: true })
  servingSize: string;

  @Column({ nullable: true })
  estimatedCalories: number;

  @Column({ nullable: true })
  proteinGrams: number;

  @Column({ nullable: true })
  carbsGrams: number;

  @Column({ nullable: true })
  fatsGrams: number;

  @Column({ nullable: true })
  fiberGrams: number;

  @Column({ nullable: true })
  notes: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

@Entity('nutrition_recipes')
export class NutritionRecipe {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column('text')
  description: string;

  @Column('simple-array')
  ingredients: string[];

  @Column('text')
  instructions: string;

  @Column()
  cuisineType: string;

  @Column()
  dietSuitability: string; // VEGETARIAN, VEGAN, LOW_CALORIE, etc.

  @Column({ nullable: true })
  estimatedCalories: number;

  @Column({ nullable: true })
  prepTimeMinutes: number;

  @Column({ nullable: true })
  cookTimeMinutes: number;

  @Column({ nullable: true })
  servings: number;

  @Column({ nullable: true })
  imageUrl: string;

  @Column({ nullable: true })
  videoUrl: string;

  @Column({ default: 0 })
  viewCount: number;

  @Column({ default: 0 })
  favoriteCount: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
