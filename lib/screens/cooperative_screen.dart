import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/gs_theme.dart';
import '../widgets/role_guard.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class CooperativeScreen extends StatelessWidget {
  const CooperativeScreen({super.key});
  @override
  Widget build(BuildContext context) => RoleGuard(
        required: UserRole.cooperative,
        child: const _CoopBody(),
      );
}

class _CoopBody extends StatefulWidget {
  const _CoopBody();
  @override
  State<_CoopBody> createState() => _CoopBodyState();
}

class _CoopBodyState extends State<_CoopBody> {
  void _transfer(LotModel lot) {
    setState(() {
      if (lot.status == LotStatus.verifie)
        lot.status = LotStatus.enTransformation;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${lot.lotId} transféré'),
      backgroundColor: GS.brown,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _showDetail(LotModel lot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LotSheet(lot: lot),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lots = AppState.lots;
    final enAttente = lots.where((l) => l.status == LotStatus.enAttente).length;
    final transferes = lots
        .where((l) =>
            l.status == LotStatus.enTransformation ||
            l.status == LotStatus.exporte)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageBanner(
              emoji: '🏛',
              title: 'Gestion des lots',
              subtitle: 'Coopérative agricole du Togo'),
          const SizedBox(height: 16),

          // Compteurs
          Row(
            children: [
              _CountCard(
                  label: 'Lots requis', count: enAttente, color: GS.statusWait),
              const SizedBox(width: 12),
              _CountCard(
                  label: 'Transférés', count: transferes, color: GS.statusOk),
            ],
          ),
          const SizedBox(height: 20),

          const SectionHeader(title: 'Tous les lots'),
          const SizedBox(height: 12),

          ...lots.map((lot) => LotCard(
                lot: lot,
                actions: ActionRow(
                  label1: '👁 Détails',
                  color1: GS.greenPale,
                  label2: 'Transférer →',
                  color2: GS.brown,
                  onTap1: () => _showDetail(lot),
                  onTap2: () => _transfer(lot),
                ),
              )),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _CountCard(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: gs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
                color: GS.greenDark.withOpacity(0.06),
                blurRadius: 5,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(fontSize: 12, color: gs.textMed)),
          ],
        ),
      ),
    );
  }
}

class _LotSheet extends StatelessWidget {
  final LotModel lot;
  const _LotSheet({required this.lot});

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Container(
      decoration: BoxDecoration(
        color: gs.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: GS.divider,
                      borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lot.lotId,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: gs.textDark)),
              StatusBadge(status: lot.status),
            ],
          ),
          const SizedBox(height: 14),
          _row(gs, 'Agriculteur', lot.agriculteurNom),
          _row(gs, 'Culture', lot.culture),
          _row(gs, 'Région', lot.region),
          _row(gs, 'Poids', '${lot.poids.toInt()} kg'),
          _row(gs, 'Date récolte',
              '${lot.dateRecolte.day}/${lot.dateRecolte.month}/${lot.dateRecolte.year}'),
          if (lot.certifications.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
                spacing: 8,
                children: lot.certifications
                    .map((c) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: gs.greenBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: GS.greenLight.withOpacity(0.4)),
                          ),
                          child: Text(c,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: GS.greenDark,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList()),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _row(GSColors gs, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
                width: 110,
                child: Text(label,
                    style: TextStyle(fontSize: 13, color: gs.textLight))),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: gs.textDark)),
          ],
        ),
      );
}
