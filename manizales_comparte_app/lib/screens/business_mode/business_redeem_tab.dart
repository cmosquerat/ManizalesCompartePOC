import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';

class BusinessRedeemTab extends StatefulWidget {
  const BusinessRedeemTab({super.key});

  @override
  State<BusinessRedeemTab> createState() => _BusinessRedeemTabState();
}

class _BusinessRedeemTabState extends State<BusinessRedeemTab> {
  final _ctrl = TextEditingController();
  BusinessProduct? _matched;
  bool _scanned = false;

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _simulateScan() {
    final state = context.read<AppState>();
    final productos = kBusinessProducts.where((p) => p.businessId == state.activeBusinessId).toList();
    if (productos.isEmpty) return;
    final rng = math.Random();
    final p = productos[rng.nextInt(productos.length)];
    setState(() {
      _matched = p;
      _scanned = true;
      _ctrl.text = '${100000 + rng.nextInt(900000)}';
    });
  }

  void _confirm() {
    if (_matched == null) return;
    context.read<AppState>().simulateRedemption(_matched!);
    final p = _matched!;
    setState(() {
      _matched = null;
      _scanned = false;
      _ctrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Canje confirmado: ${p.nombre} · ${p.precioFermines}F'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.verde,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final reds = state.redemptionsFor(state.activeBusinessId).take(15).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Validar canje',
              style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800)),
          Text('Pide al cliente su QR o el código de 6 dígitos en la app',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
          const SizedBox(height: 18),

          LayoutBuilder(builder: (ctx, c) {
            final stack = c.maxWidth < 720;
            final scanner = _ScannerCard(
              ctrl: _ctrl,
              matched: _matched,
              scanned: _scanned,
              onScan: _simulateScan,
              onConfirm: _confirm,
              onCancel: () => setState(() {
                _matched = null;
                _scanned = false;
                _ctrl.clear();
              }),
            );
            final history = _RedHistory(reds: reds);
            if (stack) {
              return Column(children: [scanner, const SizedBox(height: 16), history]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: scanner),
                const SizedBox(width: 16),
                Expanded(flex: 4, child: history),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ScannerCard extends StatelessWidget {
  final TextEditingController ctrl;
  final BusinessProduct? matched;
  final bool scanned;
  final VoidCallback onScan;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ScannerCard({
    required this.ctrl,
    required this.matched,
    required this.scanned,
    required this.onScan,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scanned ? AppColors.verde : Colors.grey.shade200, width: 2),
            ),
            child: Center(
              child: scanned
                  ? const Icon(Icons.check_circle_rounded, size: 64, color: AppColors.verde)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner_rounded, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('Apunta al QR del cliente',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Código del canje',
              hintText: '123456',
              prefixIcon: const Icon(Icons.dialpad_rounded, size: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          if (!scanned)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text('Simular escaneo QR', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            )
          else if (matched != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.verde.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.verde.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Canje detectado',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.verde, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(matched!.nombre,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.amarillo, borderRadius: BorderRadius.circular(8)),
                        child: Text('${matched!.precioFermines}F',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 8),
                      Text('= \$${matched!.precioCOP.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} COP',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    ),
                    child: Text('Rechazar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onConfirm,
                    icon: const Icon(Icons.check_rounded),
                    label: Text('Confirmar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RedHistory extends StatelessWidget {
  final List<Redemption> reds;
  const _RedHistory({required this.reds});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text('Últimos canjes',
                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('${reds.length}',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...reds.map((r) {
            final mins = DateTime.now().difference(r.fecha).inMinutes;
            final tiempo = mins < 60
                ? 'hace $mins min'
                : mins < 1440
                    ? 'hace ${(mins / 60).floor()} h'
                    : 'hace ${(mins / 1440).floor()} d';
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('$tiempo · ${r.origen}',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris)),
                      ],
                    ),
                  ),
                  Text('${r.totalFermines}F',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.rojo)),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
