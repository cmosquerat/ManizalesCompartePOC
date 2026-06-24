import 'package:flutter/material.dart';

// ===== Helpers de (de)serialización (Supabase → modelos) =====
int _asInt(dynamic v, [int def = 0]) => v == null
    ? def
    : (v is int ? v : (v is num ? v.toInt() : int.tryParse('$v') ?? def));
double _asDouble(dynamic v, [double def = 0]) => v == null
    ? def
    : (v is double ? v : (v is num ? v.toDouble() : double.tryParse('$v') ?? def));
bool _asBool(dynamic v, [bool def = false]) =>
    v == null ? def : (v is bool ? v : '$v' == 'true');
String _asStr(dynamic v, [String def = '']) => v == null ? def : '$v';
String? _asStrOrNull(dynamic v) =>
    (v == null || '$v'.isEmpty) ? null : '$v';

const List<Color> _kPalette = [
  Color(0xFF5D4037), Color(0xFFEF6C00), Color(0xFF52B9AA),
  Color(0xFF8E24AA), Color(0xFFE91E63), Color(0xFF1565C0),
  Color(0xFF6D4C41), Color(0xFF26A69A), Color(0xFFFFA726),
];
Color _paletteFor(String seed) =>
    _kPalette[seed.hashCode.abs() % _kPalette.length];

enum TransactionType { earn, spend, recharge, donate }

class Tapa {
  final String id;
  final String name;
  final String artist;
  final String address;
  final String sector;
  final double lat;
  final double lng;
  final String imageAsset;
  final String description;
  final int ferminesReward;

  const Tapa({
    required this.id,
    required this.name,
    required this.artist,
    required this.address,
    required this.sector,
    required this.lat,
    required this.lng,
    required this.imageAsset,
    required this.description,
    required this.ferminesReward,
  });
}

class Tour {
  final String id;
  final String name;
  final String description;
  final int priceCOP;
  final String duration;
  final List<String> includes;
  final IconData icon;
  final Color color;

  const Tour({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCOP,
    required this.duration,
    required this.includes,
    required this.icon,
    required this.color,
  });
}

class Ally {
  final String id;
  final String name;
  final String category;
  final String address;
  final int discountPercent;
  final String description;

  const Ally({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.discountPercent,
    required this.description,
  });
}

enum RewardCategory { product, discount, experience, exclusive }

class Reward {
  final String id;
  final String name;
  final String description;
  final int ferminCost;
  final RewardCategory category;
  final IconData icon;
  final Color color;
  final String? allyName;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.ferminCost,
    required this.category,
    required this.icon,
    required this.color,
    this.allyName,
  });
}

class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final int reward;
  final IconData icon;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.icon,
  });
}

class Membership {
  final String id;
  final String name;
  final String tagline;
  final int priceCOP;
  final int ferminesPerMonth;
  final int bonusPercent;
  final List<String> perks;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  const Membership({
    required this.id,
    required this.name,
    required this.tagline,
    required this.priceCOP,
    required this.ferminesPerMonth,
    required this.bonusPercent,
    required this.perks,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}

class FerminTransaction {
  final String id;
  final String description;
  final int amount;
  final DateTime date;
  final TransactionType type;

  const FerminTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
  });
}

// ===== Ecosistema Social =====

enum ProgramaSocial { cuidarte, imaginarte, salvarte, desarmarte }

extension ProgramaSocialX on ProgramaSocial {
  String get nombre {
    switch (this) {
      case ProgramaSocial.cuidarte:   return 'Cuidarte';
      case ProgramaSocial.imaginarte: return 'Imaginarte';
      case ProgramaSocial.salvarte:   return 'Salvarte';
      case ProgramaSocial.desarmarte: return 'Desarmarte';
    }
  }

