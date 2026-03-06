import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import 'map_screen.dart';
import 'collection_screen.dart';
import 'tours_screen.dart';
import 'tienda_screen.dart';
import 'wallet_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _i = 0;
  final _screens = const [MapScreen(), CollectionScreen(), TiendaScreen(), ToursScreen(), WalletScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(key: ValueKey(_i), child: _screens[_i]),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingNav(index: _i, onTap: (i) => setState(() => _i = i)),
          ),
        ],
      ),
    );
  }
}

class _FloatingNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _FloatingNav({required this.index, required this.onTap});

  static const _items = [
    (Icons.map_outlined, Icons.map_rounded, 'Explorar'),
    (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Tapas'),
    (Icons.storefront_outlined, Icons.storefront_rounded, 'Tienda'),
    (Icons.explore_outlined, Icons.explore_rounded, 'Tours'),
    (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Wallet'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_items.length, (i) {
          final sel = i == index;
          final item = _items[i];
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              padding: EdgeInsets.symmetric(horizontal: sel ? 12 : 8, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.rojo.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: sel ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(sel ? item.$2 : item.$1, color: sel ? AppColors.rojo : AppColors.gris, size: 21),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.$3,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                      color: sel ? AppColors.rojo : AppColors.gris,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
