import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/trainer_provider.dart';
import '../widgets/trainer_stats_card.dart';
import '../widgets/session_card.dart';
import '../widgets/skill_content_card.dart';
import 'upload_skill_content_screen.dart';
import 'my_skill_content_screen.dart';
import 'schedule_session_screen.dart';

class TrainerDashboardScreen extends ConsumerStatefulWidget {
  const TrainerDashboardScreen({super.key});

  @override
  ConsumerState<TrainerDashboardScreen> createState() =>
      _TrainerDashboardScreenState();
}

class _TrainerDashboardScreenState extends ConsumerState<TrainerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trainerProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainerState = ref.watch(trainerProvider);
    final stats = trainerState.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(trainerProvider.notifier).loadDashboard(),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'session',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleSessionScreen()),
            ),
            child: const Icon(Icons.event),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'upload',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadSkillContentScreen()),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Upload'),
          ),
        ],
      ),
      body: trainerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(trainerProvider.notifier).loadDashboard(),
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
                            Colors.orange[600]!,
                            Colors.orange[400]!,
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
                                Icons.handyman,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, Trainer!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Manage skill training content & sessions',
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
                        TrainerStatsCard(
                          title: 'Videos',
                          value: stats.totalContent.toString(),
                          icon: Icons.video_library,
                          color: Colors.orange,
                          onTap: () => _openMyContent(),
                        ),
                        TrainerStatsCard(
                          title: 'Total Views',
                          value: _formatNumber(stats.totalViews),
                          icon: Icons.visibility,
                          color: Colors.green,
                        ),
                        TrainerStatsCard(
                          title: 'Sessions Done',
                          value: stats.sessionsCompleted.toString(),
                          icon: Icons.check_circle,
                          color: Colors.blue,
                        ),
                        TrainerStatsCard(
                          title: 'Upcoming',
                          value: stats.upcomingSessions.toString(),
                          icon: Icons.schedule,
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
                            title: 'Sessions',
                            icon: Icons.event_note,
                            color: Colors.indigo,
                            onTap: () => _showSessions(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Upcoming Sessions
                    if (trainerState.upcomingSessions.isNotEmpty) ...[
                      const Text(
                        'Upcoming Sessions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...trainerState.upcomingSessions
                          .take(2)
                          .map((session) => SessionCard(session: session)),
                      const SizedBox(height: 24),
                    ],

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

                    if (trainerState.content.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.video_library,
                                color: Colors.orange[600], size: 32),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'No content uploaded yet. Start sharing skills!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...trainerState.content.take(3).map((content) =>
                          SkillContentCard(
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
        builder: (_) => const MySkillContentScreen(),
      ),
    );
  }

  void _showSessions() {
    // TODO: Implement sessions list screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sessions screen coming soon!')),
    );
  }

  void _editContent(String id) {
    // TODO: Implement edit
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
                  await ref.read(trainerProvider.notifier).deleteContent(id);
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
