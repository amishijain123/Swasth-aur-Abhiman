import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/prescription_provider.dart';
import '../widgets/prescription_card.dart';
import 'upload_prescription_screen.dart';

class PrescriptionsScreen extends ConsumerWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionState = ref.watch(prescriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(prescriptionProvider.notifier).loadPrescriptions(),
          ),
        ],
      ),
      body: prescriptionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prescriptionState.prescriptions.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () => ref.read(prescriptionProvider.notifier).loadPrescriptions(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: prescriptionState.prescriptions.length,
                    itemBuilder: (context, index) {
                      final prescription = prescriptionState.prescriptions[index];
                      return PrescriptionCard(prescription: prescription);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadPrescriptionScreen()),
          );
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Upload Prescription'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No prescriptions yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first prescription to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UploadPrescriptionScreen()),
              );
            },
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Upload Prescription'),
          ),
        ],
      ),
    );
  }
}
