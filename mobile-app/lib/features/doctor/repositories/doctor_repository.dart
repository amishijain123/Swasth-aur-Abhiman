import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../prescriptions/models/prescription_models.dart';

class DoctorRepository {
  final ApiService _apiService;

  DoctorRepository(this._apiService);

  // Get all prescriptions for doctor to review
  Future<List<Prescription>> getPrescriptions({
    String? status,
    String? block,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (block != null) queryParams['block'] = block;

      final response = await _apiService.get(
        '/prescriptions/doctor',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((p) => Prescription.fromJson(p))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Get prescription details
  Future<Prescription?> getPrescriptionById(String id) async {
    try {
      final response = await _apiService.get('/prescriptions/$id');
      return Prescription.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Review a prescription
  Future<Prescription?> reviewPrescription({
    required String id,
    required String status, // REVIEWED, NEEDS_FOLLOWUP
    String? doctorNotes,
    String? suggestedMedicines,
  }) async {
    try {
      final response = await _apiService.put(
        '/prescriptions/$id/review',
        data: {
          'status': status,
          'doctorNotes': doctorNotes,
          'suggestedMedicines': suggestedMedicines,
          'reviewedAt': DateTime.now().toIso8601String(),
        },
      );
      return Prescription.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  // Get doctor's statistics
  Future<DoctorStats> getStats() async {
    try {
      final response = await _apiService.get('/prescriptions/doctor/stats');
      return DoctorStats.fromJson(response.data);
    } catch (e) {
      return const DoctorStats();
    }
  }

  // Get patients for doctor
  Future<List<PatientInfo>> getPatients({String? block}) async {
    try {
      final queryParams = <String, String>{};
      if (block != null) queryParams['block'] = block;

      final response = await _apiService.get(
        '/doctor/patients',
        queryParameters: queryParams,
      );
      return (response.data as List)
          .map((p) => PatientInfo.fromJson(p))
          .toList();
    } catch (e) {
      return [];
    }
  }
}

class DoctorStats {
  final int totalReviewed;
  final int pendingReview;
  final int needsFollowup;
  final int todayReviewed;
  final Map<String, int> byBlock;

  const DoctorStats({
    this.totalReviewed = 0,
    this.pendingReview = 0,
    this.needsFollowup = 0,
    this.todayReviewed = 0,
    this.byBlock = const {},
  });

  factory DoctorStats.fromJson(Map<String, dynamic> json) {
    return DoctorStats(
      totalReviewed: json['totalReviewed'] ?? 0,
      pendingReview: json['pendingReview'] ?? 0,
      needsFollowup: json['needsFollowup'] ?? 0,
      todayReviewed: json['todayReviewed'] ?? 0,
      byBlock: Map<String, int>.from(json['byBlock'] ?? {}),
    );
  }
}

class PatientInfo {
  final String id;
  final String name;
  final String phone;
  final String? block;
  final int age;
  final String gender;
  final int prescriptionCount;
  final DateTime? lastVisit;

  const PatientInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.block,
    required this.age,
    required this.gender,
    this.prescriptionCount = 0,
    this.lastVisit,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      id: json['id'],
      name: json['name'],
      phone: json['phone'] ?? '',
      block: json['block'],
      age: json['age'] ?? 0,
      gender: json['gender'] ?? 'Unknown',
      prescriptionCount: json['prescriptionCount'] ?? 0,
      lastVisit:
          json['lastVisit'] != null ? DateTime.parse(json['lastVisit']) : null,
    );
  }
}

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return DoctorRepository(apiService);
});
