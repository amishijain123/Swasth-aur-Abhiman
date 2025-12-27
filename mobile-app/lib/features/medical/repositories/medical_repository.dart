import 'package:dio/dio.dart';
import '../models/health_models.dart';

class MedicalRepository {
  final Dio _dio;

  MedicalRepository(this._dio);

  Future<HealthMetrics> getHealthMetrics() async {
    try {
      final response = await _dio.get('/users/health-metrics');
      return HealthMetrics.fromJson(response.data);
    } catch (e) {
      // Return empty metrics if API fails (for offline support)
      return HealthMetrics();
    }
  }

  Future<void> addBPReading(BPReading reading) async {
    await _dio.post('/users/health-metrics/bp', data: reading.toJson());
  }

  Future<void> addSugarReading(SugarReading reading) async {
    await _dio.post('/users/health-metrics/sugar', data: reading.toJson());
  }

  Future<void> addBMIReading(BMIReading reading) async {
    await _dio.post('/users/health-metrics/bmi', data: reading.toJson());
  }

  Future<void> updateHealthMetrics(HealthMetrics metrics) async {
    await _dio.put('/users/health-metrics', data: metrics.toJson());
  }
}
