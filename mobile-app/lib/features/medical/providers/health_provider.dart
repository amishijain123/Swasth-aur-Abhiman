import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/storage_service.dart';
import '../models/health_models.dart';
import '../repositories/medical_repository.dart';

final medicalRepositoryProvider = Provider<MedicalRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return MedicalRepository(dio);
});

class HealthState {
  final HealthMetrics metrics;
  final bool isLoading;
  final String? error;

  HealthState({
    required this.metrics,
    this.isLoading = false,
    this.error,
  });

  HealthState copyWith({
    HealthMetrics? metrics,
    bool? isLoading,
    String? error,
  }) {
    return HealthState(
      metrics: metrics ?? this.metrics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HealthNotifier extends StateNotifier<HealthState> {
  final MedicalRepository _repository;
  final StorageService _storageService;
  static const String _localStorageKey = 'health_metrics';

  HealthNotifier(this._repository, this._storageService)
      : super(HealthState(metrics: HealthMetrics())) {
    _loadHealthMetrics();
  }

  Future<void> _loadHealthMetrics() async {
    state = state.copyWith(isLoading: true);

    try {
      // First try to load from local storage for offline support
      final localData = await _storageService.getMap(_localStorageKey);
      if (localData != null) {
        state = state.copyWith(
          metrics: HealthMetrics.fromJson(localData),
          isLoading: false,
        );
      }

      // Then try to sync with server
      final metrics = await _repository.getHealthMetrics();
      state = state.copyWith(metrics: metrics, isLoading: false);
      
      // Save to local storage
      await _storageService.saveMap(_localStorageKey, metrics.toJson());
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBPReading(int systolic, int diastolic, int? pulse) async {
    final reading = BPReading(
      date: DateTime.now(),
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
    );

    final updatedMetrics = HealthMetrics(
      bpHistory: [...state.metrics.bpHistory, reading],
      sugarHistory: state.metrics.sugarHistory,
      bmiHistory: state.metrics.bmiHistory,
    );

    state = state.copyWith(metrics: updatedMetrics);
    await _saveLocally(updatedMetrics);

    try {
      await _repository.addBPReading(reading);
    } catch (e) {
      // Offline - data saved locally
    }
  }

  Future<void> addSugarReading(double level, String type) async {
    final reading = SugarReading(
      date: DateTime.now(),
      level: level,
      type: type,
    );

    final updatedMetrics = HealthMetrics(
      bpHistory: state.metrics.bpHistory,
      sugarHistory: [...state.metrics.sugarHistory, reading],
      bmiHistory: state.metrics.bmiHistory,
    );

    state = state.copyWith(metrics: updatedMetrics);
    await _saveLocally(updatedMetrics);

    try {
      await _repository.addSugarReading(reading);
    } catch (e) {
      // Offline - data saved locally
    }
  }

  Future<void> addBMIReading(double weight, double height) async {
    final bmi = BMIReading.calculateBMI(weight, height);
    final reading = BMIReading(
      date: DateTime.now(),
      weight: weight,
      height: height,
      bmi: bmi,
    );

    final updatedMetrics = HealthMetrics(
      bpHistory: state.metrics.bpHistory,
      sugarHistory: state.metrics.sugarHistory,
      bmiHistory: [...state.metrics.bmiHistory, reading],
    );

    state = state.copyWith(metrics: updatedMetrics);
    await _saveLocally(updatedMetrics);

    try {
      await _repository.addBMIReading(reading);
    } catch (e) {
      // Offline - data saved locally
    }
  }

  Future<void> _saveLocally(HealthMetrics metrics) async {
    await _storageService.saveMap(_localStorageKey, metrics.toJson());
  }

  Future<void> refresh() async {
    await _loadHealthMetrics();
  }
}

final healthProvider = StateNotifierProvider<HealthNotifier, HealthState>((ref) {
  final repository = ref.watch(medicalRepositoryProvider);
  final storageService = ref.watch(storageServiceProvider);
  return HealthNotifier(repository, storageService);
});