  String get descripcion {
    switch (this) {
      case ProgramaSocial.cuidarte:
        return 'Embellecimiento colaborativo de espacios públicos. Pinta, repara y cuida la ciudad junto a tu comunidad. Recibes kit de trabajo y Fermines.';
      case ProgramaSocial.imaginarte:
        return 'Convocatoria artística para llevar las historias de Manizales a las tapas de servicios públicos. Talento local en el espacio público.';
      case ProgramaSocial.salvarte:
        return 'Acompañamiento y atención especializada en sectores priorizados. Cuidar es también sanar.';
      case ProgramaSocial.desarmarte:
        return 'Entrega voluntaria de armas a cambio de bonos de mercado o juguetes para tu familia. Construimos paz desde los barrios.';
    }
  }

  String get lema {
    switch (this) {
      case ProgramaSocial.cuidarte:   return 'Cuida lo nuestro';
      case ProgramaSocial.imaginarte: return 'Pinta tu ciudad';
      case ProgramaSocial.salvarte:   return 'Sanar también es cuidar';
      case ProgramaSocial.desarmarte: return 'Paz desde los barrios';
    }
  }

  IconData get icono {
    switch (this) {
      case ProgramaSocial.cuidarte:   return Icons.format_paint_rounded;
      case ProgramaSocial.imaginarte: return Icons.palette_rounded;
      case ProgramaSocial.salvarte:   return Icons.favorite_rounded;
      case ProgramaSocial.desarmarte: return Icons.handshake_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ProgramaSocial.cuidarte:   return const Color(0xFF88BE4C);
      case ProgramaSocial.imaginarte: return const Color(0xFFFFD122);
      case ProgramaSocial.salvarte:   return const Color(0xFF52B9AA);
      case ProgramaSocial.desarmarte: return const Color(0xFFE6323C);
    }
  }

  /// Logo del programa (PNG si existe, null si todavía no hay arte oficial).
  String? get logoAsset {
    switch (this) {
      case ProgramaSocial.cuidarte:   return 'assets/social/cuidarte_logo.png';
      default: return null;
    }
  }

  /// Hero / banner fotográfico del programa.
  String? get heroAsset {
    switch (this) {
      case ProgramaSocial.cuidarte:   return 'assets/social/cuidarte_hero.png';
      default: return null;
    }
  }

  /// Ilustración ambient (decorativa) del programa.
  String? get ambientAsset {
    switch (this) {
      case ProgramaSocial.cuidarte:   return 'assets/social/cuidarte_ambient.png';
      default: return null;
    }
  }
}

class SocialEvent {
  final String id;
  final ProgramaSocial programa;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String hora;
  final String lugar;
  final String sector;
  final double lat;
  final double lng;
  final int cupos;
  final int cuposOcupados;
  final int recompensaFermines;
  final String recompensaExtra;
  final List<String> requisitos;

  const SocialEvent({
    required this.id,
    required this.programa,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.lugar,
    required this.sector,
    required this.lat,
    required this.lng,
    required this.cupos,
    required this.cuposOcupados,
    required this.recompensaFermines,
    this.recompensaExtra = '',
    this.requisitos = const [],
  });

  int get cuposDisponibles => cupos - cuposOcupados;
}

// ===== Negocios aliados =====

enum BusinessType { cafe, restaurante, hotel, tour, tienda }

extension BusinessTypeX on BusinessType {
  String get nombre {
    switch (this) {
      case BusinessType.cafe:        return 'Café & Brunch';
      case BusinessType.restaurante: return 'Restaurante';
      case BusinessType.hotel:       return 'Hotel';
      case BusinessType.tour:        return 'Operador turístico';
      case BusinessType.tienda:      return 'Tienda';
    }
  }

  IconData get icono {
    switch (this) {
      case BusinessType.cafe:        return Icons.local_cafe_rounded;
      case BusinessType.restaurante: return Icons.restaurant_rounded;
      case BusinessType.hotel:       return Icons.hotel_rounded;
      case BusinessType.tour:        return Icons.terrain_rounded;
      case BusinessType.tienda:      return Icons.shopping_bag_rounded;
    }
  }
}

