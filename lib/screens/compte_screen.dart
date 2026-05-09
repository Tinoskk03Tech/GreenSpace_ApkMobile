import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';
import '../services/payment_service.dart';
import '../widgets/gs_logo_widget.dart';
import 'auth_screens.dart';
import 'payment_screen.dart';

class CompteScreen extends StatefulWidget {
  const CompteScreen({super.key});
  @override State<CompteScreen> createState() => _CompteState();
}

class _CompteState extends State<CompteScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _editMode = false;
  late TextEditingController _prenomC, _nomC, _emailC, _telC, _regionC;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    final u = AppState.user;
    _prenomC  = TextEditingController(text: u?.prenom ?? '');
    _nomC     = TextEditingController(text: u?.nom ?? '');
    _emailC   = TextEditingController(text: u?.email ?? '');
    _telC     = TextEditingController(text: u?.telephone ?? '');
    _regionC  = TextEditingController(text: u?.region ?? '');
  }

  @override
  void dispose() {
    _tab.dispose();
    _prenomC.dispose(); _nomC.dispose(); _emailC.dispose();
    _telC.dispose(); _regionC.dispose();
    super.dispose();
  }

  void _save() {
    final u = AppState.user;
    if (u == null) return;
    setState(() {
      u.prenom = _prenomC.text; u.nom = _nomC.text;
      u.email  = _emailC.text; u.telephone = _telC.text;
      u.region = _regionC.text; _editMode = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(context.read<AppProvider>().t('save_changes')),
      backgroundColor: GS.statusOk,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _logout() {
    final gs  = context.gs;
    final app = context.read<AppProvider>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: gs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(app.t('logout'),
          style: TextStyle(fontWeight: FontWeight.w800, color: gs.textDark)),
        content: Text('Voulez-vous vraiment vous déconnecter ?',
          style: TextStyle(color: gs.textMed)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: Text(app.t('cancel'), style: TextStyle(color: gs.textMed))),
          ElevatedButton(
            onPressed: () {
              AppState.user = null;
              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()), (_) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: GS.statusBad,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(app.t('logout'), style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs  = context.gs;
    final app = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: gs.bg,
      appBar: AppBar(
        backgroundColor: gs.bg, elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 4)]),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: gs.textDark))),
        title: Text(app.t('my_account'),
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: gs.textDark)),
        actions: [
          // Toggle dark/light
          GestureDetector(
            onTap: app.toggleTheme,
            child: Container(
              margin: const EdgeInsets.only(right: 8), width: 38, height: 38,
              decoration: BoxDecoration(
                color: app.isDark ? GS.gold.withOpacity(0.15) : gs.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 4)]),
              child: Icon(
                app.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: app.isDark ? GS.gold : gs.textDark, size: 20))),
          GestureDetector(
            onTap: () => setState(() => _editMode = !_editMode),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _editMode ? gs.greenAccent : gs.greenBg,
                borderRadius: BorderRadius.circular(20)),
              child: Text(_editMode ? app.t('cancel') : app.t('edit'),
                style: TextStyle(
                  color: _editMode ? Colors.white : gs.greenAccent,
                  fontSize: 13, fontWeight: FontWeight.w700)))),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: gs.greenAccent,
          unselectedLabelColor: gs.textLight,
          indicatorColor: gs.greenAccent,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: app.t('my_profile')),
            Tab(text: app.t('payments')),
            Tab(text: app.t('settings')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ProfileTab(gs: gs, app: app, editMode: _editMode,
            pc: _prenomC, nc: _nomC, ec: _emailC, tc: _telC, rc: _regionC,
            onSave: _save, onLogout: _logout),
          _PaymentsTab(gs: gs, app: app),
          _SettingsTab(gs: gs, app: app, onLogout: _logout),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ONGLET PROFIL
// ══════════════════════════════════════════════════════════════════════════
class _ProfileTab extends StatelessWidget {
  final GSColors gs; final AppProvider app; final bool editMode;
  final TextEditingController pc, nc, ec, tc, rc;
  final VoidCallback onSave, onLogout;
  const _ProfileTab({required this.gs, required this.app, required this.editMode,
    required this.pc, required this.nc, required this.ec,
    required this.tc, required this.rc, required this.onSave, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final user = AppState.user;
    final myLots    = AppState.lots.length;
    final verifLots = AppState.lots.where((l) => l.status == LotStatus.verifie).length;
    final expLots   = AppState.lots.where((l) => l.status == LotStatus.exporte).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(children: [
        // Avatar card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 10, offset: const Offset(0,3))]),
          child: Column(children: [
            Stack(children: [
              Container(width: 88, height: 88,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [GS.greenMid, GS.greenDark],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: GS.greenDark.withOpacity(0.3), blurRadius: 12, offset: const Offset(0,4))]),
                child: Center(child: Text(user?.initials ?? 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)))),
              Positioned(bottom: 0, right: 0,
                child: Container(width: 28, height: 28,
                  decoration: BoxDecoration(color: GS.brown, shape: BoxShape.circle,
                    border: Border.all(color: gs.surface, width: 2)),
                  child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white))),
            ]),
            const SizedBox(height: 14),
            Text(user?.fullName ?? '',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: gs.textDark)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: gs.greenBg, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(user?.role.icon ?? '', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(user?.role.label ?? '',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gs.greenAccent)),
              ])),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: TextStyle(fontSize: 12, color: gs.textLight)),
            // Wallet Polygon
            if (user?.wallet != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: GS.polygon.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GS.polygon.withOpacity(0.25))),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Text('⬡', style: TextStyle(fontSize: 14, color: GS.polygon)),
                  const SizedBox(width: 6),
                  Text(user!.wallet!.shortAddress,
                    style: const TextStyle(fontSize: 12, color: GS.polygon, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text('${user.wallet!.maticBalance.toStringAsFixed(2)} MATIC',
                    style: TextStyle(fontSize: 11, color: gs.textLight)),
                ])),
            ],
          ]),
        ),
        const SizedBox(height: 16),

        // Stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 6, offset: const Offset(0,2))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Mes statistiques',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: gs.textDark)),
            const SizedBox(height: 14),
            Row(children: [
              _St(app.t('lots'), '$myLots', GS.greenPrimary, gs),
              _St(app.t('verified'), '$verifLots', GS.statusOk, gs),
              _St(app.t('exported'), '$expLots', GS.brown, gs),
            ]),
          ]),
        ),
        const SizedBox(height: 16),

        // Formulaire infos
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 6, offset: const Offset(0,2))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Informations personnelles',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: gs.textDark)),
            const SizedBox(height: 16),
            _F('Prénom',    pc, Icons.person_outline,     editMode, gs),
            _F('Nom',       nc, Icons.badge_outlined,      editMode, gs),
            _F('Email',     ec, Icons.email_outlined,      editMode, gs, t: TextInputType.emailAddress),
            _F('Téléphone', tc, Icons.phone_outlined,      editMode, gs, t: TextInputType.phone),
            _F('Région',    rc, Icons.location_on_outlined, editMode, gs),
            // ID non modifiable
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Identifiant', style: TextStyle(fontSize: 11, color: gs.textLight, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: gs.greenBg, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Icon(Icons.fingerprint_rounded, size: 18, color: gs.greenAccent),
                  const SizedBox(width: 10),
                  Text('GS-${AppState.user?.id ?? "0001"}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gs.greenAccent)),
                  const Spacer(),
                  Text('Non modifiable', style: TextStyle(fontSize: 10, color: gs.textLight)),
                ])),
            ]),
            if (editMode) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onSave,
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(color: gs.greenAccent, borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: gs.greenAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0,3))]),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.save_rounded, color: Colors.white, size: 18), const SizedBox(width: 8),
                    Text(app.t('save_changes'), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                  ]))),
            ],
          ]),
        ),
        const SizedBox(height: 16),

        // Déconnexion
        GestureDetector(
          onTap: onLogout,
          child: Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(
              color: GS.statusBad.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GS.statusBad.withOpacity(0.3))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.logout_rounded, color: GS.statusBad, size: 20), const SizedBox(width: 10),
              Text(app.t('logout'), style: const TextStyle(color: GS.statusBad, fontSize: 15, fontWeight: FontWeight.w700)),
            ]))),
      ]),
    );
  }

  Widget _St(String l, String v, Color c, GSColors gs) => Expanded(
    child: Container(margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: c.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(v, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c)),
        Text(l, style: TextStyle(fontSize: 10, color: gs.textLight), textAlign: TextAlign.center),
      ])));

  Widget _F(String label, TextEditingController ctrl, IconData icon, bool enabled, GSColors gs, {TextInputType? t}) =>
    Padding(padding: const EdgeInsets.only(bottom: 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11, color: gs.textLight, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(controller: ctrl, enabled: enabled, keyboardType: t,
        style: TextStyle(fontSize: 14, color: gs.textDark),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: enabled ? gs.greenAccent : gs.textLight),
          filled: true, fillColor: enabled ? gs.surface : gs.inputFill,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: gs.greenAccent, width: 1.5)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
    ]));
}

