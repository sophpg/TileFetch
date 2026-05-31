import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'upload_page.dart';
import 'search_page.dart';
import 'favorites_page.dart';
import '../components/custom_bottom_nav.dart';
import '../theme/index.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomePage(),
      const AdvancedSearchPage(),
      UploadPage(onUploadSuccess: _handleUploadSuccess),
      const FavoritesPage(),
      const ProfilePage(),
    ];
  }

  void _handleUploadSuccess() {
    setState(() {
      _screens[0] = const HomePage();
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
