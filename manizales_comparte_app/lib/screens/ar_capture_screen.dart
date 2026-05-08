import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/models.dart';
import '../providers/app_state.dart';

class ArCaptureScreen extends StatefulWidget {
  final Tapa tapa;
  const ArCaptureScreen({super.key, required this.tapa});

  @override
  State<ArCaptureScreen> createState() => _ArCaptureScreenState();
}

class _ArCaptureScreenState extends State<ArCaptureScreen> with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _captureCtrl;
  late AnimationController _particlesCtrl;
  late AnimationController _flashCtrl;

  Offset _pointer = Offset.zero; // -1..1
  bool _aligned = false;
  bool _capturing = false;
  bool _captured = false;
  double _captureProgress = 0;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);
    _captureCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400));
    _captureCtrl.addListener(() {
      setState(() => _captureProgress = _captureCtrl.value);
      if (_captureCtrl.isCompleted && !_captured) _onCaptured();
    });
    _particlesCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _flashCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
  }

  void _onPointer(Offset local, Size size) {
    final dx = (local.dx / size.width) * 2 - 1; // -1..1
    final dy = (local.dy / size.height) * 2 - 1;
    final aligned = dx.abs() < 0.18 && dy.abs() < 0.18;
    setState(() {
      _pointer = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));
      if (aligned != _aligned) {
        _aligned = aligned;
        if (_aligned && !_capturing && !_captured) {
          _capturing = true;
          _captureCtrl.forward(from: 0);
        } else if (!_aligned && _capturing && !_captured) {
          _capturing = false;
          _captureCtrl.stop();
          _captureCtrl.value = 0;
        }
      }
    });
  }

  void _onCaptured() {
    setState(() => _captured = true);
    _flashCtrl.forward(from: 0);
    _particlesCtrl.forward(from: 0);
    context.read<AppState>().captureTapa(widget.tapa);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _captureCtrl.dispose();
    _particlesCtrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (ctx, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        return MouseRegion(
          onHover: (e) => _onPointer(e.localPosition, size),
          child: GestureDetector(
            onPanUpdate: (e) => _onPointer(e.localPosition, size),
            onPanStart: (e) => _onPointer(e.localPosition, size),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Fondo con Ken Burns + parallax
                AnimatedBuilder(
                  animation: _bgCtrl,
                  builder: (_, __) {
                    final scale = 1.05 + _bgCtrl.value * 0.08;
                    return Transform.translate(
                      offset: Offset(_pointer.dx * -18, _pointer.dy * -12),
                      child: Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          widget.tapa.imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1A237E), Color(0xFF311B92)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Capa oscura
                Container(color: Colors.black.withValues(alpha: 0.45)),

                // Partículas decorativas (siempre)
                CustomPaint(
                  painter: _AmbientParticlesPainter(_bgCtrl.value),
                  size: size,
                ),

                // Tapa flotante con parallax inverso
                Center(
                  child: Transform.translate(
                    offset: Offset(_pointer.dx * 24, _pointer.dy * 18),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: _captured ? 1.4 : (_aligned ? 1.08 : 1.0),
                      curve: Curves.easeOut,
                      child: _FloatingTapa(tapa: widget.tapa, aligned: _aligned, captured: _captured),
                    ),
                  ),
                ),

                // Mira / crosshair
                if (!_captured)
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _aligned ? 220 : 260,
                      height: _aligned ? 220 : 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _aligned ? AppColors.verde : Colors.white.withValues(alpha: 0.7),
                          width: _aligned ? 3 : 2,
                        ),
                      ),
                      child: CustomPaint(painter: _CrosshairPainter(progress: _captureProgress, aligned: _aligned)),
                    ),
                  ),

                // Flash
                AnimatedBuilder(
                  animation: _flashCtrl,
                  builder: (_, __) {
                    if (_flashCtrl.value == 0) return const SizedBox.shrink();
                    return Container(color: Colors.white.withValues(alpha: 1 - _flashCtrl.value));
                  },
                ),

                // Partículas de explosión
                AnimatedBuilder(
                  animation: _particlesCtrl,
                  builder: (_, __) {
                    if (_particlesCtrl.value == 0) return const SizedBox.shrink();
                    return CustomPaint(
                      size: size,
                      painter: _BurstPainter(_particlesCtrl.value),
                    );
                  },
                ),

                // Header
                Positioned(
                  top: MediaQuery.of(context).padding.top + 14,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      _glassButton(Icons.close_rounded, () => Navigator.pop(context)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.center_focus_strong_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _captured
                                      ? '¡Capturada!'
                                      : (_aligned ? 'Alineando…' : 'Apunta a la tapa'),
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                      child: _captured ? _CapturedPanel(tapa: widget.tapa) : _AimingPanel(progress: _captureProgress),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _glassButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _FloatingTapa extends StatelessWidget {
  final Tapa tapa;
  final bool aligned;
  final bool captured;
  const _FloatingTapa({required this.tapa, required this.aligned, required this.captured});

  @override
  Widget build(BuildContext context) {
    final color = captured ? AppColors.verde : (aligned ? AppColors.amarillo : Colors.white);
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 4),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 4),
        ],
      ),
      child: ClipOval(
        child: Hero(
          tag: 'tapa_${tapa.id}',
          child: Image.asset(
            tapa.imageAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.rojo,
              child: const Icon(Icons.place_rounded, color: Colors.white, size: 50),
            ),
          ),
        ),
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  final double progress;
  final bool aligned;
  _CrosshairPainter({required this.progress, required this.aligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Esquinas tipo cámara
    final paint = Paint()
      ..color = aligned ? AppColors.verde : Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    const cornerLen = 22.0;
    for (final corner in [
      [center.dx - r, center.dy - r],
      [center.dx + r, center.dy - r],
      [center.dx - r, center.dy + r],
      [center.dx + r, center.dy + r],
    ]) {
      final cx = corner[0], cy = corner[1];
      final hx = (cx > center.dx ? -1 : 1).toDouble();
      final hy = (cy > center.dy ? -1 : 1).toDouble();
      canvas.drawLine(Offset(cx, cy), Offset(cx + cornerLen * hx, cy), paint);
      canvas.drawLine(Offset(cx, cy), Offset(cx, cy + cornerLen * hy), paint);
    }

    // Arco de progreso
    if (progress > 0) {
      final arcPaint = Paint()
        ..color = AppColors.verde
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r - 6),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter old) =>
      old.progress != progress || old.aligned != aligned;
}

class _AmbientParticlesPainter extends CustomPainter {
  final double t;
  _AmbientParticlesPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7);
    for (int i = 0; i < 26; i++) {
      final x = (rng.nextDouble() * size.width + t * 30 * (i % 3 == 0 ? 1 : -1)) % size.width;
      final y = (rng.nextDouble() * size.height + t * 50) % size.height;
      final r = 1.0 + rng.nextDouble() * 2.5;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.15 + rng.nextDouble() * 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientParticlesPainter old) => old.t != t;
}

