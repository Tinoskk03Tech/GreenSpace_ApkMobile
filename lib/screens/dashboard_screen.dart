import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs  = context.gs;
    final app = context.watch<AppProvider>();
    final d   = AppState.dashboard;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Banner ────────────────────────────────────────────────────────
        _Card(gs: gs, child: Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: gs.greenBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.dashboard_outlined, color: gs.greenAccent, size: 24)),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(app.t('national_dashboard'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: gs.textDark)),
            Text(app.t('ministry'),
              style: TextStyle(fontSize: 11, color: gs.textLight)),
          ]),
        ])),
        const SizedBox(height: 16),

        // ── Stats grid ────────────────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.65,
          children: [
            _StatCard(gs: gs, label: app.t('lots_registered'), value: '${d['lots']}',
              icon: Icons.inventory_2_outlined, delta: '+4%'),
            _StatCard(gs: gs, label: app.t('exporters'), value: '${d['exportateurs']}',
              icon: Icons.local_shipping_outlined, delta: '+8%'),
            _StatCard(gs: gs, label: app.t('certifications'), value: '${d['certifications']}',
              icon: Icons.verified_outlined, delta: '+2%'),
            _StatCard(gs: gs, label: app.t('active_zones'), value: '${d['zones']}',
              icon: Icons.map_outlined),
            _StatCard(gs: gs, label: app.t('farmers'), value: '${d['agriculteurs']}',
              icon: Icons.grass_outlined, delta: '+6%'),
            _StatCard(gs: gs, label: 'OJA Compliance', value: '${d['oja']}%',
              icon: Icons.shield_outlined),
          ],
        ),
        const SizedBox(height: 20),

        // ── Zones de production ───────────────────────────────────────────
        _SectionTitle(gs: gs, title: app.t('production_zones')),
        const SizedBox(height: 12),
        _Card(gs: gs, child: Column(children: AppState.regions.asMap().entries.map((e) {
          final r = e.value;
          final isLast = e.key == AppState.regions.length - 1;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(r.nom, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: gs.textDark)),
                Text('${r.lots} lots', style: TextStyle(fontSize: 11, color: gs.textLight)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: r.pct, minHeight: 7,
                  backgroundColor: gs.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(gs.greenAccent))),
              if (!isLast) Divider(height: 1, color: gs.divider.withOpacity(0.5)),
            ]),
          );
        }).toList())),
        const SizedBox(height: 20),

        // ── Carte des zones ───────────────────────────────────────────────
        _SectionTitle(gs: gs, title: app.t('zones_map')),
        const SizedBox(height: 12),
        Container(height: 170,
          decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 6, offset: const Offset(0,2))]),
          child: ClipRRect(borderRadius: BorderRadius.circular(16),
            child: Stack(children: [
              Positioned.fill(child: Container(
                color: const Color(0xFFE4F0E4),
                child: CustomPaint(painter: _MapBgPainter(gs.divider)))),
              Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.map_outlined, size: 36, color: gs.greenAccent),
                const SizedBox(height: 6),
                Text('34 zones actives', style: TextStyle(fontSize: 13, color: gs.textMed, fontWeight: FontWeight.w600)),
                Text('1,247 lots tracés', style: TextStyle(fontSize: 11, color: gs.textLight)),
              ])),
              _pin(top: 38, left: 80, c: GS.greenPrimary, l: 'P'),
              _pin(top: 78, right: 90, c: GS.brown, l: 'M'),
              _pin(bottom: 40, left: 140, c: GS.greenLight, l: 'C'),
              _pin(top: 55, right: 46, c: GS.statusWait, l: 'K'),
            ]))),
        const SizedBox(height: 20),

        // ── Production mensuelle ──────────────────────────────────────────
        _SectionTitle(gs: gs, title: app.t('monthly_production')),
        const SizedBox(height: 12),
        _Card(gs: gs, padding: const EdgeInsets.fromLTRB(16,16,16,8),
          child: SizedBox(height: 150,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end,
              children: AppState.production.map((item) {
                final maxV = 160.0;
                final h = ((item['v'] as int) / maxV) * 110.0;
                final isMax = item['v'] == 160;
                return Expanded(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('${item['v']}', style: TextStyle(fontSize: 9,
                      color: isMax ? gs.greenAccent : gs.textLight,
                      fontWeight: isMax ? FontWeight.w700 : FontWeight.w400)),
                    const SizedBox(height: 3),
                    Container(height: h, decoration: BoxDecoration(
                      color: isMax ? gs.greenAccent : GS.greenCard,
                      borderRadius: BorderRadius.circular(5))),
                    const SizedBox(height: 6),
                    Text(item['m'] as String, style: TextStyle(fontSize: 9, color: gs.textLight)),
                  ]),
                ));
              }).toList()),
          )),
        const SizedBox(height: 20),

        // ── Impact social ─────────────────────────────────────────────────
        _SectionTitle(gs: gs, title: app.t('social_impact')),
        const SizedBox(height: 12),
        _Card(gs: gs, child: Row(children: [
          _ImpactTile(label: app.t('farmers'),   value: '2,456', color: gs.greenAccent, gs: gs),
          const SizedBox(width: 10),
          _ImpactTile(label: 'Conformité',       value: '98.7%', color: GS.statusOk,   gs: gs),
          const SizedBox(width: 10),
          _ImpactTile(label: 'Pertes',           value: '0%',    color: GS.statusWait, gs: gs),
        ])),
        const SizedBox(height: 20),

        // ── Répartition certifications ────────────────────────────────────
        _SectionTitle(gs: gs, title: app.t('cert_repartition')),
        const SizedBox(height: 12),
        _Card(gs: gs, child: Row(children: [
          SizedBox(width: 82, height: 82,
            child: CustomPaint(painter: _DonutPainter())),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Legend('Bio', '320', GS.greenPrimary, gs),
            const SizedBox(height: 8),
            _Legend('Fair Trade', '380', GS.brown, gs),
            const SizedBox(height: 8),
            _Legend('Non cert.', '226', gs.textLight, gs),
          ]),
        ])),
      ]),
    );
  }

  Widget _pin({double? top, double? bottom, double? left, double? right, required Color c, required String l}) =>
    Positioned(top: top, bottom: bottom, left: left, right: right,
      child: Container(width: 24, height: 24,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: c.withOpacity(0.45), blurRadius: 6)]),
        child: Center(child: Text(l,
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)))));
}

