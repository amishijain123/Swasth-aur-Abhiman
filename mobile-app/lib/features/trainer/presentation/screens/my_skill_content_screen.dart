import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/trainer_provider.dart';
import '../widgets/skill_content_card.dart';

class MySkillContentScreen extends ConsumerStatefulWidget {
  const MySkillContentScreen({super.key});

  @override
  ConsumerState<MySkillContentScreen> createState() =>
      _MySkillContentScreenState();
}

class _MySkillContentScreenState extends ConsumerState<MySkillContentScreen> {
  String? _selectedCategory;

  final _categories = [
    'All',
    'Bamboo',
    'Artisan',
    'Honeybee',
    'Jute',
    'Macrame',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trainerProvider.notifier).loadContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainerState = ref.watch(trainerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Skill Content'),
      ),
      body: Column(
        children: [
          // Category filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected =
                    (category == 'All' && _selectedCategory == null) ||
                        category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category == 'All' ? null : category;
                      });
                      ref.read(trainerProvider.notifier).loadContent(
                            category: _selectedCategory,
                          );
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Content list
          Expanded(
            child: trainerState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : trainerState.content.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(trainerProvider.notifier)
                            .loadContent(category: _selectedCategory),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: trainerState.content.length,
                          itemBuilder: (context, index) {
                            final content = trainerState.content[index];
                            return SkillContentCard(
                              content: content,
                              onEdit: () => _editContent(content.id),
                              onDelete: () => _deleteContent(content.id),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No content found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedCategory != null
                ? 'Try a different category'
                : 'Upload your first content',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
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
