import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';
import '../widgets/role_guard.dart';

class AgriculteurScreen extends StatelessWidget {
  const AgriculteurScreen({super.key});
  @override
  Widget build(BuildContext context) => RoleGuard(
    required: UserRole.agriculteur,
    child: const _AgriculteurBody(),
  );
}

class _AgriculteurBody extends StatefulWidget {
  const _AgriculteurBody();
  @override State<_AgriculteurBody> createState() => _AgriBodyState();
}

class _AgriBodyState extends State<_AgriculteurBody> {
  final _poidsCtrl = TextEditingController();
  String  _culture  = 'Cacao';
  DateTime _date    = DateTime.now();
  String  _gps      = '';
  bool    _loadGps  = false;
  bool    _saving   = false;
  bool    _saved    = false;

  static const _cultures = ['Cacao', 'Café', 'Coton', 'Maïs'];

  @override void dispose() { _poidsCtrl.dispose(); super.dispose(); }

  // ── GPS réel via Geolocator (simulé sans plugin natif) ─────────────────
  Future<void> _getPosition() async {
    setState(() { _loadGps = true; _gps = ''; });
    // Simulation réaliste — en production: Geolocator.getCurrentPosition()
    await Future.delayed(const Duration(milliseconds: 1400));
    // Coordonnées de Lomé + légère variation aléatoire
    final lat  = 6.1375 + (DateTime.now().millisecond % 100) * 0.0001;
    final lng  = 1.2123 + (DateTime.now().microsecond % 100) * 0.0001;
    setState(() {
      _loadGps = false;
      _gps = '${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E\nLomé, Région Maritime, Togo';
    });
  }

  // ── Date picker popup ──────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: _localeFromLang(context.read<AppProvider>().lang),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: GS.greenPrimary,
            onPrimary: Colors.white,
            surface: ctx.gs.surface,
            onSurface: ctx.gs.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Locale _localeFromLang(AppLang l) {
    switch (l) {
      case AppLang.en:  return const Locale('en');
      case AppLang.ewe: return const Locale('fr'); // fallback
      default:          return const Locale('fr');
    }
  }

  Future<void> _save() async {
    if (_poidsCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<AppProvider>().t('lot_weight')),
        backgroundColor: GS.statusBad,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 1100));
    final lot = LotModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lotId: 'LOT-TG-${DateTime.now().year}-${(DateTime.now().millisecondsSinceEpoch % 9999).toString().padLeft(4, '0')}',
      culture: _culture,
      poids: double.tryParse(_poidsCtrl.text) ?? 0,
      region: AppState.user?.region ?? 'Maritime',
      agriculteurNom: AppState.user?.fullName ?? 'Agriculteur',
      dateRecolte: _date,
      status: LotStatus.nouveau,
    );
    AppState.lots.insert(0, lot);
    setState(() { _saving = false; _saved = true; _poidsCtrl.clear(); });
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _saved = false);
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final gs  = context.gs;
    final app = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Banner
        _Banner(gs: gs, emoji: '🌾',
          title: app.t('register_lot'), subtitle: app.t('ejok_trace')),
        const SizedBox(height: 16),

        // Succès
        if (_saved) _SuccessBanner(gs: gs, msg: app.t('lot_saved')),

        // ── Géolocalisation ──────────────────────────────────────────────
        _Card(gs: gs, icon: '📍', title: app.t('geolocation'), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GreenBtn(
              label: _loadGps ? '...' : app.t('get_position'),
              icon: Icons.my_location_rounded,
              loading: _loadGps,
              onTap: _getPosition,
            ),
            if (_gps.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: gs.greenBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: gs.greenAccent.withOpacity(0.3))),
                child: Row(children: [
                  Icon(Icons.location_on_rounded, color: gs.greenAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_gps,
                    style: TextStyle(fontSize: 12, color: gs.textMed, height: 1.4))),
                ]),
              ),
            ],
          ],
        )),
        const SizedBox(height: 12),

        // ── Poids ────────────────────────────────────────────────────────
        _Card(gs: gs, icon: '⚖️', title: app.t('lot_weight'), child:
          TextField(
            controller: _poidsCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(fontSize: 15, color: gs.textDark, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Ex : 50',
              hintStyle: TextStyle(color: gs.textLight, fontWeight: FontWeight.normal),
              suffixText: 'kg',
              suffixStyle: TextStyle(color: gs.textLight, fontWeight: FontWeight.w600),
              filled: true, fillColor: gs.inputFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: gs.greenAccent, width: 1.5)),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // ── Culture ──────────────────────────────────────────────────────
        _Card(gs: gs, icon: '🌿', title: app.t('culture_type'), child:
          Wrap(spacing: 10, runSpacing: 8,
            children: _cultures.map((c) {
              final sel = c == _culture;
              return GestureDetector(
                onTap: () => setState(() => _culture = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                  decoration: BoxDecoration(
                    color: sel ? gs.greenAccent : gs.inputFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? gs.greenAccent : gs.divider),
                    boxShadow: sel ? [BoxShadow(color: gs.greenAccent.withOpacity(0.25), blurRadius: 6, offset: const Offset(0,2))] : null,
                  ),
                  child: Text(c, style: TextStyle(
                    color: sel ? Colors.white : gs.textMed,
                    fontSize: 14,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400)),
                ),
              );
            }).toList()),
        ),
        const SizedBox(height: 12),

        // ── Date de récolte avec POPUP ───────────────────────────────────
        _Card(gs: gs, icon: '📅', title: app.t('harvest_date'), child:
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: gs.inputFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: gs.divider),
              ),
              child: Row(children: [
                Icon(Icons.calendar_today_rounded, color: gs.greenAccent, size: 20),
                const SizedBox(width: 12),
                Text(_formatDate(_date),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: gs.textDark)),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down_rounded, color: gs.textLight, size: 22),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── Bouton enregistrer ───────────────────────────────────────────
        GestureDetector(
          onTap: _saving ? null : _save,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity, height: 54,
            decoration: BoxDecoration(
              color: _saving ? GS.brown.withOpacity(0.7) : GS.brown,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                color: GS.brownDark.withOpacity(0.35),
                blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Center(
              child: _saving
                  ? const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.save_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(app.t('save_lot'),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ]),
            ),
          ),
        ),

        // ── Mes lots récents ─────────────────────────────────────────────
        const SizedBox(height: 28),
        _RecentLots(gs: gs, app: app),
      ]),
    );
  }
}

