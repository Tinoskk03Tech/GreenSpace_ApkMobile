import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';

class AgricultureScreen extends StatefulWidget {
  const AgricultureScreen({super.key});

  @override
  State<AgricultureScreen> createState() => _AgricultureScreenState();
}

class _AgricultureScreenState extends State<AgricultureScreen> {
  final _lotIdCtrl = TextEditingController();
  final _poidsCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  String _selectedCulture = 'Cacao';
  String _gpsCoords = '';
  bool _loading = false;
  bool _success = false;

  final List<String> _cultures = ['Cacao', 'Café', 'Coton', 'Maïs'];

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = '01/04/2026';
  }

  @override
  void dispose() {
    _lotIdCtrl.dispose();
    _poidsCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  void _getPosition() async {
    setState(() => _gpsCoords = 'Chargement...');
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _gpsCoords = 'Lomé, Région du Plateau, Togo\n6.1377° N, 1.2123° E');
  }

  void _submitLot() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    final newLot = LotModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lotId: 'LOT-TG-2026-${(DateTime.now().millisecondsSinceEpoch % 9999).toString().padLeft(4, '0')}',
      culture: _selectedCulture,
      poids: double.tryParse(_poidsCtrl.text) ?? 50,
      region: 'Maritime',
      agriculteurNom: AppData.currentUser?.prenom ?? 'Agriculteur',
      dateRecolte: DateTime.now(),
      status: LotStatus.nouveau,
    );
    AppData.lots.insert(0, newLot);
    setState(() {
      _loading = false;
      _success = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _success = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGreen,
      appBar: const GreenAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Text('🌾', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enregistrer un nouveau lot',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Enregistrer votre récolte pour la traçabilité EJOK',
                        style: TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_success)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.statusVerified.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.statusVerified.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.statusVerified, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Lot enregistré avec succès !',
                      style: TextStyle(color: AppColors.statusVerified, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

            // Géolocalisation
            _FormSection(
              icon: '📍',
              title: 'Géolocalisation',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreenButton(
                    label: 'Obtenir ma position',
                    icon: Icons.my_location,
                    onTap: _getPosition,
                  ),
                  if (_gpsCoords.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _gpsCoords,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Poids du lot
            _FormSection(
              icon: '⚖️',
              title: 'Poids du lot (kg)',
              child: TextField(
                controller: _poidsCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                decoration: InputDecoration(
                  hintText: 'Ex.: 50',
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
            ),

            const SizedBox(height: 12),

            // Type de culture
            _FormSection(
              icon: '🌿',
              title: 'Type de culture',
              child: Row(
                children: _cultures.map((c) {
                  final selected = c == _selectedCulture;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCulture = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primaryGreen : AppColors.backgroundGreen,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected ? AppColors.primaryGreen : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        c,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textMedium,
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // Date de récolte
            _FormSection(
              icon: '📅',
              title: 'Date de récolte',
              child: TextField(
                controller: _dateCtrl,
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryGreen),
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
            ),

            const SizedBox(height: 28),

            GestureDetector(
              onTap: _loading ? null : _submitLot,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.brown,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brownDark.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save_outlined, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Enregistrer le lot',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String icon;
  final String title;
  final Widget child;

  const _FormSection({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
