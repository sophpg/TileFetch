import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_navigation_page.dart';
import 'theme/index.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pixelarticons/pixelarticons.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String numbers = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.length > 11) {
      numbers = numbers.substring(0, 11);
    }

    String formatted = '';

    if (numbers.isNotEmpty) {
      formatted += '(';
      formatted += numbers.substring(
        0,
        numbers.length >= 2 ? 2 : numbers.length,
      );
    }

    if (numbers.length >= 2) {
      formatted += ') ';
    }

    if (numbers.length > 2) {
      int end = numbers.length >= 7 ? 7 : numbers.length;
      formatted += numbers.substring(2, end);
    }

    if (numbers.length >= 7) {
      formatted += '-';
      formatted += numbers.substring(7);
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Criar usuário no Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _senhaController.text.trim(),
            );

        // Opcional: Atualizar o nome do usuário no perfil do Firebase
        await userCredential.user?.updateDisplayName(
          _nomeController.text.trim(),
        );

        // Salvar dados adicionais no Cloud Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'nome': _nomeController.text.trim(),
              'email': _emailController.text.trim(),
              'telefone': _telefoneController.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
            });

        if (mounted) {
          final theme = Theme.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Cadastro realizado com sucesso!",
                style: AppFonts.body(color: theme.colorScheme.primary),
              ),
              backgroundColor: theme.colorScheme.surface,
              behavior: SnackBarBehavior.floating,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: Colors.white, width: 1),
              ),
            ),
          );

          // Navegar para a Home
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationPage()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = "Erro ao cadastrar.";
        if (e.code == 'email-already-in-use') {
          message = "Este e-mail já está em uso.";
        } else if (e.code == 'invalid-email') {
          message = "E-mail inválido.";
        } else if (e.code == 'weak-password') {
          message = "A senha é muito fraca.";
        }

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro inesperado: ${e.toString()}")),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.maxContentWidth,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: AppSpacing.logoWidth,
                        child: Image.asset(
                          AppAssets.logoImage,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        "TileFetch",
                        style: AppFonts.title(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      Text(
                        "CADASTRO",
                        style: AppFonts.body(
                          color: AppColors.primary,
                          weight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      TextFormField(
                        controller: _nomeController,
                        style: AppTextFields.inputTextStyle(),
                        decoration: AppTextFields.requiredInputDecoration(
                          label: "Nome",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'O campo "Nome" é obrigatório';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.fieldSpacing),
                      TextFormField(
                        controller: _emailController,
                        style: AppTextFields.inputTextStyle(),
                        decoration: AppTextFields.requiredInputDecoration(
                          label: "Email",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'O campo "Email" é obrigatório';
                          }
                          final emailRegex = RegExp(
                            r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value)) {
                            return 'Insira um email válido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.fieldSpacing),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _obscurePassword,
                        style: AppTextFields.inputTextStyle(),
                        decoration: AppTextFields.passwordInputDecoration(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.sm,
                            ),
                            child: IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon:
                                  _obscurePassword
                                      ? const Icon(
                                        Pixel.eye,
                                        color: AppColors.textSecondary,
                                        size: 30,
                                      )
                                      : SvgPicture.asset(
                                        AppAssets.eyeOffIcon,
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.textSecondary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'O campo "Senha" é obrigatório';
                          }
                          if (value.length < 8) {
                            return 'A senha deve ter ao menos 8 caracteres';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'A senha precisa de uma letra maiúscula';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'A senha precisa de uma letra minúscula';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'A senha precisa de um número';
                          }
                          if (!RegExp(
                            r'[!@#$%^&*(),.?":{}|<>]',
                          ).hasMatch(value)) {
                            return 'A senha precisa de um caractere especial';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.fieldSpacing),
                      TextFormField(
                        controller: _telefoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TelefoneInputFormatter(),
                        ],
                        style: AppTextFields.inputTextStyle(),
                        decoration: AppTextFields.phoneInputDecoration(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: AppButtons.primaryButtonStyle(),
                          onPressed: _isLoading ? null : _submit,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: AppColors.textPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    "Cadastrar",
                                    style: AppButtons.buttonTextStyle(),
                                  ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: AppButtons.secondaryButtonStyle(),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Já possui uma conta?",
                            style: AppButtons.buttonTextStyle(),
                          ),
                        ),
                      ),
                    ],
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
