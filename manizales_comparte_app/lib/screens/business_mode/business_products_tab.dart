import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/media_image.dart';
import 'editors.dart';

class BusinessProductsTab extends StatelessWidget {
  const BusinessProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final productos = state.productsFor(state.activeBusinessId);

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
                onPressed: () => showProductEditor(context, businessId: state.activeBusinessId),
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
                if (productos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 36, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        Text('Aún no tienes productos',
                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Toca "Nuevo producto" para publicar el primero con su foto y precio.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.gris)),
                      ],
                    ),
                  )
                else
                  ...productos.map((p) => _ProductRow(producto: p)),
              ],
            ),
          ),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 36,
              height: 36,
              child: producto.foto != null && producto.foto!.isNotEmpty
                  ? MediaImage(source: producto.foto)
                  : Container(
                      color: producto.color.withValues(alpha: 0.15),
                      child: Icon(producto.icono, size: 18, color: producto.color),
                    ),
            ),
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
          IconButton(
            tooltip: 'Editar',
            onPressed: () => showProductEditor(context,
                product: producto, businessId: producto.businessId),
            icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.gris),
          ),
          PopupMenuButton<String>(
            tooltip: 'Más',
            icon: const Icon(Icons.more_horiz_rounded, size: 16, color: AppColors.gris),
            onSelected: (v) async {
              final state = context.read<AppState>();
              final messenger = ScaffoldMessenger.of(context);
              try {
                if (v == 'destacar') {
                  await state.saveProduct(
                      producto.copyWith(destacado: !producto.destacado),
                      isNew: false);
                } else if (v == 'visible') {
                  await state.saveProduct(
                      producto.copyWith(activo: !producto.activo),
                      isNew: false);
                } else if (v == 'eliminar') {
                  final ok = await _confirmDelete(context, producto.nombre);
                  if (ok) await state.deleteProduct(producto.id);
                }
              } catch (e) {
                messenger.showSnackBar(SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: AppColors.rojo,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'destacar',
                  child: Text(producto.destacado ? 'Quitar destacado' : 'Destacar')),
              PopupMenuItem(
                  value: 'visible',
                  child: Text(producto.activo ? 'Ocultar de la app' : 'Mostrar en la app')),
              const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirmDelete(BuildContext context, String nombre) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Eliminar', style: GoogleFonts.montserrat(fontWeight: FontWeight.w800)),
      content: Text('¿Eliminar "$nombre"? Esta acción no se puede deshacer.',
          style: GoogleFonts.poppins(fontSize: 13)),
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
