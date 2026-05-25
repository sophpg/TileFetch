import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tilefetch/models/post_model.dart';
import 'package:tilefetch/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tilefetch/components/search_bar.dart';
import 'package:tilefetch/components/filter_bar.dart';
import 'package:tilefetch/components/post_card.dart';
import 'package:tilefetch/pages/profile_page.dart';
import 'package:tilefetch/theme/index.dart';

const List<String> _commonColorCategories = [
  'Vermelho',
  'Laranja',
  'Amarelo',
  'Verde',
  'Azul',
  'Roxo',
  'Rosa',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ScrollController _scrollController = ScrollController();

  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  List<String> _availableColors = [];
  List<String> _availableTags = [];
  List<Resolucao> _availableResolutions = [];

  bool _isLoading = true;
  bool _hasMore = true;
  String _searchQuery = '';
  int _currentNavIndex = 0;

  Map<String, dynamic> _filters = {
    'color': null,
    'resolution': null,
    'order': 'recente',
    'tags': <String>[],
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final posts = await _firestoreService.fetchPostsHome();
      final tags = await _firestoreService.getAllTags();
      final resolutions = await _firestoreService.getAllResolutions();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final likedIds = await _firestoreService.getUserLikedPostIds(
          currentUser.uid,
        );
        for (var i = 0; i < posts.length; i++) {
          if (likedIds.contains(posts[i].id)) {
            posts[i] = posts[i].copyWith(isLikedByMe: true);
          }
        }
      }

      setState(() {
        _allPosts = posts;
        _filteredPosts = posts;
        _availableColors = _commonColorCategories;
        _availableTags = tags;
        _availableResolutions = resolutions;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados iniciais: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar posts: $e')));
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (!_hasMore || _allPosts.isEmpty) return;

    try {
      final newPosts = await _firestoreService.fetchPostsHome();

      if (newPosts.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }

      setState(() {
        _allPosts.addAll(newPosts);
        _applyFilters();
      });
    } catch (e) {
      print('Erro ao carregar mais posts: $e');
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _handleFilterChange(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Post> result = List.from(_allPosts);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result =
          result
              .where(
                (post) =>
                    post.titulo.toLowerCase().contains(query) ||
                    post.descricao.toLowerCase().contains(query) ||
                    post.tags.any((tag) => tag.toLowerCase().contains(query)),
              )
              .toList();
    }

    if (_filters['color'] != null) {
      final selectedCategory = _filters['color'] as String;
      result =
          result.where((post) {
            return post.cores.any((hex) {
              return _mapHexToColorCategory(hex) == selectedCategory;
            });
          }).toList();
    }

    if (_filters['resolution'] != null) {
      final res = _filters['resolution'] as Resolucao;
      result =
          result
              .where(
                (post) =>
                    post.resolucao.largura == res.largura &&
                    post.resolucao.altura == res.altura,
              )
              .toList();
    }

    if (_filters['tags'] != null &&
        (_filters['tags'] as List<String>).isNotEmpty) {
      result =
          result
              .where(
                (post) => (post.tags as List<String>).any(
                  (tag) => (_filters['tags'] as List<String>).contains(tag),
                ),
              )
              .toList();
    }

    switch (_filters['order']) {
      case 'popular':
        result.sort((a, b) => b.curtidas.compareTo(a.curtidas));
        break;
      case 'curtidas':
        result.sort((a, b) => b.curtidas.compareTo(a.curtidas));
        break;
      case 'recente':
      default:
        result.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
        break;
    }

    setState(() => _filteredPosts = result);
  }

  void _handleBottomNavTap(int index) {
    setState(() => _currentNavIndex = index);

    switch (index) {
      case 0:
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Busca avançada em desenvolvimento')),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload de posts em desenvolvimento')),
        );
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Favoritos em desenvolvimento')),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        ).then((_) {
          setState(() => _currentNavIndex = 0);
        });
        break;
    }
  }

  String _mapHexToColorCategory(String hex) {
    final color = AppHelpers.hexToColor(hex);
    final hsv = HSVColor.fromColor(color);
    final saturation = hsv.saturation;
    final value = hsv.value;

    if (value < 0.25 || saturation < 0.15) {
      return 'Rosa';
    }

    final hue = hsv.hue;
    if (hue < 15 || hue >= 345) return 'Vermelho';
    if (hue < 45) return 'Laranja';
    if (hue < 75) return 'Amarelo';
    if (hue < 165) return 'Verde';
    if (hue < 225) return 'Azul';
    if (hue < 285) return 'Roxo';
    return 'Rosa';
  }

  Future<void> _handlePostTap(String postId) async {
    final post = _allPosts.firstWhere(
      (post) => post.id == postId,
      orElse: () => _allPosts.first,
    );

    final userId =
        post.authorUid?.isNotEmpty == true ? post.authorUid! : post.uid;
    final userProfile = await _firestoreService.getUserProfile(userId);
    final authorName =
        userProfile?['nome'] as String? ??
        userProfile?['email'] as String? ??
        userId;

    if (!mounted) return;

    final likedNotifier = ValueNotifier<bool>(post.isLikedByMe);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.fieldBackground,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.borderDefault, width: 1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  post.titulo,
                  style: AppFonts.title(color: AppColors.textPrimary, size: 20),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppHelpers.borderedContainer(
                  padding: EdgeInsets.zero,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: Center(
                      child:
                          post.imagemUrl.isNotEmpty
                              ? InteractiveViewer(
                                child: Image.network(
                                  post.imagemUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.fieldBackground,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: AppColors.textSecondary,
                                      ),
                                    );
                                  },
                                ),
                              )
                              : (post.imagemBase64 != null
                                  ? Image.memory(
                                    base64Decode(post.imagemBase64!),
                                    fit: BoxFit.contain,
                                  )
                                  : (post.thumbnail.isNotEmpty
                                      ? InteractiveViewer(
                                        child: Image.network(
                                          post.thumbnail,
                                          fit: BoxFit.contain,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Container(
                                              color: AppColors.fieldBackground,
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: AppColors.textSecondary,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      : Container(
                                        color: AppColors.fieldBackground,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: AppColors.textSecondary,
                                        ),
                                      ))),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Criado por: $authorName',
                  style: AppFonts.body(
                    color: AppColors.textPrimary,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  post.descricao,
                  style: AppFonts.body(color: AppColors.textSecondary),
                ),
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tags: ${post.tags.join(', ')}',
                    style: AppFonts.body(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Resolução: ${post.resolucao.largura} x ${post.resolucao.altura}',
                  style: AppFonts.body(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppHelpers.styledButton(
                      label: 'Fechar',
                      onPressed: () => Navigator.of(context).pop(),
                      borderColor: AppColors.primary,
                      textColor: AppColors.background,
                      backgroundColor: AppColors.primary,
                    ),
                    StatefulBuilder(
                      builder: (context, setDialogState) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: likedNotifier,
                          builder: (context, liked, child) {
                            return IconButton(
                              icon: Icon(
                                liked ? Icons.favorite : Icons.favorite_border,
                                color: AppColors.primary,
                              ),
                              onPressed: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user == null) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Faça login para curtir.'),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                final likedSuccess = await _firestoreService
                                    .toggleLike(post.id, user.uid);
                                if (!likedSuccess) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Falha ao atualizar curtida.',
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                likedNotifier.value = !liked;

                                setState(() {
                                  _allPosts =
                                      _allPosts.map((p) {
                                        if (p.id == post.id) {
                                          final isNowLiked = !p.isLikedByMe;
                                          final curtidas =
                                              isNowLiked
                                                  ? p.curtidas + 1
                                                  : (p.curtidas - 1).clamp(
                                                    0,
                                                    999999,
                                                  );
                                          return p.copyWith(
                                            curtidas: curtidas,
                                            isLikedByMe: isNowLiked,
                                          );
                                        }
                                        return p;
                                      }).toList();
                                  _applyFilters();
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLike(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faça login para curtir.')),
        );
      }
      return;
    }

    final likedSuccess = await _firestoreService.toggleLike(postId, user.uid);
    if (!likedSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao atualizar curtida.')),
        );
      }
      return;
    }

    setState(() {
      _allPosts =
          _allPosts.map((p) {
            if (p.id == postId) {
              final isNowLiked = !(p.isLikedByMe);
              final curtidas =
                  isNowLiked
                      ? p.curtidas + 1
                      : (p.curtidas - 1).clamp(0, 999999);
              return p.copyWith(curtidas: curtidas, isLikedByMe: isNowLiked);
            }
            return p;
          }).toList();
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: HomeSearchBar(
          onSearch: _handleSearch,
          onClearSearch: () {
            setState(() {
              _searchQuery = '';
              _applyFilters();
            });
          },
        ),
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
          Column(
            children: [
              FilterBar(
                onFilterChange: _handleFilterChange,
                availableColors: _availableColors,
                availableTags: _availableTags,
                availableResolutions: _availableResolutions,
              ),
              Expanded(
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                        : _filteredPosts.isEmpty
                        ? Center(
                          child: Text(
                            'Nenhum post encontrado',
                            style: AppFonts.body(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                        : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                                childAspectRatio: 3 / 4,
                              ),
                          itemCount: _filteredPosts.length,
                          itemBuilder: (context, index) {
                            return PostCard(
                              post: _filteredPosts[index],
                              onTap: _handlePostTap,
                              onLike: _handleLike,
                            );
                          },
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
