import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      print('Erro ao carregar dados do usuário: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Perfil',
          style: AppFonts.title(color: AppColors.textPrimary, size: 20),
        ),
        leading: const SizedBox.shrink(),
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
          Positioned.fill(
            child: Container(color: AppColors.overlayDark),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                )
              : _currentUser == null
                  ? Center(
                      child: Text(
                        'Usuário não autenticado',
                        style: AppFonts.body(color: AppColors.textSecondary),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.pagePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              color: AppColors.fieldBackground,
                            ),
                            child: _userData?['avatarUrl'] != null
                                ? Image.network(
                                    _userData!['avatarUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.account_circle,
                                        color: AppColors.primary,
                                        size: 60,
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.account_circle,
                                    color: AppColors.primary,
                                    size: 60,
                                  ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          Text(
                            _userData?['nome'] ?? _currentUser!.displayName ?? 'Sem nome',
                            style: AppFonts.title(
                              color: AppColors.textPrimary,
                              size: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Text(
                            _currentUser!.email ?? 'Sem email',
                            style: AppFonts.body(
                              color: AppColors.textSecondary,
                              size: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.cardPadding),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.borderDefault,
                                width: 0.8,
                              ),
                              color: AppColors.fieldBackground,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow('Telefone:', _userData?['telefone'] ?? 'Não informado'),
                                const SizedBox(height: AppSpacing.md),
                                _buildInfoRow('Bio:', _userData?['bio'] ?? 'Sem bio'),
                                const SizedBox(height: AppSpacing.md),
                                _buildInfoRow(
                                  'Posts:',
                                  (_userData?['postsCount'] ?? 0).toString(),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _buildInfoRow(
                                  'Seguidores:',
                                  (_userData?['seguidores'] ?? 0).toString(),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _buildInfoRow(
                                  'Seguindo:',
                                  (_userData?['seguindo'] ?? 0).toString(),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _buildInfoRow(
                                  'Membro desde:',
                                  _userData?['createdAt'] != null
                                      ? _formatDate(_userData!['createdAt'])
                                      : 'Data indisponível',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),

                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  AppColors.error.withOpacity(0.2),
                                ),
                                side: WidgetStateProperty.all(
                                  const BorderSide(
                                    color: AppColors.error,
                                    width: 1.0,
                                  ),
                                ),
                                padding: WidgetStateProperty.all(
                                  const EdgeInsets.symmetric(
                                    vertical: AppSpacing.buttonHeight,
                                  ),
                                ),
                                shape: WidgetStateProperty.all(
                                  const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                              ),
                              onPressed: _handleLogout,
                              child: Text(
                                'SAIR DA CONTA',
                                style: AppFonts.body(
                                  color: AppColors.error,
                                  weight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          Opacity(
                            opacity: 0.5,
                            child: Text(
                              'ID: ${_currentUser!.uid}',
                              style: AppFonts.body(
                                size: 10,
                                color: AppColors.textDisabled,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppFonts.body(
            color: AppColors.textSecondary,
            size: 12,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppFonts.body(
              color: AppColors.textPrimary,
              size: 12,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        return '${date.day}/${date.month}/${date.year}';
      }
      return 'Data inválida';
    } catch (e) {
      return 'Data indisponível';
    }
  }
}
