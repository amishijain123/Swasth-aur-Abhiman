import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/doctor_provider.dart';
import '../widgets/doctor_stats_card.dart';
import '../widgets/prescription_review_card.dart';
import 'prescription_review_screen.dart';
import 'patients_screen.dart';

class DoctorDashboardScreen extends ConsumerStatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  ConsumerState<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends ConsumerState<DoctorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doctorProvider.notifier).loadDashboard();
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
    final stats = doctorState.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(doctorProvider.notifier).loadDashboard(),
          ),
        ],
      ),
      body: doctorState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(doctorProvider.notifier).loadDashboard(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green[600]!,
                            Colors.green[400]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.medical_services,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, Doctor!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Review prescriptions from patients',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        DoctorStatsCard(
                          title: 'Pending Review',
                          value: stats.pendingReview.toString(),
                          icon: Icons.pending_actions,
                          color: Colors.orange,
                          onTap: () => _openPrescriptions('PENDING'),
                        ),
                        DoctorStatsCard(
                          title: 'Reviewed Today',
                          value: stats.todayReviewed.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                          onTap: () => _openPrescriptions('REVIEWED'),
                        ),
                        DoctorStatsCard(
                          title: 'Total Reviewed',
                          value: stats.totalReviewed.toString(),
                          icon: Icons.assignment_turned_in,
                          color: Colors.blue,
                        ),
                        DoctorStatsCard(
                          title: 'Needs Follow-up',
                          value: stats.needsFollowup.toString(),
                          icon: Icons.schedule,
                          color: Colors.red,
                          onTap: () => _openPrescriptions('NEEDS_FOLLOWUP'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            title: 'View Patients',
                            icon: Icons.people,
                            color: Colors.purple,
                            onTap: () => _openPatients(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            title: 'All Prescriptions',
                            icon: Icons.receipt_long,
                            color: Colors.teal,
                            onTap: () => _openPrescriptions(null),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Pending Prescriptions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pending Review',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _openPrescriptions('PENDING'),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (doctorState.pendingPrescriptions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green[600], size: 32),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'No pending prescriptions to review!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...doctorState.pendingPrescriptions
                          .take(3)
                          .map((prescription) => PrescriptionReviewCard(
                                prescription: prescription,
                                onReview: () =>
                                    _openReviewScreen(prescription.id),
                              )),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  void _openPrescriptions(String? status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrescriptionReviewScreen(initialStatus: status),
      ),
    );
  }

  void _openPatients() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PatientsScreen(),
      ),
    );
  }

  void _openReviewScreen(String prescriptionId) {
    // TODO: Open individual prescription review
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
