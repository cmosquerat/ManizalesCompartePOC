import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/models.dart';

/// Acceso a datos del catálogo de aliados en Supabase.
///
/// Lectura: la app turista (anónima) ve negocios/productos/promos `activo = true`.
/// Escritura: solo el dueño del negocio (RLS por `owner_id = auth.uid()`).
class CatalogRepository {
  // Getter perezoso: NO toca el cliente hasta que se usa, así construir el
  // repositorio nunca lanza aunque Supabase no esté inicializado.
  SupabaseClient get _db => Supabase.instance.client;

  // ----------------------------------------------------------------- Lectura
  Future<List<Business>> fetchBusinesses() async {
    final rows = await _db
        .from('businesses')
        .select()
        .eq('activo', true)
        .order('created_at');
    return rows.map<Business>((r) => Business.fromMap(r)).toList();
  }

  /// Negocios de los que el comerciante autenticado es dueño (incluye inactivos).
  Future<List<Business>> fetchMyBusinesses() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _db
        .from('businesses')
        .select()
        .eq('owner_id', uid)
        .order('created_at');
    return rows.map<Business>((r) => Business.fromMap(r)).toList();
  }

  Future<List<BusinessProduct>> fetchProducts({String? businessId}) async {
    var q = _db.from('products').select();
    if (businessId != null) q = q.eq('business_id', businessId);
    final rows = await q.order('created_at');
    return rows.map<BusinessProduct>((r) => BusinessProduct.fromMap(r)).toList();
  }

  Future<List<Promotion>> fetchPromotions({String? businessId}) async {
    var q = _db.from('promotions').select();
    if (businessId != null) q = q.eq('business_id', businessId);
    final rows = await q.order('created_at');
    return rows.map<Promotion>((r) => Promotion.fromMap(r)).toList();
  }

  Future<List<Redemption>> fetchRedemptions(String businessId) async {
    final rows = await _db
        .from('redemptions')
        .select()
        .eq('business_id', businessId)
        .order('created_at', ascending: false);
    return rows.map<Redemption>((r) => Redemption.fromMap(r)).toList();
  }

  // -------------------------------------------------------------- Escritura
  Future<Business> createBusiness(Business b) async {
    final uid = _db.auth.currentUser?.id;
    final payload = {...b.toMap(), 'owner_id': uid};
    final row = await _db.from('businesses').insert(payload).select().single();
    return Business.fromMap(row);
  }

  Future<Business> updateBusiness(Business b) async {
    final row = await _db
        .from('businesses')
        .update(b.toMap())
        .eq('id', b.id)
        .select()
        .single();
    return Business.fromMap(row);
  }

  Future<BusinessProduct> createProduct(BusinessProduct p) async {
    final row = await _db.from('products').insert(p.toMap()).select().single();
    return BusinessProduct.fromMap(row);
  }

  Future<BusinessProduct> updateProduct(BusinessProduct p) async {
    final row = await _db
        .from('products')
        .update(p.toMap())
        .eq('id', p.id)
        .select()
        .single();
    return BusinessProduct.fromMap(row);
  }

  Future<void> deleteProduct(String id) async {
    await _db.from('products').delete().eq('id', id);
  }

  Future<Promotion> createPromotion(Promotion p) async {
    final row = await _db.from('promotions').insert(p.toMap()).select().single();
    return Promotion.fromMap(row);
  }

  Future<Promotion> updatePromotion(Promotion p) async {
    final row = await _db
        .from('promotions')
        .update(p.toMap())
        .eq('id', p.id)
        .select()
        .single();
    return Promotion.fromMap(row);
  }

  Future<void> deletePromotion(String id) async {
    await _db.from('promotions').delete().eq('id', id);
  }

  /// Registra un canje (lo inserta la app turista al pagar con Fermines).
  Future<void> insertRedemption(Redemption r) async {
    await _db.from('redemptions').insert(r.toMap());
  }

  // ----------------------------------------------------- Canje con QR/código
  /// El turista (anónimo) crea la intención. No usamos `.select()` porque la
  /// policy de lectura es solo-dueño; el código ya viene generado en el cliente.
  Future<CanjeIntent> createCanjeIntent(CanjeIntent intent) async {
    await _db.from('canje_intents').insert(intent.toMap());
    return intent;
  }

  /// El comercio busca una intención pendiente por código.
  Future<CanjeIntent?> findPendingIntent(String businessId, String code) async {
    final rows = await _db
        .from('canje_intents')
        .select()
        .eq('business_id', businessId)
        .eq('code', code.trim())
        .eq('status', 'pending')
        .limit(1);
    if (rows.isEmpty) return null;
    return CanjeIntent.fromMap(rows.first);
  }

  Future<void> markIntentDone(String id) async {
    await _db.from('canje_intents').update({'status': 'done'}).eq('id', id);
  }

  String _todayStartUtcIso() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day).toUtc().toIso8601String();
  }

  Future<int> countRedemptionsToday(String businessId) async {
    final rows = await _db
        .from('redemptions')
        .select('id')
        .eq('business_id', businessId)
        .gte('created_at', _todayStartUtcIso());
    return (rows as List).length;
  }

  Future<int> countProductRedemptionsToday(String productId) async {
    final rows = await _db
        .from('redemptions')
        .select('id')
        .eq('product_id', productId)
        .gte('created_at', _todayStartUtcIso());
    return (rows as List).length;
  }

  // ------------------------------------------------------------------ Fotos
  /// Sube una imagen al bucket público y devuelve su URL pública.
  /// [folder] agrupa (ej. 'products', 'businesses', 'promos').
  Future<String> uploadImage(
    Uint8List bytes, {
    required String folder,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final path = '$folder/$fileName';
    await _db.storage.from(SupabaseConfig.mediaBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
    return _db.storage.from(SupabaseConfig.mediaBucket).getPublicUrl(path);
  }
}
