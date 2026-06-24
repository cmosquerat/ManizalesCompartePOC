import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/app_state.dart';

/// Login / registro del comerciante. Se muestra a pantalla completa cuando el
/// usuario entra al modo negocio sin sesión iniciada.
class MerchantAuthScreen extends StatefulWidget {
  const MerchantAuthScreen({super.key});

  @override
  State<MerchantAuthScreen> createState() => _MerchantAuthScreenState();
}

class _MerchantAuthScreenState extends State<MerchantAuthScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true;
  bool _busy = false;
  String? _error;
  String? _info;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final pass = _pass.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Ingresa un correo válido');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }
    setState(() { _busy = true; _error = null; _info = null; });
    final state = context.read<AppState>();
    try {
      if (_isLogin) {
        await state.signInMerchant(email, pass);
      } else {
        await state.signUpMerchant(email, pass);
        if (state.authUser == null) {
          setState(() {
            _info = 'Cuenta creada. Confirma tu correo para entrar '
                '(o desactiva la confirmación de email en Supabase para la demo).';
            _isLogin = true;
          });
        }
      }
    } catch (e) {
      setState(() => _error = _friendlyAuth(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 24)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.rojo, Color(0xFFFFD122)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storefront_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Panel de comerciantes',
                                style: GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w800)),
                            Text('Manizales Comparte',
                                style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.gris)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(_isLogin ? 'Inicia sesión' : 'Crea tu cuenta',
                      style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(
                    _isLogin
                        ? 'Gestiona tus productos, promociones y canjes.'
                        : 'Registra tu negocio y empieza a recibir Fermines.',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: _dec('Correo', Icons.mail_outline_rounded),
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pass,
                    obscureText: true,
                    onSubmitted: (_) => _submit(),
                    decoration: _dec('Contraseña', Icons.lock_outline_rounded),
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    _banner(_error!, AppColors.rojo, Icons.error_outline_rounded),
                  ],
                  if (_info != null) ...[
                    const SizedBox(height: 12),
                    _banner(_info!, AppColors.turquesa, Icons.info_outline_rounded),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: _busy
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_isLogin ? 'Entrar' : 'Crear cuenta',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: _busy ? null : () => setState(() { _isLogin = !_isLogin; _error = null; _info = null; }),
                      child: Text(
                        _isLogin ? '¿No tienes cuenta? Regístrate' : '¿Ya tienes cuenta? Inicia sesión',
                        style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.rojo),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.read<AppState>().switchRole(AppRole.citizen),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.gris),
                      label: Text('Volver a la app turista',
                          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gris)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _banner(String msg, Color color, IconData icon) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(msg, style: GoogleFonts.poppins(fontSize: 11.5, color: color, height: 1.4))),
          ],
        ),
      );
}

String _friendlyAuth(Object e) {
  final s = '$e';
  if (s.contains('Invalid login credentials')) return 'Correo o contraseña incorrectos.';
  if (s.contains('already registered') || s.contains('User already')) {
    return 'Ese correo ya está registrado. Inicia sesión.';
  }
  if (s.contains('Failed host lookup') || s.contains('SocketException')) {
    return 'Sin conexión. Revisa tu internet.';
  }
  return 'No se pudo completar. $s';
}