// ══════════════════════════════════════════════════════════════════════════
// ONGLET PAIEMENTS
// ══════════════════════════════════════════════════════════════════════════
class _PaymentsTab extends StatelessWidget {
  final GSColors gs; final AppProvider app;
  const _PaymentsTab({required this.gs, required this.app});

  @override
  Widget build(BuildContext context) {
    final history = PaymentService.history;
    final total   = PaymentService.totalPaid;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Total card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [GS.brown, GS.brownDark],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: GS.brownDark.withOpacity(0.35), blurRadius: 12, offset: const Offset(0,5))]),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total payé', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text('${total.toStringAsFixed(0)} XOF',
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
              Text('${history.where((t) => t.status == PaymentStatus.success).length} transactions confirmées',
                style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ])),
            Container(width: 50, height: 50,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 26)),
          ])),
        const SizedBox(height: 16),

        // Bouton nouveau paiement
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>
            const PaymentScreen(type: PaymentType.subscription, description: 'Abonnement GreenSpace'))),
          child: Container(
            width: double.infinity, height: 50,
            decoration: BoxDecoration(color: gs.greenAccent, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: gs.greenAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0,3))]),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 20), SizedBox(width: 8),
              Text('Effectuer un paiement', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ]))),
        const SizedBox(height: 20),

        Text(app.t('payments'),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: gs.textDark)),
        const SizedBox(height: 12),

        if (history.isEmpty)
          Container(padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(14)),
            child: Center(child: Column(children: [
              Icon(Icons.receipt_long_outlined, size: 40, color: gs.textLight),
              const SizedBox(height: 8),
              Text('Aucune transaction', style: TextStyle(color: gs.textLight, fontSize: 13)),
            ])))
        else
          ...history.map((tx) => _TxTile(tx: tx, gs: gs)),
      ]),
    );
  }
}

