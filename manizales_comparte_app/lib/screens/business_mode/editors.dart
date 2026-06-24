import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/media_image.dart';

// ============================================================================
// Editor de PRODUCTO
// ============================================================================
Future<void> showProductEditor(
  BuildContext context, {
  BusinessProduct? product,
  required String businessId,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ProductEditorDialog(product: product, businessId: businessId),
  );
}

class _ProductEditorDialog extends StatefulWidget {
  final BusinessProduct? product;
  final String businessId;
  const _ProductEditorDialog({this.product, required this.businessId});

  @override
  State<_ProductEditorDialog> createState() => _ProductEditorDialogState();
}

class _ProductEditorDialogState extends State<_ProductEditorDialog> {
  late final TextEditingController _nombre;
  late final TextEditingController _desc;
  late final TextEditingController _cop;
  late final TextEditingController _stock;
  late final TextEditingController _maxPorDia;
  int _ferminPercent = 100; // % del precio pagable con Fermines
  bool _destacado = false;
  bool _activo = true;

  String? _fotoUrl;        // foto existente (URL/asset)
  Uint8List? _newBytes;    // foto recién elegida (pendiente de subir)
  bool _saving = false;
  String? _error;

  bool get _isNew => widget.product == null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _desc = TextEditingController(text: p?.descripcion ?? '');
    _cop = TextEditingController(text: p == null ? '' : '${p.precioCOP}');
    _stock = TextEditingController(text: p == null ? '0' : '${p.stock}');
    _maxPorDia = TextEditingController(text: '${p?.maxPorDia ?? 0}');
    _ferminPercent = p?.ferminPercent ?? 100;
    _destacado = p?.destacado ?? false;
    _activo = p?.activo ?? true;
    _fotoUrl = p?.foto;
    // Refresca el desglose Fermines/plata al teclear el precio.
    _cop.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nombre.dispose();
    _desc.dispose();
    _cop.dispose();
    _stock.dispose();
    _maxPorDia.dispose();
    super.dispose();
  }

  int _parseInt(String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1280, imageQuality: 82);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;
    setState(() => _newBytes = bytes);
  }

  Future<void> _save() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final state = context.read<AppState>();
    try {
      var foto = _fotoUrl;
      if (_newBytes != null) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        foto = await state.repo.uploadImage(
          _newBytes!,
          folder: 'products',
          fileName: '${widget.businessId}_$ts.jpg',
        );
      }
      final cop = _parseInt(_cop.text);
      final fermines = (cop * _ferminPercent / 100 / 1000).round();
      final p = BusinessProduct(
        id: widget.product?.id ?? 'prod_new',
        businessId: widget.businessId,
        nombre: nombre,
        descripcion: _desc.text.trim(),
        foto: foto,
        precioCOP: cop,
        precioFermines: fermines,
        ferminPercent: _ferminPercent,
        maxPorDia: _parseInt(_maxPorDia.text),
        stock: _parseInt(_stock.text),
        destacado: _destacado,
        activo: _activo,
      );
      await state.saveProduct(p, isNew: _isNew);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_isNew ? 'Producto creado' : 'Producto actualizado'}: $nombre'),
        backgroundColor: AppColors.verde,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() { _saving = false; _error = _friendly(e); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isNew ? 'Nuevo producto' : 'Editar producto',
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('1 Fermín = \$1.000 COP · el descuento lo asume tu negocio',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
              const SizedBox(height: 16),
              _PhotoPicker(
                bytes: _newBytes,
                existing: _fotoUrl,
                onPick: _saving ? null : _pickImage,
              ),
              const SizedBox(height: 14),
              _field(_nombre, 'Nombre del producto'),
              const SizedBox(height: 10),
              _field(_desc, 'Descripción', maxLines: 2),
              const SizedBox(height: 10),
              _field(_cop, 'Precio total (COP)', number: true, prefix: '\$ '),
              const SizedBox(height: 14),
              _PercentSplit(
                percent: _ferminPercent,
                cop: _parseInt(_cop.text),
                onChanged: (v) => setState(() => _ferminPercent = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field(_stock, 'Stock', number: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_maxPorDia, 'Máx./día (0 = ∞)', number: true)),
                ],
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _destacado,
                onChanged: (v) => setState(() => _destacado = v),
                title: Text('Destacado', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('Aparece resaltado en la app', style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.gris)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
                title: Text('Visible en la app', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('Apágalo para ocultarlo sin borrarlo', style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.gris)),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                _ErrorBox(_error!),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      child: Text('Cancelar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_isNew ? 'Crear' : 'Guardar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {int maxLines = 1, bool number = false, String? prefix, String? suffix, VoidCallback? onChangedManual}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly] : null,
      onChanged: onChangedManual == null ? null : (_) => onChangedManual(),
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ============================================================================
// Editor de PROMOCIÓN
// ============================================================================
Future<void> showPromotionEditor(
  BuildContext context, {
  Promotion? promo,
  required String businessId,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PromotionEditorDialog(promo: promo, businessId: businessId),
  );
}

class _PromotionEditorDialog extends StatefulWidget {
  final Promotion? promo;
  final String businessId;
  const _PromotionEditorDialog({this.promo, required this.businessId});

  @override
  State<_PromotionEditorDialog> createState() => _PromotionEditorDialogState();
}

class _PromotionEditorDialogState extends State<_PromotionEditorDialog> {
  late final TextEditingController _titulo;
  late final TextEditingController _desc;
  late final TextEditingController _cond;
  late final TextEditingController _vig;
  bool _activa = true;
  String? _fotoUrl;
  Uint8List? _newBytes;
  bool _saving = false;
  String? _error;

  bool get _isNew => widget.promo == null;

  @override
  void initState() {
    super.initState();
    final p = widget.promo;
    _titulo = TextEditingController(text: p?.titulo ?? '');
    _desc = TextEditingController(text: p?.descripcion ?? '');
    _cond = TextEditingController(text: p?.condiciones ?? '');
    _vig = TextEditingController(text: p?.vigencia ?? 'Permanente');
    _activa = p?.activa ?? true;
    _fotoUrl = p?.foto;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _desc.dispose();
    _cond.dispose();
    _vig.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1280, imageQuality: 82);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;
    setState(() => _newBytes = bytes);
  }

  Future<void> _save() async {
    final titulo = _titulo.text.trim();
    if (titulo.isEmpty) {
      setState(() => _error = 'El título es obligatorio');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final state = context.read<AppState>();
    try {
      var foto = _fotoUrl;
      if (_newBytes != null) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        foto = await state.repo.uploadImage(
          _newBytes!,
          folder: 'promos',
          fileName: '${widget.businessId}_$ts.jpg',
        );
      }
      final p = Promotion(
        id: widget.promo?.id ?? 'promo_new',
        businessId: widget.businessId,
        titulo: titulo,
        descripcion: _desc.text.trim(),
        condiciones: _cond.text.trim(),
        vigencia: _vig.text.trim(),
        foto: foto,
        activa: _activa,
      );
      await state.savePromotion(p, isNew: _isNew);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_isNew ? 'Promoción creada' : 'Promoción actualizada'}: $titulo'),
        backgroundColor: AppColors.verde,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() { _saving = false; _error = _friendly(e); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isNew ? 'Nueva promoción' : 'Editar promoción',
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              _PhotoPicker(bytes: _newBytes, existing: _fotoUrl, onPick: _saving ? null : _pickImage),
              const SizedBox(height: 14),
              _field(_titulo, 'Título de la promoción'),
              const SizedBox(height: 10),
              _field(_desc, 'Descripción', maxLines: 2),
              const SizedBox(height: 10),
              _field(_cond, 'Condiciones', maxLines: 2),
              const SizedBox(height: 10),
              _field(_vig, 'Vigencia'),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _activa,
                onChanged: (v) => setState(() => _activa = v),
                title: Text('Activa', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('Visible para los usuarios en la app', style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.gris)),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                _ErrorBox(_error!),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : () => Navigator.of(context).pop(),
                      child: Text('Cancelar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_isNew ? 'Crear' : 'Guardar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ============================================================================
// Widgets compartidos
// ============================================================================
class _PhotoPicker extends StatelessWidget {
  final Uint8List? bytes;
  final String? existing;
  final VoidCallback? onPick;
  const _PhotoPicker({this.bytes, this.existing, this.onPick});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: bytes != null
            ? Image.memory(bytes!, fit: BoxFit.cover)
            : (existing != null && existing!.isNotEmpty)
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      MediaImage(source: existing),
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircleAvatar(radius: 16, backgroundColor: Colors.black54,
                              child: Icon(Icons.edit_rounded, size: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, size: 30, color: Colors.grey.shade500),
                      const SizedBox(height: 6),
                      Text('Subir foto', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris, fontWeight: FontWeight.w600)),
                    ],
                  ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox(this.message);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.rojo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.rojo),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.rojo))),
        ],
      ),
    );
  }
}

