import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../prescriptions/models/prescription_models.dart';
import '../repositories/doctor_repository.dart';

class DoctorState {
  final List<Prescription> prescriptions;
  final List<PatientInfo> patients;
  final DoctorStats stats;
  final bool isLoading;
  final String? error;
  final String? selectedStatus;
  final String? selectedBlock;

  const DoctorState({
    this.prescriptions = const [],
    this.patients = const [],
    this.stats = const DoctorStats(),
    this.isLoading = false,
    this.error,
    this.selectedStatus,
    this.selectedBlock,
  });

  DoctorState copyWith({
    List<Prescription>? prescriptions,
    List<PatientInfo>? patients,
    DoctorStats? stats,
    bool? isLoading,
    String? error,
    String? selectedStatus,
    String? selectedBlock,
  }) {
    return DoctorState(
      prescriptions: prescriptions ?? this.prescriptions,
      patients: patients ?? this.patients,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedBlock: selectedBlock ?? this.selectedBlock,
    );
  }

  List<Prescription> get pendingPrescriptions =>
      prescriptions.where((p) => p.status == 'PENDING').toList();

  List<Prescription> get reviewedPrescriptions =>
      prescriptions.where((p) => p.status == 'REVIEWED').toList();
}

class DoctorNotifier extends StateNotifier<DoctorState> {
  final DoctorRepository _repository;

  DoctorNotifier(this._repository) : super(const DoctorState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final stats = await _repository.getStats();
      final prescriptions = await _repository.getPrescriptions();
      
      prescriptions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = state.copyWith(
        stats: stats,
        prescriptions: prescriptions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadPrescriptions({String? status, String? block}) async {
    state = state.copyWith(
      isLoading: true,
      selectedStatus: status,
      selectedBlock: block,
    );
    try {
      final prescriptions = await _repository.getPrescriptions(
        status: status,
        block: block,
      );
      state = state.copyWith(
        prescriptions: prescriptions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadPatients({String? block}) async {
    state = state.copyWith(isLoading: true);
    try {
      final patients = await _repository.getPatients(block: block);
      state = state.copyWith(
        patients: patients,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> reviewPrescription({
    required String id,
    required String status,
    String? doctorNotes,
    String? suggestedMedicines,
  }) async {
    try {
      final result = await _repository.reviewPrescription(
        id: id,
        status: status,
        doctorNotes: doctorNotes,
        suggestedMedicines: suggestedMedicines,
      );

      if (result != null) {
        // Update local state
        final updated = state.prescriptions.map((p) {
          if (p.id == id) {
            return result;
          }
          return p;
        }).toList();

        state = state.copyWith(prescriptions: updated);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void filterByStatus(String? status) {
    loadPrescriptions(status: status, block: state.selectedBlock);
  }

  void filterByBlock(String? block) {
    loadPrescriptions(status: state.selectedStatus, block: block);
  }
}

final doctorProvider = StateNotifierProvider<DoctorNotifier, DoctorState>((ref) {
  final repository = ref.watch(doctorRepositoryProvider);
  return DoctorNotifier(repository);
});