class _BurstPainter extends CustomPainter {
  final double t;
  _BurstPainter(this.t);

  static const _colors = [
    Color(0xFFE6323C),
    Color(0xFFFFD122),
    Color(0xFF52B9AA),
    Color(0xFF88BE4C),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rng = math.Random(42);
    for (int i = 0; i < 60; i++) {
      final angle = rng.nextDouble() * 2 * math.pi;
      final speed = 90 + rng.nextDouble() * 230;
      final dist = speed * t;
      final pos = center + Offset(math.cos(angle) * dist, math.sin(angle) * dist - 80 * t * t);
      final r = 4 * (1 - t);
      if (r <= 0) continue;
      canvas.drawCircle(
        pos,
        r,
        Paint()..color = _colors[i % _colors.length].withValues(alpha: (1 - t).clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter old) => old.t != t;
}

class _AimingPanel extends StatelessWidget {
  final double progress;
  const _AimingPanel({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mantén la mira sobre la tapa',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(AppColors.amarillo),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CapturedPanel extends StatelessWidget {
  final Tapa tapa;
  const _CapturedPanel({required this.tapa});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.verde,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.verde.withValues(alpha: 0.4), blurRadius: 10)],
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('¡Tapa capturada!',
                          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800)),
                      Text(tapa.name,
                          style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.gris)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('+${tapa.ferminesReward}F',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: Text('Compartir', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.collections_bookmark_rounded, size: 16, color: Colors.white),
                    label: Text('Ver detalle', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.rojo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