/// Slider de % pagable con Fermines + desglose (Fermines de descuento vs plata).
class _PercentSplit extends StatelessWidget {
  final int percent;
  final int cop;
  final ValueChanged<int> onChanged;
  const _PercentSplit({required this.percent, required this.cop, required this.onChanged});

  String _money(int v) =>
      v.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final fermines = (cop * percent / 100 / 1000).round();
    final copReal = (cop * (100 - percent) / 100).round();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Se paga con Fermines',
                style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('$percent%',
                style: GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.rojo)),
          ]),
          Slider(
            value: percent.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            label: '$percent%',
            onChanged: (v) => onChanged(v.round()),
          ),
          Row(children: [
            Expanded(child: _chip('$fermines F', 'Fermines (descuento)', AppColors.amarillo)),
            const SizedBox(width: 8),
            Expanded(child: _chip('\$${_money(copReal)}', 'en plata real', AppColors.verde)),
          ]),
          const SizedBox(height: 6),
          Text('1 Fermín = \$1.000. El % en Fermines es el descuento que tu negocio asume.',
              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris)),
        ],
      ),
    );
  }

  Widget _chip(String big, String small, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(big, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w800)),
            Text(small, style: GoogleFonts.poppins(fontSize: 9.5, color: AppColors.gris)),
          ],
        ),
      );
}

String _friendly(Object e) {
  final s = '$e';
  if (s.contains('row-level security') || s.contains('violates')) {
    return 'No tienes permiso para editar este negocio. Inicia sesión con la cuenta dueña.';
  }
  if (s.contains('Failed host lookup') || s.contains('SocketException')) {
    return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
  }
  return 'No se pudo guardar. $s';
}
