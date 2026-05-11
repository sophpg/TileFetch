import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'theme/app_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos.")),
      );
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
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Ocorreu um erro ao entrar.";
      if (e.code == 'user-not-found') {
        message = "Usuário não encontrado.";
      } else if (e.code == 'wrong-password') {
        message = "Senha incorreta.";
      } else if (e.code == 'invalid-email') {
        message = "E-mail inválido.";
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
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
    final theme = Theme.of(context);

    const double borderWidth = 0.8;
    const double fieldSpacing = 25;
    const double buttonHeight = 20;
    const double maxContentWidth = 450;

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
                      "LOGIN",
                      style: AppFonts.body(
                        color: theme.colorScheme.primary,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 65),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppFonts.body(size: 18, color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        filled: true,
                        fillColor: fieldBackground,
                        labelStyle: AppFonts.body(
                          color: Colors.white70,
                        ),
                        border: defaultBorder,
                        enabledBorder: defaultBorder,
                        focusedBorder: focusedBorder,
                      ),
                    ),
                    const SizedBox(height: fieldSpacing),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: AppFonts.body(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Senha",
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
                        onPressed: _isLoading ? null : _signIn,
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
                                "Entrar",
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
        ],
      ),
    );
  }
}
