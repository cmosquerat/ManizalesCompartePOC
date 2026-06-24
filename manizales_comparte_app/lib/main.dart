import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'widgets/phone_frame.dart';

class _WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// Bandera global: true si Supabase quedó listo. Si no, la app corre con
/// datos semilla (mock) sin romperse.
bool supabaseReady = false;

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    // Lleva CUALQUIER error de Flutter al stdout de `flutter run`.
    FlutterError.onError = (details) {
      debugPrint('FLUTTER_ERROR: ${details.exceptionAsString()}');
      FlutterError.presentError(details);
    };
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      ).timeout(const Duration(seconds: 8));
      supabaseReady = true;
      debugPrint('SUPABASE_OK');
    } catch (e) {
      // Sin Supabase la app sigue funcionando con datos semilla (mock).
      debugPrint('SUPABASE_FAIL: $e');
    }
    runApp(const ManizalesComparteApp());
  }, (e, st) => debugPrint('ZONE_ERROR: $e'));
}

class ManizalesComparteApp extends StatelessWidget {
  const ManizalesComparteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Manizales Comparte',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        scrollBehavior: _WebScrollBehavior(),
        builder: (context, child) {
          // En modo aliado el dashboard se renderiza a pantalla completa
          // (es un panel de escritorio, no una app móvil).
          final state = context.watch<AppState>();
          final inBusiness = state.role == AppRole.business;
          if (!inBusiness && kIsWeb && MediaQuery.of(context).size.width > 600) {
            return PhoneFrame(child: child!);
          }
          return child!;
        },
        home: const SplashScreen(),
      ),
    );
  }
}
