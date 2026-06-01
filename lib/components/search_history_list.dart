import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../theme/index.dart';

class SearchHistoryList extends StatefulWidget {
  final Function(String) onHistoryTap;

  const SearchHistoryList({super.key, required this.onHistoryTap});

  @override
  State<SearchHistoryList> createState() => _SearchHistoryListState();
}

class _SearchHistoryListState extends State<SearchHistoryList> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<String>> _historyFuture;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    if (_user == null) return;
    setState(() {
      _historyFuture = _firestoreService.getSearchHistory(_user!.uid);
    });
  }

  Future<void> _clearHistory() async {
    if (_user == null) return;
    await _firestoreService.clearSearchHistory(_user!.uid);
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) return const SizedBox.shrink();

    return FutureBuilder<List<String>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final history = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PESQUISAS RECENTES',
                        style: AppFonts.body(
                          color: AppColors.textSecondary,
                          weight: FontWeight.bold,
                          size: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: _clearHistory,
                        child: Text(
                          'LIMPAR',
                          style: AppFonts.body(
                            color: AppColors.primary,
                            size: AppSpacing.md,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final query = history[index];
                      return GestureDetector(
                        onTap: () => widget.onHistoryTap(query),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history,
                              color: AppColors.textDisabled,
                              size: 16,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                query,
                                style: AppFonts.body(
                                  color: AppColors.textPrimary,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
