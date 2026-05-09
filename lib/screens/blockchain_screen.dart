import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';
import '../services/blockchain_service.dart';
import '../screens/payment_screen.dart';
import '../services/payment_service.dart';

class BlockchainScreen extends StatefulWidget {
  const BlockchainScreen({super.key});
  @override State<BlockchainScreen> createState() => _BlockchainState();
}

class _BlockchainState extends State<BlockchainScreen> with TickerProviderStateMixin {
  late TabController _tab;
  bool _loadingRegister = false;
  bool _loadingVerify   = false;
  final _verifyCtrl = TextEditingController();
  VerificationResult? _verifyResult;
  String? _registeredLotId;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose(); _verifyCtrl.dispose(); super.dispose();
  }

  void _registerLot(LotModel lot) async {
    setState(() { _loadingRegister = true; _registeredLotId = lot.lotId; });
    final record = await PolygonService.registerLot(
      lotId: lot.lotId,
      agriculteur: lot.agriculteurNom,
      culture: lot.culture,
      poids: lot.poids,
      region: lot.region,
      dateRecolte: lot.dateRecolte,
      certifications: lot.certifications,
    );
    lot.blockchainRecord = record;
    setState(() { _loadingRegister = false; _registeredLotId = null; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✓ ${lot.lotId} enregistré sur Polygon !'),
        backgroundColor: GS.polygon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _verifyHash() async {
    if (_verifyCtrl.text.trim().isEmpty) return;
    setState(() { _loadingVerify = true; _verifyResult = null; });
    final result = await PolygonService.verifyHash(_verifyCtrl.text.trim());
    setState(() { _loadingVerify = false; _verifyResult = result; });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label copié !'),
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      backgroundColor: GS.polygon,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    final wallet = AppState.user?.wallet;

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
        title: Row(children: [
          Container(width: 28, height: 28,
            decoration: BoxDecoration(color: GS.polygon, borderRadius: BorderRadius.circular(8)),
            child: const Center(child: Text('⬡', style: TextStyle(fontSize: 14)))),
          const SizedBox(width: 8),
          Text('Blockchain Polygon',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: gs.textDark)),
        ]),
        bottom: TabBar(
          controller: _tab,
          labelColor: GS.polygon,
          unselectedLabelColor: gs.textLight,
          indicatorColor: GS.polygon,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Wallet'),
            Tab(text: 'Lots'),
            Tab(text: 'Vérifier'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _WalletTab(wallet: wallet, gs: gs, onCopy: _copyToClipboard),
          _LotsTab(lots: AppState.lots, loading: _loadingRegister,
            registeredId: _registeredLotId, onRegister: _registerLot, gs: gs, onCopy: _copyToClipboard),
          _VerifyTab(ctrl: _verifyCtrl, loading: _loadingVerify,
            result: _verifyResult, onVerify: _verifyHash, gs: gs),
        ],
      ),
    );
  }
}

// ── Wallet Tab ─────────────────────────────────────────────────────────────
class _WalletTab extends StatelessWidget {
  final PolygonWallet? wallet;
  final GSColors gs;
  final Function(String, String) onCopy;
  const _WalletTab({required this.wallet, required this.gs, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Wallet Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8247E5), Color(0xFF6B35C9)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: GS.polygon.withOpacity(0.4), blurRadius: 16, offset: const Offset(0,6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('POLYGON WALLET', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 2)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Mumbai Testnet', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ]),
                const SizedBox(height: 20),
                // Adresse
                GestureDetector(
                  onTap: () => onCopy(wallet?.address ?? '', 'Adresse'),
                  child: Row(children: [
                    Expanded(child: Text(wallet?.shortAddress ?? '0x....',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1))),
                    const Icon(Icons.copy_rounded, color: Colors.white54, size: 16),
                  ]),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Solde MATIC', style: TextStyle(color: Colors.white60, fontSize: 10)),
                    Text('${wallet?.maticBalance.toStringAsFixed(4) ?? '0'} MATIC',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                  ]),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    const Text('Réseau', style: TextStyle(color: Colors.white60, fontSize: 10)),
                    const Text('Polygon', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  ]),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats blockchain
          Row(children: [
            _StatBox(label: 'Lots enregistrés',
              value: '${AppState.lots.where((l) => l.isOnBlockchain).length}',
              color: GS.polygon, icon: Icons.inventory_2_outlined, gs: gs),
            const SizedBox(width: 12),
            _StatBox(label: 'Transactions',
              value: '${wallet?.transactions.length ?? 0 + AppState.lots.where((l) => l.isOnBlockchain).length}',
              color: GS.greenPrimary, icon: Icons.swap_horiz_rounded, gs: gs),
          ]),
          const SizedBox(height: 20),

