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
                    Navigator.of(context).push(MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => CanjeFlowScreen(producto: producto),
                    ));
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

// ====== Flujo completo de canje ======

enum _CanjeStage { generating, awaiting, scanning, done }

class CanjeFlowScreen extends StatefulWidget {
  final BusinessProduct producto;
  const CanjeFlowScreen({super.key, required this.producto});

  @override
  State<CanjeFlowScreen> createState() => _CanjeFlowScreenState();
}

class _CanjeFlowScreenState extends State<CanjeFlowScreen> with TickerProviderStateMixin {
  _CanjeStage _stage = _CanjeStage.generating;
  late final AnimationController _genCtrl;
  late final AnimationController _scanCtrl;
  String _code = '';

  @override
  void initState() {
    super.initState();
    _genCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _scanCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _genCtrl.forward().then((_) {
      if (!mounted) return;
      _code = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
      setState(() => _stage = _CanjeStage.awaiting);
    });
  }

  @override
  void dispose() {
    _genCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  void _simulateScan() {
    setState(() => _stage = _CanjeStage.scanning);
    _scanCtrl.forward(from: 0).then((_) {
      if (!mounted) return;
      // Confirmar el canje en el estado
      final p = widget.producto;
      context.read<AppState>().spendFermines(p.precioFermines, 'Canje en negocio: ${p.nombre}');
      context.read<AppState>().simulateRedemption(p);
      setState(() => _stage = _CanjeStage.done);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Canje en aliado', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header del producto
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.producto.color.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.producto.icono, color: widget.producto.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.producto.nombre,
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
                          Text('${widget.producto.precioFermines} Fermines · El Sombrerero',
                              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Contenido por etapa
              Expanded(child: _buildStageContent()),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageContent() {
    switch (_stage) {
      case _CanjeStage.generating:
        return _Generating(ctrl: _genCtrl);
      case _CanjeStage.awaiting:
        return _Awaiting(code: _code);
      case _CanjeStage.scanning:
        return _Scanning(ctrl: _scanCtrl);
      case _CanjeStage.done:
        return _Done(producto: widget.producto, code: _code);
    }
  }

  Widget _buildFooter() {
    switch (_stage) {
      case _CanjeStage.generating:
        return const SizedBox.shrink();
      case _CanjeStage.awaiting:
        return Column(
          children: [
            Text('🪄  Modo demo',
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _simulateScan,
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                label: Text('Simular escaneo del aliado',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amarillo,
                  foregroundColor: AppColors.negro,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        );
      case _CanjeStage.scanning:
        return const SizedBox.shrink();
      case _CanjeStage.done:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.verde,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text('Listo, ¡a disfrutar!', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ),
        );
    }
  }
}

class _Generating extends StatelessWidget {
  final AnimationController ctrl;
  const _Generating({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: ctrl,
            builder: (_, __) => SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: ctrl.value,
                strokeWidth: 4,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(AppColors.amarillo),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('Generando QR seguro…',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text('Encriptando tu canje',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Awaiting extends StatelessWidget {
  final String code;
  const _Awaiting({required this.code});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Muestra este código al aliado',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 18),
        // QR card
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1.0),
          curve: Curves.elasticOut,
          duration: const Duration(milliseconds: 700),
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.amarillo.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 2)],
            ),
            child: Column(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(painter: _MockQrPainter()),
                ),
                const SizedBox(height: 10),
                Text(_formatCode(code),
                    style: GoogleFonts.robotoMono(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 4)),
                const SizedBox(height: 2),
                Text('o ingresa el código manualmente',
                    style: GoogleFonts.poppins(fontSize: 9.5, color: AppColors.gris)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _PulseDot(),
            const SizedBox(width: 8),
            Text('Esperando al aliado…',
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  String _formatCode(String c) =>
      c.length == 6 ? '${c.substring(0, 3)} ${c.substring(3)}' : c;
}

class _Scanning extends StatelessWidget {
  final AnimationController ctrl;
  const _Scanning({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Cámara mock
          AnimatedBuilder(
            animation: ctrl,
            builder: (_, __) => Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.amarillo, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      children: [
                        // QR detrás (lo que está "escaneando")
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Opacity(
                            opacity: 0.85,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomPaint(painter: _MockQrPainter()),
                            ),
                          ),
                        ),
                        // Línea de escaneo
                        Positioned(
                          left: 0,
                          right: 0,
                          top: ctrl.value * 220 - 2,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.transparent,
                                AppColors.amarillo,
                                AppColors.amarillo,
                                Colors.transparent,
                              ]),
                              boxShadow: [BoxShadow(color: AppColors.amarillo.withValues(alpha: 0.6), blurRadius: 8)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Esquinas tipo cámara
                ...List.generate(4, (i) {
                  final r = (i ~/ 2) == 0 ? -1 : 1;
                  final c = (i % 2) == 0 ? -1 : 1;
                  return Positioned(
                    top: r == -1 ? 4 : null,
                    bottom: r == 1 ? 4 : null,
                    left: c == -1 ? 4 : null,
                    right: c == 1 ? 4 : null,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        border: Border(
                          top: r == -1 ? const BorderSide(color: AppColors.amarillo, width: 3) : BorderSide.none,
                          bottom: r == 1 ? const BorderSide(color: AppColors.amarillo, width: 3) : BorderSide.none,
                          left: c == -1 ? const BorderSide(color: AppColors.amarillo, width: 3) : BorderSide.none,
                          right: c == 1 ? const BorderSide(color: AppColors.amarillo, width: 3) : BorderSide.none,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text('El aliado está validando…',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Verificando saldo y stock',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Done extends StatelessWidget {
  final BusinessProduct producto;
  final String code;
  const _Done({required this.producto, required this.code});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.elasticOut,
            duration: const Duration(milliseconds: 700),
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.verde,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.verde.withValues(alpha: 0.5), blurRadius: 24, spreadRadius: 4)],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 56),
            ),
          ),
          const SizedBox(height: 22),
          Text('¡Canje exitoso!',
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(producto.nombre,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('-', style: GoogleFonts.poppins(color: AppColors.amarillo, fontSize: 24, fontWeight: FontWeight.w800)),
                    Text('${producto.precioFermines} ', style: GoogleFonts.poppins(color: AppColors.amarillo, fontSize: 24, fontWeight: FontWeight.w800)),
                    Text('Fermines', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
                Text('Folio · ${_formatCode(code)}',
                    style: GoogleFonts.robotoMono(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCode(String c) =>
      c.length == 6 ? '${c.substring(0, 3)} ${c.substring(3)}' : c;
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.amarillo.withValues(alpha: 0.4 + 0.6 * _c.value),
          boxShadow: [BoxShadow(color: AppColors.amarillo.withValues(alpha: 0.5 * _c.value), blurRadius: 8)],
        ),
      ),
    );
  }
}

class _MockQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / 21;
    final paint = Paint()..color = Colors.black;

    // Dibuja patrón pseudo-aleatorio determinístico
    final rng = (int x, int y) => ((x * 73856093) ^ (y * 19349663)) & 1;
    for (int y = 0; y < 21; y++) {
      for (int x = 0; x < 21; x++) {
        if (rng(x, y) == 1) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }

    // Esquinas (3 marcadores de finder pattern)
    void finder(double cx, double cy) {
      // Bloque blanco
      canvas.drawRect(Rect.fromLTWH(cx, cy, cell * 7, cell * 7), Paint()..color = Colors.white);
      // Cuadrado negro grande
      canvas.drawRect(Rect.fromLTWH(cx, cy, cell * 7, cell * 7),
          Paint()..color = Colors.black..style = PaintingStyle.stroke..strokeWidth = cell);
      // Cuadrado interior
      canvas.drawRect(Rect.fromLTWH(cx + cell * 2, cy + cell * 2, cell * 3, cell * 3), paint);
    }

    finder(0, 0);
    finder(cell * 14, 0);
    finder(0, cell * 14);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
