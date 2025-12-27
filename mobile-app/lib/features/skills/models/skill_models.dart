import 'package:hive/hive.dart';

part 'skill_models.g.dart';

@HiveType(typeId: 31)
class SkillVideo extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String? thumbnailUrl;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final int? viewCount;

  @HiveField(7)
  final String? uploadedById;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final int? duration; // in seconds

  SkillVideo({
    required this.id,
    required this.title,
    this.description,
    required this.url,
    this.thumbnailUrl,
    required this.category,
    this.viewCount,
    this.uploadedById,
    required this.createdAt,
    this.duration,
  });

  factory SkillVideo.fromJson(Map<String, dynamic> json) {
    return SkillVideo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      category: json['subcategory'] ?? json['category'] ?? 'Skill',
      viewCount: json['viewCount'] ?? 0,
      uploadedById: json['uploadedBy']?['id'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'viewCount': viewCount,
      'duration': duration,
    };
  }
}

class SkillCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int videoCount;

  const SkillCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.videoCount = 0,
  });

  // PRD-defined skill categories
  static const List<SkillCategory> defaultCategories = [
    SkillCategory(
      id: 'bamboo',
      name: 'Bamboo',
      description: 'Bamboo craft and furniture making',
      iconName: 'grass',
    ),
    SkillCategory(
      id: 'artisan',
      name: 'Artisan',
      description: 'Traditional arts and handicrafts',
      iconName: 'palette',
    ),
    SkillCategory(
      id: 'honeybee',
      name: 'Honeybee',
      description: 'Beekeeping and honey production',
      iconName: 'hive',
    ),
    SkillCategory(
      id: 'jute',
      name: 'Jute',
      description: 'Jute bag and product making',
      iconName: 'shopping_bag',
    ),
    SkillCategory(
      id: 'macrame',
      name: 'Macrame',
      description: 'Macrame art and decoration',
      iconName: 'texture',
    ),
  ];
}
