import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';

class BusinessOverviewTab extends StatelessWidget {
  const BusinessOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final biz = state.activeBusiness;
    final reds = state.redemptionsFor(biz.id);
    final today = DateTime.now();
    final todayReds = reds.where((r) => _sameDay(r.fecha, today)).toList();
    final visitas = 84 + todayReds.length * 5;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen del día',
              style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800)),
          Text('Lo que está pasando en ${biz.nombre} hoy',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
          const SizedBox(height: 20),

          // KPI cards
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 720 ? 4 : 2;
            final w = (c.maxWidth - 16 * (cols - 1)) / cols;
            final kpis = [
              _Kpi('Visitas a la ficha', '$visitas', Icons.visibility_rounded, AppColors.turquesa, '+12% vs. ayer'),
              _Kpi('Canjes hoy', '${todayReds.length}', Icons.check_circle_rounded, AppColors.verde, '+${todayReds.length * 8}% vs. ayer'),
              _Kpi('Fermines recibidos', '${todayReds.fold<int>(0, (s, r) => s + r.totalFermines)}', Icons.monetization_on_rounded, AppColors.amarillo, '\$${(todayReds.fold<int>(0, (s, r) => s + r.totalCOP) / 1000).toStringAsFixed(0)}k COP'),
              _Kpi('Top producto', _topProducto(reds), Icons.star_rounded, AppColors.rojo, '${reds.length} canjes total'),
            ];
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: kpis.map((k) => SizedBox(width: w, child: _KpiCard(kpi: k))).toList(),
            );
          }),
          const SizedBox(height: 24),

          // Gráfico semanal + feed
          LayoutBuilder(builder: (ctx, c) {
            final stack = c.maxWidth < 720;
            final chart = _SectionCard(
              title: 'Canjes por día (últimos 7)',
              child: SizedBox(height: 220, child: _WeekChart(reds: reds)),
            );
            final feed = _SectionCard(
              title: 'Actividad en vivo',
              child: _LiveFeed(reds: reds.take(8).toList()),
            );
            if (stack) {
              return Column(children: [chart, const SizedBox(height: 16), feed]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: chart),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: feed),
              ],
            );
          }),
          const SizedBox(height: 24),

          _SectionCard(
            title: 'Pista contextual',
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.amarillo.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: AppColors.amarillo, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.negro, height: 1.5),
                        children: [
                          const TextSpan(text: '12 turistas capturaron tapas en Av. Santander en la última hora. '),
                          const TextSpan(text: 'Considera activar tu promo ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(
                            text: '"Después de la tapa: -25% en torta"',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.rojo),
                          ),
                          const TextSpan(text: ' para captar tráfico.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _topProducto(List<Redemption> reds) {
    if (reds.isEmpty) return '—';
    final counts = <String, int>{};
    for (final r in reds) {
      counts[r.productName] = (counts[r.productName] ?? 0) + 1;
    }
    final entry = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    return entry.key.length > 18 ? '${entry.key.substring(0, 16)}…' : entry.key;
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _Kpi {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String hint;
  _Kpi(this.label, this.value, this.icon, this.color, this.hint);
}

class _KpiCard extends StatelessWidget {
  final _Kpi kpi;
  const _KpiCard({required this.kpi});

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kpi.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(kpi.icon, color: kpi.color, size: 18),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 10),
          Text(kpi.value,
              style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800)),
          Text(kpi.label,
              style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(kpi.hint,
              style: GoogleFonts.poppins(fontSize: 10, color: kpi.color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

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
          Text(title,
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  final List<Redemption> reds;
  const _WeekChart({required this.reds});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final counts = days.map((d) {
      return reds.where((r) => _sameDay(r.fecha, d)).length;
    }).toList();
    // Mock relleno cuando hay poca data
    final base = [3, 5, 4, 7, 6, 9, 0];
    final values = List<double>.generate(7, (i) {
      return (counts[i] + base[i]).toDouble();
    });
    final maxY = (values.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                  style: GoogleFonts.poppins(fontSize: 9, color: AppColors.gris)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (v, _) {
                const dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                final idx = v.toInt();
                final dow = days[idx].weekday - 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(dias[dow],
                      style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.gris)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(7, (i) {
          final isToday = i == 6;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                width: 18,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isToday
                      ? [AppColors.rojo, AppColors.rojo.withValues(alpha: 0.7)]
                      : [AppColors.amarillo, AppColors.amarillo.withValues(alpha: 0.7)],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _LiveFeed extends StatelessWidget {
  final List<Redemption> reds;
  const _LiveFeed({required this.reds});

  @override
  Widget build(BuildContext context) {
    if (reds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Aún no hay actividad. Pa\'lante, parcero — ya llegará.',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
      );
    }
    return Column(
      children: reds.map((r) {
        final mins = DateTime.now().difference(r.fecha).inMinutes;
        final tiempo = mins < 60 ? '$mins min' : '${(mins / 60).floor()} h';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.rojo.withValues(alpha: 0.15),
                child: Text(r.userName[0],
                    style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.rojo)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r.userName} · ${r.productName}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    Text('hace $tiempo · ${r.origen}',
                        style: GoogleFonts.poppins(fontSize: 9.5, color: AppColors.gris)),
                  ],
                ),
              ),
              Text('${r.totalFermines}F',
                  style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.rojo)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
