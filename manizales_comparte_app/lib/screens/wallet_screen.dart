import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../providers/app_state.dart';
import 'tienda_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(floating: true, title: const Text('Wallet')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance card
                  _BalanceCard(state: state),
                  const SizedBox(height: 16),

                  // Active membership banner
                  _MembershipBanner(state: state),
                  const SizedBox(height: 16),

                  // Streak
                  _StreakBanner(days: state.streakDays),
                  const SizedBox(height: 24),

                  // Daily challenges
                  Text('Desafíos del día', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Completa desafíos para ganar Fermines extra', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.gris)),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: kDailyChallenges.length,
                itemBuilder: (_, i) {
                  final c = kDailyChallenges[i];
                  final done = state.isChallengeCompleted(c.id);
                  return _ChallengeCard(
                    challenge: c,
                    done: done,
                    onTap: done
                        ? null
                        : () {
                            state.completeChallenge(c);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('¡Desafío completado! +${c.reward} F', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                              backgroundColor: AppColors.verde,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              margin: const EdgeInsets.all(16),
                            ));
                          },
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.verde.withValues(alpha: 0.06), AppColors.verde.withValues(alpha: 0.02)]),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.verde.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.verde.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.favorite_rounded, color: AppColors.verde, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(style: GoogleFonts.poppins(fontSize: 13, color: AppColors.negro), children: [
                          const TextSpan(text: 'Has donado '),
                          TextSpan(text: '${state.totalDonated} Fermines', style: const TextStyle(fontWeight: FontWeight.w700)),
                          const TextSpan(text: ' · Canjeado '),
                          TextSpan(text: '${state.totalRedeemed} productos', style: const TextStyle(fontWeight: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Text('Movimientos', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 10), child: _TxnTile(txn: state.transactions[i])),
              childCount: state.transactions.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Balance Card ──

class _BalanceCard extends StatelessWidget {
  final AppState state;
  const _BalanceCard({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF12122a), Color(0xFF1a1040), Color(0xFF0f2040)]),
        boxShadow: [BoxShadow(color: const Color(0xFF1a1040).withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 12))],
      ),
      child: Stack(
        children: [
          Positioned(right: -20, top: -20, child: Icon(Icons.monetization_on_rounded, size: 120, color: AppColors.amarillo.withValues(alpha: 0.06))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mis Fermines', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60)),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.amarillo.withValues(alpha: 0.5), blurRadius: 16)],
                    ),
                    child: const Icon(Icons.monetization_on_rounded, color: AppColors.negro, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: state.ferminesBalance),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (_, val, __) => Text('$val', style: GoogleFonts.poppins(fontSize: 52, fontWeight: FontWeight.w700, color: Colors.white, height: 1)),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Fermines disponibles', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white38)),
                  if (state.multiplier > 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6F00), AppColors.amarillo]), borderRadius: BorderRadius.circular(8)),
                      child: Text('x${state.multiplier.toStringAsFixed(state.multiplier == state.multiplier.roundToDouble() ? 0 : 1)}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _GlassBtn(icon: Icons.add_circle_outline_rounded, label: 'Recargar', color: AppColors.verde, onTap: () => _showRecharge(context))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GlassBtn(
                      icon: Icons.storefront_rounded,
                      label: 'Tienda',
                      color: AppColors.amarillo,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TiendaScreen())),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _GlassBtn(icon: Icons.favorite_outline_rounded, label: 'Donar', color: AppColors.turquesa, onTap: () => _showDonate(context))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRecharge(BuildContext context) {
    final s = context.read<AppState>();
    final amounts = [(100, '\$10.000'), (275, '\$25.000'), (600, '\$50.000'), (1300, '\$100.000')];
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
            const SizedBox(height: 20),
            Text('Recargar Fermines', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('20% de cada recarga va al fondo benéfico', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
            const SizedBox(height: 20),
            ...amounts.map((a) => GestureDetector(
                  onTap: () {
                    s.rechargeFermines(a.$1);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('+${a.$1} Fermines recargados', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      backgroundColor: AppColors.verde,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                    child: Row(
                      children: [
                        Text(a.$2, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]), borderRadius: BorderRadius.circular(10)),
                          child: Text('${a.$1} F', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.negro)),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showDonate(BuildContext context) {
    final s = context.read<AppState>();
    final amounts = [10, 25, 50, 100];
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
            const SizedBox(height: 20),
            Text('Donar Fermines', style: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Fundación Pequeño Corazón', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.turquesa, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: amounts.map((a) {
                final can = s.ferminesBalance >= a;
                return GestureDetector(
                  onTap: can
                      ? () {
                          s.donateFermines(a);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Gracias por donar $a Fermines', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                            backgroundColor: AppColors.turquesa,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            margin: const EdgeInsets.all(16),
                          ));
                        }
                      : null,
                  child: Container(
                    width: 130,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: can ? LinearGradient(colors: [AppColors.turquesa.withValues(alpha: 0.08), AppColors.turquesa.withValues(alpha: 0.03)]) : null,
                      color: can ? null : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: can ? AppColors.turquesa.withValues(alpha: 0.3) : Colors.grey.shade200),
                    ),
                    child: Text('$a F', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: can ? AppColors.turquesa : AppColors.gris)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Membership Banner ──

class _MembershipBanner extends StatelessWidget {
  final AppState state;
  const _MembershipBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final m = state.activeMembership;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TiendaScreen())),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [m.color.withValues(alpha: 0.1), m.color.withValues(alpha: 0.03)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: m.color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(gradient: LinearGradient(colors: m.gradient), borderRadius: BorderRadius.circular(13)),
              child: Icon(m.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan ${m.name}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(
                    m.ferminesPerMonth > 0 ? '${m.ferminesPerMonth} F/mes · +${m.bonusPercent}% bonus' : 'Mejora tu plan para más beneficios',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: m.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(state.activeMembershipId == 'mem_free' ? 'Mejorar' : 'Ver', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: m.color)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Widgets ──

class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _StreakBanner extends StatelessWidget {
  final int days;
  const _StreakBanner({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFFF6F00).withValues(alpha: 0.1), AppColors.amarillo.withValues(alpha: 0.05)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.amarillo.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF6F00), AppColors.amarillo]),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [BoxShadow(color: AppColors.amarillo.withValues(alpha: 0.4), blurRadius: 10)],
            ),
            child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Racha de $days días', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700)),
                Text('¡Sigue así! A los 7 días ganas bonus extra', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gris)),
              ],
            ),
          ),
          Row(
            children: List.generate(7, (i) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: i < days ? const Color(0xFFFF6F00) : Colors.grey.shade300),
                )),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final DailyChallenge challenge;
  final bool done;
  final VoidCallback? onTap;
  const _ChallengeCard({required this.challenge, required this.done, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: done ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: done ? AppColors.verde.withValues(alpha: 0.3) : Colors.grey.shade200),
          boxShadow: done ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: done ? AppColors.verde.withValues(alpha: 0.12) : AppColors.rojo.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(done ? Icons.check_rounded : challenge.icon, color: done ? AppColors.verde : AppColors.rojo, size: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD700), AppColors.amarillo]), borderRadius: BorderRadius.circular(8)),
                  child: Text('+${challenge.reward}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.negro)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: done ? AppColors.gris : AppColors.negro)),
                Text(challenge.description, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  final FerminTransaction txn;
  const _TxnTile({required this.txn});

  @override
  Widget build(BuildContext context) {
    final pos = txn.type == TransactionType.earn || txn.type == TransactionType.recharge;
    final icon = switch (txn.type) { TransactionType.earn => Icons.place_rounded, TransactionType.spend => Icons.shopping_bag_rounded, TransactionType.recharge => Icons.add_circle_rounded, TransactionType.donate => Icons.favorite_rounded };
    final color = switch (txn.type) { TransactionType.earn => AppColors.verde, TransactionType.spend => AppColors.rojo, TransactionType.recharge => AppColors.turquesa, TransactionType.donate => AppColors.amarillo };
    final ago = DateTime.now().difference(txn.date);
    final time = ago.inMinutes < 1 ? 'Ahora' : ago.inMinutes < 60 ? '${ago.inMinutes}m' : ago.inHours < 24 ? '${ago.inHours}h' : '${ago.inDays}d';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.description, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(time, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.gris)),
              ],
            ),
          ),
          Text('${pos ? '+' : '-'}${txn.amount} F', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: pos ? AppColors.verde : AppColors.rojo)),
        ],
      ),
    );
  }
}
