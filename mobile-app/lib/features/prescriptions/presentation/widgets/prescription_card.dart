import 'package:flutter/material.dart';
import '../../models/prescription_models.dart';
import 'prescription_detail_dialog.dart';

class PrescriptionCard extends StatelessWidget {
  final Prescription prescription;
  final bool showUserInfo;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    this.showUserInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetailDialog(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview
            Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[200],
              child: prescription.imageUrl.isNotEmpty
                  ? Image.network(
                      prescription.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    )
                  : const Center(
                      child: Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                    ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: prescription.isPending 
                              ? Colors.orange.shade100 
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              prescription.isPending 
                                  ? Icons.hourglass_empty 
                                  : Icons.check_circle,
                              size: 16,
                              color: prescription.isPending 
                                  ? Colors.orange.shade700 
                                  : Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              prescription.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: prescription.isPending 
                                    ? Colors.orange.shade700 
                                    : Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(prescription.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  // Symptoms
                  if (prescription.symptoms != null && prescription.symptoms!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Symptoms: ${prescription.symptoms}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Doctor Notes (if reviewed)
                  if (prescription.isReviewed && prescription.doctorNotes != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.medical_services, 
                              size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              prescription.doctorNotes!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PrescriptionDetailDialog(prescription: prescription),
    );
  }
}
