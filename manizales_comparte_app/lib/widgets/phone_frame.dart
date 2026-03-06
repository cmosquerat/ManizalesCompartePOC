import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';

class PhoneFrame extends StatefulWidget {
  final Widget child;
  const PhoneFrame({super.key, required this.child});
  @override
  State<PhoneFrame> createState() => _PhoneFrameState();
}

class _PhoneFrameState extends State<PhoneFrame> with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
  }

  @override
  void dispose() { _glowCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (!kIsWeb || size.width < 600) return widget.child;

    const phoneW = 390.0;
    const phoneH = 844.0;

    final phone = Container(
      width: phoneW + 18,
      height: phoneH + 18,
      decoration: BoxDecoration(
        color: const Color(0xFF0a0a0a),
        borderRadius: BorderRadius.circular(46),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 60, spreadRadius: 2),
        ],
        border: Border.all(color: const Color(0xFF2a2a2a), width: 1),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(9),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(37),
              child: MediaQuery(
                data: const MediaQueryData(
                  size: Size(phoneW, phoneH),
                  padding: EdgeInsets.only(top: 50, bottom: 34),
                ),
                child: SizedBox(width: phoneW, height: phoneH, child: widget.child),
              ),
            ),
          ),
          Positioned(
            top: 9,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 120,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF0a0a0a),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                ),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1a1a1a),
                      border: Border.all(color: const Color(0xFF333333), width: 1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 130,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Small screen: just phone centered
    if (size.width < 1000) {
      return Material(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: _bgDecor(),
          child: Center(child: SingleChildScrollView(child: phone)),
        ),
      );
    }

    // Wide: phone + POC description panel
    return Material(
      child: AnimatedBuilder(
        animation: _glowCtrl,
        builder: (_, __) => Container(
          width: size.width,
          height: size.height,
          decoration: _bgDecor(),
          child: Stack(
            children: [
              // City photo background (faded)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.06 + 0.02 * _glowCtrl.value,
                  child: Image.asset('assets/images/manizales_aerial.jpg', fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.expand()),
                ),
              ),

              // Ambient glow
              Positioned(
                left: size.width * 0.08,
                top: size.height * 0.15,
                child: Container(
                  width: 350 + 100 * _glowCtrl.value,
                  height: 350 + 100 * _glowCtrl.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.rojo.withValues(alpha: 0.03 + 0.02 * _glowCtrl.value),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),

              // Content
              Row(
                children: [
                  // Left panel: POC description
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(size.width * 0.05, 60, 40, 60),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo
                          SvgPicture.asset('assets/images/logo_negativo.svg', height: 140),
                          const SizedBox(height: 36),

                          // POC label
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.rojo.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.rojo.withValues(alpha: 0.3)),
                            ),
                            child: Text('PRUEBA DE CONCEPTO', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.rojo, letterSpacing: 1.5)),
                          ),
                          const SizedBox(height: 20),

                          // Main headline
                          Text(
                            'Arte, turismo y\nimpacto social\nen una app',
                            style: GoogleFonts.montserrat(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 20),

                          Container(width: 60, height: 3, decoration: BoxDecoration(color: AppColors.rojo, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 20),

                          // Description
                          Text(
                            'Manizales Comparte App transforma las tapas de alcantarillado intervenidas '
                            'con arte en una experiencia turística gamificada. Los usuarios recorren la '
                            'ciudad capturando tapas, ganan Fermines (moneda virtual) y los canjean por '
                            'productos, descuentos en aliados y experiencias turísticas.',
                            style: GoogleFonts.poppins(fontSize: 15, color: Colors.white54, height: 1.8),
                          ),
                          const SizedBox(height: 28),

                          // Feature cards
                          Row(
                            children: [
                              _FeatureChip(icon: Icons.camera_alt_rounded, label: 'Captura tapas', color: AppColors.rojo),
                              const SizedBox(width: 10),
                              _FeatureChip(icon: Icons.monetization_on_rounded, label: 'Gana Fermines', color: AppColors.amarillo),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _FeatureChip(icon: Icons.storefront_rounded, label: 'Canjea premios', color: AppColors.turquesa),
                              const SizedBox(width: 10),
                              _FeatureChip(icon: Icons.favorite_rounded, label: 'Genera impacto', color: AppColors.verde),
                            ],
                          ),
                          const SizedBox(height: 28),

                          // City photos strip
                          SizedBox(
                            height: 90,
                            child: Row(
                              children: [
                                _CityPhoto('assets/images/manizales_panorama.jpg'),
                                const SizedBox(width: 8),
                                _CityPhoto('assets/images/manizales_city.jpg'),
                                const SizedBox(width: 8),
                                _CityPhoto('assets/images/manizales_publi.jpg'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Ecosistema Social
                          Text('Ecosistema Social', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white70)),
                          const SizedBox(height: 10),
                          Text(
                            'Cada Fermín apoya a la Fundación Pequeño Corazón y al embellecimiento '
                            'de Manizales. Programas: CUIDARTE · IMAGINARTE · SALVARTE · DESARMARTE.',
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white38, height: 1.7),
                          ),
                          const SizedBox(height: 28),

                          // Color palette
                          Row(
                            children: [AppColors.rojo, AppColors.amarillo, AppColors.verde, AppColors.turquesa, AppColors.gris]
                                .map((c) => Container(
                                      width: 14,
                                      height: 14,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: c,
                                        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.4), blurRadius: 8)],
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 20),

                          // Tech stack
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['Flutter Web', 'Provider', 'OpenStreetMap', 'GitHub Pages', 'Google Fonts', 'SVG Assets']
                                .map((t) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.06),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                                      ),
                                      child: Text(t, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white30)),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                          Text('Fundación Manizales Comparte · POC 2026', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withValues(alpha: 0.2))),
                        ],
                      ),
                    ),
                  ),

                  // Phone
                  Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: phone),
                  SizedBox(width: size.width * 0.04),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _bgDecor() => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06060c), Color(0xFF0a0a18), Color(0xFF08101e)],
        ),
      );
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _FeatureChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Flexible(child: Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color))),
          ],
        ),
      ),
    );
  }
}

class _CityPhoto extends StatelessWidget {
  final String asset;
  const _CityPhoto(this.asset);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(asset, fit: BoxFit.cover, height: 90,
            errorBuilder: (_, __, ___) => Container(color: Colors.white10)),
      ),
    );
  }
}
