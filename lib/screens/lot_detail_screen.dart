import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../services/payment_service.dart';
import 'payment_screen.dart';

class LotDetailScreen extends StatelessWidget {
  final LotModel lot;
  const LotDetailScreen({super.key, required this.lot});

  void _copyHash(BuildContext context, String hash) {
    Clipboard.setData(ClipboardData(text: hash));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Hash copié !'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: GS.polygon,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    final bc = lot.blockchainRecord;

    return Scaffold(
      backgroundColor: gs.bg,
      appBar: AppBar(
        backgroundColor: gs.bg, elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 4)]),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: gs.textDark),
          ),
        ),
        title: Text(lot.lotId,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: gs.textDark)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: StatusBadge(status: lot.status)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Infos principales ────────────────────────────────────────────
          _Card(gs: gs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionTitle('Informations du lot', Icons.inventory_2_outlined, GS.greenPrimary, gs),
            const SizedBox(height: 14),
            _row('Culture', lot.culture, gs),
            _row('Poids', '${lot.poids.toInt()} kg', gs),
            _row('Région', lot.region, gs),
            _row('Agriculteur', lot.agriculteurNom, gs),
            _row('Date de récolte',
              '${lot.dateRecolte.day}/${lot.dateRecolte.month}/${lot.dateRecolte.year}', gs),
            if (lot.transformateurNom != null) _row('Transformateur', lot.transformateurNom!, gs),
            if (lot.exportateurNom != null)    _row('Exportateur', lot.exportateurNom!, gs),
          ])),
          const SizedBox(height: 14),

          // ── Certifications ───────────────────────────────────────────────
          _Card(gs: gs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionTitle('Certifications', Icons.workspace_premium_rounded, GS.gold, gs),
            const SizedBox(height: 14),
            lot.certifications.isEmpty
                ? Text('Aucune certification attribuée',
                    style: TextStyle(fontSize: 13, color: gs.textLight, fontStyle: FontStyle.italic))
                : Wrap(spacing: 8, runSpacing: 8,
                    children: lot.certifications.map((c) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: GS.greenPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GS.greenPrimary.withOpacity(0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.verified_rounded, color: GS.greenPrimary, size: 14),
                        const SizedBox(width: 6),
                        Text(c, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GS.greenPrimary)),
                      ]),
                    )).toList()),
          ])),
          const SizedBox(height: 14),

          // ── Blockchain Polygon ───────────────────────────────────────────
          _Card(gs: gs,
            borderColor: bc != null ? GS.polygon.withOpacity(0.3) : null,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Blockchain Polygon', null, GS.polygon, gs, emoji: '⬡'),
              const SizedBox(height: 14),
              if (bc == null)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: GS.polygon.withOpacity(0.06), borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Text('⬡', style: TextStyle(fontSize: 20, color: GS.polygon)),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Ce lot n\'est pas encore enregistré sur la blockchain Polygon.',
                      style: TextStyle(fontSize: 12, color: gs.textMed))),
                  ]),
                )
              else ...[
                _hashRow('Transaction', bc.txHash, gs, context),
                _hashRow('Hash bloc', bc.blockHash, gs, context),
                _row('Numéro de bloc', '#${bc.blockNumber}', gs),
                _row('Réseau', bc.network, gs),
                _row('Contrat', '${bc.contractAddress.substring(0,10)}...', gs),
                _row('Gaz utilisé', '${bc.gasUsed} Gwei', gs),
                _row('Statut', bc.status.toUpperCase(), gs, valueColor: GS.statusOk),
                _row('Horodatage',
                  '${bc.timestamp.day}/${bc.timestamp.month}/${bc.timestamp.year} à ${bc.timestamp.hour}:${bc.timestamp.minute.toString().padLeft(2,'0')}', gs),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(color: GS.polygon.withOpacity(0.1), borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GS.polygon.withOpacity(0.3))),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.open_in_new_rounded, color: GS.polygon, size: 16),
                      SizedBox(width: 8),
                      Text('Voir sur PolygonScan', style: TextStyle(color: GS.polygon, fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ],
            ])),
          const SizedBox(height: 14),

          // ── Historique statuts ───────────────────────────────────────────
          _Card(gs: gs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionTitle('Historique des statuts', Icons.timeline_rounded, GS.statusNew, gs),
            const SizedBox(height: 14),
            _StatusTimeline(lot: lot, gs: gs),
          ])),
          const SizedBox(height: 14),

          // ── Paiements liés ───────────────────────────────────────────────
          _Card(gs: gs, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _sectionTitle('Paiements liés', Icons.payments_outlined, GS.brown, gs),
            const SizedBox(height: 14),
            ...PaymentService.history
                .where((t) => t.lotId == lot.lotId)
                .map<Widget>((t) => _PaymentRow(tx: t, gs: gs))
                .toList()
              ..add(
                PaymentService.history.where((t) => t.lotId == lot.lotId).isEmpty
                    ? _EmptyPayments(gs: gs) as Widget
                    : const SizedBox.shrink()),
          ])),
          const SizedBox(height: 24),

          // ── Bouton payer certification ────────────────────────────────────
          if (lot.certifications.isEmpty && lot.status != LotStatus.exporte)
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => PaymentScreen(type: PaymentType.certification, lotId: lot.lotId,
                  description: 'Certification pour ${lot.lotId}'))),
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  color: GS.gold,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: GS.gold.withOpacity(0.35), blurRadius: 10, offset: const Offset(0,4))],
                ),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text('Payer pour certifier ce lot', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
        ]),
      ),
    );
  }

  Widget _Card({required GSColors gs, required Widget child, Color? borderColor}) =>
    Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gs.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? gs.divider.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,2))]),
      child: child);

  Widget _sectionTitle(String title, IconData? icon, Color color, GSColors gs, {String? emoji}) =>
    Row(children: [
      Container(width: 32, height: 32,
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(9)),
        child: Center(child: emoji != null
            ? Text(emoji, style: TextStyle(fontSize: 16, color: color))
            : Icon(icon, color: color, size: 17))),
      const SizedBox(width: 10),
      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: gs.textDark)),
    ]);

  Widget _row(String k, String v, GSColors gs, {Color? valueColor}) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(width: 130, child: Text(k, style: TextStyle(fontSize: 12, color: gs.textLight))),
        Expanded(child: Text(v, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
          color: valueColor ?? gs.textDark))),
      ]));

  Widget _hashRow(String k, String v, GSColors gs, BuildContext context) =>
    Padding(padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(width: 120, child: Text(k, style: TextStyle(fontSize: 12, color: gs.textLight))),
        Expanded(child: GestureDetector(
          onTap: () => _copyHash(context, v),
          child: Row(children: [
            Expanded(child: Text(
              v.length > 18 ? '${v.substring(0,10)}...${v.substring(v.length-6)}' : v,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GS.polygon, fontFamily: 'monospace'))),
            const Icon(Icons.copy_rounded, size: 13, color: GS.polygon),
          ]),
        )),
      ]));
}

