import 'package:flutter/material.dart';
import '../models/models.dart';
import '../data/mock_data.dart';

enum AppRole { citizen, business }

enum MapLayer { tapas, eventos, negocios }

class AppState extends ChangeNotifier {
  bool onboardingDone = false;
  int ferminesBalance = 150;
  final Set<String> capturedTapaIds = {};
  final List<FerminTransaction> transactions = [];
  int totalDonated = 0;
  String userName = 'Explorador';

  // Rewards / Canje
  final List<String> redeemedRewardIds = [];
  int totalRedeemed = 0;

  // Membership
  String activeMembershipId = 'mem_free';
  Membership get activeMembership =>
      kMemberships.firstWhere((m) => m.id == activeMembershipId);

  // Gamification
  int streakDays = 3;
  final Set<String> completedChallengeIds = {};
  int totalChallengesCompleted = 0;

  // Eventos sociales (inscripciones)
  final Set<String> enrolledEventIds = {};

  // Capas activas en el mapa
  final Set<MapLayer> activeLayers = {MapLayer.tapas, MapLayer.eventos, MapLayer.negocios};

  // Filtro por sector (null = todos)
  String? selectedSector;

  // Modo App: turista / negocio
  AppRole role = AppRole.citizen;
  String activeBusinessId = 'biz_sombrerero';
  Business get activeBusiness =>
      kBusinesses.firstWhere((b) => b.id == activeBusinessId);

  // Canjes simulados desde el lado del aliado
  final List<Redemption> liveRedemptions = [];
  double get multiplier {
    double m = 1.0;
    if (activeMembershipId != 'mem_free') {
      m += activeMembership.bonusPercent / 100;
    }
    return m;
  }

  AppState() {
    transactions.add(FerminTransaction(
      id: 'txn_welcome',
      description: 'Bienvenida a Manizales Comparte',
      amount: 150,
      date: DateTime.now().subtract(const Duration(minutes: 5)),
      type: TransactionType.earn,
    ));
  }

  void completeOnboarding() {
    onboardingDone = true;
    notifyListeners();
  }

  bool isTapaCaptured(String tapaId) => capturedTapaIds.contains(tapaId);

  void captureTapa(Tapa tapa) {
    if (capturedTapaIds.contains(tapa.id)) return;
    capturedTapaIds.add(tapa.id);
    final reward = (tapa.ferminesReward * multiplier).round();
    ferminesBalance += reward;
    transactions.insert(
      0,
      FerminTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Tapa capturada: ${tapa.name}${multiplier > 1 ? ' (${multiplier}x)' : ''}',
        amount: reward,
        date: DateTime.now(),
        type: TransactionType.earn,
      ),
    );
    notifyListeners();
  }

  void rechargeFermines(int amount) {
    ferminesBalance += amount;
    transactions.insert(
      0,
      FerminTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Recarga de Fermines',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.recharge,
      ),
    );
    notifyListeners();
  }

  void donateFermines(int amount) {
    if (amount > ferminesBalance) return;
    ferminesBalance -= amount;
    totalDonated += amount;
    transactions.insert(
      0,
      FerminTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Donación - Fundación Pequeño Corazón',
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.donate,
      ),
    );
    notifyListeners();
  }

  void spendFermines(int amount, String description) {
    if (amount > ferminesBalance) return;
    ferminesBalance -= amount;
    transactions.insert(
      0,
      FerminTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        description: description,
        amount: amount,
        date: DateTime.now(),
        type: TransactionType.spend,
      ),
    );
    notifyListeners();
  }

  bool isRewardRedeemed(String rewardId) => redeemedRewardIds.contains(rewardId);

  bool canAffordReward(Reward reward) => ferminesBalance >= reward.ferminCost;

  void redeemReward(Reward reward) {
    if (!canAffordReward(reward) || isRewardRedeemed(reward.id)) return;
    ferminesBalance -= reward.ferminCost;
    redeemedRewardIds.add(reward.id);
    totalRedeemed++;
    transactions.insert(
      0,
      FerminTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Canje: ${reward.name}',
        amount: reward.ferminCost,
        date: DateTime.now(),
        type: TransactionType.spend,
      ),
    );
    notifyListeners();
  }

  bool isChallengeCompleted(String id) => completedChallengeIds.contains(id);

  void completeChallenge(DailyChallenge challenge) {
    if (completedChallengeIds.contains(challenge.id)) return;
    completedChallengeIds.add(challenge.id);
    totalChallengesCompleted++;
    final reward = (challenge.reward * multiplier).round();
    ferminesBalance += reward;
    transactions.insert(
      0,
      FerminTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Desafío: ${challenge.title}${multiplier > 1 ? ' (${multiplier}x)' : ''}',
        amount: reward,
        date: DateTime.now(),
        type: TransactionType.earn,
      ),
    );
    notifyListeners();
  }

  // ===== Eventos sociales =====
  bool isEnrolled(String eventId) => enrolledEventIds.contains(eventId);

  void enrollInEvent(SocialEvent event) {
    if (enrolledEventIds.contains(event.id)) return;
    enrolledEventIds.add(event.id);
    transactions.insert(
      0,
      FerminTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Inscripción: ${event.titulo}',
        amount: 0,
        date: DateTime.now(),
        type: TransactionType.earn,
      ),
    );
    notifyListeners();
  }

  void completeEvent(SocialEvent event) {
    if (!enrolledEventIds.contains(event.id)) return;
    final reward = (event.recompensaFermines * multiplier).round();
    ferminesBalance += reward;
    transactions.insert(
      0,
      FerminTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        description: 'Jornada ${event.programa.nombre}: ${event.titulo}',
        amount: reward,
        date: DateTime.now(),
        type: TransactionType.earn,
      ),
    );
    notifyListeners();
  }

  // ===== Capas / filtros del mapa =====
  void toggleLayer(MapLayer layer) {
    if (activeLayers.contains(layer)) {
      activeLayers.remove(layer);
    } else {
      activeLayers.add(layer);
    }
    notifyListeners();
  }

  void setSectorFilter(String? sector) {
    selectedSector = sector;
    notifyListeners();
  }

  // ===== Modo negocio =====
  void switchRole(AppRole newRole) {
    role = newRole;
    notifyListeners();
  }

  void switchBusiness(String businessId) {
    activeBusinessId = businessId;
    notifyListeners();
  }

  void simulateRedemption(BusinessProduct product) {
    final r = Redemption(
      id: 'red_live_${DateTime.now().millisecondsSinceEpoch}',
      businessId: product.businessId,
      userName: 'Turista demo',
      productName: product.nombre,
      totalFermines: product.precioFermines,
      totalCOP: product.precioCOP,
      fecha: DateTime.now(),
      origen: 'turista',
    );
    liveRedemptions.insert(0, r);
    notifyListeners();
  }

  List<Redemption> redemptionsFor(String businessId) => [
        ...liveRedemptions.where((r) => r.businessId == businessId),
        ...kRedemptions.where((r) => r.businessId == businessId),
      ];

  void subscribeMembership(Membership membership) {
    activeMembershipId = membership.id;
    if (membership.ferminesPerMonth > 0) {
      ferminesBalance += membership.ferminesPerMonth;
      transactions.insert(
        0,
        FerminTransaction(
          id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
          description: 'Membresía ${membership.name} — Fermines mensuales',
          amount: membership.ferminesPerMonth,
          date: DateTime.now(),
          type: TransactionType.recharge,
        ),
      );
    }
    notifyListeners();
  }
}
