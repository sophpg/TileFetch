import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tilefetch/models/post_model.dart';
import 'package:tilefetch/services/firestore_service.dart';
import 'package:tilefetch/theme/index.dart';
import 'dart:convert';

class PostDetailDialog {
  static Future<void> show(BuildContext context, Post post, FirestoreService firestoreService, VoidCallback onUpdate) async {
    final userId = post.authorUid?.isNotEmpty == true ? post.authorUid! : post.uid;
    final userProfile = await firestoreService.getUserProfile(userId);
    final authorName = userProfile?['nome'] as String? ?? userProfile?['email'] as String? ?? userId;

    if (!context.mounted) return;

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
            side: const BorderSide(color: AppColors.borderDefault, width: 1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    post.titulo,
                    style: AppFonts.body(color: AppColors.textPrimary, size: 32),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppHelpers.borderedContainer(
                    padding: EdgeInsets.zero,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: Center(
                        child: post.imagemUrl.isNotEmpty
                            ? InteractiveViewer(
                                child: Image.network(
                                  post.imagemUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: AppColors.textSecondary),
                                ),
                              )
                            : (post.imagemBase64 != null
                                ? Image.memory(base64Decode(post.imagemBase64!), fit: BoxFit.contain)
                                : const Icon(Icons.broken_image, color: AppColors.textSecondary)),
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
                        borderColor: AppColors.primary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      ValueListenableBuilder<bool>(
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Faça login para curtir.')),
                                );
                                return;
                              }

                              final success = await firestoreService.toggleLike(post.id, user.uid);
                              if (success) {
                                likedNotifier.value = !liked;
                                onUpdate();
                              }
                            },
                          );
                        },
                      ),
                    ],
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
