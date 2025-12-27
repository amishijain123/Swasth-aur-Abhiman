import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/media_models.dart';
import '../../events/models/event_models.dart';
import '../repositories/admin_repository.dart';

class AdminState {
  final DashboardStats stats;
  final List<MediaContent> contentList;
  final List<Event> eventsList;
  final List<AdminUser> usersList;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  const AdminState({
    this.stats = const DashboardStats(),
    this.contentList = const [],
    this.eventsList = const [],
    this.usersList = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  AdminState copyWith({
    DashboardStats? stats,
    List<MediaContent>? contentList,
    List<Event>? eventsList,
    List<AdminUser>? usersList,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return AdminState(
      stats: stats ?? this.stats,
      contentList: contentList ?? this.contentList,
      eventsList: eventsList ?? this.eventsList,
      usersList: usersList ?? this.usersList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repository;

  AdminNotifier(this._repository) : super(const AdminState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final stats = await _repository.getDashboardStats();
      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadContent(String category) async {
    state = state.copyWith(isLoading: true, selectedCategory: category);
    try {
      final content = await _repository.getContentByCategory(category);
      state = state.copyWith(contentList: content, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true);
    try {
      final events = await _repository.getAllEvents();
      state = state.copyWith(eventsList: events, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadUsers({String? role, String? block}) async {
    state = state.copyWith(isLoading: true);
    try {
      final users = await _repository.getUsers(role: role, block: block);
      state = state.copyWith(usersList: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> uploadContent({
    required String title,
    required String description,
    required String category,
    required String subcategory,
    required String mediaUrl,
    String? thumbnailUrl,
  }) async {
    try {
      await _repository.uploadContent(
        title: title,
        description: description,
        category: category,
        subcategory: subcategory,
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
      );
      // Refresh content list
      await loadContent(category);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteContent(String id) async {
    try {
      await _repository.deleteContent(id);
      final updated = state.contentList.where((c) => c.id != id).toList();
      state = state.copyWith(contentList: updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> createEvent(Event event) async {
    try {
      final newEvent = await _repository.createEvent(event);
      state = state.copyWith(eventsList: [...state.eventsList, newEvent]);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteEvent(String id) async {
    try {
      await _repository.deleteEvent(id);
      final updated = state.eventsList.where((e) => e.id != id).toList();
      state = state.copyWith(eventsList: updated);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminNotifier(repository);
});
