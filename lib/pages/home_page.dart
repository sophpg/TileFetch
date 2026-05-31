import 'package:flutter/material.dart';
import 'package:tilefetch/models/post_model.dart';
import 'package:tilefetch/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tilefetch/components/search_bar.dart';
import 'package:tilefetch/components/filter_bar.dart';
import 'package:tilefetch/components/post_card.dart';
import 'package:tilefetch/components/post_detail_dialog.dart';
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

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && query.trim().isNotEmpty) {
      _firestoreService.saveSearchQuery(user.uid, query);
    }
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

    await PostDetailDialog.show(context, post, _firestoreService, () {
      setState(() {
        _loadInitialData();
      });
    });
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
      appBar: HomeSearchBar(
        onSearch: (q) {
          setState(() {
            _searchQuery = q;
            _applyFilters();
          });
        },
        onSubmitted: _handleSearch,
        onClearSearch: () {
          setState(() {
            _searchQuery = '';
            _applyFilters();
          });
        },
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
