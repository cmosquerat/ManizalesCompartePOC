/// Configuración de Supabase para Manizales Comparte.
///
/// La `anonKey` (publishable key) es segura para el cliente: el acceso real
/// está protegido por las políticas RLS definidas en `supabase/schema.sql`.
///
/// Para apuntar a otro proyecto sin tocar código, corre con:
///   flutter run -d chrome \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=sb_publishable_xxx
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://osyscedwjcpgikqsloes.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_aKPGyC-tVOTGdkhRPD6WFA_fR8y8Ml1',
  );

  /// Bucket público de Storage para fotos de negocios/productos/promos.
  static const String mediaBucket = 'business-media';
}
