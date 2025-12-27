import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/teacher_provider.dart';
import '../widgets/content_card.dart';

class MyContentScreen extends ConsumerStatefulWidget {
  const MyContentScreen({super.key});

  @override
  ConsumerState<MyContentScreen> createState() => _MyContentScreenState();
}

class _MyContentScreenState extends ConsumerState<MyContentScreen> {
  String? _selectedCategory;

  final _categories = [
    'All',
    'Class 1-5',
    'Class 6-8',
    'Class 9-10',
    'Class 11-12',
    'Competitive',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teacherProvider.notifier).loadContent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final teacherState = ref.watch(teacherProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Content'),
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
                final isSelected = (category == 'All' && _selectedCategory == null) ||
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
                      ref.read(teacherProvider.notifier).loadContent(
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
            child: teacherState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : teacherState.content.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(teacherProvider.notifier)
                            .loadContent(category: _selectedCategory),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: teacherState.content.length,
                          itemBuilder: (context, index) {
                            final content = teacherState.content[index];
                            return ContentCard(
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
