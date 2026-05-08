import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class ManizalesContext {
  static String saludo() {
    final h = DateTime.now().hour;
    if (h < 6)  return 'Trasnochando, parcero';
    if (h < 12) return 'Buenos días, parcero';
    if (h < 18) return 'Buenas, ¿quiubo?';
    if (h < 22) return 'Buenas noches, paisa';
    return 'Bien tarde ya, ¡pero pa\'lante!';
  }

  static String climaMock() {
    // Mock estable durante la sesión.
    final hora = DateTime.now().hour;
    if (hora < 11) return '☁️  Nublado · 16°C · Aire fresco de cordillera';
    if (hora < 16) return '🌤️  Parcial · 19°C · Buen día para cazar tapas';
    return '🌧️  Lluvia ligera · 17°C · Lleva paraguas';
  }

  static String datoCurioso() {
    final dia = DateTime.now().day;
    return kDatosManizales[dia % kDatosManizales.length];
  }

  static String microcopyCargando() {
    final opciones = [
      'Calentando el tinto…',
      'Llamando al colibrí…',
      'Subiendo a Chipre…',
      'Pidiendo permiso al Nevado…',
      'Despertando a los arrieros…',
    ];
    return opciones[DateTime.now().second % opciones.length];
  }
}

class SectorInfo {
  final String nombre;
  final Color color;
  final IconData icono;
  final String descripcion;
  final List<List<double>> bounds; // polígono aproximado

  const SectorInfo({
    required this.nombre,
    required this.color,
    required this.icono,
    required this.descripcion,
    required this.bounds,
  });
}

const List<SectorInfo> kSectores = [
  SectorInfo(
    nombre: 'Chipre',
    color: Color(0xFFE6323C),
    icono: Icons.landscape_rounded,
    descripcion: 'El balcón de Manizales. Atardeceres, miradores y el Monumento a los Colonizadores.',
    bounds: [
      [5.0590, -75.5305],
      [5.0590, -75.5250],
      [5.0540, -75.5250],
      [5.0540, -75.5305],
    ],
  ),
  SectorInfo(
    nombre: 'Centro Histórico',
    color: Color(0xFFFFD122),
    icono: Icons.account_balance_rounded,
    descripcion: 'Catedral, Plaza de Bolívar y la arquitectura republicana.',
    bounds: [
      [5.0710, -75.5200],
      [5.0710, -75.5150],
      [5.0660, -75.5150],
      [5.0660, -75.5200],
    ],
  ),
  SectorInfo(
    nombre: 'Fundadores',
    color: Color(0xFF52B9AA),
    icono: Icons.history_edu_rounded,
    descripcion: 'Cable Aéreo, arrieros, primeros pasos de la ciudad.',
    bounds: [
      [5.0725, -75.5170],
      [5.0725, -75.5135],
      [5.0695, -75.5135],
      [5.0695, -75.5170],
    ],
  ),
  SectorInfo(
    nombre: 'Av. Santander',
    color: Color(0xFF88BE4C),
    icono: Icons.park_rounded,
    descripcion: 'Corredor verde, restaurantes y vida universitaria.',
    bounds: [
      [5.0660, -75.5120],
      [5.0660, -75.5050],
      [5.0590, -75.5050],
      [5.0590, -75.5120],
    ],
  ),
];
