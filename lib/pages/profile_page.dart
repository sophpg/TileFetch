import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'login_page.dart';
import '../theme/index.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isUploadingAvatar = false;

  final List<String> _myPosts = [];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (mounted) {
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar perfil: $e')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer logout: $e')),
        );
      }
    }
  }

  // ── Salva nome + bio no Firestore ──────────────────────────────────────────
  Future<void> _saveProfile({
    required String nome,
    required String bio,
  }) async {
    if (_currentUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({'nome': nome, 'bio': bio}, SetOptions(merge: true));

      setState(() {
        _userData = {...?_userData, 'nome': nome, 'bio': bio};
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: $e')),
        );
      }
    }
  }

  // ── Abre galeria/câmera, comprime e salva Base64 no Firestore ─────────────
  Future<void> _pickAndSaveAvatar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingAvatar = true);

      Uint8List imageBytes;

      if (kIsWeb) {
        // Na web: flutter_image_compress não é suportado.
        // Usa os bytes direto do image_picker (já redimensionado pelo maxWidth/maxHeight acima).
        imageBytes = await picked.readAsBytes();
      } else {
        // Mobile/desktop: comprime com flutter_image_compress
        final compressed = await FlutterImageCompress.compressWithFile(
          picked.path,
          minWidth: 256,
          minHeight: 256,
          quality: 70,
          format: CompressFormat.jpeg,
        );
        if (compressed == null) throw Exception('Falha ao comprimir imagem');
        imageBytes = compressed;
      }

      // Verifica tamanho final (limite seguro para o Firestore: ~700 KB)
      final sizeKB = imageBytes.length / 1024;
      if (sizeKB > 700) {
        throw Exception(
            'Imagem muito grande (${sizeKB.toStringAsFixed(0)} KB). Tente uma foto menor.');
      }

      final base64Str = base64Encode(imageBytes);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({'avatarBase64': base64Str}, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _userData = {...?_userData, 'avatarBase64': base64Str};
          _isUploadingAvatar = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  // ── Bottom sheet: escolher galeria ou câmera ───────────────────────────────
  void _showAvatarSourceSheet() {
    // Na web, câmera via ImageSource.camera pode não funcionar em todos os browsers.
    // Oferece apenas galeria na web para evitar erros.
    if (kIsWeb) {
      _pickAndSaveAvatar(ImageSource.gallery);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.fieldBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.borderDefault, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'foto de perfil',
                  style: AppFonts.body(
                    color: AppColors.primary,
                    size: 13,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                  height: 1, thickness: 0.5, color: AppColors.borderDefault),

              // Galeria
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.textPrimary, size: 20),
                title: Text(
                  'escolher da galeria',
                  style: AppFonts.body(color: AppColors.textPrimary, size: 13),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSaveAvatar(ImageSource.gallery);
                },
              ),

              // Câmera
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.textPrimary, size: 20),
                title: Text(
                  'tirar foto',
                  style: AppFonts.body(color: AppColors.textPrimary, size: 13),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSaveAvatar(ImageSource.camera);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ── Dialog: editar nome e bio ──────────────────────────────────────────────
  void _showEditProfileDialog() {
    final nomeCtrl =
        TextEditingController(text: _userData?['nome'] ?? '');
    final bioCtrl =
        TextEditingController(text: _userData?['bio'] ?? '');
    bool saving = false;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.fieldBackground,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero),
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.borderDefault, width: 1),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'editar perfil',
                    style: AppFonts.body(
                      color: AppColors.primary,
                      size: 14,
                      weight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'nome',
                    style: AppFonts.body(
                        color: AppColors.textSecondary, size: 11),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nomeCtrl,
                    style: AppFonts.body(
                        color: AppColors.textPrimary, size: 13),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                            color: AppColors.borderDefault, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'bio',
                    style: AppFonts.body(
                        color: AppColors.textSecondary, size: 11),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: bioCtrl,
                    maxLines: 3,
                    style: AppFonts.body(
                        color: AppColors.textPrimary, size: 13),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                            color: AppColors.borderDefault, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: AppButtons.secondaryButtonStyle(),
                          onPressed:
                              saving ? null : () => Navigator.pop(ctx),
                          child: Text(
                            'cancelar',
                            style: AppFonts.body(
                                color: AppColors.textSecondary, size: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton(
                          style: AppButtons.primaryButtonStyle(),
                          onPressed: saving
                              ? null
                              : () async {
                                  setDialogState(() => saving = true);
                                  await _saveProfile(
                                    nome: nomeCtrl.text.trim(),
                                    bio: bioCtrl.text.trim(),
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                },
                          child: saving
                              ? const SizedBox(
                                  height: 14,
                                  width: 14,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'salvar',
                                  style: AppFonts.body(
                                      color: AppColors.primary,
                                      size: 12,
                                      weight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.backgroundImage,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(
            child: Container(color: AppColors.overlayDark),
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (_currentUser == null)
            Center(
              child: Text(
                'Usuário não autenticado',
                style: AppFonts.body(color: AppColors.textSecondary),
              ),
            )
          else
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),

                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: AppColors.borderDefault,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Text(
                            'Meus pixels',
                            style: AppFonts.body(
                              color: AppColors.textPrimary,
                              size: 14,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_myPosts.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Nenhum post ainda',
                          style: AppFonts.body(
                            color: AppColors.textSecondary,
                            size: 14,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => Image.network(
                          _myPosts[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.fieldBackground,
                            child: const Icon(
                              Icons.broken_image,
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ),
                        childCount: _myPosts.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        childAspectRatio: 0.65,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final nome = (_userData?['nome'] as String?)?.isNotEmpty == true
        ? _userData!['nome'] as String
        : (_currentUser!.displayName ?? 'Sem nome');
    final bio = (_userData?['bio'] as String?) ?? '';
    final base64Str = _userData?['avatarBase64'] as String?;

    Uint8List? avatarBytes;
    if (base64Str != null && base64Str.isNotEmpty) {
      try {
        avatarBytes = base64Decode(base64Str);
      } catch (_) {
        avatarBytes = null;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar circular ──────────────────────────────────────────
          GestureDetector(
            onTap: _isUploadingAvatar ? null : _showAvatarSourceSheet,
            onLongPress: _handleLogout,
            child: Stack(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.primary, width: 2),
                    color: AppColors.fieldBackground,
                  ),
                  child: ClipOval(
                    child: _isUploadingAvatar
                        ? const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : avatarBytes != null
                            ? Image.memory(
                                avatarBytes,
                                key: ValueKey(base64Str!.hashCode),
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.account_circle,
                                color: AppColors.primary,
                                size: 40,
                              ),
                  ),
                ),
                if (!_isUploadingAvatar)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.background, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── Nome + bio ───────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nome,
                  style: AppFonts.body(color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        bio.isNotEmpty ? bio : 'Adicione uma bio',
                        style: AppFonts.body(
                          color: bio.isNotEmpty
                              ? AppColors.textSecondary
                              : AppColors.textDisabled,
                          size: 13,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _showEditProfileDialog,
                      child: Text(
                        '+',
                        style: AppFonts.body(
                          color: AppColors.primary,
                          size: 18,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}