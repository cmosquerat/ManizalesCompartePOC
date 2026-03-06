import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/app_state.dart';

class TiendaScreen extends StatefulWidget {
  const TiendaScreen({super.key});
  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tienda'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: AppColors.rojo,
          unselectedLabelColor: AppColors.gris,
          indicatorColor: AppColors.rojo,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
          tabs: const [
            Tab(text: 'Membresías'),
            Tab(text: 'Canjear'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _MembershipsTab(state: state),
          _RewardsTab(state: state),
        ],
      ),
    );
  }
}

// ── Memberships Tab ──

class _MembershipsTab extends StatelessWidget {
  final AppState state;
  const _MembershipsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // Current plan banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: state.activeMembership.gradient),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: state.activeMembership.color.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(15)),
                child: Icon(state.activeMembership.icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Plan actual', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                    Text(state.activeMembership.name, style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
              if (state.activeMembership.bonusPercent > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                  child: Text('+${state.activeMembership.bonusPercent}%', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        Text('Planes disponibles', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('Mejora tu plan para ganar más Fermines y desbloquear beneficios exclusivos',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gris, height: 1.5)),
        const SizedBox(height: 20),

        ...kMemberships.map((m) {
          final isActive = state.activeMembershipId == m.id;
          final isFree = m.priceCOP == 0;
          return _MembershipCard(membership: m, isActive: isActive, isFree: isFree, state: state);
        }),
      ],
    );
  }
}

class _MembershipCard extends StatefulWidget {
  final Membership membership;
  final bool isActive;
  final bool isFree;
  final AppState state;
  const _MembershipCard({required this.membership, required this.isActive, required this.isFree, required this.state});
  @override
  State<_MembershipCard> createState() => _MembershipCardState();
}

class _MembershipCardState extends State<_MembershipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.membership;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: widget.isActive ? m.color.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: widget.isActive ? m.color : Colors.grey.shade200,
            width: widget.isActive ? 2 : 1,
          ),
          boxShadow: widget.isActive
              ? [BoxShadow(color: m.color.withValues(alpha: 0.1), blurRadius: 16)]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: m.gradient),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: m.color.withValues(alpha: 0.3), blurRadius: 10)],
                  ),
                  child: Icon(m.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(m.name, style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700)),
                          if (widget.isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: m.color, borderRadius: BorderRadius.circular(6)),
                              child: Text('ACTIVO', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
                            ),
                          ],
                        ],
                      ),
                      Text(m.tagline, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
                    ],
                  ),
                ),
                Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: AppColors.gris),
              ],
            ),

            // Price + fermines row
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  if (!widget.isFree) ...[
                    Text('\$${_formatPrice(m.priceCOP)}', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800, color: m.color)),
                    Text('/mes', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gris)),
                  ] else
                    Text('Gratis', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gris)),
                  const Spacer(),
                  if (m.ferminesPerMonth > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: AppColors.amarillo.withValues(alpha: 0.3), blurRadius: 8)],
                      ),
                      child: Text('${m.ferminesPerMonth} F/mes', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.negro)),
                    ),
                  if (m.bonusPercent > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.verde.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('+${m.bonusPercent}%', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.verde)),
                    ),
                  ],
                ],
              ),
            ),

            // Expandable perks
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 1, color: Colors.grey.shade100),
                    const SizedBox(height: 14),
                    Text('Incluye:', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...m.perks.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(color: m.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(7)),
                                child: Icon(Icons.check_rounded, size: 14, color: m.color),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(p, style: GoogleFonts.poppins(fontSize: 13))),
                            ],
                          ),
                        )),
                    if (!widget.isActive && !widget.isFree) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: LinearGradient(colors: m.gradient),
                            boxShadow: [BoxShadow(color: m.color.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6))],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                widget.state.subscribeMembership(m);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('¡Bienvenido al plan ${m.name}! +${m.ferminesPerMonth} Fermines', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                  backgroundColor: m.color,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  margin: const EdgeInsets.all(16),
                                ));
                              },
                              child: Center(child: Text('Suscribirme', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ── Rewards/Canjear Tab ──

class _RewardsTab extends StatelessWidget {
  final AppState state;
  const _RewardsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final categories = RewardCategory.values;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        // Balance reminder
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.amarillo.withValues(alpha: 0.1), AppColors.amarillo.withValues(alpha: 0.03)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.amarillo.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.monetization_on_rounded, color: AppColors.amarillo, size: 22),
              const SizedBox(width: 10),
              Text('Tienes ', style: GoogleFonts.poppins(fontSize: 14)),
              Text('${state.ferminesBalance} Fermines', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.negro)),
              Text(' disponibles', style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        ...categories.map((cat) {
          final items = kRewards.where((r) => r.category == cat).toList();
          if (items.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_catEmoji(cat), style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(_catLabel(cat), style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              ...items.map((r) => _RewardTile(reward: r, state: state)),
              const SizedBox(height: 20),
            ],
          );
        }),
      ],
    );
  }

  String _catLabel(RewardCategory c) => switch (c) {
        RewardCategory.product => 'Productos',
        RewardCategory.discount => 'Descuentos',
        RewardCategory.experience => 'Experiencias',
        RewardCategory.exclusive => 'Exclusivos',
      };

  String _catEmoji(RewardCategory c) => switch (c) {
        RewardCategory.product => '🎁',
        RewardCategory.discount => '🏷️',
        RewardCategory.experience => '🌄',
        RewardCategory.exclusive => '⭐',
      };
}

