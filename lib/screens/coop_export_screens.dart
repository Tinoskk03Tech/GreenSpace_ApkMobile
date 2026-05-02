import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

// ── Cooperative Screen ─────────────────────────────────────────────────────
class CooperativeScreen extends StatefulWidget {
  const CooperativeScreen({super.key});

  @override
  State<CooperativeScreen> createState() => _CooperativeScreenState();
}

class _CooperativeScreenState extends State<CooperativeScreen> {
  @override
  Widget build(BuildContext context) {
    final myLots = AppData.lots;
    final lotsEnAttente = myLots.where((l) => l.status == LotStatus.enAttente).toList();
    final lotsVerifies = myLots.where((l) => l.status == LotStatus.verifie).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: const GreenAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('🏛', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestion des lots',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      Text(
                        'Coopérative agricole',
                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tabs counter
            Row(
              children: [
                _TabCounter(
                  label: 'Lots requis',
                  count: lotsEnAttente.length,
                  color: AppColors.statusPending,
                ),
                const SizedBox(width: 10),
                _TabCounter(
                  label: 'Transférés',
                  count: lotsVerifies.length,
                  color: AppColors.statusVerified,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Lots list
            const SectionTitle(title: 'Tous les lots'),
            const SizedBox(height: 12),
            ...myLots.map(
              (lot) => LotCard(
                lot: lot,
                trailing: Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Détails',
                        color: AppColors.primaryGreen,
                        outlined: true,
                        onTap: () => _showLotDetails(context, lot),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Transférer →',
                        color: AppColors.brown,
                        onTap: () => setState(() {
                          if (lot.status == LotStatus.verifie) {
                            lot.status = LotStatus.enTransformation;
                          }
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showLotDetails(BuildContext context, LotModel lot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LotDetailSheet(lot: lot),
    );
  }
}

class _TabCounter extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _TabCounter({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  final VoidCallback? onTap;

  const _ActionBtn({required this.label, required this.color, this.outlined = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: outlined ? color.withOpacity(0.05) : color,
          borderRadius: BorderRadius.circular(8),
          border: outlined ? Border.all(color: color.withOpacity(0.4)) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: outlined ? color : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _LotDetailSheet extends StatelessWidget {
  final LotModel lot;
  const _LotDetailSheet({required this.lot});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            lot.lotId,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          StatusBadge(status: lot.status),
          const SizedBox(height: 16),
          _DetailRow(label: 'Agriculteur', value: lot.agriculteurNom),
          _DetailRow(label: 'Région', value: lot.region),
          _DetailRow(label: 'Culture', value: lot.culture),
          _DetailRow(label: 'Poids', value: '${lot.poids.toInt()} kg'),
          _DetailRow(
            label: 'Date récolte',
            value: '${lot.dateRecolte.day}/${lot.dateRecolte.month}/${lot.dateRecolte.year}',
          ),
          if (lot.certifications.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text('Certifications', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: lot.certifications.map((c) => CertBadge(label: c)).toList(),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textLight)),
          ),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        ],
      ),
    );
  }
}

// ── Exportateur Screen ─────────────────────────────────────────────────────
class ExportateurScreen extends StatefulWidget {
  const ExportateurScreen({super.key});

  @override
  State<ExportateurScreen> createState() => _ExportateurScreenState();
}

class _ExportateurScreenState extends State<ExportateurScreen> {
  @override
  Widget build(BuildContext context) {
    final lotsDisponibles = AppData.lots
        .where((l) => l.status == LotStatus.enTransformation || l.status == LotStatus.verifie)
        .toList();
    final lotsExportes = AppData.lots.where((l) => l.status == LotStatus.exporte).toList();
    final totalPoids = lotsDisponibles.fold<double>(0, (sum, l) => sum + l.poids);

    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: const GreenAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('🚢', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestion des exports',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      Text(
                        'Exportateur agréé',
                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _ExportStat(
                    label: 'Prêts à exporter',
                    value: '${lotsDisponibles.length}',
                    unit: 'Lots',
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExportStat(
                    label: 'Total',
                    value: '${totalPoids.toInt()}',
                    unit: 'kg',
                    color: AppColors.brown,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Lots disponibles
            const SectionTitle(title: 'Lots disponibles pour export'),
            const SizedBox(height: 12),
            ...lotsDisponibles.map(
              (lot) => LotCard(
                lot: lot,
                trailing: Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(label: 'Détails', color: AppColors.primaryGreen, outlined: true, onTap: () {}),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Exporter →',
                        color: AppColors.brown,
                        onTap: () => setState(() {
                          lot.status = LotStatus.exporte;
                          lot.exportateurNom = AppData.currentUser?.prenom;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // QR Code export preuves
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.qr_code, color: AppColors.primaryGreen, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'QR Code preuve EJOK',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: GridView.count(
                          crossAxisCount: 8,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(64, (i) {
                            final filled = [0,1,2,3,4,5,6,7,8,14,16,17,18,19,20,21,22,23,28,35,42,49,56,57,58,59,60,61,62,63].contains(i);
                            return Container(
                              color: filled ? AppColors.textDark : AppColors.white,
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GreenButton(
                    label: 'Générer preuve EJOK',
                    icon: Icons.qr_code_2,
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download_outlined, color: AppColors.textMedium, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Télécharger documents',
                            style: TextStyle(color: AppColors.textMedium, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (lotsExportes.isNotEmpty) ...[
              const SizedBox(height: 20),
              const SectionTitle(title: 'Lots exportés'),
              const SizedBox(height: 12),
              ...lotsExportes.map((lot) => LotCard(lot: lot)),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ExportStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _ExportStat({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(unit, style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
