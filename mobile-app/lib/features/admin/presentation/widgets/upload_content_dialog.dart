import 'package:flutter/material.dart';

class UploadContentDialog extends StatefulWidget {
  final String category;
  final List<String> subcategories;
  final Function(String title, String description, String subcategory,
      String url, String? thumbnail) onUpload;

  const UploadContentDialog({
    super.key,
    required this.category,
    required this.subcategories,
    required this.onUpload,
  });

  @override
  State<UploadContentDialog> createState() => _UploadContentDialogState();
}

class _UploadContentDialogState extends State<UploadContentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _thumbnailController = TextEditingController();
  String? _selectedSubcategory;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Upload ${_getCategoryName()} Content',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Title *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Subcategory
                        DropdownButtonFormField<String>(
                          value: _selectedSubcategory,
                          decoration: const InputDecoration(
                            labelText: 'Subcategory *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: widget.subcategories
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(_formatSubcategory(s)),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedSubcategory = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a subcategory';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Media URL
                        TextFormField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: 'Media URL *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.link),
                            hintText: 'https://...',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a media URL';
                            }
                            if (!value.startsWith('http')) {
                              return 'Please enter a valid URL';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Thumbnail URL (optional)
                        TextFormField(
                          controller: _thumbnailController,
                          decoration: const InputDecoration(
                            labelText: 'Thumbnail URL (optional)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.image),
                            hintText: 'https://...',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Upload Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isUploading ? null : _handleUpload,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isUploading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Upload Content'),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        return '';
    }
  }

  String _formatSubcategory(String subcategory) {
    return subcategory
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _handleUpload() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);
      widget.onUpload(
        _titleController.text,
        _descriptionController.text,
        _selectedSubcategory!,
        _urlController.text,
        _thumbnailController.text.isEmpty ? null : _thumbnailController.text,
      );
    }
  }
}
