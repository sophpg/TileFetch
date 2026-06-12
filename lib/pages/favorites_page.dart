import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tilefetch/services/firestore_service.dart';
import 'package:tilefetch/models/post_model.dart';
import 'package:tilefetch/components/post_card.dart';
import 'package:tilefetch/components/post_detail_dialog.dart';
import 'package:tilefetch/theme/index.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Post> _favoritePosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final posts = await _firestoreService.getUserLikedPosts(user.uid);
        setState(() {
          _favoritePosts = posts;
        });
      }
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLike(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final success = await _firestoreService.toggleLike(postId, user.uid);
    if (success) {
      // Remove from list if unliked
      setState(() {
        _favoritePosts.removeWhere((p) => p.id == postId);
      });
    }
  }

  Future<void> _handlePostTap(String postId) async {
    final post = _favoritePosts.firstWhere((p) => p.id == postId);
    await PostDetailDialog.show(context, post, _firestoreService, () {
      _loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAVORITOS', style: AppFonts.title(size: 20)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.backgroundImage,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(child: Container(color: AppColors.overlayDark)),
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
              : _favoritePosts.isEmpty
              ? Center(
                child: Text(
                  'Nenhum favorito encontrado',
                  style: AppFonts.body(color: AppColors.textSecondary),
                ),
              )
              : GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: _favoritePosts.length,
                itemBuilder: (context, index) {
                  return PostCard(
                    post: _favoritePosts[index],
                    onTap: _handlePostTap,
                    onLike: _handleLike,
                  );
                },
              ),
        ],
      ),
    );
  }
}
