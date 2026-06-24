import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/app_state.dart';
import '../../widgets/media_image.dart';

/// Crea o edita el perfil de un negocio. Al crear queda con owner = la cuenta
/// del comerciante autenticado (RLS), por lo que aparece en "mis negocios".
Future<void> showBusinessEditor(BuildContext context, {Business? business}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _BusinessEditorDialog(business: business),
  );
}

class _BusinessEditorDialog extends StatefulWidget {
  final Business? business;
  const _BusinessEditorDialog({this.business});

  @override
  State<_BusinessEditorDialog> createState() => _BusinessEditorDialogState();
}

class _BusinessEditorDialogState extends State<_BusinessEditorDialog> {
  late final TextEditingController _nombre;
  late final TextEditingController _desc;
  late final TextEditingController _direccion;
  late final TextEditingController _sector;
  late final TextEditingController _horarios;
  late final TextEditingController _telefono;
  late final TextEditingController _instagram;
  late final TextEditingController _maxCanjes;
  final _mapCtrl = MapController();
  BusinessType _tipo = BusinessType.cafe;
  late LatLng _point;

  String? _fotoUrl;
  Uint8List? _newBytes;
  bool _saving = false;
  String? _error;

  bool get _isNew => widget.business == null;

  @override
  void initState() {
    super.initState();
    final b = widget.business;
    _nombre = TextEditingController(text: b?.nombre ?? '');
    _desc = TextEditingController(text: b?.descripcion ?? '');
    _direccion = TextEditingController(text: b?.direccion ?? '');
    _sector = TextEditingController(text: b?.sector ?? '');
    _horarios = TextEditingController(text: b?.horarios ?? '');
    _telefono = TextEditingController(text: b?.telefono ?? '');
    _instagram = TextEditingController(text: b?.instagram ?? '');
    _maxCanjes = TextEditingController(text: '${b?.maxCanjesDia ?? 0}');
    _tipo = b?.tipo ?? BusinessType.cafe;
    _point = LatLng(b?.lat ?? 5.0700, b?.lng ?? -75.5138);
    _fotoUrl = b?.foto;
  }

  @override
  void dispose() {
    for (final c in [_nombre, _desc, _direccion, _sector, _horarios, _telefono, _instagram, _maxCanjes]) {
      c.dispose();
    }
    super.dispose();
  }

