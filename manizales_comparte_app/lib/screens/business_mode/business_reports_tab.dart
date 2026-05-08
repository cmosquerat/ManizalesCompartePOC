import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';

class BusinessReportsTab extends StatelessWidget {
  const BusinessReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final reds = state.redemptionsFor(state.activeBusinessId);
    final tot = reds.length;
    final turistas = reds.where((r) => r.origen == 'turista').length;
    final locales = tot - turistas;

    final productosCount = <String, int>{};
    for (final r in reds) {
      productosCount[r.productName] = (productosCount[r.productName] ?? 0) + 1;
    }
    final top = productosCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reportes',
              style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800)),
          Text('Cómo te está yendo en el ecosistema Manizales Comparte',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
          const SizedBox(height: 18),

          LayoutBuilder(builder: (ctx, c) {
            final stack = c.maxWidth < 720;
            final left = _OrigenCard(turistas: turistas, locales: locales);
            final right = _TopProductos(top: top.take(5).toList());
            if (stack) {
              return Column(children: [left, const SizedBox(height: 16), right]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                const SizedBox(width: 16),
                Expanded(child: right),
              ],
            );
          }),
          const SizedBox(height: 16),
          _Benchmark(),
        ],
      ),
    );
  }
}

class _OrigenCard extends StatelessWidget {
  final int turistas;
  final int locales;
  const _OrigenCard({required this.turistas, required this.locales});

  @override
  Widget build(BuildContext context) {
    final tot = (turistas + locales).clamp(1, 9999);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Origen del cliente',
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: turistas.toDouble(),
                    color: AppColors.rojo,
                    title: '${(turistas / tot * 100).round()}%',
                    radius: 50,
                    titleStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: locales.toDouble(),
                    color: AppColors.turquesa,
                    title: '${(locales / tot * 100).round()}%',
                    radius: 50,
                    titleStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _legend(AppColors.rojo, 'Turistas', turistas),
              const SizedBox(width: 12),
              _legend(AppColors.turquesa, 'Locales', locales),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color c, String label, int n) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label · $n',
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _TopProductos extends StatelessWidget {
  final List<MapEntry<String, int>> top;
  const _TopProductos({required this.top});

  @override
  Widget build(BuildContext context) {
    final maxV = top.isEmpty ? 1 : top.first.value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top productos',
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text('Aún no hay datos suficientes',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
              ),
            )
          else
            ...top.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(e.key,
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                          Text('${e.value} canjes',
                              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: e.value / maxV,
                          minHeight: 7,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation(AppColors.rojo),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}

class _Benchmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Comparativa con cafés y brunchs aliados',
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._mockComparativa().map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(m.label,
                          style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: (m.tu / 100).clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.rojo,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Positioned(
                            left: ((m.promedio / 100).clamp(0.0, 1.0)) * 280,
                            top: -4,
                            child: Container(
                              width: 2,
                              height: 16,
                              color: AppColors.gris,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: Text('Tú: ${m.tu} · Prom: ${m.promedio}',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _BMRow {
  final String label;
  final int tu;
  final int promedio;
  _BMRow(this.label, this.tu, this.promedio);
}

List<_BMRow> _mockComparativa() => [
      _BMRow('Visitas/día', 84, 62),
      _BMRow('Canjes/día', 18, 12),
      _BMRow('Ticket promedio (F)', 165, 140),
      _BMRow('Repetición (%)', 42, 31),
      _BMRow('Rating', 45, 42),
    ];
