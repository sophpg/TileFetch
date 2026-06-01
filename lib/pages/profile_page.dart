import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'login_page.dart';
import '../theme/index.dart';
import '../models/post_model.dart';
import '../services/firestore_service.dart';
import '../components/post_card.dart';
import '../components/post_detail_dialog.dart';

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

  final FirestoreService _firestoreService = FirestoreService();
  List<Post> _myPosts = [];
  bool _isLoadingPosts = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserData();
    _loadMyPosts();
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

  Future<void> _loadMyPosts() async {
    if (_currentUser == null) return;
    setState(() => _isLoadingPosts = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: _currentUser!.uid)
          .orderBy('dataCriacao', descending: true)
          .get();

      final posts = snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();

      if (mounted) {
        setState(() {
          _myPosts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPosts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar posts: $e')),
        );
      }
    }
  }

  int _calculateGridColumns(double screenWidth) {
    if (screenWidth < 600) return 2;
    if (screenWidth < 900) return 3;
    if (screenWidth < 1200) return 4;
    if (screenWidth < 1500) return 5;
    return 6;
  }

  void _openPostDetail(String postId) {
    final post = _myPosts.firstWhere((p) => p.id == postId);
    PostDetailDialog.show(context, post, _firestoreService, () {
      _loadMyPosts();
    });
  }

  Future<void> _toggleLike(String postId) async {
    if (_currentUser == null) return;
    await _firestoreService.toggleLike(postId, _currentUser!.uid);
    _loadMyPosts();
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

  Future<void> _saveProfile({required String nome, required String bio}) async {
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
        imageBytes = await picked.readAsBytes();
      } else {
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

      final sizeKB = imageBytes.length / 1024;
      if (sizeKB > 700) {
        throw Exception(
          'Imagem muito grande (${sizeKB.toStringAsFixed(0)} KB). Tente uma foto menor.',
        );
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

  void _showAvatarSourceSheet() {
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'foto de perfil',
                  style: AppFonts.body(
                    color: AppColors.primary,
                    size: 13,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 0.5, color: AppColors.borderDefault),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.textPrimary, size: 20),
                title: Text(
                  'escolher da galeria',
                  style: AppFonts.body(color: AppColors.textPrimary, size: 13),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndSaveAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.textPrimary, size: 20),
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

  void _showEditProfileDialog() {
    final nomeCtrl = TextEditingController(text: _userData?['nome'] ?? '');
    final bioCtrl = TextEditingController(text: _userData?['bio'] ?? '');
    bool saving = false;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: AppColors.fieldBackground,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDefault, width: 1),
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
                    Text('nome', style: AppFonts.body(color: AppColors.textSecondary, size: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nomeCtrl,
                      style: AppFonts.body(color: AppColors.textPrimary, size: 13),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.borderDefault, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('bio', style: AppFonts.body(color: AppColors.textSecondary, size: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: bioCtrl,
                      maxLines: 3,
                      style: AppFonts.body(color: AppColors.textPrimary, size: 13),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.black,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.borderDefault, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: AppButtons.secondaryButtonStyle(),
                            onPressed: saving ? null : () => Navigator.pop(ctx),
                            child: Text(
                              'cancelar',
                              style: AppFonts.body(color: AppColors.textSecondary, size: AppSpacing.md),
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
                                      size: AppSpacing.md,
                                      weight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
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
              filterQuality: FilterQuality.none,
            ),
          ),
          Positioned.fill(child: Container(color: AppColors.overlayDark)),

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
              child: RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.fieldBackground,
                onRefresh: () async {
                  await Future.wait([_loadUserData(), _loadMyPosts()]);
                },
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
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Meus pixels',
                                  style: AppFonts.body(
                                    color: AppColors.textPrimary,
                                    size: 14,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!_isLoadingPosts)
                                  Text(
                                    '(${_myPosts.length})',
                                    style: AppFonts.body(
                                      color: AppColors.textSecondary,
                                      size: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_isLoadingPosts)
                      const SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (_myPosts.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                color: AppColors.textDisabled,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhum post ainda',
                                style: AppFonts.body(
                                  color: AppColors.textSecondary,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.all(2),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => PostCard(
                              post: _myPosts[index],
                              onTap: _openPostDetail,
                              onLike: _toggleLike,
                            ),
                            childCount: _myPosts.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _calculateGridColumns(
                              MediaQuery.of(context).size.width,
                            ),
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            childAspectRatio: 0.65,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPixelButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppFonts.body(
                color: AppColors.textSecondary,
                size: 9,
                weight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final nome =
        (_userData?['nome'] as String?)?.isNotEmpty == true
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
                    border: Border.all(color: AppColors.primary, width: 2),
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
                        border: Border.all(color: AppColors.background, width: 1.5),
                      ),
                      child: const Icon(Icons.edit, color: Colors.black, size: AppSpacing.md),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

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
                Text(
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
              ],
            ),
          ),

          const SizedBox(width: 12),

          Row(
            children: [
              _buildPixelButton(
                icon: Icons.edit_outlined,
                label: 'EDITAR\nPERFIL',
                onTap: _showEditProfileDialog,
              ),
              const SizedBox(width: 8),
              _buildPixelButton(
                icon: Pixel.logout,
                label: 'SAIR',
                onTap: _handleLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }
}