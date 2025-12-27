import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../education/models/education_models.dart';

class TeacherRepository {
  final ApiService _apiService;

  TeacherRepository(this._apiService);

  // Get education content uploaded by this teacher
  Future<List<EducationVideo>> getMyContent({String? category}) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;

      final response = await _apiService.get(
        '/media/teacher',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((v) => EducationVideo.fromJson(v))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Upload new education content
  Future<EducationVideo?> uploadContent({
    required String title,
    required String description,
    required String category,
    required String subcategory,
    required String videoUrl,
    String? thumbnailUrl,
  }) async {
    try {
      final response = await _apiService.post(
        '/media',
        data: {
          'title': title,
          'description': description,
          'category': 'EDUCATION',
          'subcategory': subcategory,
          'url': videoUrl,
          'thumbnailUrl': thumbnailUrl,
        },
      );
      return EducationVideo.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Update content
  Future<EducationVideo?> updateContent({
    required String id,
    String? title,
    String? description,
    String? subcategory,
  }) async {
    try {
      final response = await _apiService.put(
        '/media/$id',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (subcategory != null) 'subcategory': subcategory,
        },
      );
      return EducationVideo.fromJson(response.data);
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

  // Get teacher stats
  Future<TeacherStats> getStats() async {
    try {
      final response = await _apiService.get('/media/teacher/stats');
      return TeacherStats.fromJson(response.data);
    } catch (e) {
      return const TeacherStats();
    }
  }

  // Get student engagement
  Future<List<StudentEngagement>> getStudentEngagement() async {
    try {
      final response = await _apiService.get('/media/teacher/engagement');
      return (response.data as List)
          .map((e) => StudentEngagement.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

class TeacherStats {
  final int totalContent;
  final int totalViews;
  final int thisMonthViews;
  final Map<String, int> byCategory;

  const TeacherStats({
    this.totalContent = 0,
    this.totalViews = 0,
    this.thisMonthViews = 0,
    this.byCategory = const {},
  });

  factory TeacherStats.fromJson(Map<String, dynamic> json) {
    return TeacherStats(
      totalContent: json['totalContent'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      thisMonthViews: json['thisMonthViews'] ?? 0,
      byCategory: Map<String, int>.from(json['byCategory'] ?? {}),
    );
  }
}

class StudentEngagement {
  final String date;
  final int views;
  final int uniqueStudents;

  const StudentEngagement({
    required this.date,
    required this.views,
    required this.uniqueStudents,
  });

  factory StudentEngagement.fromJson(Map<String, dynamic> json) {
    return StudentEngagement(
      date: json['date'],
      views: json['views'] ?? 0,
      uniqueStudents: json['uniqueStudents'] ?? 0,
    );
  }
}

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TeacherRepository(apiService);
});
