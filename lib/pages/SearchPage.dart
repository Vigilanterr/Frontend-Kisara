import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/app_theme.dart';
import 'package:frontend/models/posts_model.dart';
import 'package:frontend/services/api.dart';
import 'package:frontend/pages/PostDetailPage.dart';
import 'package:frontend/widgets/post_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  List<PostModel> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await ApiService.searchPosts(query);
      if (mounted) setState(() => _results = results);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencari: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
      _hasSearched = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jelajahi',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Temukan artikel yang menarik',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari artikel...',
                    hintStyle: GoogleFonts.inter(color: AppTheme.textHint),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textHint, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.textHint, size: 20),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _search(),
                  onChanged: (val) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                    ? _buildInitialState()
                    : _results.isEmpty
                        ? _buildEmptyState()
                        : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
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
            child: const Icon(Icons.explore_outlined, size: 40, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'Mulai mencari',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ketik kata kunci untuk menemukan artikel',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.textHint.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 40, color: AppTheme.textHint),
          ),
          const SizedBox(height: 24),
          Text(
            'Artikel tidak ditemukan',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba kata kunci lain untuk "${_searchController.text}"',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final post = _results[index];
        return PostCard(
          post: post,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
            );
          },
        );
      },
    );
  }
}
