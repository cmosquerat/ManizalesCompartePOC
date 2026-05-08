import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/manizales_context.dart';
import '../config/theme.dart';
import '../providers/app_state.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _dotsCtrl;
  late Animation<double> _bgFade, _logoScale, _logoFade, _textSlide, _textFade;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _dotsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);

    _bgFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeOut));
    _logoScale = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.4)));
    _textSlide = Tween(begin: 30.0, end: 0.0).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _textFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _bgCtrl.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _logoCtrl.forward());
    Future.delayed(const Duration(milliseconds: 1000), () => _textCtrl.forward());
    Future.delayed(const Duration(milliseconds: 3200), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final next = context.read<AppState>().onboardingDone
        ? const HomeScreen()
        : const OnboardingScreen();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (_, __) => Stack(
          fit: StackFit.expand,
          children: [
            // City photo background
            Opacity(
              opacity: 0.3 * _bgFade.value,
              child: Image.asset('assets/images/manizales_panorama.jpg', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.expand()),
            ),
            // Dark gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85 * _bgFade.value),
                    const Color(0xFF0d0d1a).withValues(alpha: 0.95 * _bgFade.value),
                  ],
                ),
              ),
            ),

            // Glow behind logo
            AnimatedBuilder(
              animation: _dotsCtrl,
              builder: (_, __) => Center(
                child: Container(
                  width: 340 + 60 * _dotsCtrl.value,
                  height: 340 + 60 * _dotsCtrl.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.rojo.withValues(alpha: 0.06 + 0.03 * _dotsCtrl.value),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),

            // Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SVG Logo — big
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: SvgPicture.asset(
                          'assets/images/logo_negativo.svg',
                          height: 220,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Tagline
                  AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (_, __) => Opacity(
                      opacity: _textFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: Column(
                          children: [
                            Container(width: 50, height: 2, color: AppColors.rojo),
                            const SizedBox(height: 20),
                            Text(
                              'De tapa en tapa,\nManizales te cuenta su historia',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.white60,
                                letterSpacing: 1,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Animated dots
                  AnimatedBuilder(
                    animation: _dotsCtrl,
                    builder: (_, __) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _glowDot(AppColors.rojo, 0),
                        _glowDot(AppColors.amarillo, 0.2),
                        _glowDot(AppColors.verde, 0.4),
                        _glowDot(AppColors.turquesa, 0.6),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Dato curioso de Manizales abajo
            Positioned(
              left: 24,
              right: 24,
              bottom: 36,
              child: AnimatedBuilder(
                animation: _textCtrl,
                builder: (_, __) => Opacity(
                  opacity: _textFade.value * 0.85,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: AppColors.amarillo, size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ManizalesContext.datoCurioso(),
                            textAlign: TextAlign.start,
                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowDot(Color c, double offset) {
    final t = ((_dotsCtrl.value + offset) % 1.0);
    final scale = 0.8 + 0.4 * sin(t * pi);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 10 * scale,
      height: 10 * scale,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 8)],
      ),
    );
  }
}
