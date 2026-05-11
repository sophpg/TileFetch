import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final theme = Theme.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Cadastro realizado!",
            style: AppFonts.body(color: theme.colorScheme.primary),
          ),

          backgroundColor: theme.colorScheme.surface,

          behavior: SnackBarBehavior.floating,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,

            side: BorderSide(color: theme.colorScheme.primary, width: 1),
          ),
        ),
      );
    }
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
                              icon:
                                  _obscurePassword
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

                          onPressed: _submit,

                          child: Text(
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
