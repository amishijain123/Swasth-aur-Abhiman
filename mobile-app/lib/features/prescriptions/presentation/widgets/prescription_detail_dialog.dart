import 'package:flutter/material.dart';
import '../../models/prescription_models.dart';

class PrescriptionDetailDialog extends StatelessWidget {
  final Prescription prescription;

  const PrescriptionDetailDialog({super.key, required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[200],
              child: prescription.imageUrl.isNotEmpty
                  ? InteractiveViewer(
                      child: Image.network(
                        prescription.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                    ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: prescription.isPending 
                              ? Colors.orange.shade100 
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          prescription.status,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: prescription.isPending 
                                ? Colors.orange.shade700 
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDateTime(prescription.createdAt),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  
                  if (prescription.symptoms != null && prescription.symptoms!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Symptoms',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(prescription.symptoms!),
                  ],
                  
                  if (prescription.description != null && prescription.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Notes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(prescription.description!),
                  ],
                  
                  if (prescription.isReviewed) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.medical_services, 
                                  size: 18, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Doctor\'s Notes',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prescription.doctorNotes ?? 'Reviewed',
                            style: TextStyle(color: Colors.green.shade800),
                          ),
                          if (prescription.reviewedAt != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Reviewed on: ${_formatDateTime(prescription.reviewedAt!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Close Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
