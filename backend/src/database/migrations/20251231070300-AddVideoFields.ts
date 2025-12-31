import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class AddVideoFields20251231070300 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    if (!(await queryRunner.hasColumn('media_content', 'source'))) {
      await queryRunner.addColumn(
        'media_content',
        new TableColumn({ name: 'source', type: 'varchar', length: '20', isNullable: true }),
      );
    }

    if (!(await queryRunner.hasColumn('media_content', 'externalUrl'))) {
      await queryRunner.addColumn(
        'media_content',
        new TableColumn({ name: 'externalUrl', type: 'text', isNullable: true }),
      );
    }

    if (!(await queryRunner.hasColumn('media_content', 'rating'))) {
      await queryRunner.addColumn(
        'media_content',
        new TableColumn({ name: 'rating', type: 'decimal', precision: 2, scale: 1, isNullable: true }),
      );
    }

    if (!(await queryRunner.hasColumn('media_content', 'difficulty'))) {
      await queryRunner.addColumn(
        'media_content',
        new TableColumn({ name: 'difficulty', type: 'varchar', length: '20', isNullable: true }),
      );
    }

    if (!(await queryRunner.hasColumn('media_content', 'ageGroup'))) {
      await queryRunner.addColumn(
        'media_content',
        new TableColumn({ name: 'ageGroup', type: 'varchar', length: '20', isNullable: true }),
      );
    }

    if (!(await queryRunner.hasColumn('media_content', 'subject'))) {
      await queryRunner.addColumn(
        'media_content',
        new TableColumn({ name: 'subject', type: 'varchar', length: '50', isNullable: true }),
      );
    }

    if (!(await queryRunner.hasColumn('media_content', 'chapter'))) {
      await queryRunner.addColumn(
        'media_content',
        new TableColumn({ name: 'chapter', type: 'varchar', length: '100', isNullable: true }),
      );
    }

    if (!(await queryRunner.hasColumn('media_content', 'language'))) {
      await queryRunner.addColumn(
        'media_content',
        new TableColumn({ name: 'language', type: 'varchar', length: '20', isNullable: true }),
      );
    }

    if (!(await queryRunner.hasColumn('media_content', 'durationSeconds'))) {
      await queryRunner.addColumn(
        'media_content',
        new TableColumn({ name: 'durationSeconds', type: 'integer', isNullable: true }),
      );
    }

    if (!(await queryRunner.hasColumn('media_content', 'isFree'))) {
      await queryRunner.addColumn(
        'media_content',
        new TableColumn({ name: 'isFree', type: 'boolean', isNullable: false, default: true }),
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    if (await queryRunner.hasColumn('media_content', 'isFree')) {
      await queryRunner.dropColumn('media_content', 'isFree');
    }
    if (await queryRunner.hasColumn('media_content', 'durationSeconds')) {
      await queryRunner.dropColumn('media_content', 'durationSeconds');
    }
    if (await queryRunner.hasColumn('media_content', 'language')) {
      await queryRunner.dropColumn('media_content', 'language');
    }
    if (await queryRunner.hasColumn('media_content', 'chapter')) {
      await queryRunner.dropColumn('media_content', 'chapter');
    }
    if (await queryRunner.hasColumn('media_content', 'subject')) {
      await queryRunner.dropColumn('media_content', 'subject');
    }
    if (await queryRunner.hasColumn('media_content', 'ageGroup')) {
      await queryRunner.dropColumn('media_content', 'ageGroup');
    }
    if (await queryRunner.hasColumn('media_content', 'difficulty')) {
      await queryRunner.dropColumn('media_content', 'difficulty');
    }
    if (await queryRunner.hasColumn('media_content', 'rating')) {
      await queryRunner.dropColumn('media_content', 'rating');
    }
    if (await queryRunner.hasColumn('media_content', 'externalUrl')) {
      await queryRunner.dropColumn('media_content', 'externalUrl');
    }
    if (await queryRunner.hasColumn('media_content', 'source')) {
      await queryRunner.dropColumn('media_content', 'source');
    }
  }
}
