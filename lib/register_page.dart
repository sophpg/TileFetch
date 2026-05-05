import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      formatted += numbers.substring(0, numbers.length >= 2 ? 2 : numbers.length);
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
            style: TextStyle(color: theme.colorScheme.primary),
          ),
          backgroundColor: theme.colorScheme.surface,
          behavior: SnackBarBehavior.floating,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crie seu cadastro")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "NOME *"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "O campo \"Nome\" é obrigatório";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "EMAIL *"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "O campo \"Email\" é obrigatório";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "SENHA *"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "O campo \"Senha\" é obrigatório";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "TELEFONE"),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TelefoneInputFormatter(),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _submit();
                  },
                  child: const Text("Cadastre-se"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
