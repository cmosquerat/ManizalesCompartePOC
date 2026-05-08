import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';

class BusinessProductsTab extends StatelessWidget {
  const BusinessProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final productos = kBusinessProducts.where((p) => p.businessId == state.activeBusinessId).toList();

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
                    Text('Productos',
                        style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800)),
                    Text('Define qué se puede pagar con Fermines y a qué precio',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('Nuevo producto', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Resumen
          Row(
            children: [
              _Pill(label: 'Total', value: '${productos.length}', color: AppColors.rojo),
              const SizedBox(width: 8),
              _Pill(
                label: 'Activos',
                value: '${productos.where((p) => p.stock > 0).length}',
                color: AppColors.verde,
              ),
              const SizedBox(width: 8),
              _Pill(
                label: 'Sin stock',
                value: '${productos.where((p) => p.stock == 0).length}',
                color: AppColors.gris,
              ),
              const SizedBox(width: 8),
              _Pill(
                label: 'Destacados',
                value: '${productos.where((p) => p.destacado).length}',
                color: AppColors.amarillo,
              ),
            ],
          ),
          const SizedBox(height: 18),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
            ),
            child: Column(
              children: [
                _TableHeader(),
                ...productos.map((p) => _ProductRow(producto: p)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Nuevo producto', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
        content: Text(
          'En la versión completa podrás cargar foto, descripción, definir precio en COP y ratio de Fermines (1F = \$100 COP por defecto).',
          style: GoogleFonts.poppins(fontSize: 12.5, color: AppColors.gris),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Listo', style: GoogleFonts.poppins(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Pill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(value,
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.negro)),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 44),
          Expanded(flex: 4, child: _hdr('Producto')),
          Expanded(flex: 2, child: _hdr('COP')),
          Expanded(flex: 2, child: _hdr('Fermines')),
          Expanded(flex: 2, child: _hdr('Stock')),
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _hdr(String t) => Text(t,
      style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.gris, letterSpacing: 0.5));
}

class _ProductRow extends StatelessWidget {
  final BusinessProduct producto;
  const _ProductRow({required this.producto});

  @override
  Widget build(BuildContext context) {
    final cop = producto.precioCOP.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: producto.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(producto.icono, size: 18, color: producto.color),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(producto.nombre,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    ),
                    if (producto.destacado) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.star_rounded, size: 12, color: AppColors.amarillo),
                    ],
                  ],
                ),
                Text(producto.descripcion,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.gris)),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text('\$$cop', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amarillo.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text('${producto.precioFermines}F',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: producto.stock > 0 ? AppColors.verde : AppColors.gris,
                  ),
                ),
                const SizedBox(width: 6),
                Text('${producto.stock}',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.gris)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded, size: 16, color: AppColors.gris)),
        ],
      ),
    );
  }
}
