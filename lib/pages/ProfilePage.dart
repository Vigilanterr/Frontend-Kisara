import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/app_theme.dart';
import 'package:frontend/services/api.dart';
import 'package:frontend/models/posts_model.dart';
import 'package:frontend/pages/LoginPage.dart';
import 'package:frontend/pages/RegisterPage.dart';
import 'package:frontend/pages/PostDetailPage.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onLoginRequired;

  const ProfilePage({super.key, this.onLoginRequired});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool get _isLoggedIn => ApiService.token != null;
  late Future<List<PostModel>> _userPostsFuture;

  @override
  void initState() {
    super.initState();
    _userPostsFuture = Future.value([]);
    _loadUserPosts();
  }

  void _loadUserPosts() {
    if (_isLoggedIn) {
      _userPostsFuture = ApiService.getUserPosts();
    }
  }

  void _openLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    setState(() {
      _loadUserPosts();
    });
  }

  void _logout() {
    ApiService.logout();
    setState(() {
      _userPostsFuture = Future.value([]);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil logout')),
      );
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _loadUserPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _buildLoggedOutView();
    }
    return _buildLoggedInView();
  }

  Widget _buildLoggedOutView() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 48,
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Selamat datang di Kisara',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Login untuk melihat profil, menyimpan,\ndan membuat artikel',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Login', style: GoogleFonts.inter(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  ).then((_) => setState(() {}));
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text('Daftar Akun Baru', style: GoogleFonts.inter(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: ApiService.getMe(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.error_outline, size: 40, color: AppTheme.errorColor),
                ),
                const SizedBox(height: 20),
                Text(
                  'Gagal memuat profil',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Terjadi kesalahan saat memuat data',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _logout,
                  child: Text('Logout', style: GoogleFonts.inter()),
                ),
              ],
            ),
          );
        }

        final user = snapshot.data!;
        return SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 32),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      backgroundImage: user['picture'] != null
                          ? NetworkImage(user['picture'])
                          : null,
                      child: user['picture'] == null
                          ? Text(
                              '${(user['name'] ?? 'U')[0]}'.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user['name'] ?? 'User',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user['email'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Info Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      title: 'Nama',
                      value: user['name'] ?? '-',
                    ),
                    const SizedBox(height: 10),
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: user['email'] ?? '-',
                    ),
                    const SizedBox(height: 24),

                    // Artikel Saya Section
                    _buildMyPostsSection(),
                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Apakah Anda yakin ingin logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _logout();
                                  },
                                  child: const Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                        label: Text(
                          'Logout',
                          style: GoogleFonts.inter(
                            color: AppTheme.errorColor,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppTheme.errorColor),
                        ),
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
  }

  Widget _buildMyPostsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.article_outlined, color: AppTheme.primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Artikel Saya',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FutureBuilder<List<PostModel>>(
          future: _userPostsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Gagal memuat artikel',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final posts = snapshot.data ?? [];

            if (posts.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 40,
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Belum ada artikel',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mulai tulis artikel pertamamu',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textHint,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: posts.map((post) => _buildPostItem(post)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPostItem(PostModel post) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
        );
        _refreshProfile();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            // Thumbnail
            if (post.picture != null && post.picture!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: post.picture!.startsWith('http')
                    ? Image.network(
                        post.picture!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _postThumbnailPlaceholder(),
                      )
                    : Image.memory(
                        base64Decode(post.picture!),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _postThumbnailPlaceholder(),
                      ),
              )
            else
              _postThumbnailPlaceholder(),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (post.categoryName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post.categoryName!,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Icon(Icons.favorite_outline, size: 12, color: AppTheme.textHint),
                      const SizedBox(width: 2),
                      Text(
                        '${post.likeCount ?? 0}',
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textHint),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.chat_bubble_outline, size: 12, color: AppTheme.textHint),
                      const SizedBox(width: 2),
                      Text(
                        '${post.commentCount ?? 0}',
                        style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textHint),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }

  Widget _postThumbnailPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppTheme.dividerColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_outlined, size: 24, color: AppTheme.textHint),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
