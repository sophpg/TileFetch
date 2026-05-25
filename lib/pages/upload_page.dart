import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/upload_service.dart';
import '../theme/index.dart';

class UploadPage extends StatefulWidget {
  final VoidCallback? onUploadSuccess;

  const UploadPage({super.key, this.onUploadSuccess});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _colorsController = TextEditingController();
  final UploadService _uploadService = UploadService();

  XFile? _selectedImage;
  Uint8List? _previewBytes;
  bool _isUploading = false;
  String? _statusMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _colorsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2048,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();

      setState(() {
        _selectedImage = image;
        _previewBytes = bytes;
        _statusMessage = null;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Falha ao selecionar imagem: $e';
      });
    }
  }

  List<String> _parseCommaSeparated(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _statusMessage = 'Você precisa estar logado para fazer upload.';
      });
      return;
    }

    if (_selectedImage == null) {
      setState(() {
        _statusMessage = 'Selecione uma imagem antes de enviar.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
      _statusMessage = null;
    });

    try {
      await _uploadService.uploadPost(
        imageFile: _selectedImage!,
        titulo: _titleController.text.trim(),
        descricao: _descriptionController.text.trim(),
        tags: _parseCommaSeparated(_tagsController.text),
        cores: _parseCommaSeparated(_colorsController.text),
        useFirestoreOnly: true,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload realizado com sucesso!')),
      );
      widget.onUploadSuccess?.call();
    } on UploadSizeException catch (e) {
      setState(() {
        _statusMessage = e.toString();
      });
    } catch (e) {
      setState(() {
        _statusMessage = _userFriendlyErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  String _userFriendlyErrorMessage(Object error) {
    if (error is UploadSizeException) {
      return error.toString();
    }

    if (error is FirebaseException &&
        error.message != null &&
        error.message!.isNotEmpty) {
      return error.message!;
    }

    final message =
        error
            .toString()
            .replaceAll('Exception:', '')
            .replaceAll('FirebaseException:', '')
            .trim();
    if (message.isNotEmpty) {
      return message;
    }

    return 'Erro ao enviar. Verifique a conexão e tente novamente.';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload de Pixel Art'),
        backgroundColor: AppColors.background,
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
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child:
                    user == null
                        ? Center(
                          child: Text(
                            'Faça login para enviar imagens.',
                            style: AppFonts.body(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Nova publicação',
                                  style: AppFonts.body(
                                    color: AppColors.textPrimary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _previewBytes != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: AppHelpers.borderedContainer(
                                        padding: const EdgeInsets.all(0),
                                        child: Image.memory(
                                          _previewBytes!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                    : SizedBox(
                                      height: 200,
                                      child: AppHelpers.borderedContainer(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.md,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Nenhuma imagem selecionada',
                                            style: AppFonts.body(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                const SizedBox(height: AppSpacing.md),
                                AppHelpers.styledButton(
                                  label: 'Escolher imagem',
                                  onPressed: _pickImage,
                                  borderColor: AppColors.primary,
                                  textColor: AppColors.textPrimary,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                AppHelpers.styledTextField(
                                  controller: _titleController,
                                  label: 'Título',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Informe um título';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppHelpers.styledTextField(
                                  controller: _descriptionController,
                                  label: 'Descrição',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Informe uma descrição';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                                AppHelpers.styledTextField(
                                  controller: _tagsController,
                                  label: 'Tags (separadas por vírgula)',
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  'Tamanho máximo permitido para upload: ~${(UploadService.firestoreMaxImageBytes / 1024).round()} KB.',
                                  style: AppFonts.body(
                                    color: AppColors.textSecondary,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                if (_statusMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.md,
                                    ),
                                    child: Text(
                                      _statusMessage!,
                                      style: AppFonts.body(
                                        color: AppColors.error,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                AppHelpers.styledButton(
                                  label:
                                      _isUploading
                                          ? 'Enviando...'
                                          : 'Enviar publicação',
                                  onPressed: _isUploading ? () {} : _submit,
                                  borderColor: AppColors.primary,
                                  textColor: AppColors.textPrimary,
                                  isDisabled: _isUploading,
                                ),
                              ],
                            ),
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
