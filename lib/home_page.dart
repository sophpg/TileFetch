import 'package:flutter/material.dart';
import 'package:tilefetch/models/post_model.dart';
import 'package:tilefetch/services/firestore_service.dart';
import 'package:tilefetch/components/search_bar.dart';
import 'package:tilefetch/components/filter_bar.dart';
import 'package:tilefetch/components/post_card.dart';
import 'package:tilefetch/pages/profile_page.dart';
import 'package:tilefetch/theme/index.dart';

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
      final colors = await _firestoreService.getAllColors();
      final tags = await _firestoreService.getAllTags();
      final resolutions = await _firestoreService.getAllResolutions();

      setState(() {
        _allPosts = posts;
        _filteredPosts = posts;
        _availableColors = colors;
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
      final newPosts = await _firestoreService
          .fetchPostsHome();

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
      result =
          result
              .where((post) => post.cores.contains(_filters['color']))
              .toList();
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

    if (_filters['tags'] != null && (_filters['tags'] as List<String>).isNotEmpty) {
      result = result
          .where((post) => (post.tags as List<String>).any(
                (tag) => (_filters['tags'] as List<String>).contains(tag),
              ))
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
                                crossAxisCount: 4,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.md,
                              ),
                          itemCount: _filteredPosts.length,
                          itemBuilder: (context, index) {
                            return PostCard(
                              post: _filteredPosts[index],
                              onTap: (postId) {
                                print('Clicou no post: $postId');
                              },
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