class _TxTile extends StatelessWidget {
  final PaymentTransaction tx; final GSColors gs;
  const _TxTile({required this.tx, required this.gs});
  Color get sc => switch(tx.status) {
    PaymentStatus.success    => GS.statusOk,
    PaymentStatus.failed     => GS.statusBad,
    PaymentStatus.pending    => GS.statusWait,
    PaymentStatus.processing => GS.statusNew,
    _                        => GS.polygon,
  };
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: gs.divider.withOpacity(0.5)),
      boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 5, offset: const Offset(0,2))]),
    child: Row(children: [
      Container(width: 44, height: 44,
        decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(tx.method.logo, style: const TextStyle(fontSize: 22)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tx.type.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gs.textDark)),
        Text('${tx.reference} · ${tx.method.label}', style: TextStyle(fontSize: 11, color: gs.textLight)),
        if (tx.lotId != null) Text(tx.lotId!, style: TextStyle(fontSize: 10, color: gs.greenAccent.withOpacity(0.8))),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(tx.formattedAmount, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: sc)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(tx.statusLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: sc))),
      ]),
    ]));
}

// ══════════════════════════════════════════════════════════════════════════
// ONGLET PARAMÈTRES — Dark/Light + Langue + Notifications
// ══════════════════════════════════════════════════════════════════════════
class _SettingsTab extends StatelessWidget {
  final GSColors gs; final AppProvider app; final VoidCallback onLogout;
  const _SettingsTab({required this.gs, required this.app, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Apparence ───────────────────────────────────────────────────
        _Section(gs: gs, title: app.t('appearance'), children: [
          _ThemeToggle(gs: gs, app: app),
        ]),
        const SizedBox(height: 14),

        // ── Langue ──────────────────────────────────────────────────────
        _Section(gs: gs, title: app.t('language'), children: [
          _LangSelector(gs: gs, app: app),
        ]),
        const SizedBox(height: 14),

        // ── Notifications ────────────────────────────────────────────────
        _Section(gs: gs, title: app.t('notifications'), children: [
          _NotifToggle(gs: gs, app: app),
        ]),
        const SizedBox(height: 14),

        // ── Autres ──────────────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 6, offset: const Offset(0,2))]),
          child: Column(children: [
            _STile(icon: Icons.security_outlined, label: app.t('security'), gs: gs),
            Divider(height: 1, indent: 56, endIndent: 16, color: gs.divider),
            _STile(icon: Icons.account_balance_wallet_outlined, label: 'Wallet Polygon',
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('⬡', style: TextStyle(color: GS.polygon, fontSize: 14)), const SizedBox(width: 4),
                Text(AppState.user?.wallet?.shortAddress ?? '0x...',
                  style: const TextStyle(fontSize: 11, color: GS.polygon)),
              ]), gs: gs),
            Divider(height: 1, indent: 56, endIndent: 16, color: gs.divider),
            _STile(icon: Icons.help_outline_rounded, label: app.t('help'), gs: gs),
            Divider(height: 1, indent: 56, endIndent: 16, color: gs.divider),
            _STile(icon: Icons.info_outline_rounded, label: app.t('about'),
              trailing: Text('v2.0.0', style: TextStyle(fontSize: 12, color: gs.textLight)), gs: gs),
          ])),
        const SizedBox(height: 16),

        // Déconnexion
        GestureDetector(
          onTap: onLogout,
          child: Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(
              color: GS.statusBad.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GS.statusBad.withOpacity(0.3))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.logout_rounded, color: GS.statusBad, size: 20), const SizedBox(width: 10),
              Text(app.t('logout'), style: const TextStyle(color: GS.statusBad, fontSize: 15, fontWeight: FontWeight.w700)),
            ]))),
      ]),
    );
  }
}

