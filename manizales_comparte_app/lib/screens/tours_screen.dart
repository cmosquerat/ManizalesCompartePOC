import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import 'tour_detail_screen.dart';

class ToursScreen extends StatelessWidget {
  const ToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tours & Aliados')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text('Experiencias turísticas', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Reserva tu recorrido y sé parte de esta historia', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gris)),
          const SizedBox(height: 18),
          ...List.generate(kTours.length, (i) => _AnimatedItem(
                index: i,
                child: _TourCard(tour: kTours[i], onTap: () => Navigator.push(context, _fadeRoute(TourDetailScreen(tour: kTours[i])))),
              )),
          const SizedBox(height: 28),
          Text('Aliados estratégicos', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Descuentos exclusivos con tus Fermines', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gris)),
          const SizedBox(height: 18),
          ...List.generate(kAllies.length, (i) => _AnimatedItem(
                index: i + kTours.length,
                child: _AllyCard(ally: kAllies[i]),
              )),
        ],
      ),
    );
  }
}

class _AnimatedItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedItem({required this.index, required this.child});
  @override
  State<_AnimatedItem> createState() => _AnimatedItemState();
}

class _AnimatedItemState extends State<_AnimatedItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    Future.delayed(Duration(milliseconds: 80 * widget.index), () { if (mounted) _ctrl.forward(); });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _ctrl.value,
        child: Transform.translate(offset: Offset(0, 24 * (1 - _ctrl.value)), child: child),
      ),
      child: widget.child,
    );
  }
}

class _TourCard extends StatefulWidget {
  final Tour tour;
  final VoidCallback onTap;
  const _TourCard({required this.tour, required this.onTap});
  @override
  State<_TourCard> createState() => _TourCardState();
}

class _TourCardState extends State<_TourCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tour;
    final color = t.color;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Stack(
                  children: [
                    Positioned(right: -20, top: -20, child: Icon(t.icon, size: 120, color: Colors.white.withValues(alpha: 0.1))),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(t.name, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(t.duration, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('\$${t.priceCOP}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(t.description, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gris, height: 1.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_forward_rounded, color: color, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllyCard extends StatelessWidget {
  final Ally ally;
  const _AllyCard({required this.ally});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.turquesa.withValues(alpha: 0.15), AppColors.turquesa.withValues(alpha: 0.05)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.store_rounded, color: AppColors.turquesa, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ally.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(ally.category, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.verde, Color(0xFF43A047)]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: AppColors.verde.withValues(alpha: 0.3), blurRadius: 6)],
            ),
            child: Text('${ally.discountPercent}% OFF', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

Route _fadeRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(a), child: child)),
      transitionDuration: const Duration(milliseconds: 350),
    );
