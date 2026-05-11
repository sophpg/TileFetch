import 'package:flutter/material.dart';
import 'login_page.dart';
import 'theme/app_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData.dark(useMaterial3: true);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TileFetch',

      theme: baseTheme.copyWith(
        textTheme: AppFonts.appTextTheme(baseTheme.textTheme),
      ),

      home: const LoginPage(),
    );
  }
}
