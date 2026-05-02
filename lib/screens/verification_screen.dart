import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _lotIdCtrl = TextEditingController();
  LotModel? _foundLot;
  bool _notFound = false;
  bool _scanMode = false;
  bool _scanning = false;
  final List<String> _selectedCerts = [];

  final List<String> _availableCerts = ['Bio', 'Fair Trade', 'Rainforest Alliance', 'UTZ'];

  void _search() {
    final query = _lotIdCtrl.text.trim().toUpperCase();
    final lot = AppData.lots.where((l) => l.lotId.toUpperCase().contains(query)).firstOrNull;
    setState(() {
      _foundLot = lot;
      _notFound = lot == null && query.isNotEmpty;
    });
  }

  void _startScan() async {
    setState(() {
      _scanMode = true;
      _scanning = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    // Simulate finding a lot
    setState(() {
      _scanning = false;
      _foundLot = AppData.lots.first;
      _lotIdCtrl.text = AppData.lots.first.lotId;
    });
  }

  void _cancelScan() => setState(() {
    _scanMode = false;
    _scanning = false;
  });

  void _addCertification() async {
    if (_foundLot == null) return;
    setState(() => _foundLot!.status = LotStatus.verifie);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Certifications ajoutées avec succès'),
        backgroundColor: AppColors.statusVerified,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _lotIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: const GreenAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                  Text('🔍', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vérification Traçabilité',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark),
                      ),
                      Text(
                        'Scannez le QR code ou entrez l\'ID du lot',
                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search section
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
                  const SizedBox(height: 12),
                  GreenButton(
                    label: 'Rechercher',
                    icon: Icons.search,
                    onTap: _search,
                  ),
                  const SizedBox(height: 10),
                  GreenButton(
                    label: _scanMode ? 'Mode scan actif' : 'Scanner un QR Code',
                    icon: Icons.qr_code_scanner,
                    color: _scanMode ? AppColors.statusVerified : AppColors.primaryGreenDark,
                    onTap: _startScan,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // QR Scan view
            if (_scanMode)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.pink,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.statusRejected.withOpacity(0.2)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: _scanning
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.primaryGreen, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.primaryGreen),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Positionnez le QR code...',
                                  style: TextStyle(color: AppColors.textMedium, fontSize: 13),
                                ),
                              ],
                            )
                          : const Icon(Icons.qr_code, size: 80, color: AppColors.textLight),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _cancelScan,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, size: 18, color: AppColors.textDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_scanMode) const SizedBox(height: 12),

            // Not found message
            if (_notFound)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.statusRejected.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.statusRejected.withOpacity(0.25)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.statusRejected, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Lot introuvable. Vérifiez l\'ID.',
                      style: TextStyle(color: AppColors.statusRejected, fontSize: 13),
                    ),
                  ],
                ),
              ),

            // Lot found details
            if (_foundLot != null) ...[
              const SizedBox(height: 12),
              _LotDetailCard(lot: _foundLot!),
              const SizedBox(height: 12),
              _CertificationsSection(
                lot: _foundLot!,
                availableCerts: _availableCerts,
                selectedCerts: _selectedCerts,
                onToggle: (c) => setState(() {
                  _selectedCerts.contains(c) ? _selectedCerts.remove(c) : _selectedCerts.add(c);
                }),
                onAdd: _addCertification,
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _LotDetailCard extends StatelessWidget {
  final LotModel lot;
  const _LotDetailCard({required this.lot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.statusVerified.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lot.lotId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              StatusBadge(status: lot.status),
            ],
          ),
          const Divider(height: 20, color: AppColors.divider),
          Row(
            children: [
              _Detail(label: 'Agriculteur', value: lot.agriculteurNom),
              const SizedBox(width: 20),
              _Detail(label: 'Région', value: lot.region),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Detail(label: 'Poids', value: '${lot.poids.toInt()} kg'),
              const SizedBox(width: 20),
              _Detail(label: 'Culture', value: lot.culture),
              const SizedBox(width: 20),
              _Detail(
                label: 'Récolte',
                value: '${lot.dateRecolte.day}/${lot.dateRecolte.month}/${lot.dateRecolte.year}',
              ),
            ],
          ),
          if (lot.certifications.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: lot.certifications.map((c) => CertBadge(label: c)).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;
  const _Detail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMedium)),
      ],
    );
  }
}

class _CertificationsSection extends StatelessWidget {
  final LotModel lot;
  final List<String> availableCerts;
  final List<String> selectedCerts;
  final Function(String) onToggle;
  final VoidCallback onAdd;

  const _CertificationsSection({
    required this.lot,
    required this.availableCerts,
    required this.selectedCerts,
    required this.onToggle,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text('🏆', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text(
                'Certifications disponibles',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: availableCerts.map((cert) {
              final isSelected = selectedCerts.contains(cert);
              final alreadyHas = lot.certifications.contains(cert);
              return GestureDetector(
                onTap: () => !alreadyHas ? onToggle(cert) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: alreadyHas
                        ? AppColors.statusVerified.withOpacity(0.1)
                        : isSelected
                            ? AppColors.primaryGreen.withOpacity(0.1)
                            : AppColors.backgroundGreen,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: alreadyHas
                          ? AppColors.statusVerified
                          : isSelected
                              ? AppColors.primaryGreen
                              : AppColors.divider,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        alreadyHas ? Icons.check_circle : isSelected ? Icons.check_circle_outline : Icons.circle_outlined,
                        size: 16,
                        color: alreadyHas ? AppColors.statusVerified : isSelected ? AppColors.primaryGreen : AppColors.textLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cert,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: alreadyHas
                              ? AppColors.statusVerified
                              : isSelected
                                  ? AppColors.primaryGreen
                                  : AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          GreenButton(
            label: 'Ajouter les certifications',
            icon: Icons.add_circle_outline,
            onTap: onAdd,
          ),
        ],
      ),
    );
  }
}
