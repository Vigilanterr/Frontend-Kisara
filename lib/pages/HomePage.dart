import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/app_theme.dart';
import 'package:frontend/models/posts_model.dart';
import 'package:frontend/services/api.dart';
import 'package:frontend/pages/PostDetailPage.dart';
import 'package:frontend/widgets/post_card.dart';
import 'package:frontend/widgets/category_chip.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PostModel>> _postsFuture;
  late Future<List<dynamic>> _categoriesFuture;
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _postsFuture = ApiService.getPosts();
    _categoriesFuture = ApiService.getCategories();
  }

  Future<void> _refresh() async {
    setState(() {
      _postsFuture = ApiService.getPosts();
      _categoriesFuture = ApiService.getCategories();
    });
  }

  void _navigateToDetail(PostModel post) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _refresh,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(child: const SizedBox(height: 8)),
            _buildPostsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kisara',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline, color: AppTheme.primaryColor, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Temukan cerita baru',
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Jelajahi artikel dari berbagai topik',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return FutureBuilder<List<dynamic>>(
      future: _categoriesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final categories = snapshot.data!;
        return Container(
          height: 52,
          margin: const EdgeInsets.only(top: 20),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              CategoryChip(
                label: 'Semua',
                isSelected: _selectedCategory == 'Semua',
                onTap: () => setState(() => _selectedCategory = 'Semua'),
              ),
              const SizedBox(width: 8),
              ...categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CategoryChip(
                  label: cat.name,
                  isSelected: _selectedCategory == cat.name,
                  onTap: () => setState(() => _selectedCategory = cat.name),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostsList() {
    return FutureBuilder<List<PostModel>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildSkeleton(),
                childCount: 4,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildErrorState(snapshot.error),
          );
        }

        var posts = snapshot.data ?? [];

        if (_selectedCategory != 'Semua') {
          posts = posts.where((p) => p.categoryName == _selectedCategory).toList();
        }

          if (posts.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => PostCard(
                post: posts[index],
                onTap: () => _navigateToDetail(posts[index]),
              ),
              childCount: posts.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 18,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.dividerColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              child: const Icon(Icons.wifi_off_rounded, size: 40, color: AppTheme.errorColor),
            ),
            const SizedBox(height: 24),
            Text(
              'Gagal memuat artikel',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Periksa koneksi internet dan pastikan server aktif',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.article_outlined, size: 40, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada artikel',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jadilah yang pertama membuat artikel',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
