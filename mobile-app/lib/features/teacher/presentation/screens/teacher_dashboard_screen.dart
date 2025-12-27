import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/teacher_provider.dart';
import '../widgets/teacher_stats_card.dart';
import '../widgets/content_card.dart';
import 'upload_content_screen.dart';
import 'my_content_screen.dart';

class TeacherDashboardScreen extends ConsumerStatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  ConsumerState<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends ConsumerState<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teacherProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final teacherState = ref.watch(teacherProvider);
    final stats = teacherState.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(teacherProvider.notifier).loadDashboard(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UploadContentScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Upload Content'),
      ),
      body: teacherState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(teacherProvider.notifier).loadDashboard(),
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
                            Colors.blue[600]!,
                            Colors.blue[400]!,
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
                                Icons.school,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, Teacher!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Manage your educational content',
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
                        TeacherStatsCard(
                          title: 'Total Content',
                          value: stats.totalContent.toString(),
                          icon: Icons.video_library,
                          color: Colors.blue,
                          onTap: () => _openMyContent(),
                        ),
                        TeacherStatsCard(
                          title: 'Total Views',
                          value: _formatNumber(stats.totalViews),
                          icon: Icons.visibility,
                          color: Colors.green,
                        ),
                        TeacherStatsCard(
                          title: 'This Month',
                          value: _formatNumber(stats.thisMonthViews),
                          icon: Icons.trending_up,
                          color: Colors.orange,
                        ),
                        TeacherStatsCard(
                          title: 'Categories',
                          value: stats.byCategory.length.toString(),
                          icon: Icons.category,
                          color: Colors.purple,
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
                            title: 'My Content',
                            icon: Icons.folder,
                            color: Colors.teal,
                            onTap: () => _openMyContent(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            title: 'Analytics',
                            icon: Icons.analytics,
                            color: Colors.indigo,
                            onTap: () => _showAnalytics(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Content
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Content',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _openMyContent(),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (teacherState.content.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.video_library,
                                color: Colors.blue[600], size: 32),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'No content uploaded yet. Start sharing knowledge!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...teacherState.content.take(3).map((content) =>
                          ContentCard(
                            content: content,
                            onEdit: () => _editContent(content.id),
                            onDelete: () => _deleteContent(content.id),
                          )),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  void _openMyContent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyContentScreen(),
      ),
    );
  }

  void _showAnalytics() {
    // TODO: Implement analytics screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analytics coming soon!')),
    );
  }

  void _editContent(String id) {
    // TODO: Implement edit content
  }

  void _deleteContent(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Content'),
        content: const Text('Are you sure you want to delete this content?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await ref.read(teacherProvider.notifier).deleteContent(id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Content deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
