import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _data = [
    _Slide(
      svg: 'assets/images/colobri_positivo.svg',
      gradientColors: [Color(0xFF1a0a0a), Color(0xFF3d0f0f)],
      accentColor: AppColors.rojo,
      title: 'Descubre las Tapas',
      subtitle:
          'Recorre Manizales de tapa en tapa. Cada tapa de alcantarillado es una obra de arte que cuenta la historia de la ciudad.',
    ),
    _Slide(
      svg: 'assets/images/chiprepositivo.svg',
      gradientColors: [Color(0xFF1a1a08), Color(0xFF3d3510)],
      accentColor: AppColors.amarillo,
      title: 'Gana Fermines',
      subtitle:
          'Captura tapas, participa en tours y acciones benéficas para ganar Fermines — nuestra moneda virtual con descuentos reales.',
    ),
    _Slide(
      svg: 'assets/images/nevado_positivo.svg',
      gradientColors: [Color(0xFF081a12), Color(0xFF0f3d25)],
      accentColor: AppColors.verde,
      title: 'Genera Impacto',
      subtitle:
          'Cada Fermín apoya a la Fundación Pequeño Corazón y al embellecimiento de Manizales. Tu turismo transforma vidas.',
    ),
  ];

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
    } else {
      _finish();
    }
  }

  void _finish() {
    context.read<AppState>().completeOnboarding();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: 0.95, end: 1.0).animate(a), child: child)),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final slide = _data[_page];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: slide.gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text('Saltar', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14)),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _ctrl,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: 3,
                  itemBuilder: (_, i) => _buildSlide(_data[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                          width: active ? 32 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: active ? slide.accentColor : Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: active
                                ? [BoxShadow(color: slide.accentColor.withValues(alpha: 0.5), blurRadius: 8)]
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(colors: [slide.accentColor, slide.accentColor.withValues(alpha: 0.7)]),
                          boxShadow: [BoxShadow(color: slide.accentColor.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _next,
                            child: Center(
                              child: Text(
                                _page < 2 ? 'Siguiente' : 'Comenzar',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildSlide(_Slide data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey(data.svg),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Opacity(
              opacity: v.clamp(0, 1),
              child: Transform.scale(scale: 0.5 + 0.5 * v, child: child),
            ),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: data.accentColor.withValues(alpha: 0.08),
                border: Border.all(color: data.accentColor.withValues(alpha: 0.15), width: 2),
                boxShadow: [BoxShadow(color: data.accentColor.withValues(alpha: 0.15), blurRadius: 40, spreadRadius: 10)],
              ),
              child: Center(
                child: SvgPicture.asset(
                  data.svg,
                  height: 80,
                  colorFilter: ColorFilter.mode(data.accentColor, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          TweenAnimationBuilder<double>(
            key: ValueKey('${data.title}_title'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child),
            ),
            child: Text(
              data.title,
              style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            key: ValueKey('${data.title}_sub'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, v, child) => Opacity(
              opacity: v,
              child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
            ),
            child: Text(
              data.subtitle,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.white60, height: 1.7),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide {
  final String svg;
  final List<Color> gradientColors;
  final Color accentColor;
  final String title;
  final String subtitle;
  const _Slide({required this.svg, required this.gradientColors, required this.accentColor, required this.title, required this.subtitle});
}
