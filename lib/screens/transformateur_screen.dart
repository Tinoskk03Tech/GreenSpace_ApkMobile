import 'package:flutter/material.dart';
import '../theme/gs_theme.dart';
import '../widgets/role_guard.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class TransformateurScreen extends StatelessWidget {
  const TransformateurScreen({super.key});
  @override
  Widget build(BuildContext context) => RoleGuard(
        required: UserRole.transformateur,
        child: const _TransfoBody(),
      );
}

class _TransfoBody extends StatefulWidget {
  const _TransfoBody();
  @override
  State<_TransfoBody> createState() => _TransfoBodyState();
}

class _TransfoBodyState extends State<_TransfoBody> {
  final _searchCtrl = TextEditingController();
  LotModel? _found;
  bool _scanning = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final q = _searchCtrl.text.trim().toUpperCase();
    setState(() {
      _found = AppState.lots
          .where((l) => l.lotId.toUpperCase().contains(q))
          .firstOrNull;
    });
  }

  void _scan() async {
    setState(() {
      _scanning = true;
      _found = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _scanning = false;
      _found = AppState.lots.firstWhere((l) => l.status == LotStatus.verifie,
          orElse: () => AppState.lots.first);
      _searchCtrl.text = _found!.lotId;
    });
  }

  void _valider(LotModel lot) {
    setState(() {
      lot.status = LotStatus.enTransformation;
      lot.transformateurNom = AppState.user?.fullName ?? 'Transformateur';
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${lot.lotId} → En transformation'),
      backgroundColor: GS.brown,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lotsVerifies =
        AppState.lots.where((l) => l.status == LotStatus.verifie).toList();
    final lotsEnTransfo = AppState.lots
        .where((l) => l.status == LotStatus.enTransformation)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageBanner(
            emoji: '🏭',
            title: 'Validation des lots',
            subtitle: 'Lots en attente de transformation',
          ),
          const SizedBox(height: 16),

          // Compteurs
          Row(
            children: [
              _StatBox(
                  label: 'En attente',
                  count: lotsVerifies.length,
                  color: GS.statusWait,
                  icon: Icons.hourglass_empty_rounded),
              const SizedBox(width: 12),
              _StatBox(
                  label: 'En transformation',
                  count: lotsEnTransfo.length,
                  color: GS.brown,
                  icon: Icons.factory_outlined),
            ],
          ),
          const SizedBox(height: 16),

          // Recherche
          _SearchCard(
            ctrl: _searchCtrl,
            scanning: _scanning,
            onSearch: _search,
            onScan: _scan,
          ),

          if (_found != null) ...[
            const SizedBox(height: 12),
            LotCard(
              lot: _found!,
              actions: ActionRow(
                label1: '👁 Détails',
                color1: GS.greenPale,
                label2: 'Transférer →',
                color2: GS.brown,
                onTap1: () {},
                onTap2: () => _valider(_found!),
              ),
            ),
          ],

          if (lotsVerifies.isNotEmpty) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Lots à transformer'),
            const SizedBox(height: 12),
            ...lotsVerifies.map((lot) => LotCard(
                  lot: lot,
                  actions: ActionRow(
                    label1: '👁 Détails',
                    color1: GS.greenPale,
                    label2: 'Transférer →',
                    color2: GS.brown,
                    onTap1: () {},
                    onTap2: () => setState(() => _valider(lot)),
                  ),
                )),
          ],

          if (lotsEnTransfo.isNotEmpty) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Historiques des transferts'),
            const SizedBox(height: 12),
            ...lotsEnTransfo.map((lot) => _HistoriqueTile(lot: lot)),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _StatBox(
      {super.key,
      required this.label,
      required this.count,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: gs.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: GS.greenDark.withOpacity(0.06),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$count',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color)),
                Text(label,
                    style: TextStyle(fontSize: 10, color: gs.textLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final TextEditingController ctrl;
  final bool scanning;
  final VoidCallback onSearch;
  final VoidCallback onScan;
  const _SearchCard({
    super.key,
    required this.ctrl,
    required this.scanning,
    required this.onSearch,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gs.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: GS.greenDark.withOpacity(0.06),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ID du lot',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: gs.textDark),
          ),
          const SizedBox(height: 10),
          GSInput(ctrl: ctrl, hint: 'LOT-TG-2026-XXXX', fillColor: gs.bg),
          const SizedBox(height: 10),
          GSBtn(
              label: 'Rechercher', icon: Icons.search_rounded, onTap: onSearch),
          const SizedBox(height: 10),
          GSBtn(
            label: scanning ? 'Scan en cours...' : 'Scanner un QR Code',
            icon: Icons.qr_code_scanner,
            bg: GS.greenDark,
            loading: scanning,
            onTap: onScan,
          ),
        ],
      ),
    );
  }
}

class _HistoriqueTile extends StatelessWidget {
  final LotModel lot;
  const _HistoriqueTile({super.key, required this.lot});

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: gs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GS.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: GS.brown.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9)),
            child:
                const Icon(Icons.factory_outlined, color: GS.brown, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lot.lotId,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: gs.textDark),
                ),
                Text(
                  '${lot.transformateurNom ?? 'Transformateur'} · ${lot.dateRecolte.day}/${lot.dateRecolte.month}/${lot.dateRecolte.year}',
                  style: TextStyle(fontSize: 11, color: gs.textLight),
                ),
              ],
            ),
          ),
          StatusBadge(status: lot.status),
        ],
      ),
    );
  }
}
