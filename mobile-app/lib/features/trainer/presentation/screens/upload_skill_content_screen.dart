import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/trainer_provider.dart';

class UploadSkillContentScreen extends ConsumerStatefulWidget {
  const UploadSkillContentScreen({super.key});

  @override
  ConsumerState<UploadSkillContentScreen> createState() =>
      _UploadSkillContentScreenState();
}

class _UploadSkillContentScreenState
    extends ConsumerState<UploadSkillContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();

  String _selectedCategory = 'Bamboo';
  bool _isSubmitting = false;

  final _categories = [
    'Bamboo',
    'Artisan',
    'Honeybee',
    'Jute',
    'Macrame',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Skill Content'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter video title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter video description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Skill Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category),
                          size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 16),

            // Video URL
            TextFormField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'Video URL',
                hintText: 'Enter YouTube or video URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.video_library),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a video URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Thumbnail URL (optional)
            TextFormField(
              controller: _thumbnailUrlController,
              decoration: const InputDecoration(
                labelText: 'Thumbnail URL (optional)',
                hintText: 'Enter thumbnail image URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
            ),
            const SizedBox(height: 24),

            // Upload info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[600]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Videos will be available in the Skills section for users to learn vocational skills.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Upload Content'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Bamboo':
        return Icons.grass;
      case 'Artisan':
        return Icons.palette;
      case 'Honeybee':
        return Icons.hive;
      case 'Jute':
        return Icons.shopping_bag;
      case 'Macrame':
        return Icons.texture;
      default:
        return Icons.handyman;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await ref.read(trainerProvider.notifier).uploadContent(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _selectedCategory,
          videoUrl: _videoUrlController.text,
          thumbnailUrl: _thumbnailUrlController.text.isEmpty
              ? null
              : _thumbnailUrlController.text,
        );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content uploaded successfully!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload content')),
      );
    }
  }
}
