import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class VerificationCompteScreen extends StatefulWidget {
  const VerificationCompteScreen({super.key});

  @override
  State<VerificationCompteScreen> createState() => _VerificationCompteScreenState();
}

class _VerificationCompteScreenState extends State<VerificationCompteScreen> {
  final _lotIdCtrl = TextEditingController();
  LotModel? _foundLot;

  void _search() {
    final q = _lotIdCtrl.text.trim().toUpperCase();
    setState(() {
      _foundLot = AppData.lots.where((l) => l.lotId.contains(q)).firstOrNull;
    });
  }

  @override
  void dispose() {
    _lotIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppData.currentUser;
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: const GreenAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile pending card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.statusPending.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.lightGreen,
                    child: Text(
                      user?.prenom.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${user?.prenom ?? ''} ${user?.nom ?? ''}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.statusPending.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.statusPending.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hourglass_empty, size: 14, color: AppColors.statusPending),
                        SizedBox(width: 5),
                        Text(
                          'En attente de vérification',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.statusPending,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search
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
                      Text('🔍', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text(
                        'Vérification',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _lotIdCtrl,
                    decoration: InputDecoration(
                      hintText: 'LOT-TG-2026-XXXX',
                      filled: true,
                      fillColor: AppColors.backgroundGreen,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
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

            if (_foundLot != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _foundLot!.lotId,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        StatusBadge(status: _foundLot!.status),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Col(label: 'Poids', value: '${_foundLot!.poids.toInt()} kg'),
                        _Col(label: 'Culture', value: _foundLot!.culture),
                        _Col(
                          label: 'Récolte',
                          value:
                              '${_foundLot!.dateRecolte.day}/${_foundLot!.dateRecolte.month}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _foundLot!.status = LotStatus.verifie;
                            }),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.statusVerified,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Valider',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _foundLot!.status = LotStatus.rejete;
                            }),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.statusRejected,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'Rejeter',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _Col extends StatelessWidget {
  final String label;
  final String value;
  const _Col({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
