import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';

class BusinessPromotionsTab extends StatefulWidget {
  const BusinessPromotionsTab({super.key});

  @override
  State<BusinessPromotionsTab> createState() => _BusinessPromotionsTabState();
}

class _BusinessPromotionsTabState extends State<BusinessPromotionsTab> {
  final Set<String> _pausadas = {};

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final promos = kPromotions.where((p) => p.businessId == state.activeBusinessId).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Promociones',
                        style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800)),
                    Text('Activa ofertas especiales y atrae más tráfico',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Nueva promo', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...promos.map((p) => _PromoRow(
                promo: p,
                paused: _pausadas.contains(p.id),
                onToggle: (v) => setState(() {
                  if (v) {
                    _pausadas.remove(p.id);
                  } else {
                    _pausadas.add(p.id);
                  }
                }),
              )),
        ],
      ),
    );
  }
}

class _PromoRow extends StatelessWidget {
  final Promotion promo;
  final bool paused;
  final ValueChanged<bool> onToggle;
  const _PromoRow({required this.promo, required this.paused, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: promo.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(promo.icono, color: promo.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(promo.titulo,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: paused ? AppColors.gris.withValues(alpha: 0.2) : AppColors.verde.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(paused ? 'En pausa' : 'Activa',
                          style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w800,
                              color: paused ? AppColors.gris : AppColors.verde)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(promo.descripcion,
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.negro, height: 1.4)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    _miniChip(Icons.rule_rounded, promo.condiciones),
                    _miniChip(Icons.event_available_rounded, promo.vigencia),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(value: !paused, onChanged: onToggle),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.gris)),
        ],
      ),
    );
  }

  Widget _miniChip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.gris),
          const SizedBox(width: 4),
          Text(text,
              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
