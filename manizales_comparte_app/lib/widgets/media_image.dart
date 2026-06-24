import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Imagen que puede venir de Supabase Storage (URL http) o de un asset local.
/// Si no hay fuente o falla, muestra [fallback] (o un placeholder gris).
class MediaImage extends StatelessWidget {
  final String? source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;

  const MediaImage({
    super.key,
    this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final s = source;
    if (s == null || s.isEmpty) return _fallbackOrPlaceholder();

    if (s.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: s,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, __) => _placeholder(),
        errorWidget: (_, __, ___) => _fallbackOrPlaceholder(),
      );
    }
    return Image.asset(
      s,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallbackOrPlaceholder(),
    );
  }

  Widget _fallbackOrPlaceholder() => fallback ?? _placeholder();

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: const Color(0xFFECECEC),
        alignment: Alignment.center,
        child: const Icon(Icons.image_rounded, color: Color(0xFFBDBDBD)),
      );
}