// ── Toggle Dark / Light ────────────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  final GSColors gs; final AppProvider app;
  const _ThemeToggle({required this.gs, required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: app.toggleTheme,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: app.isDark
                ? [const Color(0xFF1A2E1A), const Color(0xFF243024)]
                : [const Color(0xFFE8F5E9), const Color(0xFFD4EAD0)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: app.isDark ? GS.gold.withOpacity(0.35) : GS.greenPrimary.withOpacity(0.3))),
        child: Row(children: [
          // Icône animée
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(app.isDark),
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: app.isDark ? const Color(0xFF0D1A0D) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
              child: Icon(
                app.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: app.isDark ? GS.gold : GS.greenPrimary, size: 26))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.isDark ? app.t('dark_mode') : app.t('light_mode'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                color: app.isDark ? GS.gold : GS.greenPrimary)),
            Text(app.isDark ? app.t('dark_mode_on') : app.t('light_mode_on'),
              style: TextStyle(fontSize: 11, color: gs.textLight)),
          ])),
          // Toggle switch animé
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            width: 56, height: 30,
            decoration: BoxDecoration(
              color: app.isDark ? GS.gold : GS.greenPrimary,
              borderRadius: BorderRadius.circular(15)),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: app.isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24, height: 24, margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)])
              ))),
        ]),
      ),
    );
  }
}

// ── Sélecteur de langue ────────────────────────────────────────────────────
class _LangSelector extends StatelessWidget {
  final GSColors gs; final AppProvider app;
  const _LangSelector({required this.gs, required this.app});

  @override
  Widget build(BuildContext context) {
    final langs = [
      (AppLang.fr,  '🇫🇷', 'Français'),
      (AppLang.en,  '🇬🇧', 'English'),
      (AppLang.ewe, '🇹🇬', 'Ewe'),
    ];

    return Row(children: langs.map((item) {
      final (lang, flag, name) = item;
      final sel = app.lang == lang;
      return Expanded(
        child: GestureDetector(
          onTap: () => app.setLang(lang),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: sel ? gs.greenAccent : gs.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sel ? gs.greenAccent : gs.divider),
              boxShadow: sel ? [BoxShadow(color: gs.greenAccent.withOpacity(0.25), blurRadius: 6, offset: const Offset(0,2))] : null),
            child: Column(children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(name, style: TextStyle(
                fontSize: 11, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                color: sel ? Colors.white : gs.textMed)),
            ]),
          ),
        ),
      );
    }).toList());
  }
}

// ── Toggle Notifications ───────────────────────────────────────────────────
class _NotifToggle extends StatelessWidget {
  final GSColors gs; final AppProvider app;
  const _NotifToggle({required this.gs, required this.app});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: app.toggleNotifs,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: app.notifsOn ? gs.greenBg : gs.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: app.notifsOn ? gs.greenAccent.withOpacity(0.35) : gs.divider)),
        child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(
              color: app.notifsOn ? gs.greenAccent.withOpacity(0.15) : gs.divider.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12)),
            child: Icon(
              app.notifsOn ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
              color: app.notifsOn ? gs.greenAccent : gs.textLight, size: 24)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.t('notifications'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: gs.textDark)),
            Text(app.notifsOn ? 'Activées — vous recevrez des alertes' : 'Désactivées — aucune alerte',
              style: TextStyle(fontSize: 11, color: gs.textLight)),
          ])),
          // Switch
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 52, height: 28,
            decoration: BoxDecoration(
              color: app.notifsOn ? gs.greenAccent : gs.divider,
              borderRadius: BorderRadius.circular(14)),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220), curve: Curves.easeInOut,
              alignment: app.notifsOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(width: 22, height: 22, margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 3)])))),
        ]),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final GSColors gs; final String title; final List<Widget> children;
  const _Section({required this.gs, required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 6, offset: const Offset(0,2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: gs.textDark)),
      const SizedBox(height: 14),
      ...children,
    ]));
}

class _STile extends StatelessWidget {
  final IconData icon; final String label; final Widget? trailing; final GSColors gs;
  const _STile({required this.icon, required this.label, this.trailing, required this.gs});
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque, onTap: () {},
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(children: [
        Container(width: 36, height: 36,
          decoration: BoxDecoration(color: gs.greenBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: gs.greenAccent, size: 18)),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: gs.textDark))),
        trailing ?? Icon(Icons.chevron_right_rounded, color: gs.textLight, size: 20),
      ])));
}
