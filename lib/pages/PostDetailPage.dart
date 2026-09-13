import 'package:flutter/material.dart';
import 'package:frontend/models/posts_model.dart';
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
      if (mounted) _showSnackBar('Gagal memuat detail: $e');
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final success = await ApiService.deletePost(_post.id);
      if (success && mounted) {
        _showSnackBar('Artikel berhasil dihapus');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Gagal menghapus: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleLike() async {
    if (ApiService.token == null) {
      _showSnackBar('Silakan login untuk like');
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
      _showSnackBar('Gagal like: $e');
    }
  }

  Future<void> _toggleSave() async {
    if (ApiService.token == null) {
      _showSnackBar('Silakan login untuk save');
      return;
    }
    try {
      final success = await ApiService.toggleSave(_post.id);
      if (success) {
        setState(() => _isSaved = !_isSaved);
        _showSnackBar(_isSaved ? 'Artikel disimpan' : 'Artikel dihapus dari simpanan');
      }
    } catch (e) {
      _showSnackBar('Gagal save: $e');
    }
  }

  Future<void> _addComment() async {
    if (ApiService.token == null) {
      _showSnackBar('Silakan login untuk komentar');
      return;
    }
    if (_commentController.text.trim().isEmpty) return;

    try {
      final result = await ApiService.addComment(_post.id, _commentController.text.trim());
      if (result != null) {
        _commentController.clear();
        _refreshPost();
        _showSnackBar('Komentar ditambahkan');
      }
    } catch (e) {
      _showSnackBar('Gagal menambah komentar: $e');
    }
  }

  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateEditPostPage(post: _post)),
    ).then((_) => _refreshPost());
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
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
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        actions: _isOwner
            ? [
                IconButton(onPressed: _navigateToEdit, icon: const Icon(Icons.edit)),
                IconButton(onPressed: _deletePost, icon: const Icon(Icons.delete)),
              ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshPost,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_post.picture != null && _post.picture!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _post.picture!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey)),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(_post.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_post.categoryName != null)
                          Chip(
                            label: Text(_post.categoryName!),
                            avatar: const Icon(Icons.category, size: 16),
                          ),
                        const SizedBox(width: 8),
                        Text('oleh ${_post.author?.name ?? 'Anonim'}', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(width: 8),
                        Text(_formatDate(_post.createdAt), style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _toggleLike,
                          icon: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            color: _isLiked ? Colors.red : Colors.grey,
                          ),
                        ),
                        Text('$_likeCount'),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _toggleSave,
                          icon: Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: _isSaved ? Colors.amber : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(_post.content, style: const TextStyle(fontSize: 16, height: 1.5)),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildCommentsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Komentar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        FutureBuilder<List<CommentModel>>(
          future: ApiService.getComments(_post.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final comments = snapshot.data ?? [];
            if (comments.isEmpty) {
              return const Text('Belum ada komentar', style: TextStyle(color: Colors.grey));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                final userName = comment.user?.name ?? 'Anonim';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(userName[0].toUpperCase())),
                    title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(comment.content),
                    trailing: Text(_formatDate(comment.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Komentar', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Tulis komentar...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _addComment,
                child: const Text('Kirim'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
