import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/app_state.dart';

class BusinessDetailScreen extends StatelessWidget {
  final Business business;
  const BusinessDetailScreen({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final productos = kBusinessProducts.where((p) => p.businessId == business.id).toList();
    final promos = kPromotions.where((p) => p.businessId == business.id).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    business.foto,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: AppColors.rojo),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(business.tipo.icono, size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(business.tipo.nombre.toUpperCase(),
                                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(business.nombre,
                            style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.amarillo),
                            const SizedBox(width: 3),
                            Text('${business.ratingTxt} · ${business.ratingCount} reseñas',
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                            const SizedBox(width: 10),
                            const Icon(Icons.location_on_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 2),
                            Text(business.sector,
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                          ],
                        ),
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
                  // Descuento destacado
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded, size: 28, color: AppColors.negro),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Acepta Fermines',
                                  style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w800)),
                              Text('Hasta ${business.descuentoBaseFermines}% de descuento canjeando con tu wallet',
                                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.negro)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text('Sobre el lugar',
                      style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(business.descripcion,
                      style: GoogleFonts.poppins(fontSize: 13, height: 1.5)),
                  const SizedBox(height: 16),

                  _InfoTile(icon: Icons.location_on_rounded, label: business.direccion),
                  _InfoTile(icon: Icons.access_time_rounded, label: business.horarios),
                  _InfoTile(icon: Icons.phone_rounded, label: business.telefono),
                  _InfoTile(icon: Icons.alternate_email_rounded, label: business.instagram),
                  const SizedBox(height: 18),

                  if (promos.isNotEmpty) ...[
                    Text('Promociones activas',
                        style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    ...promos.map((p) => _PromoCard(promo: p)),
                    const SizedBox(height: 14),
                  ],

                  Text('Catálogo · paga con Fermines',
                      style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  ...productos.map((p) => _ProductoCard(producto: p)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.gris),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 12.5))),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final Promotion promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: promo.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: promo.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: promo.color,
              shape: BoxShape.circle,
            ),
            child: Icon(promo.icono, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.titulo,
                    style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(promo.descripcion,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris, height: 1.3)),
                const SizedBox(height: 2),
                Text(promo.condiciones,
                    style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final BusinessProduct producto;
  const _ProductoCard({required this.producto});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final canBuy = state.ferminesBalance >= producto.precioFermines;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: producto.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(producto.icono, color: producto.color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(producto.nombre,
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                    if (producto.destacado)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amarillo,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('TOP',
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(producto.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris, height: 1.3)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('\$${producto.precioCOP.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris, decoration: TextDecoration.lineThrough)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.amarillo.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${producto.precioFermines}F',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: canBuy
                ? () {
                    context.read<AppState>().spendFermines(producto.precioFermines, 'Canje en negocio: ${producto.nombre}');
                    context.read<AppState>().simulateRedemption(producto);
                    showDialog(
                      context: context,
                      builder: (_) => _CanjeOkDialog(producto: producto),
                    );
                  }
                : null,
            style: IconButton.styleFrom(
              backgroundColor: canBuy ? AppColors.rojo : Colors.grey.shade300,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.qr_code_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _CanjeOkDialog extends StatelessWidget {
  final BusinessProduct producto;
  const _CanjeOkDialog({required this.producto});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR mock
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.rojo, width: 2),
              ),
              child: CustomPaint(painter: _MockQrPainter()),
            ),
            const SizedBox(height: 14),
            Text('Tu canje está listo',
                style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(producto.nombre,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gris)),
            const SizedBox(height: 4),
            Text('Muéstralo en caja',
                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Listo', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MockQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 16;
    final paint = Paint()..color = AppColors.negro;
    final pattern = [
      0x7E,0x42,0x5A,0x5A,0x42,0x7E,0x18,0x66,
      0x7E,0x42,0x5A,0x5A,0x42,0x7E,0x18,0x66,
    ];
    for (int y = 0; y < 16; y++) {
      for (int x = 0; x < 16; x++) {
        final on = (pattern[(y + x) % pattern.length] >> (x % 8)) & 1;
        if (on == 1) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
