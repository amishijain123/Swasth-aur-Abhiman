import 'package:flutter/material.dart';
import '../../../prescriptions/models/prescription_models.dart';

class ReviewDialog extends StatefulWidget {
  final Prescription prescription;
  final Function(String status, String? notes, String? medicines) onSubmit;

  const ReviewDialog({
    super.key,
    required this.prescription,
    required this.onSubmit,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _medicinesController = TextEditingController();
  String _selectedStatus = 'REVIEWED';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    _medicinesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Review Prescription',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Patient info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: Image.network(
                            widget.prescription.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.receipt_long,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.prescription.patientName ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.prescription.description != null)
                              Text(
                                widget.prescription.description!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _viewFullImage(context),
                        child: const Text('View'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Status selection
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatusOption(
                        title: 'Reviewed',
                        subtitle: 'No issues',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        isSelected: _selectedStatus == 'REVIEWED',
                        onTap: () => setState(() => _selectedStatus = 'REVIEWED'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatusOption(
                        title: 'Follow-up',
                        subtitle: 'Needs attention',
                        icon: Icons.schedule,
                        color: Colors.orange,
                        isSelected: _selectedStatus == 'NEEDS_FOLLOWUP',
                        onTap: () => setState(() => _selectedStatus = 'NEEDS_FOLLOWUP'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Doctor notes
                const Text(
                  'Doctor Notes',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Add notes about the prescription...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Suggested medicines
                const Text(
                  'Suggested Medicines',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _medicinesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Suggest alternative or additional medicines...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Review'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _viewFullImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(
            widget.prescription.imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void _submit() {
    setState(() => _isSubmitting = true);
    widget.onSubmit(
      _selectedStatus,
      _notesController.text.isEmpty ? null : _notesController.text,
      _medicinesController.text.isEmpty ? null : _medicinesController.text,
    );
  }
}

class _StatusOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
