import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../config/manizales_context.dart';
import '../config/theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import 'ar_capture_screen.dart';
import 'business_detail_screen.dart';
import 'comunidad_screen.dart';
import 'tapa_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

enum _SelectedKind { tapa, business, event }

class _MapSelection {
  final _SelectedKind kind;
  final dynamic item;
  _MapSelection(this.kind, this.item);
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  _MapSelection? _selected;
  final _mapCtrl = MapController();
  late AnimationController _previewCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  bool _showLayers = false;

  // Posición simulada del usuario (para brújula): centro de Manizales por defecto.
  static const _userPosition = LatLng(5.0645, -75.5215);

  @override
  void initState() {
    super.initState();
    _previewCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _slideAnim = Tween(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _previewCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(_previewCtrl);
  }

  void _select(_MapSelection? sel) {
    if (sel == null) {
      _previewCtrl.reverse().then((_) { if (mounted) setState(() => _selected = null); });
    } else {
      setState(() => _selected = sel);
      _previewCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _previewCtrl.dispose(); super.dispose(); }

  double _distKm(double lat, double lng) {
    final d = const Distance().as(LengthUnit.Kilometer, _userPosition, LatLng(lat, lng));
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pad = MediaQuery.of(context).padding;

    final filteredTapas = state.selectedSector == null
        ? kTapas
        : kTapas.where((t) => t.sector == state.selectedSector).toList();
    final filteredEvents = state.selectedSector == null
        ? kSocialEvents
        : kSocialEvents.where((e) => e.sector == state.selectedSector).toList();
    final filteredBusinesses = state.selectedSector == null
        ? kBusinesses
        : kBusinesses.where((b) => b.sector == state.selectedSector).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: const LatLng(5.0660, -75.5180),
            initialZoom: 14.6,
            onTap: (_, __) {
              _select(null);
              if (_showLayers) setState(() => _showLayers = false);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.manizalescomparte.app',
              maxNativeZoom: 19,
            ),

            // Polígonos de sectores
            PolygonLayer(
              polygons: kSectores.map((s) {
                final selected = state.selectedSector == s.nombre;
                return Polygon(
                  points: s.bounds.map((p) => LatLng(p[0], p[1])).toList(),
                  color: s.color.withValues(alpha: selected ? 0.22 : 0.10),
                  borderColor: s.color.withValues(alpha: selected ? 0.9 : 0.5),
                  borderStrokeWidth: selected ? 2.5 : 1.5,
                );
              }).toList(),
            ),

            // Tapas
            if (state.activeLayers.contains(MapLayer.tapas))
              MarkerLayer(
                markers: filteredTapas.map((t) {
                  final cap = state.isTapaCaptured(t.id);
                  final isSel = _selected?.kind == _SelectedKind.tapa && (_selected?.item as Tapa).id == t.id;
                  return Marker(
                    point: LatLng(t.lat, t.lng),
                    width: isSel ? 50 : 38,
                    height: isSel ? 50 : 38,
                    child: GestureDetector(
                      onTap: () => _select(_MapSelection(_SelectedKind.tapa, t)),
                      child: AnimatedScale(
                        scale: isSel ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack,
                        child: _CircleMarker(
                          color: cap ? AppColors.verde : AppColors.rojo,
                          icon: cap ? Icons.check_rounded : Icons.place_rounded,
                          highlight: isSel,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            // Eventos sociales
            if (state.activeLayers.contains(MapLayer.eventos))
              MarkerLayer(
                markers: filteredEvents.map((e) {
                  final isSel = _selected?.kind == _SelectedKind.event && (_selected?.item as SocialEvent).id == e.id;
                  return Marker(
                    point: LatLng(e.lat, e.lng),
                    width: isSel ? 50 : 38,
                    height: isSel ? 50 : 38,
                    child: GestureDetector(
                      onTap: () => _select(_MapSelection(_SelectedKind.event, e)),
                      child: AnimatedScale(
                        scale: isSel ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: _CircleMarker(
                          color: e.programa.color,
                          icon: e.programa.icono,
                          highlight: isSel,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            // Negocios
            if (state.activeLayers.contains(MapLayer.negocios))
              MarkerLayer(
                markers: filteredBusinesses.map((b) {
                  final isSel = _selected?.kind == _SelectedKind.business && (_selected?.item as Business).id == b.id;
                  return Marker(
                    point: LatLng(b.lat, b.lng),
                    width: isSel ? 50 : 38,
                    height: isSel ? 50 : 38,
                    child: GestureDetector(
                      onTap: () => _select(_MapSelection(_SelectedKind.business, b)),
                      child: AnimatedScale(
                        scale: isSel ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: _CircleMarker(
                          color: AppColors.amarillo,
                          icon: b.tipo.icono,
                          highlight: isSel,
                          dark: true,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            // Marcador del usuario
            MarkerLayer(
              markers: [
                Marker(
                  point: _userPosition,
                  width: 26,
                  height: 26,
                  child: _PulsingDot(),
                ),
              ],
            ),
          ],
        ),

        // Header: ciudad + clima
        Positioned(
          top: pad.top + 10,
          left: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 14)],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_city_rounded, color: AppColors.rojo, size: 16),
                const SizedBox(width: 5),
                Text('Manizales', style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(width: 4),
                Text('· 2.150 msnm', style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris)),
                const Spacer(),
                Flexible(
                  child: Text(
                    ManizalesContext.climaMock(),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Filtros de sector — compactos, sin icono
        Positioned(
          top: pad.top + 60,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SectorChip(
                  label: 'Todos',
                  selected: state.selectedSector == null,
                  color: AppColors.rojo,
                  onTap: () => state.setSectorFilter(null),
                ),
                const SizedBox(width: 5),
                ...kSectores.map((s) => Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: _SectorChip(
                        label: s.nombre,
                        selected: state.selectedSector == s.nombre,
                        color: s.color,
                        onTap: () => state.setSectorFilter(state.selectedSector == s.nombre ? null : s.nombre),
                      ),
                    )),
              ],
            ),
          ),
        ),

        // Brújula a tapa más cercana — debajo de los chips
        if (_nearestPending(state) != null)
          Positioned(
            top: pad.top + 100,
            left: 12,
            child: _BrujulaCompacta(tapa: _nearestPending(state)!, distKm: _distKm(_nearestPending(state)!.lat, _nearestPending(state)!.lng)),
          ),

        // FAB capas + Fermines
        Positioned(
          top: pad.top + 100,
          right: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.amarillo.withValues(alpha: 0.35), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.negro),
                    const SizedBox(width: 4),
                    Text('${state.ferminesBalance}',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _LayersFab(
                showLayers: _showLayers,
                onToggle: () => setState(() => _showLayers = !_showLayers),
              ),
              if (_showLayers) ...[
                const SizedBox(height: 8),
                _LayersPanel(),
              ],
            ],
          ),
        ),

        // Progreso por sector
        Positioned(
          left: 16,
          right: 16,
          bottom: _selected != null ? 280 : 100,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _SectorProgressBar(state: state),
          ),
        ),

        // Preview seleccionado
        if (_selected != null)
          Positioned(
            bottom: 90,
            left: 16,
            right: 16,
            child: SlideTransition(
              position: _slideAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _buildPreview(_selected!),
              ),
            ),
          ),
      ],
    );
  }

  Tapa? _nearestPending(AppState s) {
    final pending = kTapas.where((t) => !s.isTapaCaptured(t.id)).toList();
    if (pending.isEmpty) return null;
    pending.sort((a, b) => _distKm(a.lat, a.lng).compareTo(_distKm(b.lat, b.lng)));
    return pending.first;
  }

  Widget _buildPreview(_MapSelection sel) {
    switch (sel.kind) {
      case _SelectedKind.tapa:
        final t = sel.item as Tapa;
        return _TapaPreview(
          tapa: t,
          captured: context.read<AppState>().isTapaCaptured(t.id),
          distKm: _distKm(t.lat, t.lng),
          onDetail: () => Navigator.push(context, _fade(TapaDetailScreen(tapa: t))),
          onCapture: () => Navigator.push(context, _fade(ArCaptureScreen(tapa: t))),
        );
      case _SelectedKind.business:
        final b = sel.item as Business;
        return _BusinessPreview(
          business: b,
          distKm: _distKm(b.lat, b.lng),
          onDetail: () => Navigator.push(context, _fade(BusinessDetailScreen(business: b))),
        );
      case _SelectedKind.event:
        final e = sel.item as SocialEvent;
        return _EventPreview(
          evento: e,
          distKm: _distKm(e.lat, e.lng),
          onDetail: () => Navigator.push(context, _fade(EventoDetailScreen(evento: e))),
        );
    }
  }
}

Route _fade(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(a), child: child)),
      transitionDuration: const Duration(milliseconds: 350),
    );

class _CircleMarker extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool highlight;
  final bool dark;
  const _CircleMarker({required this.color, required this.icon, this.highlight = false, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: highlight ? 14 : 6, spreadRadius: highlight ? 2 : 0),
        ],
      ),
      child: Icon(icon, color: dark ? AppColors.negro : Colors.white, size: highlight ? 22 : 18),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1 - _c.value).clamp(0.0, 1.0),
              child: Container(
                width: 26 * (0.5 + _c.value * 0.5),
                height: 26 * (0.5 + _c.value * 0.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withValues(alpha: 0.25),
                ),
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectorChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _SectorChip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : Colors.grey.shade200),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6)]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 3)],
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.negro)),
      ),
    );
  }
}

