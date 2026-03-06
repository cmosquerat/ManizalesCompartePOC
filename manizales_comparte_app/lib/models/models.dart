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