BusinessType businessTypeFromString(String s) => BusinessType.values
    .firstWhere((t) => t.name == s, orElse: () => BusinessType.cafe);

class Business {
  final String id;
  final String nombre;
  final BusinessType tipo;
  final String descripcion;
  final String foto;
  final String logo;
  final double lat;
  final double lng;
  final String direccion;
  final String sector;
  final String horarios;
  final String telefono;
  final String instagram;
  final int rating; // 0-50 (4.5 = 45)
  final int ratingCount;
  final int descuentoBaseFermines; // obsoleto (se mantiene por compatibilidad)
  final int maxCanjesDia; // tope de canjes por día (0 = ilimitado)
  final bool activo;

  const Business({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.descripcion,
    required this.foto,
    required this.logo,
    required this.lat,
    required this.lng,
    required this.direccion,
    required this.sector,
    required this.horarios,
    required this.telefono,
    required this.instagram,
    required this.rating,
    required this.ratingCount,
    this.descuentoBaseFermines = 0,
    this.maxCanjesDia = 0,
    this.activo = true,
  });

  String get ratingTxt => (rating / 10).toStringAsFixed(1);

  factory Business.fromMap(Map<String, dynamic> m) => Business(
        id: _asStr(m['id']),
        nombre: _asStr(m['nombre'], 'Negocio'),
        tipo: businessTypeFromString(_asStr(m['tipo'], 'cafe')),
        descripcion: _asStr(m['descripcion']),
        foto: _asStr(m['foto']),
        logo: _asStr(m['logo'], 'assets/images/Logo_positivo.svg'),
        lat: _asDouble(m['lat'], 5.07),
        lng: _asDouble(m['lng'], -75.51),
        direccion: _asStr(m['direccion']),
        sector: _asStr(m['sector']),
        horarios: _asStr(m['horarios']),
        telefono: _asStr(m['telefono']),
        instagram: _asStr(m['instagram']),
        rating: _asInt(m['rating'], 45),
        ratingCount: _asInt(m['rating_count']),
        maxCanjesDia: _asInt(m['max_canjes_dia']),
        activo: _asBool(m['activo'], true),
      );

  /// Mapa para insertar/actualizar (sin `id` ni `owner_id`: los maneja el repo/DB).
  Map<String, dynamic> toMap() => {
        'nombre': nombre,
        'tipo': tipo.name,
        'descripcion': descripcion,
        'foto': foto,
        'logo': logo,
        'lat': lat,
        'lng': lng,
        'direccion': direccion,
        'sector': sector,
        'horarios': horarios,
        'telefono': telefono,
        'instagram': instagram,
        'rating': rating,
        'rating_count': ratingCount,
        'max_canjes_dia': maxCanjesDia,
        'activo': activo,
      };

  Business copyWith({
    String? nombre,
    BusinessType? tipo,
    String? descripcion,
    String? foto,
    String? logo,
    double? lat,
    double? lng,
    String? direccion,
    String? sector,
    String? horarios,
    String? telefono,
    String? instagram,
    int? rating,
    int? ratingCount,
    int? maxCanjesDia,
    bool? activo,
  }) =>
      Business(
        id: id,
        nombre: nombre ?? this.nombre,
        tipo: tipo ?? this.tipo,
        descripcion: descripcion ?? this.descripcion,
        foto: foto ?? this.foto,
        logo: logo ?? this.logo,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        direccion: direccion ?? this.direccion,
        sector: sector ?? this.sector,
        horarios: horarios ?? this.horarios,
        telefono: telefono ?? this.telefono,
        instagram: instagram ?? this.instagram,
        rating: rating ?? this.rating,
        ratingCount: ratingCount ?? this.ratingCount,
        maxCanjesDia: maxCanjesDia ?? this.maxCanjesDia,
        activo: activo ?? this.activo,
      );
}

