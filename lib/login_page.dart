import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_navigation_page.dart';
import 'register_page.dart';
import 'theme/index.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _passwordError;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O campo "Email" é obrigatório';
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Insira um email válido';
    }
    return null;
  }

  Future<void> _signIn() async {
    _passwordError = null;

    if (!_formKey.currentState!.validate()) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Ocorreu um erro ao entrar.";
      if (e.code == 'user-not-found') {
        _passwordError = "Usuário não encontrado.";
      } else if (e.code == 'wrong-password') {
        _passwordError = "Senha incorreta.";
      } else if (e.code == 'invalid-email') {
        _passwordError = "E-mail inválido.";
      } else {
        message = e.message ?? "Erro ao entrar.";
      }

      if (mounted) {
        setState(() {});
        if (_passwordError == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
          Positioned.fill(
            child: Container(color: AppColors.overlayDark),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
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
                        "LOGIN",
                        style: AppFonts.body(
                          color: AppColors.primary,
                          weight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextFields.inputTextStyle(size: 18),
                        decoration: AppTextFields.emailInputDecoration(),
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: AppSpacing.fieldSpacing),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: AppTextFields.inputTextStyle(),
                        decoration: InputDecoration(
                          labelText: "Senha",
                          filled: true,
                          fillColor: AppColors.fieldBackground,
                          labelStyle: AppFonts.body(
                            color: AppColors.textSecondary,
                          ),
                          errorStyle: AppFonts.body(
                            size: 15,
                            color: AppColors.error,
                          ),
                          border: AppBorders.defaultInputBorder,
                          enabledBorder: AppBorders.defaultInputBorder,
                          focusedBorder: AppBorders.focusedInputBorder,
                          errorBorder: AppBorders.errorInputBorder,
                          focusedErrorBorder: AppBorders.errorInputBorder,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.inputPadding,
                            vertical: AppSpacing.inputPadding,
                          ),
                        ),
                        validator: (value) {
                          if (_validateEmail(_emailController.text) != null) {
                            return null;
                          }
                          if (_passwordError != null) {
                            return _passwordError;
                          }
                          if (value == null || value.isEmpty) {
                            return 'O campo "Senha" é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: AppButtons.primaryButtonStyle(),
                          onPressed: _isLoading ? null : _signIn,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.textPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Entrar",
                                  style: AppButtons.buttonTextStyle(),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: AppButtons.primaryButtonStyle(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Cadastrar-se",
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
