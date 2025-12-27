import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../prescriptions/models/prescription_models.dart';

class PrescriptionReviewCard extends StatelessWidget {
  final Prescription prescription;
  final VoidCallback? onReview;
  final VoidCallback? onView;

  const PrescriptionReviewCard({
    super.key,
    required this.prescription,
    this.onReview,
    this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(prescription.status);
    final statusLabel = _getStatusLabel(prescription.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prescription thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey[200],
                  child: Image.network(
                    prescription.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.receipt_long,
                      color: Colors.grey[400],
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            prescription.patientName ?? 'Unknown Patient',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (prescription.description?.isNotEmpty ?? false)
                      Text(
                        prescription.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(prescription.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (prescription.block != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.apartment,
                              size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            prescription.block!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (prescription.status == 'PENDING') ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onReview,
                          icon: const Icon(Icons.rate_review, size: 18),
                          label: const Text('Review Now'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'REVIEWED':
        return Colors.green;
      case 'NEEDS_FOLLOWUP':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'REVIEWED':
        return 'Reviewed';
      case 'NEEDS_FOLLOWUP':
        return 'Follow-up';
      default:
        return status;
    }
  }
}
