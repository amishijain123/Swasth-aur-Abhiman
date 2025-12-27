import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/media_models.dart';
import '../../providers/admin_provider.dart';
import '../widgets/content_item_card.dart';
import '../widgets/upload_content_dialog.dart';

class ContentManagementScreen extends ConsumerStatefulWidget {
  final String category;

  const ContentManagementScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState
    extends ConsumerState<ContentManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadContent(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final content = adminState.contentList;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_getCategoryName()} Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: adminState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : content.isEmpty
              ? _buildEmptyState()
              : _buildContentList(content),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Upload'),
      ),
    );
  }

  String _getCategoryName() {
    switch (widget.category) {
      case 'MEDICAL':
        return 'Medical';
      case 'EDUCATION':
        return 'Education';
      case 'SKILL':
        return 'Skills';
      case 'NUTRITION':
        return 'Nutrition';
      default:
        return 'Content';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No content uploaded yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to upload new content',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showUploadDialog(),
            icon: const Icon(Icons.upload),
            label: const Text('Upload Content'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList(List<MediaContent> content) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(adminProvider.notifier).loadContent(widget.category),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: content.length,
        itemBuilder: (context, index) {
          final item = content[index];
          return ContentItemCard(
            content: item,
            onEdit: () => _editContent(item),
            onDelete: () => _deleteContent(item),
          );
        },
      ),
    );
  }

  void _showUploadDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => UploadContentDialog(
        category: widget.category,
        subcategories: _getSubcategories(),
        onUpload: (title, description, subcategory, url, thumbnail) async {
          final success = await ref.read(adminProvider.notifier).uploadContent(
                title: title,
                description: description,
                category: widget.category,
                subcategory: subcategory,
                mediaUrl: url,
                thumbnailUrl: thumbnail,
              );
          if (success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Content uploaded successfully')),
            );
          }
        },
      ),
    );
  }

  List<String> _getSubcategories() {
    switch (widget.category) {
      case 'MEDICAL':
        return ['herbal_remedies', 'general_health', 'post_covid'];
      case 'EDUCATION':
        return ['class_1', 'class_2', 'class_3', 'class_4', 'class_5',
                'class_6', 'class_7', 'class_8', 'class_9', 'class_10',
                'class_11', 'class_12'];
      case 'SKILL':
        return ['bamboo', 'artisan', 'honeybee', 'jute', 'macrame'];
      case 'NUTRITION':
        return ['post_covid', 'anemia', 'pregnancy', 'children', 'diabetes', 'general'];
      default:
        return [];
    }
  }

  void _editContent(MediaContent content) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon')),
    );
  }

  void _deleteContent(MediaContent content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Content'),
        content: Text('Are you sure you want to delete "${content.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(adminProvider.notifier)
                  .deleteContent(content.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Content deleted')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
