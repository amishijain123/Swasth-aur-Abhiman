import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prescriptions/models/prescription_models.dart';
import '../../providers/doctor_provider.dart';
import '../widgets/prescription_review_card.dart';
import '../widgets/review_dialog.dart';

class PrescriptionReviewScreen extends ConsumerStatefulWidget {
  final String? initialStatus;

  const PrescriptionReviewScreen({
    super.key,
    this.initialStatus,
  });

  @override
  ConsumerState<PrescriptionReviewScreen> createState() =>
      _PrescriptionReviewScreenState();
}

class _PrescriptionReviewScreenState
    extends ConsumerState<PrescriptionReviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Set initial tab based on status
    if (widget.initialStatus == 'REVIEWED') {
      _tabController.index = 1;
    } else if (widget.initialStatus == 'NEEDS_FOLLOWUP') {
      _tabController.index = 2;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doctorProvider.notifier).loadPrescriptions(
            status: widget.initialStatus,
          );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescriptions'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (block) {
              ref.read(doctorProvider.notifier).filterByBlock(
                    block == 'All' ? null : block,
                  );
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'All', child: Text('All Blocks')),
              PopupMenuItem(value: 'VIKASNAGAR', child: Text('Vikasnagar')),
              PopupMenuItem(value: 'DOIWALA', child: Text('Doiwala')),
              PopupMenuItem(value: 'SAHASPUR', child: Text('Sahaspur')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            final statuses = ['PENDING', 'REVIEWED', 'NEEDS_FOLLOWUP'];
            ref.read(doctorProvider.notifier).filterByStatus(statuses[index]);
          },
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Reviewed'),
            Tab(text: 'Follow-up'),
          ],
        ),
      ),
      body: doctorState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPrescriptionsList(doctorState.prescriptions),
    );
  }

  Widget _buildPrescriptionsList(List<Prescription> prescriptions) {
    if (prescriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No prescriptions found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(doctorProvider.notifier).loadPrescriptions(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];
          return PrescriptionReviewCard(
            prescription: prescription,
            onReview: () => _showReviewDialog(prescription),
            onView: () => _viewPrescription(prescription),
          );
        },
      ),
    );
  }

  void _showReviewDialog(Prescription prescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReviewDialog(
        prescription: prescription,
        onSubmit: (status, notes, medicines) async {
          final success = await ref.read(doctorProvider.notifier).reviewPrescription(
                id: prescription.id,
                status: status,
                doctorNotes: notes,
                suggestedMedicines: medicines,
              );
          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Prescription reviewed successfully')),
            );
          }
        },
      ),
    );
  }

  void _viewPrescription(Prescription prescription) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Prescription Image'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Flexible(
              child: InteractiveViewer(
                child: Image.network(
                  prescription.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, size: 64),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
