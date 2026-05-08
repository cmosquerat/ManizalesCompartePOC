import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../data/mock_data.dart';
import '../providers/app_state.dart';
// kGlosarioPaisa proviene de mock_data.dart

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tapas = state.capturedTapaIds.length;
    final level = tapas < 3 ? 'Explorador' : tapas < 8 ? 'Coleccionista' : tapas < 14 ? 'Experto' : 'Leyenda';
    final levelIdx = tapas < 3 ? 0 : tapas < 8 ? 1 : tapas < 14 ? 2 : 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF12122a), Color(0xFF1a1040), Color(0xFF0f2040)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: const Color(0xFF1a1040).withValues(alpha: 0.4), blurRadius: 24)],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [AppColors.rojo, AppColors.rojo.withValues(alpha: 0.6)]),
                        boxShadow: [BoxShadow(color: AppColors.rojo.withValues(alpha: 0.4), blurRadius: 20)],
                      ),
                      child: Center(
                        child: Text(
                          state.userName.isNotEmpty ? state.userName[0].toUpperCase() : 'M',
                          style: GoogleFonts.montserrat(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF12122a)),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.amarillo),
                          child: const Icon(Icons.star_rounded, size: 14, color: AppColors.negro),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(state.userName, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.amarillo.withValues(alpha: 0.2), AppColors.amarillo.withValues(alpha: 0.08)]),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.amarillo.withValues(alpha: 0.3)),
                  ),
                  child: Text(level, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.amarillo)),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (i) {
                          final labels = ['Explorador', 'Coleccionista', 'Experto', 'Leyenda'];
                          final active = i <= levelIdx;
                          return Text(labels[i], style: GoogleFonts.poppins(fontSize: 9, color: active ? AppColors.amarillo : Colors.white24));
                        }),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: (levelIdx + 1) / 4),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => LinearProgressIndicator(value: v, backgroundColor: Colors.white10, color: AppColors.amarillo, minHeight: 6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats grid
          Row(
            children: [
              _StatCard(icon: Icons.place_rounded, color: AppColors.rojo, value: '$tapas', label: 'Tapas'),
              const SizedBox(width: 8),
              _StatCard(icon: Icons.monetization_on_rounded, color: AppColors.amarillo, value: '${state.ferminesBalance}', label: 'Fermines'),
              const SizedBox(width: 8),
              _StatCard(icon: Icons.favorite_rounded, color: AppColors.turquesa, value: '${state.totalDonated}', label: 'Donados'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatCard(icon: Icons.shopping_bag_rounded, color: Color(0xFF6A1B9A), value: '${state.totalRedeemed}', label: 'Canjes'),
              const SizedBox(width: 8),
              _StatCard(icon: Icons.local_fire_department_rounded, color: Color(0xFFFF6F00), value: '${state.streakDays}', label: 'Racha'),
              const SizedBox(width: 8),
              _StatCard(icon: Icons.emoji_events_rounded, color: AppColors.verde, value: '${state.totalChallengesCompleted}', label: 'Desafíos'),
            ],
          ),
          const SizedBox(height: 28),

          // Badges
          Text('Mis Logros', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Badge(icon: Icons.place_rounded, label: 'Primera\nTapa', earned: tapas >= 1, color: AppColors.rojo),
                _Badge(icon: Icons.grid_view_rounded, label: '5\nTapas', earned: tapas >= 5, color: AppColors.verde),
                _Badge(icon: Icons.explore_rounded, label: '10\nTapas', earned: tapas >= 10, color: AppColors.turquesa),
                _Badge(icon: Icons.star_rounded, label: 'Todas las\nTapas', earned: tapas >= kTapas.length, color: AppColors.amarillo),
                _Badge(icon: Icons.favorite_rounded, label: 'Primera\nDonación', earned: state.totalDonated > 0, color: const Color(0xFFE91E63)),
                _Badge(icon: Icons.shopping_bag_rounded, label: 'Primer\nCanje', earned: state.totalRedeemed > 0, color: const Color(0xFF6A1B9A)),
                _Badge(icon: Icons.local_fire_department_rounded, label: 'Racha\n7 días', earned: state.streakDays >= 7, color: const Color(0xFFFF6F00)),
                _Badge(icon: Icons.emoji_events_rounded, label: '5\nDesafíos', earned: state.totalChallengesCompleted >= 5, color: AppColors.verde),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Cómo ganar Fermines
          Text('Cómo ganar Fermines', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...[
            ('Captura tapas', 'Encuentra y escanea tapas artísticas en la calle', '20-30 F', Icons.camera_alt_rounded, AppColors.rojo),
            ('Desafíos diarios', 'Completa retos para ganar recompensas extra', '10-20 F', Icons.emoji_events_rounded, AppColors.verde),
            ('Racha de días', '7 días seguidos = multiplicador x2', 'x2', Icons.local_fire_department_rounded, const Color(0xFFFF6F00)),
            ('Recarga directa', 'Compra Fermines — 20% va al fondo benéfico', '\$10K+', Icons.add_circle_rounded, AppColors.turquesa),
          ].map((p) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.$5.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: p.$5.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(p.$4, color: p.$5, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.$1, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(p.$2, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [p.$5.withValues(alpha: 0.12), p.$5.withValues(alpha: 0.04)]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(p.$3, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: p.$5)),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),

          // Cómo usar Fermines
          Text('Cómo usar Fermines', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...[
            ('Canjear productos', 'Tapitas de colección, camisetas, packs exclusivos', Icons.diamond_outlined, const Color(0xFF6A1B9A)),
            ('Descuentos en aliados', 'Cafés, restaurantes, hoteles y más', Icons.local_offer_rounded, AppColors.turquesa),
            ('Experiencias turísticas', 'Descuentos en tours y recorridos guiados', Icons.explore_rounded, const Color(0xFF2E7D32)),
            ('Donar', 'Apoya la Fundación Pequeño Corazón', Icons.favorite_rounded, AppColors.rojo),
          ].map((p) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.$4.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: p.$4.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(p.$3, color: p.$4, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.$1, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text(p.$2, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 28),

          // Ecosistema Social
          Text('Ecosistema Social', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          ...[
            ('CUIDARTE', 'Embellecimiento colaborativo de espacios públicos', AppColors.verde, Icons.park_rounded),
            ('IMAGINARTE', 'Convocatoria artística para las tapas de alcantarillado', AppColors.turquesa, Icons.palette_rounded),
            ('SALVARTE', 'Atención médica con Fundación Pequeño Corazón', AppColors.rojo, Icons.favorite_rounded),
            ('DESARMARTE', 'Entrega voluntaria de armas por beneficios familiares', AppColors.amarillo, Icons.shield_rounded),
          ].map((p) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.$3.withValues(alpha: 0.15)),
                  boxShadow: [BoxShadow(color: p.$3.withValues(alpha: 0.06), blurRadius: 12)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [p.$3.withValues(alpha: 0.15), p.$3.withValues(alpha: 0.05)]),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(p.$4, color: p.$3, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.$1, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: p.$3, letterSpacing: 1)),
                          const SizedBox(height: 2),
                          Text(p.$2, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 24),

          // Cambiar a Modo Negocio
          _RoleSwitch(),
          const SizedBox(height: 14),

          // Glosario manizaleño
          _GlosarioCard(),
          const SizedBox(height: 24),

          Center(
            child: Column(
              children: [
                SvgPicture.asset('assets/images/letras_positivo.svg', height: 30, colorFilter: ColorFilter.mode(AppColors.gris.withValues(alpha: 0.4), BlendMode.srcIn)),
                const SizedBox(height: 8),
                Text('Manizales Comparte App v1.0', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                Text('POC · Flutter Web · 2026', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _RoleSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D1D1B), Color(0xFF2D2D2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.rojo, AppColors.amarillo]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('¿Tienes un negocio?',
                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 3),
                Text('Entra al modo aliado y administra tus productos, promociones y canjes',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70, height: 1.3)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AppState>().switchRole(AppRole.business);
                  },
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: Text('Entrar como El Sombrerero',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.amarillo,
                    foregroundColor: AppColors.negro,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _GlosarioCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.translate_rounded, color: AppColors.rojo, size: 18),
              const SizedBox(width: 8),
              Text('Vocabulario manizaleño',
                  style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Pa\'que no quedes mal en la conversa',
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
          const SizedBox(height: 12),
          ...kGlosarioPaisa.entries.take(5).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(e.key,
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.rojo)),
                    ),
                    Expanded(
                      child: Text(e.value,
                          style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.negro, height: 1.4)),
                    ),
                  ],
                ),
              )),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vocabulario completo',
                            style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        ...kGlosarioPaisa.entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: Text(e.key,
                                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.rojo)),
                                  ),
                                  Expanded(child: Text(e.value, style: GoogleFonts.poppins(fontSize: 11.5))),
                                ],
                              ),
                            )),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cerrar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: Text('Ver todo el glosario →',
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.rojo)),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatCard({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12)],
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Text('$v', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
            Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool earned;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.earned, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: earned ? 1.0 : 0.6),
            duration: const Duration(milliseconds: 400),
            builder: (_, v, child) => Opacity(opacity: v, child: Transform.scale(scale: 0.8 + 0.2 * v, child: child)),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: earned ? LinearGradient(colors: [color, color.withValues(alpha: 0.7)]) : null,
                color: earned ? null : Colors.grey.shade200,
                boxShadow: earned ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12)] : null,
              ),
              child: Icon(icon, color: earned ? Colors.white : Colors.grey.shade400, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: earned ? FontWeight.w600 : FontWeight.normal, color: earned ? AppColors.negro : AppColors.gris),
          ),
        ],
      ),
    );
  }
}