// ── Lots récents de l'agriculteur ─────────────────────────────────────────
class _RecentLots extends StatelessWidget {
  final GSColors gs;
  final AppProvider app;
  const _RecentLots({required this.gs, required this.app});

  @override
  Widget build(BuildContext context) {
    final myLots = AppState.lots
        .where((l) => l.agriculteurNom == AppState.user?.fullName)
        .take(5)
        .toList();
    if (myLots.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(app.t('all_lots'),
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: gs.textDark)),
      const SizedBox(height: 12),
      ...myLots.map((lot) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: gs.surface, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 6, offset: const Offset(0,2))]),
        child: Row(children: [
          Container(width: 42, height: 42,
            decoration: BoxDecoration(color: gs.greenBg, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(lot.culture == 'Cacao' ? '🍫' : '☕',
              style: const TextStyle(fontSize: 22)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lot.lotId, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: gs.textDark)),
            Text('${lot.poids.toInt()} kg · ${lot.region}',
              style: TextStyle(fontSize: 11, color: gs.textLight)),
          ])),
          _StatusBadge(status: lot.status),
        ]),
      )),
    ]);
  }
}

class _StatusBadge extends StatelessWidget {
  final LotStatus status;
  const _StatusBadge({required this.status});
  Color get color => switch(status) {
    LotStatus.nouveau          => GS.statusNew,
    LotStatus.enAttente        => GS.statusWait,
    LotStatus.verifie          => GS.statusOk,
    LotStatus.rejete           => GS.statusBad,
    LotStatus.enTransformation => GS.brown,
    LotStatus.exporte          => GS.greenDark,
  };
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.35))),
    child: Text(status.label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)));
}

// ── Widgets locaux réutilisables ──────────────────────────────────────────
class _Banner extends StatelessWidget {
  final GSColors gs; final String emoji, title, subtitle;
  const _Banner({required this.gs, required this.emoji, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: gs.surface, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 8, offset: const Offset(0,2))]),
    child: Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 30)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: gs.textDark)),
        Text(subtitle, style: TextStyle(fontSize: 12, color: gs.textLight)),
      ])),
    ]),
  );
}

class _SuccessBanner extends StatelessWidget {
  final GSColors gs; final String msg;
  const _SuccessBanner({required this.gs, required this.msg});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: GS.statusOk.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: GS.statusOk.withOpacity(0.35))),
    child: Row(children: [
      const Icon(Icons.check_circle_rounded, color: GS.statusOk, size: 20),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: const TextStyle(color: GS.statusOk, fontWeight: FontWeight.w600, fontSize: 13))),
    ]),
  );
}

class _Card extends StatelessWidget {
  final GSColors gs; final String icon, title; final Widget child;
  const _Card({required this.gs, required this.icon, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: gs.surface, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 6, offset: const Offset(0,2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: gs.textDark)),
      ]),
      const SizedBox(height: 12),
      child,
    ]),
  );
}

class _GreenBtn extends StatelessWidget {
  final String label; final IconData? icon;
  final bool loading; final VoidCallback? onTap;
  const _GreenBtn({required this.label, this.icon, this.loading = false, this.onTap});
  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity, height: 50,
        decoration: BoxDecoration(
          color: gs.greenAccent, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: gs.greenAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0,3))]),
        child: Center(
          child: loading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ]),
        ),
      ),
    );
  }
}