class _LayersFab extends StatelessWidget {
  final bool showLayers;
  final VoidCallback onToggle;
  const _LayersFab({required this.showLayers, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onToggle,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(showLayers ? Icons.close_rounded : Icons.layers_rounded,
              color: AppColors.rojo, size: 22),
        ),
      ),
    );
  }
}

class _LayersPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = [
      (MapLayer.tapas, 'Tapas', AppColors.rojo, Icons.place_rounded, kTapas.length),
      (MapLayer.eventos, 'Jornadas', AppColors.verde, Icons.volunteer_activism_rounded, kSocialEvents.length),
      (MapLayer.negocios, 'Negocios', AppColors.amarillo, Icons.storefront_rounded, kBusinesses.length),
    ];
    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 14)],
      ),
      child: Column(
        children: items.map((it) {
          final active = state.activeLayers.contains(it.$1);
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => state.toggleLayer(it.$1),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: it.$3.withValues(alpha: active ? 1 : 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(it.$4, size: 16, color: active ? Colors.white : it.$3),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.$2, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700)),
                        Text('${it.$5} en mapa',
                            style: GoogleFonts.poppins(fontSize: 9, color: AppColors.gris)),
                      ],
                    ),
                  ),
                  Switch(
                    value: active,
                    onChanged: (_) => state.toggleLayer(it.$1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BrujulaCompacta extends StatelessWidget {
  final Tapa tapa;
  final double distKm;
  const _BrujulaCompacta({required this.tapa, required this.distKm});

  @override
  Widget build(BuildContext context) {
    final near = distKm < 0.05;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)],
        border: Border.all(color: near ? AppColors.verde : Colors.transparent, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.navigation_rounded, color: near ? AppColors.verde : AppColors.rojo, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(near ? '¡Muy cerca!' : 'Próxima tapa',
                  style: GoogleFonts.poppins(fontSize: 9, color: AppColors.gris)),
              Text('${tapa.name} · ${distKm.toStringAsFixed(distKm < 1 ? 2 : 1)} km',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectorProgressBar extends StatelessWidget {
  final AppState state;
  const _SectorProgressBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final byS = <String, (int, int)>{};
    for (final t in kTapas) {
      final c = byS[t.sector] ?? (0, 0);
      byS[t.sector] = (c.$1 + (state.isTapaCaptured(t.id) ? 1 : 0), c.$2 + 1);
    }
    return Container(
      key: const ValueKey('progress'),
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 14)],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: byS.length,
        itemBuilder: (_, i) {
          final s = byS.keys.elementAt(i);
          final p = byS[s]!;
          final pct = p.$2 == 0 ? 0.0 : p.$1 / p.$2;
          final color = kSectores.firstWhere(
                (sec) => sec.nombre == s,
                orElse: () => kSectores.first,
              ).color;
          return SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation(color),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('${p.$1}/${p.$2}',
                        style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===== Previews =====

class _TapaPreview extends StatelessWidget {
  final Tapa tapa;
  final bool captured;
  final double distKm;
  final VoidCallback onDetail;
  final VoidCallback onCapture;
  const _TapaPreview({
    required this.tapa,
    required this.captured,
    required this.distKm,
    required this.onDetail,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    final near = distKm < 0.4;
    return _BasePreview(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _Avatar(asset: tapa.imageAsset, color: captured ? AppColors.verde : AppColors.rojo, heroTag: 'tapa_${tapa.id}'),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.rojo.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('TAPA',
                              style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.rojo)),
                        ),
                        const SizedBox(width: 6),
                        Text('· ${distKm.toStringAsFixed(distKm < 1 ? 2 : 1)} km',
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(tapa.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text('${tapa.artist} · ${tapa.sector}',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  gradient: captured
                      ? LinearGradient(colors: [AppColors.verde, AppColors.verde.withValues(alpha: 0.8)])
                      : const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(captured ? '✓' : '+${tapa.ferminesReward}F',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800,
                        color: captured ? Colors.white : AppColors.negro)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDetail,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: Text('Ver ficha', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.negro)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: captured ? null : onCapture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: near ? AppColors.rojo : AppColors.gris,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  icon: const Icon(Icons.center_focus_strong_rounded, size: 16, color: Colors.white),
                  label: Text(captured ? 'Capturada' : (near ? 'Capturar AR' : 'Acércate'),
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusinessPreview extends StatelessWidget {
  final Business business;
  final double distKm;
  final VoidCallback onDetail;
  const _BusinessPreview({required this.business, required this.distKm, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return _BasePreview(
      child: GestureDetector(
        onTap: onDetail,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.amarillo,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppColors.amarillo.withValues(alpha: 0.3), blurRadius: 8)],
              ),
              child: Icon(business.tipo.icono, color: AppColors.negro, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amarillo.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('NEGOCIO ALIADO',
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(width: 6),
                      Text('· ${distKm.toStringAsFixed(distKm < 1 ? 2 : 1)} km',
                          style: GoogleFonts.poppins(fontSize: 10, color: AppColors.gris)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(business.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 12, color: AppColors.amarillo),
                      const SizedBox(width: 2),
                      Text('${business.ratingTxt}',
                          style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.rojo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('-${business.descuentoBaseFermines}% con Fermines',
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.rojo)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gris),
          ],
        ),
      ),
    );
  }
}

class _EventPreview extends StatelessWidget {
  final SocialEvent evento;
  final double distKm;
  final VoidCallback onDetail;
  const _EventPreview({required this.evento, required this.distKm, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return _BasePreview(
      child: GestureDetector(
        onTap: onDetail,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: evento.programa.color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: evento.programa.color.withValues(alpha: 0.3), blurRadius: 8)],
              ),
              child: Icon(evento.programa.icono, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: evento.programa.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${evento.programa.nombre.toUpperCase()} · JORNADA',
                            style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w800, color: evento.programa.color)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(evento.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.w700)),
                  Text('${_fmtFecha(evento.fecha)} · ${evento.hora.split('–').first.trim()} · +${evento.recompensaFermines}F',
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.gris),
          ],
        ),
      ),
    );
  }
}

class _BasePreview extends StatelessWidget {
  final Widget child;
  const _BasePreview({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 22, offset: const Offset(0, 8))],
      ),
      child: child,
    );
  }
}

class _Avatar extends StatelessWidget {
  final String asset;
  final Color color;
  final String heroTag;
  const _Avatar({required this.asset, required this.color, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 8)],
        ),
        child: ClipOval(
          child: Image.asset(asset, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: color.withValues(alpha: 0.1), child: Icon(Icons.place_rounded, color: color))),
        ),
      ),
    );
  }
}

String _fmtFecha(DateTime d) {
  const meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
  return '${d.day} ${meses[d.month - 1]}';
}
