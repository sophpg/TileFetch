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

  final List<String> _availableColors = ['Vermelho', 'Laranja', 'Amarelo', 'Verde', 'Azul', 'Roxo', 'Rosa'];
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
      final results = await _firestoreService.searchPosts(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
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
    await _firestoreService.toggleLike(postId, user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : (!_hasSearched)
                        ? SearchHistoryList(
                            onHistoryTap: (query) {
                              _handleSearch(query);
                              // Note: We might need a way to update the text field in HomeSearchBar
                              // This would require a controller shared or a key. 
                              // For now, it will trigger the search.
                            },
                          )
                        : _searchResults.isEmpty
                            ? Center(child: Text('Nenhum resultado encontrado', style: AppFonts.body(color: AppColors.textSecondary)))
                            : GridView.builder(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
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
        ],
      ),
    );
  }
}
