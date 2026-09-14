import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/app_theme.dart';
import 'package:frontend/models/category_model.dart';
import 'package:frontend/models/posts_model.dart';
import 'package:frontend/services/api.dart';

class EditPostPage extends StatefulWidget {
  final PostModel post;

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  Uint8List? _imageBytes;
  String? _imagePath;
  String? _existingPicture;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.title;
    _contentController.text = widget.post.content;
    _existingPicture = widget.post.picture;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.getCategories();
      setState(() {
        _categories = categories;
        if (categories.isNotEmpty) {
          _selectedCategory = categories.firstWhere(
            (c) => c.id == widget.post.categoryId,
            orElse: () => categories.first,
          );
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imagePath = image.path;
          _existingPicture = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imagePath = null;
      _existingPicture = null;
    });
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
      final result = await ApiService.updatePost(
        id: widget.post.id,
        categoryId: _selectedCategory!.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imagePath: _imagePath,
        existingPicture: _imagePath == null ? _existingPicture : null,
      );

      if (result != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel diperbarui')),
        );
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Artikel',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _submit,
            icon: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
                  _buildCategoryField(),
                  const SizedBox(height: 20),
                  _buildTitleField(),
                  const SizedBox(height: 20),
                  _buildContentField(),
                  const SizedBox(height: 20),
                  _buildImageSection(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategori', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<CategoryModel>(
          initialValue: _selectedCategory,
          decoration: InputDecoration(
            hintText: 'Pilih kategori',
            hintStyle: GoogleFonts.inter(color: AppTheme.textHint),
            prefixIcon: const Icon(Icons.category_outlined, size: 20),
          ),
          items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.name))).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
          validator: (val) => val == null ? 'Pilih kategori' : null,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Judul', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Judul artikel yang menarik',
            hintStyle: GoogleFonts.inter(color: AppTheme.textHint),
            prefixIcon: const Icon(Icons.title, size: 20),
          ),
          validator: (val) => val == null || val.trim().isEmpty ? 'Judul wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Konten', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contentController,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Tuliskan cerita atau artikel Anda di sini...',
            hintStyle: GoogleFonts.inter(color: AppTheme.textHint),
            alignLabelWithHint: true,
          ),
          maxLines: 10,
          validator: (val) => val == null || val.trim().isEmpty ? 'Konten wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gambar (opsional)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 8),
        if (_imageBytes != null)
          _buildNewImagePreview()
        else if (_existingPicture != null && _existingPicture!.isNotEmpty)
          _buildExistingImagePreview()
        else
          _buildImagePicker(),
      ],
    );
  }

  Widget _buildNewImagePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.memory(_imageBytes!, width: double.infinity, height: 200, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Gambar baru dipilih', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                ),
                GestureDetector(
                  onTap: _removeImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Hapus', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.errorColor)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingImagePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: _existingPicture!.startsWith('http')
                ? Image.network(
                    _existingPicture!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                  )
                : _existingPicture!.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(_existingPicture!),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.link, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Gambar dari artikel', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                ),
                GestureDetector(
                  onTap: _removeImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Hapus', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.errorColor)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 12),
            Text('Tap untuk memilih gambar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
            const SizedBox(height: 4),
            Text('Galeri / File', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textHint)),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 200,
      color: AppTheme.dividerColor.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 48, color: AppTheme.textHint),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text('Perbarui Artikel', style: GoogleFonts.inter(fontSize: 16)),
      ),
    );
  }
}
