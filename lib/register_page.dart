import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'theme/app_fonts.dart';
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
        await userCredential.user?.updateDisplayName(_nomeController.text.trim());

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
            MaterialPageRoute(builder: (_) => const HomePage()),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
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
    final theme = Theme.of(context);

    const double borderWidth = 0.8;
    const double fieldSpacing = 25;
    const double buttonHeight = 20;
    const double maxContentWidth = 450;
    const double erroMessageSize = 15;

    const Color fieldBackground = Colors.black;
    const Color borderColor = Colors.white;

    const String backgroundPath = "assets/images/background.png";
    const String logoPath = "assets/images/logo.png";

    final OutlineInputBorder defaultBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: borderColor, width: borderWidth),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: theme.colorScheme.primary,
        width: borderWidth,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              backgroundPath,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: maxContentWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        child: Image.asset(
                          logoPath,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        "TileFetch",
                        style: AppFonts.title(color: Colors.white),
                      ),
                      const SizedBox(height: 65),
                      Text(
                        "CADASTRO",
                        style: AppFonts.body(
                          color: theme.colorScheme.primary,
                          weight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 65),
                      TextFormField(
                        controller: _nomeController,
                        style: AppFonts.body(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Nome *",
                          filled: true,
                          fillColor: fieldBackground,
                          labelStyle: AppFonts.body(color: Colors.white70),
                          errorStyle: AppFonts.body(
                            size: erroMessageSize,
                            color: theme.colorScheme.error,
                          ),
                          border: defaultBorder,
                          enabledBorder: defaultBorder,
                          focusedBorder: focusedBorder,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'O campo "Nome" é obrigatório';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: fieldSpacing),
                      TextFormField(
                        controller: _emailController,
                        style: AppFonts.body(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Email *",
                          filled: true,
                          fillColor: fieldBackground,
                          labelStyle: AppFonts.body(color: Colors.white70),
                          errorStyle: AppFonts.body(
                            size: erroMessageSize,
                            color: theme.colorScheme.error,
                          ),
                          border: defaultBorder,
                          enabledBorder: defaultBorder,
                          focusedBorder: focusedBorder,
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
                      SizedBox(height: fieldSpacing),
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _obscurePassword,
                        style: AppFonts.body(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Senha *",
                          filled: true,
                          fillColor: fieldBackground,
                          labelStyle: AppFonts.body(color: Colors.white70),
                          errorStyle: AppFonts.body(
                            size: erroMessageSize,
                            color: theme.colorScheme.error,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: _obscurePassword
                                  ? const Icon(
                                      Pixel.eye,
                                      color: Colors.white70,
                                      size: 30,
                                    )
                                  : SvgPicture.asset(
                                      'assets/icons/eye_off.svg',
                                      width: 20,
                                      height: 20,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white70,
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
                          border: defaultBorder,
                          enabledBorder: defaultBorder,
                          focusedBorder: focusedBorder,
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
                      SizedBox(height: fieldSpacing),
                      TextFormField(
                        controller: _telefoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TelefoneInputFormatter(),
                        ],
                        style: AppFonts.body(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Telefone",
                          filled: true,
                          fillColor: fieldBackground,
                          labelStyle: AppFonts.body(color: Colors.white70),
                          border: defaultBorder,
                          enabledBorder: defaultBorder,
                          focusedBorder: focusedBorder,
                        ),
                      ),
                      const SizedBox(height: 35),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: fieldBackground,
                            padding: const EdgeInsets.symmetric(
                              vertical: buttonHeight,
                            ),
                            side: const BorderSide(
                              color: borderColor,
                              width: borderWidth,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Cadastrar",
                                  style: AppFonts.body(
                                    color: Colors.white,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              vertical: buttonHeight,
                            ),
                            side: const BorderSide(
                              color: borderColor,
                              width: borderWidth,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Já possui uma conta?",
                            style: AppFonts.body(
                              color: Colors.white,
                              weight: FontWeight.bold,
                            ),
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
