import 'package:flutter/material.dart';
import 'package:frontend/app_theme.dart';
import 'package:frontend/models/category_model.dart';
import 'package:frontend/models/posts_model.dart';
import 'package:frontend/services/api.dart';

class CreateEditPostPage extends StatefulWidget {
  final PostModel? post;

  const CreateEditPostPage({super.key, this.post});

  @override
  State<CreateEditPostPage> createState() => _CreateEditPostPageState();
}

class _CreateEditPostPageState extends State<CreateEditPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _pictureController = TextEditingController();

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
      _pictureController.text = widget.post!.picture ?? '';
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.getCategories();
      setState(() {
        _categories = categories;
        if (widget.post != null && categories.isNotEmpty) {
          _selectedCategory = categories.firstWhere(
            (c) => c.id == widget.post!.categoryId,
            orElse: () => categories.first,
          );
        } else if (categories.isNotEmpty) {
          _selectedCategory = categories.first;
        }
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat kategori: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool success;
      if (widget.post != null) {
        final result = await ApiService.updatePost(
          id: widget.post!.id,
          categoryId: _selectedCategory!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          picture: _pictureController.text.trim().isEmpty ? null : _pictureController.text.trim(),
        );
        success = result != null;
      } else {
        final result = await ApiService.createPost(
          categoryId: _selectedCategory!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          picture: _pictureController.text.trim().isEmpty ? null : _pictureController.text.trim(),
        );
        success = result != null;
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.post != null ? 'Artikel diperbarui' : 'Artikel berhasil dibuat')),
        );
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _pictureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.post != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Artikel' : 'Buat Artikel'),
        actions: [
          if (isEdit)
            IconButton(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
            ),
        ],
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<CategoryModel>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      hintText: 'Pilih kategori',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat.name));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator: (val) => val == null ? 'Pilih kategori' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Judul',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Judul artikel yang menarik',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Judul wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Konten',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Tuliskan cerita atau artikel Anda di sini...',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 12,
                    validator: (val) => val == null || val.trim().isEmpty ? 'Konten wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'URL Gambar (opsional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _pictureController,
                    decoration: const InputDecoration(
                      hintText: 'https://example.com/image.jpg',
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!isEdit)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Terbitkan Artikel', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