class BusinessProduct {
  final String id;
  final String businessId;
  final String nombre;
  final String descripcion;
  final IconData icono;
  final Color color;
  final String? foto; // URL de Storage o asset; si null se muestra el icono
  final int precioCOP;
  final int precioFermines;
  final int ferminPercent; // % del precio pagable con Fermines (default 100)
  final int maxPorDia; // tope de canjes/día de este producto (0 = ilimitado)
  final int stock;
  final bool destacado;
  final bool activo;

  const BusinessProduct({
    required this.id,
    required this.businessId,
    required this.nombre,
    required this.descripcion,
    this.icono = Icons.local_offer_rounded,
    this.color = const Color(0xFF5D4037),
    this.foto,
    required this.precioCOP,
    required this.precioFermines,
    this.ferminPercent = 100,
    this.maxPorDia = 0,
    required this.stock,
    this.destacado = false,
    this.activo = true,
  });

  /// Fermines a pagar (1F = $1.000), según el % configurado.
  int get ferminesPart => (precioCOP * ferminPercent / 100 / 1000).round();

  /// Parte del precio que se paga en plata real (COP).
  int get copReal => (precioCOP * (100 - ferminPercent) / 100).round();

  factory BusinessProduct.fromMap(Map<String, dynamic> m) {
    final id = _asStr(m['id']);
    return BusinessProduct(
      id: id,
      businessId: _asStr(m['business_id']),
      nombre: _asStr(m['nombre'], 'Producto'),
      descripcion: _asStr(m['descripcion']),
      color: _paletteFor(id),
      foto: _asStrOrNull(m['foto']),
      precioCOP: _asInt(m['precio_cop']),
      precioFermines: _asInt(m['precio_fermines']),
      ferminPercent: _asInt(m['fermin_percent'], 100),
      maxPorDia: _asInt(m['max_por_dia']),
      stock: _asInt(m['stock']),
      destacado: _asBool(m['destacado']),
      activo: _asBool(m['activo'], true),
    );
  }

  Map<String, dynamic> toMap() => {
        'business_id': businessId,
        'nombre': nombre,
        'descripcion': descripcion,
        'foto': foto,
        'precio_cop': precioCOP,
        'precio_fermines': precioFermines,
        'fermin_percent': ferminPercent,
        'max_por_dia': maxPorDia,
        'stock': stock,
        'destacado': destacado,
        'activo': activo,
      };

  BusinessProduct copyWith({
    String? nombre,
    String? descripcion,
    String? foto,
    int? precioCOP,
    int? precioFermines,
    int? ferminPercent,
    int? maxPorDia,
    int? stock,
    bool? destacado,
    bool? activo,
  }) =>
      BusinessProduct(
        id: id,
        businessId: businessId,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        icono: icono,
        color: color,
        foto: foto ?? this.foto,
        precioCOP: precioCOP ?? this.precioCOP,
        precioFermines: precioFermines ?? this.precioFermines,
        ferminPercent: ferminPercent ?? this.ferminPercent,
        maxPorDia: maxPorDia ?? this.maxPorDia,
        stock: stock ?? this.stock,
        destacado: destacado ?? this.destacado,
        activo: activo ?? this.activo,
      );
}

class Promotion {
  final String id;
  final String businessId;
  final String titulo;
  final String descripcion;
  final String condiciones;
  final String vigencia;
  final IconData icono;
  final Color color;
  final String? foto;
  final bool activa;

  const Promotion({
    required this.id,
    required this.businessId,
    required this.titulo,
    required this.descripcion,
    required this.condiciones,
    required this.vigencia,
    this.icono = Icons.local_offer_rounded,
    this.color = const Color(0xFFE6323C),
    this.foto,
    this.activa = true,
  });

