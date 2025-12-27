import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/admin_menu_card.dart';
import 'content_management_screen.dart';
import 'event_management_screen.dart';
import 'user_management_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final stats = adminState.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminProvider.notifier).loadDashboard(),
          ),
        ],
      ),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(adminProvider.notifier).loadDashboard(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome, Admin!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage content across all 5 domains',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick Stats
                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        StatsCard(
                          title: 'Total Users',
                          value: stats.totalUsers.toString(),
                          icon: Icons.people,
                          color: Colors.blue,
                        ),
                        StatsCard(
                          title: 'Doctors',
                          value: stats.totalDoctors.toString(),
                          icon: Icons.medical_services,
                          color: Colors.green,
                        ),
                        StatsCard(
                          title: 'Content',
                          value: stats.totalContent.toString(),
                          icon: Icons.video_library,
                          color: Colors.purple,
                        ),
                        StatsCard(
                          title: 'Events',
                          value: stats.totalEvents.toString(),
                          icon: Icons.event,
                          color: Colors.orange,
                        ),
                        StatsCard(
                          title: 'Prescriptions',
                          value: stats.totalPrescriptions.toString(),
                          subtitle: '${stats.pendingPrescriptions} pending',
                          icon: Icons.receipt_long,
                          color: Colors.pink,
                        ),
                        StatsCard(
                          title: 'Trainers',
                          value: stats.totalTrainers.toString(),
                          icon: Icons.person_outline,
                          color: Colors.teal,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Management Sections
                    const Text(
                      'Content Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 5 Domain Content Management
                    AdminMenuCard(
                      title: 'Medical Content',
                      subtitle: 'Health videos, herbal remedies',
                      icon: Icons.local_hospital,
                      color: Colors.red,
                      onTap: () => _openContentManagement('MEDICAL'),
                    ),
                    AdminMenuCard(
                      title: 'Education Content',
                      subtitle: 'NCERT books and materials',
                      icon: Icons.school,
                      color: Colors.blue,
                      onTap: () => _openContentManagement('EDUCATION'),
                    ),
                    AdminMenuCard(
                      title: 'Skills Training',
                      subtitle: 'Vocational training videos',
                      icon: Icons.construction,
                      color: Colors.orange,
                      onTap: () => _openContentManagement('SKILL'),
                    ),
                    AdminMenuCard(
                      title: 'Nutrition Content',
                      subtitle: 'Diet plans, nutrition videos',
                      icon: Icons.restaurant_menu,
                      color: Colors.green,
                      onTap: () => _openContentManagement('NUTRITION'),
                    ),
                    const SizedBox(height: 24),

                    // Other Management
                    const Text(
                      'Other Management',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    AdminMenuCard(
                      title: 'Event Management',
                      subtitle: 'Create and manage community events',
                      icon: Icons.event,
                      color: Colors.purple,
                      onTap: () => _openEventManagement(),
                    ),
                    AdminMenuCard(
                      title: 'User Management',
                      subtitle: 'Manage users, doctors, trainers',
                      icon: Icons.people,
                      color: Colors.teal,
                      onTap: () => _openUserManagement(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  void _openContentManagement(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContentManagementScreen(category: category),
      ),
    );
  }

  void _openEventManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EventManagementScreen(),
      ),
    );
  }

  void _openUserManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserManagementScreen(),
      ),
    );
  }
}
