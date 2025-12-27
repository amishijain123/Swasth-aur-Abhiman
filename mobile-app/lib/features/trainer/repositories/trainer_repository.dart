import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../skills/models/skill_models.dart';

class TrainerRepository {
  final ApiService _apiService;

  TrainerRepository(this._apiService);

  // Get skills content uploaded by this trainer
  Future<List<SkillVideo>> getMyContent({String? category}) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;

      final response = await _apiService.get(
        '/media/trainer',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((v) => SkillVideo.fromJson(v))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Upload new skills content
  Future<SkillVideo?> uploadContent({
    required String title,
    required String description,
    required String category,
    required String videoUrl,
    String? thumbnailUrl,
  }) async {
    try {
      final response = await _apiService.post(
        '/media',
        data: {
          'title': title,
          'description': description,
          'category': 'SKILL',
          'subcategory': category,
          'url': videoUrl,
          'thumbnailUrl': thumbnailUrl,
        },
      );
      return SkillVideo.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Update content
  Future<SkillVideo?> updateContent({
    required String id,
    String? title,
    String? description,
    String? category,
  }) async {
    try {
      final response = await _apiService.put(
        '/media/$id',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (category != null) 'subcategory': category,
        },
      );
      return SkillVideo.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Delete content
  Future<bool> deleteContent(String id) async {
    try {
      await _apiService.delete('/media/$id');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get trainer stats
  Future<TrainerStats> getStats() async {
    try {
      final response = await _apiService.get('/media/trainer/stats');
      return TrainerStats.fromJson(response.data);
    } catch (e) {
      return const TrainerStats();
    }
  }

  // Get training sessions
  Future<List<TrainingSession>> getTrainingSessions() async {
    try {
      final response = await _apiService.get('/trainer/sessions');
      return (response.data as List)
          .map((s) => TrainingSession.fromJson(s))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Schedule a training session
  Future<TrainingSession?> scheduleSession({
    required String title,
    required String description,
    required String category,
    required String block,
    required DateTime dateTime,
    required String location,
  }) async {
    try {
      final response = await _apiService.post(
        '/trainer/sessions',
        data: {
          'title': title,
          'description': description,
          'category': category,
          'block': block,
          'dateTime': dateTime.toIso8601String(),
          'location': location,
        },
      );
      return TrainingSession.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}

class TrainerStats {
  final int totalContent;
  final int totalViews;
  final int sessionsCompleted;
  final int upcomingSessions;
  final Map<String, int> byCategory;

  const TrainerStats({
    this.totalContent = 0,
    this.totalViews = 0,
    this.sessionsCompleted = 0,
    this.upcomingSessions = 0,
    this.byCategory = const {},
  });

  factory TrainerStats.fromJson(Map<String, dynamic> json) {
    return TrainerStats(
      totalContent: json['totalContent'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      sessionsCompleted: json['sessionsCompleted'] ?? 0,
      upcomingSessions: json['upcomingSessions'] ?? 0,
      byCategory: Map<String, int>.from(json['byCategory'] ?? {}),
    );
  }
}

class TrainingSession {
  final String id;
  final String title;
  final String description;
  final String category;
  final String block;
  final DateTime dateTime;
  final String location;
  final String status; // SCHEDULED, IN_PROGRESS, COMPLETED, CANCELLED
  final int enrolledCount;

  const TrainingSession({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.block,
    required this.dateTime,
    required this.location,
    required this.status,
    this.enrolledCount = 0,
  });

  factory TrainingSession.fromJson(Map<String, dynamic> json) {
    return TrainingSession(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'],
      block: json['block'],
      dateTime: DateTime.parse(json['dateTime']),
      location: json['location'],
      status: json['status'] ?? 'SCHEDULED',
      enrolledCount: json['enrolledCount'] ?? 0,
    );
  }

  bool get isUpcoming => dateTime.isAfter(DateTime.now());
}

final trainerRepositoryProvider = Provider<TrainerRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TrainerRepository(apiService);
});