          // Lots avec blockchain
          Align(alignment: Alignment.centerLeft,
            child: Text('Lots sur Blockchain', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: gs.textDark))),
          const SizedBox(height: 12),
          ...AppState.lots.where((l) => l.isOnBlockchain).map((lot) =>
            _BlockchainLotTile(lot: lot, gs: gs, onCopy: onCopy)),

          if (AppState.lots.where((l) => l.isOnBlockchain).isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Column(children: [
                const Text('⬡', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text('Aucun lot sur la blockchain', style: TextStyle(color: gs.textLight, fontSize: 13)),
                Text('Enregistrez vos lots dans l\'onglet Lots', style: TextStyle(color: gs.textLight, fontSize: 11)),
              ])),
            ),
        ],
      ),
    );
  }
}

// ── Lots Tab ───────────────────────────────────────────────────────────────
class _LotsTab extends StatelessWidget {
  final List<LotModel> lots;
  final bool loading;
  final String? registeredId;
  final Function(LotModel) onRegister;
  final GSColors gs;
  final Function(String, String) onCopy;
  const _LotsTab({required this.lots, required this.loading, required this.registeredId,
    required this.onRegister, required this.gs, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GS.polygon.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GS.polygon.withOpacity(0.25)),
            ),
            child: Row(children: [
              const Text('⬡', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(child: Text(
                'Chaque lot enregistré sur Polygon reçoit un hash unique et immuable qui garantit son authenticité.',
                style: TextStyle(fontSize: 12, color: gs.textMed, height: 1.4))),
            ]),
          ),
          const SizedBox(height: 16),
          Text('Tous les lots', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: gs.textDark)),
          const SizedBox(height: 12),
          ...lots.map((lot) {
            final isThis = loading && registeredId == lot.lotId;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: gs.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: lot.isOnBlockchain
                    ? GS.polygon.withOpacity(0.3) : gs.divider.withOpacity(0.5)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5, offset: const Offset(0,2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(lot.lotId,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gs.textDark)),
                    if (lot.isOnBlockchain)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: GS.polygon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: GS.polygon.withOpacity(0.35)),
                        ),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('⬡', style: TextStyle(fontSize: 10)),
                          SizedBox(width: 4),
                          Text('Sur Polygon', style: TextStyle(color: GS.polygon, fontSize: 10, fontWeight: FontWeight.w700)),
                        ]),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(color: gs.inputFill, borderRadius: BorderRadius.circular(20)),
                        child: Text('Non enregistré', style: TextStyle(fontSize: 10, color: gs.textLight)),
                      ),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    _chip(lot.culture, gs), const SizedBox(width: 8),
                    _chip('${lot.poids.toInt()} kg', gs), const SizedBox(width: 8),
                    _chip(lot.region, gs),
                  ]),
                  if (lot.isOnBlockchain) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => onCopy(lot.blockchainRecord!.txHash, 'Hash TX'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: GS.polygon.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          const Icon(Icons.link_rounded, color: GS.polygon, size: 14),
                          const SizedBox(width: 6),
                          Expanded(child: Text(
                            _short(lot.blockchainRecord!.txHash),
                            style: const TextStyle(fontSize: 11, color: GS.polygon, fontFamily: 'monospace'))),
                          const Icon(Icons.copy_rounded, color: GS.polygon, size: 12),
                        ]),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: isThis ? null : () => onRegister(lot),
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: isThis ? GS.polygon.withOpacity(0.3) : GS.polygon,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          child: isThis
                              ? const Row(mainAxisSize: MainAxisSize.min, children: [
                                  SizedBox(width: 16, height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                  SizedBox(width: 8),
                                  Text('Enregistrement...', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                ])
                              : const Row(mainAxisSize: MainAxisSize.min, children: [
                                  Text('⬡', style: TextStyle(fontSize: 14)),
                                  SizedBox(width: 6),
                                  Text('Enregistrer sur Polygon', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                ]),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _chip(String t, GSColors gs) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: gs.inputFill, borderRadius: BorderRadius.circular(6)),
    child: Text(t, style: TextStyle(fontSize: 10, color: gs.textMed)),
  );
  String _short(String h) => h.length > 20 ? '${h.substring(0,12)}...${h.substring(h.length-8)}' : h;
}

