import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'theme/app_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
