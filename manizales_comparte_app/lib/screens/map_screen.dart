import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import 'tapa_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  Tapa? _selected;
  late AnimationController _previewCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _previewCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _previewCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _previewCtrl, curve: Curves.easeOut));
  }

  void _selectTapa(Tapa? t) {
    if (t == null) {
      _previewCtrl.reverse().then((_) { if (mounted) setState(() => _selected = null); });
    } else {
      setState(() => _selected = t);
      _previewCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _previewCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pad = MediaQuery.of(context).padding;

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(5.0645, -75.5215),
            initialZoom: 14.5,
            onTap: (_, __) => _selectTapa(null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.manizalescomparte.app',
            ),
            MarkerLayer(
              markers: kTapas.map((t) {
                final cap = state.isTapaCaptured(t.id);
                final isSel = _selected?.id == t.id;
                return Marker(
                  point: LatLng(t.lat, t.lng),
                  width: isSel ? 48 : 38,
                  height: isSel ? 48 : 38,
                  child: GestureDetector(
                    onTap: () => _selectTapa(t),
                    child: AnimatedScale(
                      scale: isSel ? 1.3 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      child: Container(
                        decoration: BoxDecoration(
                          color: cap ? AppColors.verde : AppColors.rojo,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: (cap ? AppColors.verde : AppColors.rojo).withValues(alpha: 0.5),
                              blurRadius: isSel ? 12 : 6,
                              spreadRadius: isSel ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Icon(cap ? Icons.check_rounded : Icons.place_rounded, color: Colors.white, size: isSel ? 22 : 18),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Header
        Positioned(
          top: pad.top + 10,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.map_rounded, color: AppColors.rojo, size: 20),
                const SizedBox(width: 8),
                Text('Explorar', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),

        // Fermines + counter
        Positioned(
          top: pad.top + 10,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.amarillo.withValues(alpha: 0.35), blurRadius: 12)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded, size: 18, color: AppColors.negro),
                    const SizedBox(width: 6),
                    Text('${state.ferminesBalance}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.negro)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                ),
                child: Text(
                  '${state.capturedTapaIds.length}/${kTapas.length} tapas',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        // Preview card
        if (_selected != null)
          Positioned(
            bottom: 90,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _TapaPreview(
                  tapa: _selected!,
                  captured: state.isTapaCaptured(_selected!.id),
                  onTap: () => Navigator.push(context, _fadeRoute(TapaDetailScreen(tapa: _selected!))),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

Route _fadeRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(a), child: child)),
      transitionDuration: const Duration(milliseconds: 350),
    );

class _TapaPreview extends StatelessWidget {
  final Tapa tapa;
  final bool captured;
  final VoidCallback onTap;
  const _TapaPreview({required this.tapa, required this.captured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Hero(
              tag: 'tapa_${tapa.id}',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: captured ? AppColors.verde : AppColors.rojo, width: 3),
                  boxShadow: [BoxShadow(color: (captured ? AppColors.verde : AppColors.rojo).withValues(alpha: 0.2), blurRadius: 8)],
                ),
                child: ClipOval(
                  child: Image.asset(tapa.imageAsset, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.rojo.withValues(alpha: 0.08), child: const Icon(Icons.place_rounded, color: AppColors.rojo))),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tapa.name, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text('${tapa.artist} · ${tapa.sector}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: captured
                    ? LinearGradient(colors: [AppColors.verde, AppColors.verde.withValues(alpha: 0.8)])
                    : LinearGradient(colors: [AppColors.amarillo, AppColors.amarillo.withValues(alpha: 0.8)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: (captured ? AppColors.verde : AppColors.amarillo).withValues(alpha: 0.3), blurRadius: 6),
                ],
              ),
              child: Text(
                captured ? '✓' : '+${tapa.ferminesReward}F',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: captured ? Colors.white : AppColors.negro),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
