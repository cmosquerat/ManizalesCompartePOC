import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';

class BusinessRedeemTab extends StatefulWidget {
  const BusinessRedeemTab({super.key});

  @override
  State<BusinessRedeemTab> createState() => _BusinessRedeemTabState();
}

class _BusinessRedeemTabState extends State<BusinessRedeemTab> {
  final _ctrl = TextEditingController();
  CanjeIntent? _found;
  bool _busy = false;
  String? _message; // error / info

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _lookup([String? codeArg]) async {
    final code = (codeArg ?? _ctrl.text).trim();
    if (code.isEmpty) return;
    setState(() { _busy = true; _message = null; _found = null; });
    final state = context.read<AppState>();
    try {
      final intent = await state.buscarCanje(code);
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (intent == null) {
          _message = 'Código no encontrado, ya usado o de otro negocio.';
        } else {
          _found = intent;
          _ctrl.text = code;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _busy = false; _message = 'Error: $e'; });
    }
  }

  Future<void> _scan() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _QrScanDialog(),
    );
    if (code != null && code.isNotEmpty) {
      await _lookup(code);
    }
  }

  Future<void> _confirm() async {
    final intent = _found;
    if (intent == null) return;
    setState(() { _busy = true; _message = null; });
    final state = context.read<AppState>();
    final messenger = ScaffoldMessenger.of(context);
    final err = await state.confirmarCanje(intent);
    if (!mounted) return;
    if (err == null) {
      setState(() { _busy = false; _found = null; _ctrl.clear(); });
      messenger.showSnackBar(SnackBar(
        content: Text('Canje aplicado: ${intent.productName}'),
        backgroundColor: AppColors.verde,
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      setState(() { _busy = false; _message = err; });
    }
  }

  void _cancel() => setState(() { _found = null; _message = null; _ctrl.clear(); });

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
          Text('Escanea el QR del cliente o teclea su código de 6 dígitos',
              style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
          const SizedBox(height: 18),
          LayoutBuilder(builder: (ctx, c) {
            final stack = c.maxWidth < 720;
            final scanner = _ScannerCard(
              ctrl: _ctrl,
              found: _found,
              busy: _busy,
              message: _message,
              onLookup: () => _lookup(),
              onScan: _scan,
              onConfirm: _confirm,
              onCancel: _cancel,
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
  final CanjeIntent? found;
  final bool busy;
  final String? message;
  final VoidCallback onLookup;
  final VoidCallback onScan;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ScannerCard({
    required this.ctrl,
    required this.found,
    required this.busy,
    required this.message,
    required this.onLookup,
    required this.onScan,
    required this.onConfirm,
    required this.onCancel,
  });

  String _money(int v) =>
      v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: busy ? null : onScan,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: Text('Escanear QR del cliente', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.rojo),
                foregroundColor: AppColors.rojo,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Divider(color: Colors.grey.shade200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('o código', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
            ),
            Expanded(child: Divider(color: Colors.grey.shade200)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => onLookup(),
                decoration: InputDecoration(
                  labelText: 'Código del canje',
                  hintText: '123 456',
                  prefixIcon: const Icon(Icons.dialpad_rounded, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: busy ? null : onLookup,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15)),
              child: busy && found == null
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Buscar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            ),
          ]),
          if (message != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(color: AppColors.rojo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.rojo),
                const SizedBox(width: 8),
                Expanded(child: Text(message!, style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.rojo))),
              ]),
            ),
          ],
          if (found != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.verde.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.verde.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Canje válido',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.verde, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(found!.productName,
                      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.amarillo, borderRadius: BorderRadius.circular(8)),
                      child: Text('${found!.fermines} F descuento',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Text(found!.copReal > 0 ? 'Cobra \$${_money(found!.copReal)} en caja' : 'Sin cobro en caja',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris, fontWeight: FontWeight.w600)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Rechazar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: busy ? null : onConfirm,
                  icon: busy
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.check_rounded),
                  label: Text('Aplicar canje', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verde,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

/// Escáner de QR con cámara (mobile_scanner). Devuelve el código leído.
class _QrScanDialog extends StatefulWidget {
  const _QrScanDialog();
  @override
  State<_QrScanDialog> createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<_QrScanDialog> {
  final MobileScannerController _controller = MobileScannerController();
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    final list = capture.barcodes;
    if (list.isEmpty) return;
    final code = list.first.rawValue;
    if (code == null || code.isEmpty) return;
    _done = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(children: [
                Text('Escanear QR', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
              ]),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 300,
                height: 300,
                child: MobileScanner(controller: _controller, onDetect: _onDetect),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text('Apunta al QR que muestra el cliente.',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.gris)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedHistory extends StatelessWidget {
  final List<Redemption> reds;
  const _RedHistory({required this.reds});

  String _money(int v) =>
      v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

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
            child: Row(children: [
              Text('Últimos canjes', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('${reds.length}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
            ]),
          ),
          const Divider(height: 1),
          if (reds.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Aún no hay canjes. Pa\'lante, parcero.',
                  style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
            )
          else
            ...reds.map((r) {
              final mins = DateTime.now().difference(r.fecha).inMinutes;
              final tiempo = mins < 60
                  ? 'hace $mins min'
                  : mins < 1440
                      ? 'hace ${(mins / 60).floor()} h'
                      : 'hace ${(mins / 1440).floor()} d';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.rojo.withValues(alpha: 0.15),
                    child: Text(r.userName.isNotEmpty ? r.userName[0] : '?',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.rojo)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.productName,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text('$tiempo${r.totalCOP > 0 ? ' · \$${_money(r.totalCOP)} en caja' : ''}',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris)),
                      ],
                    ),
                  ),
                  Text('-${r.totalFermines} F',
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.rojo)),
                ]),
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
