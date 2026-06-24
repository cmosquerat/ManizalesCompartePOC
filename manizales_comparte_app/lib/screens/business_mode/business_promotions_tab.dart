import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import 'editors.dart';

class BusinessPromotionsTab extends StatelessWidget {
  const BusinessPromotionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final promos = state.promotionsFor(state.activeBusinessId);

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
                onPressed: () => showPromotionEditor(context, businessId: state.activeBusinessId),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Nueva promo', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (promos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
              ),
              child: Column(
                children: [
                  Icon(Icons.local_offer_outlined, size: 36, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text('Sin promociones todavía',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Crea una promo para atraer a quienes capturan tapas cerca.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.gris)),
                ],
              ),
            )
          else
            ...promos.map((p) => _PromoRow(promo: p)),
        ],
      ),
    );
  }
}

class _PromoRow extends StatelessWidget {
  final Promotion promo;
  const _PromoRow({required this.promo});

  @override
  Widget build(BuildContext context) {
    final paused = !promo.activa;
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
          Switch(
            value: promo.activa,
            onChanged: (v) {
              context.read<AppState>().savePromotion(promo.copyWith(activa: v), isNew: false);
            },
          ),
          IconButton(
            tooltip: 'Editar',
            onPressed: () => showPromotionEditor(context, promo: promo, businessId: promo.businessId),
            icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.gris),
          ),
          PopupMenuButton<String>(
            tooltip: 'Más',
            icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.gris),
            onSelected: (v) async {
              final state = context.read<AppState>();
              final messenger = ScaffoldMessenger.of(context);
              if (v == 'eliminar') {
                final ok = await _confirmDeletePromo(context, promo.titulo);
                if (ok) {
                  try {
                    await state.deletePromotion(promo.id);
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.rojo,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
            ],
          ),
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

Future<bool> _confirmDeletePromo(BuildContext context, String titulo) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Eliminar promoción', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
      content: Text('¿Eliminar "$titulo"?', style: GoogleFonts.poppins(fontSize: 13)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
        ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rojo),
            child: Text('Eliminar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
      ],
    ),
  );
  return r ?? false;
}
