import 'package:flutter/material.dart';

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
  final int descuentoBaseFermines; // %
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
    required this.descuentoBaseFermines,
    this.activo = true,
  });

  String get ratingTxt => (rating / 10).toStringAsFixed(1);
}

class BusinessProduct {
  final String id;
  final String businessId;
  final String nombre;
  final String descripcion;
  final IconData icono;
  final Color color;
  final int precioCOP;
  final int precioFermines;
  final int stock;
  final bool destacado;

  const BusinessProduct({
    required this.id,
    required this.businessId,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.precioCOP,
    required this.precioFermines,
    required this.stock,
    this.destacado = false,
  });
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
  final bool activa;

  const Promotion({
    required this.id,
    required this.businessId,
    required this.titulo,
    required this.descripcion,
    required this.condiciones,
    required this.vigencia,
    required this.icono,
    required this.color,
    this.activa = true,
  });
}

class Redemption {
  final String id;
  final String businessId;
  final String userName;
  final String productName;
  final int totalFermines;
  final int totalCOP;
  final DateTime fecha;
  final String origen; // 'turista', 'local'

  const Redemption({
    required this.id,
    required this.businessId,
    required this.userName,
    required this.productName,
    required this.totalFermines,
    required this.totalCOP,
    required this.fecha,
    required this.origen,
  });
}
