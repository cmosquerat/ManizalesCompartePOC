import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';
import 'business_mode/business_shell.dart';
import 'collection_screen.dart';
import 'comunidad_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'tienda_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _i = 0;
  final _screens = const [
    MapScreen(),
    ComunidadScreen(),
    WalletScreen(),
    TiendaScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (state.role == AppRole.business) {
      return const BusinessShell();
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
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
      floatingActionButton: _i == 0
          ? FloatingActionButton.small(
              heroTag: 'fab_collection',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.rojo,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionScreen())),
              child: const Icon(Icons.collections_rounded),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _FloatingNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _FloatingNav({required this.index, required this.onTap});

  static const _items = [
    (Icons.map_outlined, Icons.map_rounded, 'Mapa'),
    (Icons.diversity_3_outlined, Icons.diversity_3_rounded, 'Comunidad'),
    (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Wallet'),
    (Icons.storefront_outlined, Icons.storefront_rounded, 'Tienda'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              padding: EdgeInsets.symmetric(horizontal: sel ? 14 : 10, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.rojo.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: sel ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 240),
                    child: Icon(sel ? item.$2 : item.$1, color: sel ? AppColors.rojo : AppColors.gris, size: 22),
                  ),
                  const SizedBox(height: 2),
                  Text(item.$3,
                      style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? AppColors.rojo : AppColors.gris)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

