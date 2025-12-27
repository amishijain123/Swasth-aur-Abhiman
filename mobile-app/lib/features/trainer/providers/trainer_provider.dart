import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../skills/models/skill_models.dart';
import '../repositories/trainer_repository.dart';

class TrainerState {
  final List<SkillVideo> content;
  final List<TrainingSession> sessions;
  final TrainerStats stats;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  const TrainerState({
    this.content = const [],
    this.sessions = const [],
    this.stats = const TrainerStats(),
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  TrainerState copyWith({
    List<SkillVideo>? content,
    List<TrainingSession>? sessions,
    TrainerStats? stats,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return TrainerState(
      content: content ?? this.content,
      sessions: sessions ?? this.sessions,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  List<TrainingSession> get upcomingSessions =>
      sessions.where((s) => s.isUpcoming).toList();

  List<TrainingSession> get pastSessions =>
      sessions.where((s) => !s.isUpcoming).toList();
}

class TrainerNotifier extends StateNotifier<TrainerState> {
  final TrainerRepository _repository;

  TrainerNotifier(this._repository) : super(const TrainerState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final stats = await _repository.getStats();
      final content = await _repository.getMyContent();
      final sessions = await _repository.getTrainingSessions();

      state = state.copyWith(
        stats: stats,
        content: content,
        sessions: sessions,
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

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true);
    try {
      final sessions = await _repository.getTrainingSessions();
      state = state.copyWith(
        sessions: sessions,
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
    required String videoUrl,
    String? thumbnailUrl,
  }) async {
    try {
      final result = await _repository.uploadContent(
        title: title,
        description: description,
        category: category,
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

  Future<bool> scheduleSession({
    required String title,
    required String description,
    required String category,
    required String block,
    required DateTime dateTime,
    required String location,
  }) async {
    try {
      final result = await _repository.scheduleSession(
        title: title,
        description: description,
        category: category,
        block: block,
        dateTime: dateTime,
        location: location,
      );

      if (result != null) {
        final updated = [result, ...state.sessions];
        state = state.copyWith(sessions: updated);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final trainerProvider = StateNotifierProvider<TrainerNotifier, TrainerState>((ref) {
  final repository = ref.watch(trainerRepositoryProvider);
  return TrainerNotifier(repository);
});
