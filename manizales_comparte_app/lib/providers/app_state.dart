import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../services/catalog_repository.dart';

enum AppRole { citizen, business }

enum MapLayer { tapas, eventos, negocios }

class AppState extends ChangeNotifier {
  final CatalogRepository repo = CatalogRepository();

  // ===== Catálogo (Supabase con fallback a datos semilla) =====
  List<Business> businesses = List.of(kBusinesses);
  List<BusinessProduct> products = List.of(kBusinessProducts);
  List<Promotion> promotions = List.of(kPromotions);
  final Map<String, List<Redemption>> _remoteRedemptions = {};
  bool catalogLoaded = false;
  bool catalogLoading = false;
  String? catalogError;

  // ===== Auth de comerciante =====
  List<Business> myBusinesses = [];
  bool myBusinessesLoading = false;
  User? get authUser {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null; // Supabase no inicializado
    }
  }

  bool get isMerchantSignedIn => authUser != null;

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

  Business? get _activeOrNull {
    for (final b in myBusinesses) {
      if (b.id == activeBusinessId) return b;
    }
    for (final b in businesses) {
      if (b.id == activeBusinessId) return b;
    }
    return null;
  }

  Business get activeBusiness =>
      _activeOrNull ??
      (myBusinesses.isNotEmpty
          ? myBusinesses.first
          : (businesses.isNotEmpty ? businesses.first : kBusinesses.first));

  List<BusinessProduct> productsFor(String businessId) =>
      products.where((p) => p.businessId == businessId).toList();

  List<Promotion> promotionsFor(String businessId) =>
      promotions.where((p) => p.businessId == businessId).toList();

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
    // Carga el catálogo en vivo (si falla, se queda con datos semilla).
    loadCatalog();
    // Reacciona a login/logout del comerciante (si Supabase está listo).
    try {
      Supabase.instance.client.auth.onAuthStateChange.listen((_) {
        if (isMerchantSignedIn) {
          loadMyBusinesses();
        } else {
          myBusinesses = [];
          notifyListeners();
        }
      });
    } catch (_) {
      // Supabase no inicializado: la app sigue con datos semilla.
    }
  }

  // ===== Carga de catálogo =====
  Future<void> loadCatalog() async {
    if (catalogLoading) return;
    catalogLoading = true;
    catalogError = null;
    notifyListeners();
    try {
      final b = await repo.fetchBusinesses();
      final p = await repo.fetchProducts();
      final pr = await repo.fetchPromotions();
      if (b.isNotEmpty) businesses = b;
      if (p.isNotEmpty) products = p;
      if (pr.isNotEmpty) promotions = pr;
      catalogLoaded = true;
    } catch (e) {
      catalogError = '$e';
    } finally {
      catalogLoading = false;
      notifyListeners();
    }
  }

  // ===== Auth de comerciante =====
  Future<void> signInMerchant(String email, String password) async {
    await Supabase.instance.client.auth
        .signInWithPassword(email: email, password: password);
    await loadMyBusinesses();
  }

  Future<void> signUpMerchant(String email, String password) async {
    await Supabase.instance.client.auth
        .signUp(email: email, password: password);
    await loadMyBusinesses();
  }

  Future<void> signOutMerchant() async {
    await Supabase.instance.client.auth.signOut();
    myBusinesses = [];
    role = AppRole.citizen;
    notifyListeners();
  }

  Future<void> loadMyBusinesses() async {
    myBusinessesLoading = true;
    notifyListeners();
    try {
      myBusinesses = await repo.fetchMyBusinesses();
      if (myBusinesses.isNotEmpty &&
          !myBusinesses.any((b) => b.id == activeBusinessId)) {
        activeBusinessId = myBusinesses.first.id;
        await loadBusinessAdminData(activeBusinessId);
      }
    } catch (_) {
      // Mantiene lo que haya.
    } finally {
      myBusinessesLoading = false;
      notifyListeners();
    }
  }

  /// Carga datos completos (incluye inactivos) del negocio que gestiona el dueño.
  Future<void> loadBusinessAdminData(String businessId) async {
    try {
      final pr = await repo.fetchProducts(businessId: businessId);
      final pm = await repo.fetchPromotions(businessId: businessId);
      final rd = await repo.fetchRedemptions(businessId);
      products = [
        ...products.where((p) => p.businessId != businessId),
        ...pr,
      ];
      promotions = [
        ...promotions.where((p) => p.businessId != businessId),
        ...pm,
      ];
      _remoteRedemptions[businessId] = rd;
      notifyListeners();
    } catch (_) {
      // Mantiene lo que haya.
    }
  }

  // ===== CRUD catálogo (panel comerciante) =====
  Future<Business> saveBusiness(Business b, {required bool isNew}) async {
    final saved =
        isNew ? await repo.createBusiness(b) : await repo.updateBusiness(b);
    myBusinesses = [
      ...myBusinesses.where((x) => x.id != saved.id),
      saved,
    ];
    businesses = [
      ...businesses.where((x) => x.id != saved.id),
      if (saved.activo) saved,
    ];
    activeBusinessId = saved.id;
    notifyListeners();
    return saved;
  }

  Future<void> saveProduct(BusinessProduct p, {required bool isNew}) async {
    final saved =
        isNew ? await repo.createProduct(p) : await repo.updateProduct(p);
    products = [...products.where((x) => x.id != saved.id), saved];
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await repo.deleteProduct(id);
    products = products.where((p) => p.id != id).toList();
    notifyListeners();
  }

  Future<void> savePromotion(Promotion p, {required bool isNew}) async {
    final saved =
        isNew ? await repo.createPromotion(p) : await repo.updatePromotion(p);
    promotions = [...promotions.where((x) => x.id != saved.id), saved];
    notifyListeners();
  }

  Future<void> deletePromotion(String id) async {
    await repo.deletePromotion(id);
    promotions = promotions.where((p) => p.id != id).toList();
    notifyListeners();
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
    loadBusinessAdminData(businessId);
  }

  /// Registra un canje real: lo persiste en Supabase y lo refleja al instante.
  void simulateRedemption(BusinessProduct product, {String? userName}) {
    final r = Redemption(
      id: 'red_live_${DateTime.now().millisecondsSinceEpoch}',
      businessId: product.businessId,
      productId: product.id,
      userName: userName ?? 'Turista demo',
      productName: product.nombre,
      totalFermines: product.precioFermines,
      totalCOP: product.precioCOP,
      fecha: DateTime.now(),
      origen: 'turista',
    );
    liveRedemptions.insert(0, r);
    notifyListeners();
    // Persiste sin bloquear la UI (si falla, queda al menos en la sesión).
    repo.insertRedemption(r).catchError((_) {});
  }

  List<Redemption> redemptionsFor(String businessId) {
    final remote = _remoteRedemptions[businessId];
    final base = remote ??
        kRedemptions.where((r) => r.businessId == businessId).toList();
    return [
      ...liveRedemptions.where((r) => r.businessId == businessId),
      ...base,
    ];
  }

  // ===== Canje con QR / código =====
  /// El turista genera una intención de canje y gasta sus Fermines.
  /// Lanza un mensaje si no le alcanzan.
  Future<CanjeIntent> generarCanje(BusinessProduct product) async {
    final fermines = product.ferminesPart;
    if (fermines > ferminesBalance) {
      throw 'No te alcanzan los Fermines: necesitas $fermines F y tienes $ferminesBalance F.';
    }
    final code = (DateTime.now().millisecondsSinceEpoch % 1000000)
        .toString()
        .padLeft(6, '0');
    final intent = CanjeIntent(
      id: 'cnj_new',
      code: code,
      businessId: product.businessId,
      productId: product.id,
      productName: product.nombre,
      fermines: fermines,
      copReal: product.copReal,
    );
    final saved = await repo.createCanjeIntent(intent);
    // La persona NO recibe Fermines: los gasta como descuento.
    if (fermines > 0) spendFermines(fermines, 'Canje: ${product.nombre}');
    return saved;
  }

  /// El comercio busca una intención pendiente por código en su negocio activo.
  Future<CanjeIntent?> buscarCanje(String code) =>
      repo.findPendingIntent(activeBusinessId, code);

  /// Valida límites + stock y registra el canje. Devuelve null si ok, o el motivo.
  Future<String?> confirmarCanje(CanjeIntent intent) async {
    final biz = activeBusiness;
    if (biz.maxCanjesDia > 0) {
      final n = await repo.countRedemptionsToday(biz.id);
      if (n >= biz.maxCanjesDia) {
        return 'Límite diario del negocio alcanzado ($n/${biz.maxCanjesDia}).';
      }
    }
    BusinessProduct? prod;
    for (final p in products) {
      if (p.id == intent.productId) {
        prod = p;
        break;
      }
    }
    if (prod != null) {
      if (prod.stock <= 0) return 'Sin stock de "${prod.nombre}".';
      if (prod.maxPorDia > 0 && intent.productId != null) {
        final n = await repo.countProductRedemptionsToday(intent.productId!);
        if (n >= prod.maxPorDia) {
          return 'Tope diario de "${prod.nombre}" alcanzado ($n/${prod.maxPorDia}).';
        }
      }
    }
    final red = Redemption(
      id: 'red_${DateTime.now().millisecondsSinceEpoch}',
      businessId: intent.businessId,
      productId: intent.productId,
      userName: 'Cliente',
      productName: intent.productName,
      totalFermines: intent.fermines,
      totalCOP: intent.copReal,
      fecha: DateTime.now(),
      origen: 'turista',
    );
    await repo.insertRedemption(red);
    await repo.markIntentDone(intent.id);
    if (prod != null && prod.stock > 0) {
      final updated = prod.copyWith(stock: prod.stock - 1);
      try {
        await repo.updateProduct(updated);
      } catch (_) {}
      products = [...products.where((p) => p.id != updated.id), updated];
    }
    liveRedemptions.insert(0, red);
    _remoteRedemptions[intent.businessId]?.insert(0, red);
    notifyListeners();
    return null;
  }

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
