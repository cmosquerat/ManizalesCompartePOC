import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/app_state.dart';
import 'widgets/phone_frame.dart';
import 'screens/splash_screen.dart';

class _WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ManizalesComparteApp());
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
          if (kIsWeb && MediaQuery.of(context).size.width > 600) {
            return PhoneFrame(child: child!);
          }
          return child!;
        },
        home: const SplashScreen(),
      ),
    );
  }
}
