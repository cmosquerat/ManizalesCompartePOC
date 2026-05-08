import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import 'business_overview_tab.dart';
import 'business_products_tab.dart';
import 'business_promotions_tab.dart';
import 'business_redeem_tab.dart';
import 'business_reports_tab.dart';

class BusinessShell extends StatefulWidget {
  const BusinessShell({super.key});
  @override
  State<BusinessShell> createState() => _BusinessShellState();
}

class _BusinessShellState extends State<BusinessShell> {
  int _i = 0;

  static const _items = [
    (Icons.dashboard_rounded, 'Resumen'),
    (Icons.inventory_2_rounded, 'Productos'),
    (Icons.local_offer_rounded, 'Promociones'),
    (Icons.qr_code_scanner_rounded, 'Validar canje'),
    (Icons.bar_chart_rounded, 'Reportes'),
  ];

  Widget get _body {
    switch (_i) {
      case 0: return const BusinessOverviewTab();
      case 1: return const BusinessProductsTab();
      case 2: return const BusinessPromotionsTab();
      case 3: return const BusinessRedeemTab();
      case 4: return const BusinessReportsTab();
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final biz = state.activeBusiness;
    final wide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: SafeArea(
        child: wide
            ? Row(
                children: [
                  _Sidebar(
                    items: _items,
                    selected: _i,
                    onSelect: (i) => setState(() => _i = i),
                    bizName: biz.nombre,
                    bizSubtitle: '${biz.tipo.nombre} · ${biz.sector}',
                  ),
                  Expanded(child: _body),
                ],
              )
            : Column(
                children: [
                  _MobileTopbar(
                    bizName: biz.nombre,
                    bizSubtitle: '${biz.tipo.nombre} · ${biz.sector}',
                  ),
                  _MobileTabs(
                    items: _items,
                    selected: _i,
                    onSelect: (i) => setState(() => _i = i),
                  ),
                  Expanded(child: _body),
                ],
              ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final List<(IconData, String)> items;
  final int selected;
  final ValueChanged<int> onSelect;
  final String bizName;
  final String bizSubtitle;
  const _Sidebar({
    required this.items,
    required this.selected,
    required this.onSelect,
    required this.bizName,
    required this.bizSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.rojo, Color(0xFFFFD122)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bizName,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800)),
                      Text(bizSubtitle,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...List.generate(items.length, (i) {
            final sel = i == selected;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Material(
                color: sel ? AppColors.rojo.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onSelect(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    child: Row(
                      children: [
                        Icon(items[i].$1, size: 18, color: sel ? AppColors.rojo : AppColors.gris),
                        const SizedBox(width: 10),
                        Text(items[i].$2,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                                color: sel ? AppColors.rojo : AppColors.negro)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Material(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  context.read<AppState>().switchRole(AppRole.citizen);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded, size: 18, color: AppColors.negro),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Volver a app turista',
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
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

class _MobileTopbar extends StatelessWidget {
  final String bizName;
  final String bizSubtitle;
  const _MobileTopbar({required this.bizName, required this.bizSubtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.rojo, Color(0xFFFFD122)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bizName, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800)),
                Text(bizSubtitle, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Volver a app turista',
            onPressed: () {
              context.read<AppState>().switchRole(AppRole.citizen);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.negro),
          ),
        ],
      ),
    );
  }
}

class _MobileTabs extends StatelessWidget {
  final List<(IconData, String)> items;
  final int selected;
  final ValueChanged<int> onSelect;
  const _MobileTabs({required this.items, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final sel = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: sel ? AppColors.rojo.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(items[i].$1, size: 16, color: sel ? AppColors.rojo : AppColors.gris),
                  const SizedBox(width: 6),
                  Text(items[i].$2,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: sel ? AppColors.rojo : AppColors.negro)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