// ── Local widgets ──────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final GSColors gs; final Widget child; final EdgeInsets? padding;
  const _Card({required this.gs, required this.child, this.padding});
  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 6, offset: const Offset(0,2))]),
    child: child);
}

class _StatCard extends StatelessWidget {
  final GSColors gs; final String label, value; final IconData icon; final String? delta;
  const _StatCard({required this.gs, required this.label, required this.value, required this.icon, this.delta});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: gs.surface, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 6, offset: const Offset(0,2))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icon(icon, color: gs.greenAccent, size: 18),
        if (delta != null)
          Text(delta!, style: const TextStyle(fontSize: 10, color: GS.statusOk, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: gs.textDark)),
      Text(label, style: TextStyle(fontSize: 10, color: gs.textLight)),
    ]));
}

class _SectionTitle extends StatelessWidget {
  final GSColors gs; final String title;
  const _SectionTitle({required this.gs, required this.title});
  @override
  Widget build(BuildContext context) =>
    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: gs.textDark));
}

class _ImpactTile extends StatelessWidget {
  final String label, value; final Color color; final GSColors gs;
  const _ImpactTile({required this.label, required this.value, required this.color, required this.gs});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 3),
      Text(label, style: TextStyle(fontSize: 9, color: gs.textLight), textAlign: TextAlign.center),
    ])));
}

Widget _Legend(String label, String val, Color c, GSColors gs) => Row(children: [
  Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
  const SizedBox(width: 8),
  Text('$label · $val', style: TextStyle(fontSize: 12, color: gs.textMed)),
]);

class _MapBgPainter extends CustomPainter {
  final Color divider;
  _MapBgPainter(this.divider);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..color = divider.withOpacity(0.4)..strokeWidth = 0.5..style = PaintingStyle.stroke;
    for (var i = 1; i < 5; i++) {
      canvas.drawLine(Offset(0, s.height * i / 5), Offset(s.width, s.height * i / 5), p);
      canvas.drawLine(Offset(s.width * i / 5, 0), Offset(s.width * i / 5, s.height), p);
    }
  }
  @override bool shouldRepaint(_) => false;
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.42;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 15..strokeCap = StrokeCap.butt;
    const total = 926.0;
    var start = -1.5707963;
    for (final (val, color) in [(380.0, GS.brown), (320.0, GS.greenPrimary), (226.0, GS.textLight)]) {
      final sweep = (val / total) * 6.2831853;
      paint.color = color;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), start, sweep - 0.06, false, paint);
      start += sweep;
    }
  }
  @override bool shouldRepaint(_) => false;
}
