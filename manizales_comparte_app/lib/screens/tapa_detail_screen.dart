import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/app_state.dart';

class TapaDetailScreen extends StatefulWidget {
  final Tapa tapa;
  const TapaDetailScreen({super.key, required this.tapa});
  @override
  State<TapaDetailScreen> createState() => _TapaDetailScreenState();
}

class _TapaDetailScreenState extends State<TapaDetailScreen> with TickerProviderStateMixin {
  late AnimationController _infoCtrl;
  late AnimationController _captureCtrl;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _infoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _captureCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _infoCtrl.dispose();
    _captureCtrl.dispose();
    super.dispose();
  }

  void _capture() {
    final state = context.read<AppState>();
    if (state.isTapaCaptured(widget.tapa.id)) return;
    state.captureTapa(widget.tapa);
    setState(() => _showCelebration = true);
    _captureCtrl.forward(from: 0);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showCelebration = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tapa = widget.tapa;
    final state = context.watch<AppState>();
    final captured = state.isTapaCaptured(tapa.id);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                backgroundColor: AppColors.rojo,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'tapa_${tapa.id}',
                        child: Image.asset(
                          tapa.imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.rojo, AppColors.rojo.withValues(alpha: 0.7)],
                              ),
                            ),
                            child: const Icon(Icons.place_rounded, size: 80, color: Colors.white24),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (captured)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.verde,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('CAPTURADA', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1)),
                              ),
                            Text(tapa.name, style: GoogleFonts.montserrat(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _infoCtrl,
                  builder: (_, child) => Opacity(
                    opacity: CurvedAnimation(parent: _infoCtrl, curve: Curves.easeOut).value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - CurvedAnimation(parent: _infoCtrl, curve: Curves.easeOutCubic).value)),
                      child: child,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info chips
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _InfoChip(icon: Icons.palette_rounded, label: tapa.artist, color: AppColors.rojo),
                            _InfoChip(icon: Icons.location_on_rounded, label: tapa.sector, color: AppColors.turquesa),
                            _InfoChip(icon: Icons.place_rounded, label: tapa.address, color: AppColors.gris),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(tapa.description, style: GoogleFonts.poppins(fontSize: 15, color: AppColors.negro, height: 1.75)),
                        const SizedBox(height: 28),

                        // Reward card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.amarillo.withValues(alpha: 0.12), AppColors.amarillo.withValues(alpha: 0.04)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.amarillo.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: AppColors.amarillo.withValues(alpha: 0.4), blurRadius: 12)],
                                ),
                                child: const Icon(Icons.monetization_on_rounded, color: AppColors.negro, size: 26),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Recompensa', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                                  Text('${tapa.ferminesReward} Fermines', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        if (!captured)
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: const LinearGradient(colors: [AppColors.rojo, Color(0xFFc62828)]),
                                boxShadow: [BoxShadow(color: AppColors.rojo.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: _capture,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
                                      const SizedBox(width: 10),
                                      Text('Capturar esta tapa', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Celebration overlay
          if (_showCelebration)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _captureCtrl,
                builder: (_, __) {
                  final t = _captureCtrl.value;
                  return IgnorePointer(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5 * (t < 0.3 ? t / 0.3 : t > 0.7 ? (1 - t) / 0.3 : 1)),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.scale(
                              scale: t < 0.3 ? t / 0.3 : 1 + 0.05 * ((t - 0.3) / 0.7),
                              child: Opacity(
                                opacity: t < 0.1 ? t * 10 : t > 0.8 ? (1 - t) * 5 : 1,
                                child: Column(
                                  children: [
                                    const Icon(Icons.celebration_rounded, size: 64, color: AppColors.amarillo),
                                    const SizedBox(height: 16),
                                    Text('¡Tapa Capturada!', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                                    const SizedBox(height: 8),
                                    Text('+${widget.tapa.ferminesReward} Fermines', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.amarillo)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: color), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
