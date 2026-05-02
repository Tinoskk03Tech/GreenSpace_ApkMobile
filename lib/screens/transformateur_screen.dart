import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class TransformateurScreen extends StatefulWidget {
  const TransformateurScreen({super.key});

  @override
  State<TransformateurScreen> createState() => _TransformateurScreenState();
}

class _TransformateurScreenState extends State<TransformateurScreen> {
  final _lotIdCtrl = TextEditingController();
  LotModel? _selectedLot;
  int _lotsEnAttente = 0;
  int _lotsTransformes = 0;

  @override
  void initState() {
    super.initState();
    _lotsEnAttente = AppData.lots.where((l) => l.status == LotStatus.verifie).length;
    _lotsTransformes = AppData.lots.where((l) => l.status == LotStatus.enTransformation).length;
  }

  @override
  void dispose() {
    _lotIdCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final query = _lotIdCtrl.text.trim().toUpperCase();
    final lot = AppData.lots.where((l) => l.lotId.toUpperCase().contains(query)).firstOrNull;
    setState(() => _selectedLot = lot);
  }

  void _validerTransformation(LotModel lot) async {
    setState(() {
      lot.status = LotStatus.enTransformation;
      lot.transformateurNom = AppData.currentUser?.prenom ?? 'Transformateur';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${lot.lotId} en transformation'),
        backgroundColor: AppColors.brown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lotsVerifies = AppData.lots.where((l) => l.status == LotStatus.verifie).toList();
    final lotsEnTransfo = AppData.lots.where((l) => l.status == LotStatus.enTransformation).toList();

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
                  Text('🏭', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Validation des lots',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      Text(
                        '3 lots en attente de transformation',
                        style: TextStyle(fontSize: 12, color: AppColors.statusPending),
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
                  child: _CountCard(
                    label: 'En attente',
                    count: lotsVerifies.length,
                    color: AppColors.statusPending,
                    icon: Icons.hourglass_empty,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CountCard(
                    label: 'Transformés',
                    count: lotsEnTransfo.length,
                    color: AppColors.brown,
                    icon: Icons.factory_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Search by QR
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ID du lot',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _lotIdCtrl,
                    style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'LOT-TG-2026-XXXX',
                      filled: true,
                      fillColor: AppColors.backgroundGreen,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GreenButton(label: 'Rechercher', icon: Icons.search, onTap: _search),
                  const SizedBox(height: 10),
                  GreenButton(
                    label: 'Scanner un QR Code',
                    icon: Icons.qr_code_scanner,
                    color: AppColors.primaryGreenDark,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            if (_selectedLot != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.statusPending.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedLot!.lotId,
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
                        ),
                        StatusBadge(status: _selectedLot!.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _InfoTile(label: 'Poids', value: '${_selectedLot!.poids.toInt()} kg'),
                        _InfoTile(label: 'Type', value: _selectedLot!.culture),
                        _InfoTile(label: 'Région', value: _selectedLot!.region),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
                              ),
                              child: const Center(
                                child: Text('Détails',
                                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _validerTransformation(_selectedLot!),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.brown,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Transférer',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Lots en attente
            if (lotsVerifies.isNotEmpty) ...[
              const SectionTitle(title: 'Lots à transformer'),
              const SizedBox(height: 12),
              ...lotsVerifies.map((lot) => LotCard(
                lot: lot,
                trailing: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('Détails',
                                style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _validerTransformation(lot),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.brown,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Transférer',
                                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],

            // Historique
            if (lotsEnTransfo.isNotEmpty) ...[
              const SizedBox(height: 20),
              const SectionTitle(title: 'Historiques des transferts'),
              const SizedBox(height: 12),
              ...lotsEnTransfo.map((lot) => _HistoriqueTile(lot: lot)),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _CountCard({required this.label, required this.count, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
              ),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
        ],
      ),
    );
  }
}

class _HistoriqueTile extends StatelessWidget {
  final LotModel lot;
  const _HistoriqueTile({required this.lot});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.brown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.factory_outlined, color: AppColors.brown, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lot.lotId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textDark)),
                Text(
                  '${lot.transformateurNom ?? 'Transformateur'} · ${lot.dateRecolte.day}/${lot.dateRecolte.month}/${lot.dateRecolte.year}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
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
