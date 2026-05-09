import 'package:flutter/material.dart';
import '../theme/gs_theme.dart';
import '../widgets/role_guard.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class VerificateurScreen extends StatelessWidget {
  const VerificateurScreen({super.key});
  @override
  Widget build(BuildContext context) => RoleGuard(
        required: UserRole.verificateur,
        child: const _VerifBody(),
      );
}

class _VerifBody extends StatefulWidget {
  const _VerifBody();
  @override
  State<_VerifBody> createState() => _VerifBodyState();
}

class _VerifBodyState extends State<_VerifBody> {
  final _ctrl = TextEditingController();
  LotModel? _lot;
  bool _notFound = false;
  bool _scanMode = false;
  bool _scanning = false;
  final List<String> _selectedCerts = [];
  final List<String> _allCerts = [
    'Bio',
    'Fair Trade',
    'Rainforest Alliance',
    'UTZ'
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _search() {
    final q = _ctrl.text.trim().toUpperCase();
    final found = AppState.lots
        .where((l) => l.lotId.toUpperCase().contains(q))
        .firstOrNull;
    setState(() {
      _lot = found;
      _notFound = found == null && q.isNotEmpty;
    });
  }

  void _scan() async {
    setState(() {
      _scanMode = true;
      _scanning = true;
      _lot = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    final lot = AppState.lots.firstOrNull;
    setState(() {
      _scanning = false;
      _lot = lot;
      if (lot != null) _ctrl.text = lot.lotId;
    });
  }

  void _cancelScan() => setState(() {
        _scanMode = false;
        _scanning = false;
      });

  void _addCerts() {
    if (_lot == null || _selectedCerts.isEmpty) return;
    setState(() {
      for (final c in _selectedCerts) {
        if (!_lot!.certifications.contains(c)) {
          _lot!.certifications = [..._lot!.certifications, c];
        }
      }
      _lot!.status = LotStatus.verifie;
      _selectedCerts.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Certifications ajoutées avec succès ✓'),
      backgroundColor: GS.statusOk,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageBanner(
            emoji: '🔍',
            title: 'Vérification Traçabilité',
            subtitle: "Scannez le QR code ou entrez l'ID du lot",
          ),
          const SizedBox(height: 16),

          // Recherche
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: gs.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: GS.greenDark.withOpacity(0.06),
                    blurRadius: 5,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID du lot',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: gs.textDark)),
                const SizedBox(height: 10),
                GSInput(
                    ctrl: _ctrl, hint: 'LOT-TG-2026-XXXX', fillColor: gs.bg),
                const SizedBox(height: 10),
                GSBtn(
                    label: 'Rechercher',
                    icon: Icons.search_rounded,
                    onTap: _search),
                const SizedBox(height: 10),
                GSBtn(
                  label: _scanMode ? 'Mode scan actif' : 'Scanner un QR Code',
                  icon: Icons.qr_code_scanner,
                  bg: _scanMode ? GS.statusOk : GS.greenDark,
                  onTap: _scanMode ? _cancelScan : _scan,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Vue caméra QR
          if (_scanMode)
            Container(
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GS.statusBad.withOpacity(0.2)),
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
                                  border: Border.all(
                                      color: GS.greenPrimary, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                    child: Icon(Icons.camera_alt_outlined,
                                        size: 38, color: GS.greenPrimary)),
                              ),
                              const SizedBox(height: 10),
                              Text('Positionnez le QR code...',
                                  style: TextStyle(
                                      color: gs.textMed, fontSize: 12)),
                            ],
                          )
                        : Icon(Icons.qr_code_2_rounded,
                            size: 80, color: gs.textLight),
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
                            color: gs.surface.withOpacity(0.8),
                            shape: BoxShape.circle),
                        child: Icon(Icons.close, size: 18, color: gs.textDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Lot non trouvé
          if (_notFound)
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: GS.statusBad.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GS.statusBad.withOpacity(0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.error_outline, color: GS.statusBad, size: 20),
                  SizedBox(width: 10),
                  Text("Lot introuvable. Vérifiez l'ID.",
                      style: TextStyle(color: GS.statusBad, fontSize: 13)),
                ],
              ),
            ),

          // Lot trouvé
          if (_lot != null) ...[
            const SizedBox(height: 12),
            _LotDetail(lot: _lot!),
            const SizedBox(height: 12),
            _CertsSection(
              lot: _lot!,
              allCerts: _allCerts,
              selected: _selectedCerts,
              onToggle: (c) => setState(() {
                _selectedCerts.contains(c)
                    ? _selectedCerts.remove(c)
                    : _selectedCerts.add(c);
              }),
              onAdd: _addCerts,
            ),
          ],
        ],
      ),
    );
  }
}

class _LotDetail extends StatelessWidget {
  final LotModel lot;
  const _LotDetail({super.key, required this.lot});

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GS.statusOk.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: GS.greenDark.withOpacity(0.06),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lot.lotId,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: gs.textDark)),
              StatusBadge(status: lot.status),
            ],
          ),
          const Divider(height: 20, color: GS.divider),
          Row(children: [
            _D(gs, 'Agriculteur', lot.agriculteurNom),
            const SizedBox(width: 20),
            _D(gs, 'Région', lot.region),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _D(gs, 'Poids', '${lot.poids.toInt()} kg'),
            const SizedBox(width: 20),
            _D(gs, 'Culture', lot.culture),
            const SizedBox(width: 20),
            _D(gs, 'Récolte',
                '${lot.dateRecolte.day}/${lot.dateRecolte.month}'),
          ]),
          if (lot.certifications.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: lot.certifications
                  .map((c) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: gs.greenBg,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: GS.greenLight.withOpacity(0.4)),
                        ),
                        child: Text(c,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: GS.greenDark)),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _D(GSColors gs, String label, String val) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: gs.textLight)),
          Text(val,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: gs.textMed)),
        ],
      );
}

class _CertsSection extends StatelessWidget {
  final LotModel lot;
  final List<String> allCerts, selected;
  final Function(String) onToggle;
  final VoidCallback onAdd;
  const _CertsSection(
      {super.key,
      required this.lot,
      required this.allCerts,
      required this.selected,
      required this.onToggle,
      required this.onAdd});

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
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('🏆', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text('Certifications disponibles',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: gs.textDark)),
          ]),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: allCerts.map((cert) {
              final isSel = selected.contains(cert);
              final hasIt = lot.certifications.contains(cert);
              return GestureDetector(
                onTap: hasIt ? null : () => onToggle(cert),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: hasIt
                        ? GS.statusOk.withOpacity(0.1)
                        : isSel
                            ? GS.greenPrimary.withOpacity(0.1)
                            : gs.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: hasIt
                            ? GS.statusOk
                            : isSel
                                ? GS.greenPrimary
                                : GS.divider),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          hasIt
                              ? Icons.check_circle
                              : isSel
                                  ? Icons.check_circle_outline
                                  : Icons.circle_outlined,
                          size: 15,
                          color: hasIt
                              ? GS.statusOk
                              : isSel
                                  ? GS.greenPrimary
                                  : gs.textLight),
                      const SizedBox(width: 6),
                      Text(cert,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: hasIt
                                  ? GS.statusOk
                                  : isSel
                                      ? GS.greenPrimary
                                      : gs.textMed)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          GSBtn(
              label: 'Ajouter les certifications',
              icon: Icons.add_circle_outline,
              onTap: onAdd),
        ],
      ),
    );
  }
}
