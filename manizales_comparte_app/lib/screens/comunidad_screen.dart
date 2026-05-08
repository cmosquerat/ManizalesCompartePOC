import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/app_state.dart';

class ComunidadScreen extends StatelessWidget {
  const ComunidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final state = context.watch<AppState>();
    final inscritas = kSocialEvents.where((e) => state.isEnrolled(e.id)).length;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: ListView(
        padding: EdgeInsets.only(top: pad.top + 12, left: 16, right: 16, bottom: 120),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.rojo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.diversity_3_rounded, color: AppColors.rojo, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Comunidad', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800)),
                    Text('Ecosistema social de Manizales',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Banner narrativo
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE6323C), Color(0xFFFFD122)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cada jornada vale Fermines',
                          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Cuida, pinta, salva, desarma — y construye Manizales con tu tiempo.',
                          style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.92), fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          if (inscritas > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.verde.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.verde.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.verde, size: 18),
                  const SizedBox(width: 8),
                  Text('Estás inscrito en $inscritas jornada${inscritas == 1 ? '' : 's'}',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          Text('Los 4 pilares', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          ...ProgramaSocial.values.map((p) => _ProgramaCard(programa: p)),
        ],
      ),
    );
  }
}

class _ProgramaCard extends StatelessWidget {
  final ProgramaSocial programa;
  const _ProgramaCard({required this.programa});

