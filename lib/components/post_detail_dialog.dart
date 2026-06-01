import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tilefetch/models/post_model.dart';
import 'package:tilefetch/services/firestore_service.dart';
import 'package:tilefetch/theme/index.dart';
import 'dart:convert';

class PostDetailDialog {
  static Future<void> show(
    BuildContext context,
    Post post,
    FirestoreService firestoreService,
    VoidCallback onUpdate,
  ) async {
    final userId =
        post.authorUid?.isNotEmpty == true ? post.authorUid! : post.uid;
    final userProfile = await firestoreService.getUserProfile(userId);
    final authorName =
        userProfile?['nome'] as String? ??
        userProfile?['email'] as String? ??
        userId;

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
                    style: AppFonts.body(
                      color: AppColors.textPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ImageZoomViewer(
                    post: post,
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
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
                                  const SnackBar(
                                    content: Text('Faça login para curtir.'),
                                  ),
                                );
                                return;
                              }

                              final success = await firestoreService.toggleLike(
                                post.id,
                                user.uid,
                              );
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

class _ImageZoomViewer extends StatefulWidget {
  final Post post;
  final double maxHeight;

  const _ImageZoomViewer({required this.post, required this.maxHeight});

  @override
  State<_ImageZoomViewer> createState() => _ImageZoomViewerState();
}

class _ImageZoomViewerState extends State<_ImageZoomViewer> {
  late double _zoomLevel;
  late double _calculatedZoom;
  final TransformationController _transformationController =
      TransformationController();
  late ValueNotifier<bool> _isZoomModified;

  @override
  void initState() {
    super.initState();
    _calculatedZoom = _calculateInitialZoom();
    _zoomLevel = 1.0;
    _isZoomModified = ValueNotifier<bool>(false);
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final isModified =
        _transformationController.value != Matrix4.identity() ||
        (_zoomLevel - 1.0).abs() > 0.01;
    _isZoomModified.value = isModified;
  }

  ({double width, double height}) _calculateContainerSize(
    double maxAvailableWidth,
    double maxAvailableHeight,
  ) {
    final imageWidth = (widget.post.resolucao.largura ?? 1920).toDouble();
    final imageHeight = (widget.post.resolucao.altura ?? 1080).toDouble();
    final isSquare = (imageWidth - imageHeight).abs() < 1;

    final squareSize =
        maxAvailableWidth < maxAvailableHeight
            ? maxAvailableWidth
            : maxAvailableHeight;
    return (width: squareSize, height: squareSize);
  }

  double _calculateInitialZoom() {
    const double targetSize = 300.0;
    final imageDimension = (widget.post.resolucao.largura ?? 1920).toDouble();
    final imageHeight = (widget.post.resolucao.altura ?? 1080).toDouble();

    final maxImageDim =
        imageDimension > imageHeight ? imageDimension : imageHeight;
    return targetSize / maxImageDim;
  }

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.2).clamp(0.5, 4.0);
    });
    _onTransformationChanged();
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.2).clamp(0.5, 4.0);
    });
    _onTransformationChanged();
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
    });
    _transformationController.value = Matrix4.identity();
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    _isZoomModified.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final size = _calculateContainerSize(
              constraints.maxWidth,
              widget.maxHeight,
            );

            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderDefault, width: 0.8),
              ),
              width: size.width,
              height: size.height,
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.5,
                maxScale: 4.0,
                child: _buildImage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImage() {
    final imageWidth = (widget.post.resolucao.largura ?? 1920).toDouble();
    final imageHeight = (widget.post.resolucao.altura ?? 1080).toDouble();
    final isSquare = (imageWidth - imageHeight).abs() < 1;

    final fit = isSquare ? BoxFit.cover : BoxFit.contain;

    if (widget.post.imagemUrl.isNotEmpty) {
      return Image.network(
        widget.post.imagemUrl,
        fit: fit,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
        errorBuilder:
            (context, error, stackTrace) =>
                const Icon(Icons.broken_image, color: AppColors.textSecondary),
      );
    } else if (widget.post.imagemBase64 != null) {
      return Image.memory(
        base64Decode(widget.post.imagemBase64!),
        fit: fit,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
      );
    } else {
      return const Icon(Icons.broken_image, color: AppColors.textSecondary);
    }
  }
}
