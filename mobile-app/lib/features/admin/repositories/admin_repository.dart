import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/media_models.dart';
import '../../events/models/event_models.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository(this._apiService);

  // ========== Statistics ==========
  Future<DashboardStats> getDashboardStats() async {
    try {
      final response = await _apiService.get('/admin/stats');
      return DashboardStats.fromJson(response.data);
    } catch (e) {
      return const DashboardStats();
    }
  }

  // ========== Content Management ==========
  Future<List<MediaContent>> getContentByCategory(String category) async {
    try {
      final response = await _apiService.get(
        '/media',
        queryParameters: {'category': category},
      );
      return (response.data as List)
          .map((m) => MediaContent.fromJson(m))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<MediaContent> uploadContent({
    required String title,
    required String description,
    required String category,
    required String subcategory,
    required String mediaUrl,
    String? thumbnailUrl,
    String contentType = 'VIDEO',
  }) async {
    final response = await _apiService.post(
      '/media',
      data: {
        'title': title,
        'description': description,
        'category': category,
        'subcategory': subcategory,
        'mediaUrl': mediaUrl,
        'thumbnailUrl': thumbnailUrl,
        'contentType': contentType,
      },
    );
    return MediaContent.fromJson(response.data);
  }

  Future<void> deleteContent(String id) async {
    await _apiService.delete('/media/$id');
  }

  // ========== Event Management ==========
  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _apiService.get('/events');
      return (response.data as List)
          .map((e) => Event.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Event> createEvent(Event event) async {
    final response = await _apiService.post(
      '/events',
      data: event.toJson(),
    );
    return Event.fromJson(response.data);
  }

  Future<Event> updateEvent(String id, Event event) async {
    final response = await _apiService.put(
      '/events/$id',
      data: event.toJson(),
    );
    return Event.fromJson(response.data);
  }

  Future<void> deleteEvent(String id) async {
    await _apiService.delete('/events/$id');
  }

  // ========== User Management ==========
  Future<List<AdminUser>> getUsers({String? role, String? block}) async {
    try {
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;
      if (block != null) queryParams['block'] = block;

      final response = await _apiService.get(
        '/users',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((u) => AdminUser.fromJson(u))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    await _apiService.put(
      '/users/$userId/role',
      data: {'role': newRole},
    );
  }
}

class DashboardStats {
  final int totalUsers;
  final int totalDoctors;
  final int totalTeachers;
  final int totalTrainers;
  final int totalContent;
  final int totalEvents;
  final int totalPrescriptions;
  final int pendingPrescriptions;
  final Map<String, int> usersByBlock;
  final Map<String, int> contentByCategory;

  const DashboardStats({
    this.totalUsers = 0,
    this.totalDoctors = 0,
    this.totalTeachers = 0,
    this.totalTrainers = 0,
    this.totalContent = 0,
    this.totalEvents = 0,
    this.totalPrescriptions = 0,
    this.pendingPrescriptions = 0,
    this.usersByBlock = const {},
    this.contentByCategory = const {},
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalDoctors: json['totalDoctors'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      totalTrainers: json['totalTrainers'] ?? 0,
      totalContent: json['totalContent'] ?? 0,
      totalEvents: json['totalEvents'] ?? 0,
      totalPrescriptions: json['totalPrescriptions'] ?? 0,
      pendingPrescriptions: json['pendingPrescriptions'] ?? 0,
      usersByBlock: Map<String, int>.from(json['usersByBlock'] ?? {}),
      contentByCategory: Map<String, int>.from(json['contentByCategory'] ?? {}),
    );
  }
}

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? block;
  final bool isActive;
  final DateTime createdAt;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.block,
    this.isActive = true,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'],
      block: json['block'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AdminRepository(apiService);
});
