import 'package:flutter/material.dart';
import 'home_page.dart';
import 'pages/profile_page.dart';
import 'components/custom_bottom_nav.dart';
import 'theme/index.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomePage(),
    _buildComingSoonScreen('Busca Avançada'),
    _buildComingSoonScreen('Upload de Posts'),
    _buildComingSoonScreen('Favoritos'),
    const ProfilePage(),
  ];

  static Widget _buildComingSoonScreen(String title) {
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppFonts.title(
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Em desenvolvimento',
                  style: AppFonts.body(
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
