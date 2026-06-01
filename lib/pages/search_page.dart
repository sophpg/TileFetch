import 'package:flutter/material.dart';
import 'package:tilefetch/services/firestore_service.dart';
import 'package:tilefetch/models/post_model.dart';
import 'package:tilefetch/components/filter_bar.dart';
import 'package:tilefetch/components/post_card.dart';
import 'package:tilefetch/components/search_bar.dart';
import 'package:tilefetch/components/post_detail_dialog.dart';
import 'package:tilefetch/components/search_history_list.dart';
import 'package:tilefetch/theme/index.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdvancedSearchPage extends StatefulWidget {
  const AdvancedSearchPage({super.key});

  @override
  State<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Post> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _currentQuery = '';
  int _historyKey = 0;

  final List<String> _availableColors = [
    'Vermelho',
    'Laranja',
    'Amarelo',
    'Verde',
    'Azul',
    'Roxo',
    'Rosa',
  ];
  List<String> _availableTags = [];
  List<Resolucao> _availableResolutions = [];

  Map<String, dynamic> _filters = {
    'color': null,
    'resolution': null,
    'order': 'recente',
    'tags': <String>[],
  };

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final tags = await _firestoreService.getAllTags();
      final resolutions = await _firestoreService.getAllResolutions();
      setState(() {
        _availableTags = tags;
        _availableResolutions = resolutions;
      });
    } catch (e) {
      print('Erro ao carregar metadados: $e');
    }
  }

  int _calculateGridColumns(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1200) return 4;
    if (screenWidth < 1500) return 5;
    return 6;
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults = [];
        _currentQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _currentQuery = query;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await _firestoreService.saveSearchQuery(user.uid, query.trim());
      }

      final results = await _firestoreService.searchPosts(
        query,
        userId: user?.uid,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
        _historyKey++;
      });
    } catch (e) {
      print('Erro na busca: $e');
      setState(() => _isLoading = false);
    }
  }

  void _handleFilterChange(Map<String, dynamic> filters) {
    setState(() {
      _filters = filters;
    });
  }

  Future<void> _handlePostTap(String postId) async {
    final post = _searchResults.firstWhere((p) => p.id == postId);
    await PostDetailDialog.show(context, post, _firestoreService, () {
      setState(() {});
    });
  }

  Future<void> _handleLike(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final success = await _firestoreService.toggleLike(postId, user.uid);
    if (!success) return;

    setState(() {
      _searchResults =
          _searchResults.map((p) {
            if (p.id != postId) return p;
            final isNowLiked = !p.isLikedByMe;
            return p.copyWith(
              isLikedByMe: isNowLiked,
              curtidas:
                  isNowLiked
                      ? p.curtidas + 1
                      : (p.curtidas - 1).clamp(0, 999999),
            );
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: HomeSearchBar(
        onSearch: (q) {
          if (q.isEmpty && _hasSearched) {
            setState(() => _hasSearched = false);
          }
        },
        onSubmitted: _handleSearch,
        onClearSearch: () {
          setState(() {
            _hasSearched = false;
            _searchResults = [];
            _currentQuery = '';
          });
        },
      ),
      body: Column(
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
                    : (!_hasSearched)
                    ? SearchHistoryList(
                      key: ValueKey(_historyKey),
                      onHistoryTap: _handleSearch,
                    )
                    : _searchResults.isEmpty
                    ? Center(
                      child: Text(
                        'Nenhum resultado encontrado',
                        style: AppFonts.body(color: AppColors.textSecondary),
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _calculateGridColumns(
                          MediaQuery.of(context).size.width,
                        ),
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return PostCard(
                          post: _searchResults[index],
                          onTap: _handlePostTap,
                          onLike: _handleLike,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
