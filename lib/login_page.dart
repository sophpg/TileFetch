import 'package:flutter/material.dart';
import 'register_page.dart';
import 'theme/app_fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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

                    SizedBox(height: fieldSpacing),

                    TextField(
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

                        onPressed: () {},

                        child: Text(
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
