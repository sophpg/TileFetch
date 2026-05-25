import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../theme/index.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final Function(String postId) onTap;
  final Function(String postId)? onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.onLike,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.post.id),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.borderDefault,
              width: 0.8,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.post.thumbnail.isNotEmpty
                  ? Image.network(
                      widget.post.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.fieldBackground,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.fieldBackground,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.success,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : (widget.post.thumbnailBase64 != null
                      ? Image.memory(
                          base64Decode(widget.post.thumbnailBase64!),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.fieldBackground,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.textSecondary,
                          ),
                        )),
              if (_isHovered)
                Container(
                  color: AppColors.overlayDark,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Text(
                          widget.post.titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                            size: 14,
                            color: AppColors.textPrimary,
                            weight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        widget.post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                                        color: AppColors.primary,
                                        size: 16,
                                      ),
                                      onPressed: () {
                                        widget.onLike?.call(widget.post.id);
                                      },
                                    ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.post.curtidas.toString(),
                                  style: AppFonts.body(
                                    size: 12,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.post.tags.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Wrap(
                                  spacing: 4,
                                  children: widget.post.tags
                                      .take(2)
                                      .map((tag) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.borderDefault,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Text(
                                              tag,
                                              style: AppFonts.body(
                                                size: 10,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
