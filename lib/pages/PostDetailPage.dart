import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/app_theme.dart';
import 'package:frontend/models/posts_model.dart';
import 'package:frontend/models/comment_model.dart';
import 'package:frontend/services/api.dart';
import 'package:frontend/pages/CreateEditPostPage.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late PostModel _post;
  bool _isLoading = false;
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isSaved = false;
  int? _currentUserId;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _likeCount = _post.likeCount ?? 0;
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    if (ApiService.token == null) return;
    try {
      final user = await ApiService.getMe();
      if (user != null && mounted) {
        setState(() => _currentUserId = user['id']);
      }
    } catch (_) {}
  }

  bool get _isOwner {
    if (_currentUserId == null || _post.author?.id == null) return false;
    return _currentUserId == _post.author!.id;
  }

  Future<void> _refreshPost() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getPostById(_post.id);
      if (response != null) {
        setState(() => _post = response);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat detail: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: const Text('Apakah Anda yakin ingin menghapus artikel ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final success = await ApiService.deletePost(_post.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dihapus')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike() async {
    if (ApiService.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk like')),
      );
      return;
    }
    try {
      final result = await ApiService.toggleLike(_post.id);
      if (result != null) {
        setState(() {
          _isLiked = result['liked'];
          _likeCount = result['likeCount'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal like: $e')),
      );
    }
  }

  Future<void> _toggleSave() async {
    if (ApiService.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk save')),
      );
      return;
    }
    try {
      final success = await ApiService.toggleSave(_post.id);
      if (success) {
        setState(() => _isSaved = !_isSaved);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isSaved ? 'Artikel disimpan' : 'Artikel dihapus dari simpanan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal save: $e')),
      );
    }
  }

  Future<void> _addComment() async {
    if (ApiService.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login untuk komentar')),
      );
      return;
    }
    if (_commentController.text.trim().isEmpty) return;

    try {
      final result = await ApiService.addComment(_post.id, _commentController.text.trim());
      if (result != null) {
        _commentController.clear();
        _refreshPost();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambah komentar: $e')),
      );
    }
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateEditPostPage(post: _post)),
    ).then((_) => _refreshPost());
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: _post.picture != null ? 300 : 0,
                  pinned: true,
                  backgroundColor: AppTheme.scaffoldBg,
                  foregroundColor: AppTheme.textPrimary,
                  flexibleSpace: _post.picture != null && _post.picture!.isNotEmpty
                      ? FlexibleSpaceBar(
                          background: Image.network(
                            _post.picture!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppTheme.dividerColor.withValues(alpha: 0.3),
                              child: const Center(
                                child: Icon(Icons.image_not_supported_outlined, size: 48, color: AppTheme.textHint),
                              ),
                            ),
                          ),
                        )
                      : null,
                  actions: [
                    if (_isOwner) ...[
                      IconButton(
                        onPressed: _navigateToEdit,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        onPressed: _deletePost,
                        icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                      ),
                    ],
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        if (_post.categoryName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _post.categoryName!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          _post.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Author
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                              backgroundImage: _post.author?.picture != null
                                  ? NetworkImage(_post.author!.picture!)
                                  : null,
                              child: _post.author?.picture == null
                                  ? Text(
                                      (_post.author?.name ?? 'A')[0].toUpperCase(),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryColor,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _post.author?.name ?? 'Anonim',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(_post.createdAt),
                                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textHint),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Action Chips
                        Row(
                          children: [
                            _buildActionChip(
                              icon: _isLiked ? Icons.favorite : Icons.favorite_outline,
                              label: '$_likeCount',
                              color: _isLiked ? AppTheme.errorColor : AppTheme.textSecondary,
                              onTap: _toggleLike,
                            ),
                            const SizedBox(width: 12),
                            _buildActionChip(
                              icon: _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                              label: 'Simpan',
                              color: _isSaved ? AppTheme.primaryColor : AppTheme.textSecondary,
                              onTap: _toggleSave,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Divider(color: AppTheme.dividerColor),
                        const SizedBox(height: 24),

                        // Content
                        Text(
                          _post.content,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Divider(color: AppTheme.dividerColor),
                        const SizedBox(height: 24),

                        // Comments
                        _buildCommentsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Komentar',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<CommentModel>>(
          future: ApiService.getComments(_post.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return Text(
                'Gagal memuat komentar',
                style: GoogleFonts.inter(color: AppTheme.errorColor),
              );
            }
            final comments = snapshot.data ?? [];
            if (comments.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Belum ada komentar',
                    style: GoogleFonts.inter(color: AppTheme.textHint, fontSize: 14),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final comment = comments[index];
                final userName = comment.user?.name ?? 'Anonim';
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        backgroundImage: comment.user?.picture != null
                            ? NetworkImage(comment.user!.picture!)
                            : null,
                        child: comment.user?.picture == null
                            ? Text(
                                userName[0].toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryColor,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  userName,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(comment.createdAt),
                                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textHint),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              comment.content,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        _buildAddCommentForm(),
      ],
    );
  }

  Widget _buildAddCommentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Komentar',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            style: GoogleFonts.inter(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tulis komentar Anda...',
              hintStyle: GoogleFonts.inter(color: AppTheme.textHint),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _addComment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text('Kirim', style: GoogleFonts.inter()),
            ),
          ),
        ],
      ),
    );
  }
}
