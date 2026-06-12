import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixelarticons/pixelarticons.dart';

import 'package:tilefetch/components/custom_bottom_nav.dart';
import 'package:tilefetch/theme/index.dart';

/// TESTE DE INTEGRAÇÃO (Widget Test)
///
/// Verifica a integração entre o componente CustomBottomNav e a interação
/// do usuário: renderização dos itens de navegação, destaque do item
/// selecionado e disparo do callback ao tocar em outro item.
void main() {
  Widget criarWidgetDeTeste({required int selectedIndex, required Function(int) onTap}) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: CustomBottomNav(
          selectedIndex: selectedIndex,
          onTap: onTap,
        ),
      ),
    );
  }

  group('CustomBottomNav - Integração', () {
    testWidgets('renderiza todos os itens de navegação com seus rótulos', (tester) async {
      await tester.pumpWidget(
        criarWidgetDeTeste(selectedIndex: 0, onTap: (_) {}),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Buscar'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);

      expect(find.byIcon(Pixel.home), findsOneWidget);
      expect(find.byIcon(Pixel.search), findsOneWidget);
      expect(find.byIcon(Pixel.plus), findsOneWidget);
      expect(find.byIcon(Pixel.heart), findsOneWidget);
      expect(find.byIcon(Pixel.user), findsOneWidget);
    });

    testWidgets('o item selecionado é destacado com a cor primária', (tester) async {
      await tester.pumpWidget(
        criarWidgetDeTeste(selectedIndex: 1, onTap: (_) {}),
      );

      final iconBuscar = tester.widget<Icon>(find.byIcon(Pixel.search));
      final iconHome = tester.widget<Icon>(find.byIcon(Pixel.home));

      // O ícone selecionado (Buscar, index 1) deve usar a cor primária
      expect(iconBuscar.color, AppColors.primary);
      // O ícone não selecionado (Home) deve usar a cor secundária
      expect(iconHome.color, AppColors.textSecondary);
    });

    testWidgets('ao tocar em um item, o callback onTap é chamado com o índice correto', (tester) async {
      int? indiceTocado;

      await tester.pumpWidget(
        criarWidgetDeTeste(
          selectedIndex: 0,
          onTap: (index) => indiceTocado = index,
        ),
      );

      // Toca no item "Favoritos" (índice 3)
      await tester.tap(find.text('Favoritos'));
      await tester.pump();

      expect(indiceTocado, 3);
    });

    testWidgets('ao tocar no item "Upload", o callback é chamado com índice 2', (tester) async {
      int? indiceTocado;

      await tester.pumpWidget(
        criarWidgetDeTeste(
          selectedIndex: 0,
          onTap: (index) => indiceTocado = index,
        ),
      );

      await tester.tap(find.text('Upload'));
      await tester.pump();

      expect(indiceTocado, 2);
    });
  });
}