  int _parseInt(String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 82);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;
    setState(() => _newBytes = bytes);
  }

  Future<void> _save() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'El nombre del negocio es obligatorio');
      return;
    }
    setState(() { _saving = true; _error = null; });
    final state = context.read<AppState>();
    try {
      var foto = _fotoUrl ?? '';
      if (_newBytes != null) {
        final ts = DateTime.now().millisecondsSinceEpoch;
        foto = await state.repo.uploadImage(_newBytes!, folder: 'businesses', fileName: 'biz_$ts.jpg');
      }
      final base = widget.business;
      final b = (base ??
              const Business(
                id: 'biz_new',
                nombre: '',
                tipo: BusinessType.cafe,
                descripcion: '',
                foto: '',
                logo: 'assets/images/Logo_positivo.svg',
                lat: 5.07,
                lng: -75.51,
                direccion: '',
                sector: '',
                horarios: '',
                telefono: '',
                instagram: '',
                rating: 45,
                ratingCount: 0,
              ))
          .copyWith(
        nombre: nombre,
        tipo: _tipo,
        descripcion: _desc.text.trim(),
        foto: foto,
        direccion: _direccion.text.trim(),
        sector: _sector.text.trim(),
        horarios: _horarios.text.trim(),
        telefono: _telefono.text.trim(),
        instagram: _instagram.text.trim(),
        lat: _point.latitude,
        lng: _point.longitude,
        maxCanjesDia: _parseInt(_maxCanjes.text),
        activo: true,
      );
      await state.saveBusiness(b, isNew: _isNew);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${_isNew ? 'Negocio creado' : 'Negocio actualizado'}: $nombre'),
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
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_isNew ? 'Registra tu negocio' : 'Editar negocio',
                  style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              _photo(),
              const SizedBox(height: 14),
              _field(_nombre, 'Nombre del negocio'),
              const SizedBox(height: 10),
              DropdownButtonFormField<BusinessType>(
                initialValue: _tipo,
                isExpanded: true,
                decoration: _dec('Tipo'),
                items: BusinessType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Row(children: [
                            Icon(t.icono, size: 16, color: AppColors.gris),
                            const SizedBox(width: 8),
                            Text(t.nombre, style: GoogleFonts.poppins(fontSize: 13)),
                          ]),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _tipo = v ?? _tipo),
              ),
              const SizedBox(height: 10),
              _field(_desc, 'Descripción', maxLines: 2),
              const SizedBox(height: 10),
              _field(_sector, 'Sector (ej. Av. Santander)'),
              const SizedBox(height: 10),
              _field(_direccion, 'Dirección'),
              const SizedBox(height: 10),
              _field(_horarios, 'Horarios'),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _field(_telefono, 'Teléfono')),
                const SizedBox(width: 10),
                Expanded(child: _field(_instagram, 'Instagram')),
              ]),
              const SizedBox(height: 16),

              // ---- Ubicación en mapa ----
              Row(children: [
                const Icon(Icons.place_rounded, size: 16, color: AppColors.rojo),
                const SizedBox(width: 6),
                Text('Ubicación', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('Toca el mapa para fijarla', style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.gris)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  child: FlutterMap(
                    mapController: _mapCtrl,
                    options: MapOptions(
                      initialCenter: _point,
                      initialZoom: 14,
                      onTap: (_, p) => setState(() => _point = p),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.manizalescomparte.app',
                      ),
                      MarkerLayer(markers: [
                        Marker(
                          point: _point,
                          width: 44,
                          height: 44,
                          alignment: Alignment.topCenter,
                          child: const Icon(Icons.location_on_rounded, color: AppColors.rojo, size: 40),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text('Lat ${_point.latitude.toStringAsFixed(5)} · Lng ${_point.longitude.toStringAsFixed(5)}',
                  style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.gris)),
              const SizedBox(height: 14),

              _field(_maxCanjes, 'Máx. canjes por día (0 = sin límite)', number: true),
              const SizedBox(height: 4),
              Text('Evita saturarte: tope de canjes diarios para todo el negocio.',
                  style: GoogleFonts.poppins(fontSize: 10.5, color: AppColors.gris)),

              if (_error != null) ...[
                const SizedBox(height: 10),
                _errorBox(_error!),
              ],
              const SizedBox(height: 16),
              Row(children: [
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
                        : Text(_isNew ? 'Crear negocio' : 'Guardar', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photo() => InkWell(
        onTap: _saving ? null : _pickImage,
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
          child: _newBytes != null
              ? Image.memory(_newBytes!, fit: BoxFit.cover)
              : (_fotoUrl != null && _fotoUrl!.isNotEmpty)
                  ? MediaImage(source: _fotoUrl)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, size: 30, color: Colors.grey.shade500),
                        const SizedBox(height: 6),
                        Text('Foto de portada', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris, fontWeight: FontWeight.w600)),
                      ],
                    ),
        ),
      );

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _field(TextEditingController c, String label, {int maxLines = 1, bool number = false}) => TextField(
        controller: c,
        maxLines: maxLines,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        inputFormatters: number ? [FilteringTextInputFormatter.digitsOnly] : null,
        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
        decoration: _dec(label),
      );

  Widget _errorBox(String msg) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.rojo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          const Icon(Icons.error_outline_rounded, size: 16, color: AppColors.rojo),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.rojo))),
        ]),
      );
}

String _friendly(Object e) {
  final s = '$e';
  if (s.contains('row-level security') || s.contains('violates')) {
    return 'No tienes permiso. Verifica tu sesión.';
  }
  if (s.contains('Failed host lookup') || s.contains('SocketException')) {
    return 'Sin conexión. Revisa tu internet.';
  }
  return 'No se pudo guardar. $s';
}
