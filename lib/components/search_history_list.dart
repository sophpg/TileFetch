import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../theme/index.dart';

class SearchHistoryList extends StatelessWidget {
  final Function(String) onHistoryTap;

  const SearchHistoryList({super.key, required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const SizedBox.shrink();

    return FutureBuilder<List<String>>(
      future: firestoreService.getSearchHistory(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final history = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300), // Tamanho fixo para alinhar à esquerda
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
                        onTap: () async {
                          await firestoreService.clearSearchHistory(user.uid);
                          (context as Element).markNeedsBuild();
                        },
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
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final query = history[index];
                      return GestureDetector(
                        onTap: () => onHistoryTap(query),
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