// ── Verify Tab ─────────────────────────────────────────────────────────────
class _VerifyTab extends StatelessWidget {
  final TextEditingController ctrl;
  final bool loading;
  final VerificationResult? result;
  final VoidCallback onVerify;
  final GSColors gs;
  const _VerifyTab({required this.ctrl, required this.loading, required this.result,
    required this.onVerify, required this.gs});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0,2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hash ou TX à vérifier', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gs.textDark)),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                style: TextStyle(fontSize: 12, color: gs.textDark, fontFamily: 'monospace'),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: '0x7d8f2a1b3c4e5f6a...',
                  hintStyle: TextStyle(color: gs.textLight, fontSize: 12),
                  filled: true, fillColor: gs.inputFill,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: loading ? null : onVerify,
                child: Container(
                  width: double.infinity, height: 48,
                  decoration: BoxDecoration(
                    color: GS.polygon,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: GS.polygon.withOpacity(0.35), blurRadius: 8, offset: const Offset(0,3))],
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('⬡', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text('Vérifier sur Polygon', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                          ]),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          if (result != null) _VerifyResultCard(result: result!, gs: gs),

          // Lots avec blockchain pour vérification rapide
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerLeft,
            child: Text('Vérification rapide', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: gs.textDark))),
          const SizedBox(height: 10),
          ...AppState.lots.where((l) => l.isOnBlockchain).map((lot) => GestureDetector(
            onTap: () {
              ctrl.text = lot.blockchainRecord!.txHash;
              onVerify();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GS.polygon.withOpacity(0.2))),
              child: Row(children: [
                const Text('⬡', style: TextStyle(fontSize: 16, color: GS.polygon)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(lot.lotId, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: gs.textDark)),
                  Text(_short(lot.blockchainRecord!.txHash),
                    style: const TextStyle(fontSize: 10, color: GS.polygon, fontFamily: 'monospace')),
                ])),
                Icon(Icons.arrow_forward_ios_rounded, size: 12, color: gs.textLight),
              ]),
            ),
          )),
        ],
      ),
    );
  }
  String _short(String h) => h.length > 20 ? '${h.substring(0,14)}...${h.substring(h.length-6)}' : h;
}

class _VerifyResultCard extends StatelessWidget {
  final VerificationResult result;
  final GSColors gs;
  const _VerifyResultCard({required this.result, required this.gs});

  @override
  Widget build(BuildContext context) {
    final color = result.isValid ? GS.statusOk : GS.statusBad;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(result.isValid ? Icons.verified_rounded : Icons.cancel_rounded, color: color, size: 22),
          const SizedBox(width: 10),
          Text(result.isValid ? 'Hash valide ✓' : 'Hash invalide ✗',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        ]),
        const SizedBox(height: 12),
        _row('Réseau', result.network, gs),
        _row('Confiance', '${result.confidence}%', gs),
        _row('Vérifié le', '${result.verifiedAt.day}/${result.verifiedAt.month}/${result.verifiedAt.year} à ${result.verifiedAt.hour}:${result.verifiedAt.minute.toString().padLeft(2,'0')}', gs),
      ]),
    );
  }
  Widget _row(String k, String v, GSColors gs) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      SizedBox(width: 90, child: Text(k, style: TextStyle(fontSize: 11, color: gs.textLight))),
      Text(v, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: gs.textDark)),
    ]),
  );
}

class _BlockchainLotTile extends StatelessWidget {
  final LotModel lot;
  final GSColors gs;
  final Function(String, String) onCopy;
  const _BlockchainLotTile({required this.lot, required this.gs, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final r = lot.blockchainRecord!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: gs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GS.polygon.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(lot.lotId, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gs.textDark)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: GS.statusOk.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: GS.statusOk.withOpacity(0.3))),
            child: const Text('Confirmé', style: TextStyle(color: GS.statusOk, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 8),
        _hashRow('TX Hash', r.txHash, gs),
        _hashRow('Bloc #', '${r.blockNumber}', gs),
        _hashRow('Réseau', r.network, gs),
        _hashRow('Date', '${r.timestamp.day}/${r.timestamp.month}/${r.timestamp.year}', gs),
      ]),
    );
  }
  Widget _hashRow(String k, String v, GSColors gs) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      SizedBox(width: 70, child: Text(k, style: TextStyle(fontSize: 10, color: gs.textLight))),
      Expanded(child: Text(v.length > 22 ? '${v.substring(0,12)}...${v.substring(v.length-8)}' : v,
        style: const TextStyle(fontSize: 10, color: GS.polygon, fontFamily: 'monospace'))),
    ]),
  );
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  final GSColors gs;
  const _StatBox({required this.label, required this.value, required this.color,
    required this.icon, required this.gs});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0,2))]),
      child: Row(children: [
        Container(width: 38, height: 38,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 9, color: gs.textLight)),
        ]),
      ]),
    ),
  );
}
