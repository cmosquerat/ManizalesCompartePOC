import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import 'tapa_detail_screen.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final count = state.capturedTapaIds.length;
    final total = kTapas.length;
    final pct = total > 0 ? count / total : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Colección'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.rojo, AppColors.rojo.withValues(alpha: 0.8)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.rojo.withValues(alpha: 0.3), blurRadius: 8)],
                ),
                child: Text('$count/$total', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: pct),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  backgroundColor: Colors.grey.shade200,
                  color: AppColors.rojo,
                  minHeight: 8,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(pct * 100).toInt()}% completado', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                Text('${total - count} por descubrir', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 18,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: total,
              itemBuilder: (context, i) {
                final tapa = kTapas[i];
                final cap = state.isTapaCaptured(tapa.id);
                return _AnimatedCell(
                  index: i,
                  child: _TapaCell(
                    tapa: tapa,
                    captured: cap,
                    onTap: () => Navigator.push(context, _fadeRoute(TapaDetailScreen(tapa: tapa))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedCell extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedCell({required this.index, required this.child});
  @override
  State<_AnimatedCell> createState() => _AnimatedCellState();
}

class _AnimatedCellState extends State<_AnimatedCell> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Opacity(
        opacity: _anim.value,
        child: Transform.translate(offset: Offset(0, 24 * (1 - _anim.value)), child: child),
      ),
      child: widget.child,
    );
  }
}

class _TapaCell extends StatelessWidget {
  final Tapa tapa;
  final bool captured;
  final VoidCallback onTap;
  const _TapaCell({required this.tapa, required this.captured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Hero(
                tag: 'tapa_${tapa.id}',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: captured ? AppColors.verde : Colors.grey.shade300, width: 3),
                    boxShadow: captured
                        ? [BoxShadow(color: AppColors.verde.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2)]
                        : null,
                  ),
                  child: ClipOval(
                    child: captured
                        ? Image.asset(tapa.imageAsset, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.verde.withValues(alpha: 0.08),
                                  child: const Icon(Icons.check_circle_rounded, color: AppColors.verde, size: 32),
                                ))
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Colors.grey.shade100, Colors.grey.shade200],
                              ),
                            ),
                            child: Icon(Icons.help_outline_rounded, color: Colors.grey.shade400, size: 30),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            captured ? tapa.name : '???',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: captured ? FontWeight.w600 : FontWeight.normal,
              color: captured ? AppColors.negro : AppColors.gris,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

Route _fadeRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(a), child: child)),
      transitionDuration: const Duration(milliseconds: 350),
    );