  factory Promotion.fromMap(Map<String, dynamic> m) {
    final id = _asStr(m['id']);
    return Promotion(
      id: id,
      businessId: _asStr(m['business_id']),
      titulo: _asStr(m['titulo'], 'Promoción'),
      descripcion: _asStr(m['descripcion']),
      condiciones: _asStr(m['condiciones']),
      vigencia: _asStr(m['vigencia']),
      color: _paletteFor(id),
      foto: _asStrOrNull(m['foto']),
      activa: _asBool(m['activa'], true),
    );
  }

  Map<String, dynamic> toMap() => {
        'business_id': businessId,
        'titulo': titulo,
        'descripcion': descripcion,
        'condiciones': condiciones,
        'vigencia': vigencia,
        'foto': foto,
        'activa': activa,
      };

  Promotion copyWith({
    String? titulo,
    String? descripcion,
    String? condiciones,
    String? vigencia,
    String? foto,
    bool? activa,
  }) =>
      Promotion(
        id: id,
        businessId: businessId,
        titulo: titulo ?? this.titulo,
        descripcion: descripcion ?? this.descripcion,
        condiciones: condiciones ?? this.condiciones,
        vigencia: vigencia ?? this.vigencia,
        icono: icono,
        color: color,
        foto: foto ?? this.foto,
        activa: activa ?? this.activa,
      );
}

class Redemption {
  final String id;
  final String businessId;
  final String? productId;
  final String userName;
  final String productName;
  final int totalFermines;
  final int totalCOP;
  final DateTime fecha;
  final String origen; // 'turista', 'local'

  const Redemption({
    required this.id,
    required this.businessId,
    this.productId,
    required this.userName,
    required this.productName,
    required this.totalFermines,
    required this.totalCOP,
    required this.fecha,
    required this.origen,
  });

  factory Redemption.fromMap(Map<String, dynamic> m) => Redemption(
        id: _asStr(m['id']),
        businessId: _asStr(m['business_id']),
        productId: _asStrOrNull(m['product_id']),
        userName: _asStr(m['user_name'], 'Invitado'),
        productName: _asStr(m['product_name']),
        totalFermines: _asInt(m['total_fermines']),
        totalCOP: _asInt(m['total_cop']),
        fecha: DateTime.tryParse(_asStr(m['created_at']))?.toLocal() ??
            DateTime.now(),
        origen: _asStr(m['origen'], 'turista'),
      );

  /// Mapa para insertar el canje (sin `id`: lo genera la DB).
  Map<String, dynamic> toMap() => {
        'business_id': businessId,
        if (productId != null) 'product_id': productId,
        'user_name': userName,
        'product_name': productName,
        'total_fermines': totalFermines,
        'total_cop': totalCOP,
        'origen': origen,
      };
}

/// Intención de canje: el turista la genera (con su código/QR) y el comercio
/// la valida. `fermines` es la parte que cubre con Fermines (descuento que el
/// comercio absorbe) y `copReal` la plata que paga el cliente.
class CanjeIntent {
  final String id;
  final String code;
  final String businessId;
  final String? productId;
  final String productName;
  final int fermines;
  final int copReal;
  final String status; // pending | done | expired

  const CanjeIntent({
    required this.id,
    required this.code,
    required this.businessId,
    this.productId,
    required this.productName,
    required this.fermines,
    required this.copReal,
    this.status = 'pending',
  });

  factory CanjeIntent.fromMap(Map<String, dynamic> m) => CanjeIntent(
        id: _asStr(m['id']),
        code: _asStr(m['code']),
        businessId: _asStr(m['business_id']),
        productId: _asStrOrNull(m['product_id']),
        productName: _asStr(m['product_name']),
        fermines: _asInt(m['fermines']),
        copReal: _asInt(m['cop_real']),
        status: _asStr(m['status'], 'pending'),
      );

  Map<String, dynamic> toMap() => {
        'code': code,
        'business_id': businessId,
        if (productId != null) 'product_id': productId,
        'product_name': productName,
        'fermines': fermines,
        'cop_real': copReal,
        'status': status,
      };
}