  @override
  Widget build(BuildContext context) {
    final eventos = kSocialEvents.where((e) => e.programa == programa).toList();
    final proximaFecha = eventos.isNotEmpty ? eventos.first.fecha : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ProgramaDetailScreen(programa: programa))),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: programa.color.withValues(alpha: 0.25), width: 1.5),
            ),
            child: Row(
              children: [
                _ProgramaAvatar(programa: programa, size: 60),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(programa.nombre,
                          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(programa.lema,
                          style: GoogleFonts.poppins(fontSize: 11, color: programa.color, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.event_rounded, size: 13, color: AppColors.gris),
                          const SizedBox(width: 4),
                          Text(
                            proximaFecha != null
                                ? 'Próxima: ${_fmtFecha(proximaFecha)}'
                                : 'Sin jornadas próximas',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: programa.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('${eventos.length}',
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: programa.color)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gris),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _fmtFecha(DateTime d) {
  const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
  return '${d.day} ${meses[d.month - 1]}';
}

class _ProgramaAvatar extends StatelessWidget {
  final ProgramaSocial programa;
  final double size;
  const _ProgramaAvatar({required this.programa, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final logo = programa.logoAsset;
    if (logo != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.27),
          border: Border.all(color: programa.color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: programa.color.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        padding: EdgeInsets.all(size * 0.08),
        child: Image.asset(logo, fit: BoxFit.contain),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [programa.color, programa.color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.27),
        boxShadow: [
          BoxShadow(color: programa.color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(programa.icono, color: Colors.white, size: size * 0.45),
    );
  }
}

class ProgramaDetailScreen extends StatelessWidget {
  final ProgramaSocial programa;
  const ProgramaDetailScreen({super.key, required this.programa});

  @override
  Widget build(BuildContext context) {
    final eventos = kSocialEvents.where((e) => e.programa == programa).toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));
    final state = context.watch<AppState>();
    final yaInscrito = eventos.where((e) => state.isEnrolled(e.id)).length;

    final hero = programa.heroAsset;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: programa.color,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(programa.nombre,
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w800)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Foto hero o gradiente como fallback
                  if (hero != null)
                    Image.asset(hero, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: programa.color))
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [programa.color, programa.color.withValues(alpha: 0.6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  // Gradiente oscuro abajo para legibilidad del título
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: hero != null ? 0.15 : 0.0),
                          Colors.transparent,
                          Colors.black.withValues(alpha: hero != null ? 0.65 : 0.4),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  // Icono decorativo solo si NO hay foto
                  if (hero == null)
                    Positioned(
                      right: -30,
                      top: 30,
                      child: Icon(programa.icono, size: 220, color: Colors.white.withValues(alpha: 0.15)),
                    ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 70,
                    child: Text(programa.lema,
                        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600,
                            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 6)])),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(programa.descripcion,
                      style: GoogleFonts.poppins(fontSize: 13.5, height: 1.5, color: AppColors.negro)),
                  const SizedBox(height: 18),

                  // Ilustración ambient (si existe)
                  if (programa.ambientAsset != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.asset(programa.ambientAsset!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                        ),
                      ),
                    ),

                  // Impacto
                  _ImpactoStrip(programa: programa),
                  const SizedBox(height: 22),

                  Row(
                    children: [
                      Text('Próximas jornadas',
                          style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      if (yaInscrito > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.verde.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$yaInscrito inscrito',
                              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.verde)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...eventos.map((e) => _EventoCard(evento: e)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactoStrip extends StatelessWidget {
  final ProgramaSocial programa;
  const _ImpactoStrip({required this.programa});

  @override
  Widget build(BuildContext context) {
    final impactos = _impactoMap[programa]!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: programa.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: impactos.map((e) {
          return Expanded(
            child: Column(
              children: [
                Text(e.$1,
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800, color: programa.color)),
                const SizedBox(height: 2),
                Text(e.$2,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris, height: 1.2)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

const Map<ProgramaSocial, List<(String, String)>> _impactoMap = {
  ProgramaSocial.cuidarte: [('12', 'Jornadas\nrealizadas'), ('340', 'Voluntarios'), ('21k', 'Fermines\nrepartidos')],
  ProgramaSocial.imaginarte: [('18', 'Tapas\npintadas'), ('25', 'Artistas\nlocales'), ('150k', 'Inversión\nCOP')],
  ProgramaSocial.salvarte: [('8', 'Brigadas\nde salud'), ('420', 'Familias\natendidas'), ('Pequeño', 'Corazón\nFundación')],
  ProgramaSocial.desarmarte: [('47', 'Armas\nentregadas'), ('47', 'Familias\nbeneficiadas'), ('100%', 'Anonimato\ngarantizado')],
};

class _EventoCard extends StatelessWidget {
  final SocialEvent evento;
  const _EventoCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final inscrito = state.isEnrolled(evento.id);
    final ocupacion = evento.cuposOcupados / evento.cupos;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventoDetailScreen(evento: evento))),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: evento.programa.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${evento.fecha.day}',
                              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800, color: evento.programa.color, height: 1)),
                          Text(_fmtFecha(evento.fecha).split(' ').last.toUpperCase(),
                              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: evento.programa.color)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(evento.titulo,
                              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 12, color: AppColors.gris),
                              const SizedBox(width: 3),
                              Expanded(child: Text(evento.lugar, overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris))),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(evento.hora,
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
                        ],
                      ),
                    ),
                    if (inscrito)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.verde,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.amarillo,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('+${evento.recompensaFermines}F',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.negro)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ocupacion,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(evento.programa.color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${evento.cuposOcupados}/${evento.cupos}',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gris)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventoDetailScreen extends StatelessWidget {
  final SocialEvent evento;
  const EventoDetailScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final inscrito = state.isEnrolled(evento.id);
    final color = evento.programa.color;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: color,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (evento.programa.heroAsset != null)
                    Image.asset(evento.programa.heroAsset!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: color))
                  else ...[
                    Container(color: color),
                    Positioned(
                      right: -40,
                      top: -20,
                      child: Icon(evento.programa.icono, size: 240, color: Colors.white.withValues(alpha: 0.15)),
                    ),
                  ],
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(evento.programa.nombre.toUpperCase(),
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                        ),
                        const SizedBox(height: 8),
                        Text(evento.titulo,
                            style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white,
                                shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 8)])),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Datos rápidos
                  Row(
                    children: [
                      _MetaChip(icon: Icons.event_rounded, label: _fmtFechaLarga(evento.fecha)),
                      const SizedBox(width: 8),
                      _MetaChip(icon: Icons.access_time_rounded, label: evento.hora),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _MetaChip(icon: Icons.location_on_rounded, label: '${evento.lugar} · ${evento.sector}', wide: true),
                  const SizedBox(height: 18),

                  Text('Sobre la jornada', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(evento.descripcion,
                      style: GoogleFonts.poppins(fontSize: 13, height: 1.5, color: AppColors.negro)),
                  const SizedBox(height: 18),

                  // Recompensa
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.amarillo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.amarillo, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: AppColors.amarillo, shape: BoxShape.circle),
                              child: const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.negro),
                            ),
                            const SizedBox(width: 8),
                            Text('+${evento.recompensaFermines} Fermines',
                                style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        if (evento.recompensaExtra.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('También recibes: ${evento.recompensaExtra}',
                              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.negro.withValues(alpha: 0.8))),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  if (evento.requisitos.isNotEmpty) ...[
                    Text('Qué llevar', style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...evento.requisitos.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 16, color: color),
                              const SizedBox(width: 8),
                              Expanded(child: Text(r, style: GoogleFonts.poppins(fontSize: 12.5))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 14),
                  ],

                  // Cupos
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Cupos', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Text('${evento.cuposOcupados} de ${evento.cupos}',
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: evento.cuposOcupados / evento.cupos,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(color),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('Quedan ${evento.cuposDisponibles} cupos',
                            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: inscrito
                ? null
                : () {
                    context.read<AppState>().enrollInEvent(evento);
                    showDialog(
                      context: context,
                      builder: (_) => _InscritoDialog(evento: evento),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: inscrito ? AppColors.verde : color,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(inscrito ? Icons.check_circle_rounded : Icons.volunteer_activism_rounded),
            label: Text(inscrito ? 'Ya estás inscrito' : 'Quiero participar',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool wide;
  const _MetaChip({required this.icon, required this.label, this.wide = false});

  @override
  Widget build(BuildContext context) {
    final w = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gris),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    return wide ? SizedBox(width: double.infinity, child: w) : w;
  }
}

class _InscritoDialog extends StatelessWidget {
  final SocialEvent evento;
  const _InscritoDialog({required this.evento});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: evento.programa.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.celebration_rounded, color: evento.programa.color, size: 32),
            ),
            const SizedBox(height: 14),
            Text('¡Te esperamos!',
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(
              'Quedaste inscrito en "${evento.titulo}". Cuando completes la jornada recibirás +${evento.recompensaFermines} Fermines.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.gris, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: evento.programa.color),
              child: Text('¡Hágale!', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtFechaLarga(DateTime d) {
  const meses = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
  return '${d.day} de ${meses[d.month - 1]}';
}