class _RewardTile extends StatelessWidget {
  final Reward reward;
  final AppState state;
  const _RewardTile({required this.reward, required this.state});

  @override
  Widget build(BuildContext context) {
    final redeemed = state.isRewardRedeemed(reward.id);
    final canAfford = state.canAffordReward(reward);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: redeemed ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: redeemed ? Colors.grey.shade200 : reward.color.withValues(alpha: 0.12)),
          boxShadow: redeemed ? null : [BoxShadow(color: reward.color.withValues(alpha: 0.06), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: redeemed ? null : LinearGradient(colors: [reward.color.withValues(alpha: 0.15), reward.color.withValues(alpha: 0.05)]),
                color: redeemed ? Colors.grey.shade200 : null,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(redeemed ? Icons.check_rounded : reward.icon, color: redeemed ? AppColors.gris : reward.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reward.name, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: redeemed ? AppColors.gris : AppColors.negro)),
                  const SizedBox(height: 2),
                  Text(
                    reward.description,
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (reward.allyName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('📍 ${reward.allyName}', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.turquesa, fontWeight: FontWeight.w500)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: redeemed
                        ? null
                        : canAfford
                            ? LinearGradient(colors: [reward.color, reward.color.withValues(alpha: 0.8)])
                            : null,
                    color: redeemed ? Colors.grey.shade200 : canAfford ? null : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    redeemed ? '✓' : '${reward.ferminCost} F',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: redeemed ? AppColors.gris : canAfford ? Colors.white : AppColors.gris,
                    ),
                  ),
                ),
                if (!canAfford && !redeemed) ...[
                  const SizedBox(height: 4),
                  Text('Faltan ${reward.ferminCost - state.ferminesBalance}', style: GoogleFonts.poppins(fontSize: 9, color: AppColors.gris)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final redeemed = state.isRewardRedeemed(reward.id);
    final canAfford = state.canAffordReward(reward);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [reward.color, reward.color.withValues(alpha: 0.7)]),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: reward.color.withValues(alpha: 0.3), blurRadius: 20)],
              ),
              child: Icon(reward.icon, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 18),
            Text(reward.name, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(reward.description, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.gris, height: 1.6), textAlign: TextAlign.center),
            if (reward.allyName != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: AppColors.turquesa.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text('📍 ${reward.allyName}', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.turquesa, fontWeight: FontWeight.w500)),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]), borderRadius: BorderRadius.circular(14)),
              child: Text('${reward.ferminCost} Fermines', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.negro)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: redeemed
                  ? Container(
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
                      child: Center(child: Text('Ya canjeado', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gris))),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: canAfford ? LinearGradient(colors: [reward.color, reward.color.withValues(alpha: 0.8)]) : null,
                        color: canAfford ? null : Colors.grey.shade200,
                        boxShadow: canAfford ? [BoxShadow(color: reward.color.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))] : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: canAfford
                              ? () {
                                  state.redeemReward(reward);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('¡${reward.name} canjeado!', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                    backgroundColor: reward.color,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    margin: const EdgeInsets.all(16),
                                  ));
                                }
                              : null,
                          child: Center(
                            child: Text(
                              canAfford ? 'Confirmar Canje' : 'Fermines insuficientes',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: canAfford ? Colors.white : AppColors.gris),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