// ── Status Timeline ────────────────────────────────────────────────────────
class _StatusTimeline extends StatelessWidget {
  final LotModel lot;
  final GSColors gs;
  const _StatusTimeline({required this.lot, required this.gs});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (LotStatus.nouveau, '🌱', 'Enregistrement', true),
      (LotStatus.enAttente, '⏳', 'En attente de vérification', lot.status.index >= LotStatus.enAttente.index),
      (LotStatus.verifie, '✅', 'Vérifié & Certifié', lot.status.index >= LotStatus.verifie.index),
      (LotStatus.enTransformation, '🏭', 'En transformation', lot.status.index >= LotStatus.enTransformation.index),
      (LotStatus.exporte, '🚢', 'Exporté', lot.status == LotStatus.exporte),
    ];

    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key;
        final (status, emoji, label, done) = e.value;
        final isCurrent = lot.status == status;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              Container(width: 28, height: 28,
                decoration: BoxDecoration(
                  color: done ? GS.greenPrimary : isCurrent ? GS.statusWait : gs.inputFill,
                  shape: BoxShape.circle,
                  border: isCurrent ? Border.all(color: GS.statusWait, width: 2) : null,
                ),
                child: Center(child: done
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : Text(emoji, style: const TextStyle(fontSize: 12)))),
              if (i < steps.length - 1)
                Container(width: 2, height: 28,
                  color: done ? GS.greenPrimary.withOpacity(0.3) : gs.divider),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              child: Text(label,
                style: TextStyle(fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: done ? gs.textDark : gs.textLight)),
            )),
          ],
        );
      }).toList(),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final PaymentTransaction tx;
  final GSColors gs;
  const _PaymentRow({required this.tx, required this.gs});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: gs.inputFill, borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
      Text(tx.method.logo, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tx.description, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gs.textDark)),
        Text('${tx.reference} · ${tx.method.label}', style: TextStyle(fontSize: 10, color: gs.textLight)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(tx.formattedAmount,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GS.statusOk)),
        Text(tx.statusLabel, style: const TextStyle(fontSize: 10, color: GS.statusOk)),
      ]),
    ]),
  );
}

class _EmptyPayments extends StatelessWidget {
  final GSColors gs;
  const _EmptyPayments({required this.gs});
  @override
  Widget build(BuildContext context) => Text(
    'Aucun paiement associé à ce lot',
    style: TextStyle(fontSize: 12, color: gs.textLight, fontStyle: FontStyle.italic));
}
