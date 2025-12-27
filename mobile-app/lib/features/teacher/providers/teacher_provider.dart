import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../education/models/education_models.dart';
import '../repositories/teacher_repository.dart';

class TeacherState {
  final List<EducationVideo> content;
  final List<StudentEngagement> engagement;
  final TeacherStats stats;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  const TeacherState({
    this.content = const [],
    this.engagement = const [],
    this.stats = const TeacherStats(),
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  TeacherState copyWith({
    List<EducationVideo>? content,
    List<StudentEngagement>? engagement,
    TeacherStats? stats,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return TeacherState(
      content: content ?? this.content,
      engagement: engagement ?? this.engagement,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class TeacherNotifier extends StateNotifier<TeacherState> {
  final TeacherRepository _repository;

  TeacherNotifier(this._repository) : super(const TeacherState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final stats = await _repository.getStats();
      final content = await _repository.getMyContent();
      final engagement = await _repository.getStudentEngagement();

      state = state.copyWith(
        stats: stats,
        content: content,
        engagement: engagement,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadContent({String? category}) async {
    state = state.copyWith(isLoading: true, selectedCategory: category);
    try {
      final content = await _repository.getMyContent(category: category);
      state = state.copyWith(
        content: content,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> uploadContent({
    required String title,
    required String description,
    required String category,
    required String subcategory,
    required String videoUrl,
    String? thumbnailUrl,
  }) async {
    try {
      final result = await _repository.uploadContent(
        title: title,
        description: description,
        category: category,
        subcategory: subcategory,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );

      if (result != null) {
        final updated = [result, ...state.content];
        state = state.copyWith(content: updated);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateContent({
    required String id,
    String? title,
    String? description,
    String? subcategory,
  }) async {
    try {
      final result = await _repository.updateContent(
        id: id,
        title: title,
        description: description,
        subcategory: subcategory,
      );

      if (result != null) {
        final updated = state.content.map((c) {
          if (c.id == id) return result;
          return c;
        }).toList();
        state = state.copyWith(content: updated);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteContent(String id) async {
    try {
      final success = await _repository.deleteContent(id);
      if (success) {
        final updated = state.content.where((c) => c.id != id).toList();
        state = state.copyWith(content: updated);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final teacherProvider = StateNotifierProvider<TeacherNotifier, TeacherState>((ref) {
  final repository = ref.watch(teacherRepositoryProvider);
  return TeacherNotifier(repository);
});
