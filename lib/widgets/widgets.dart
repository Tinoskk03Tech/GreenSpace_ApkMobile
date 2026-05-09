import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'gs_logo_widget.dart';
import 'package:flutter/material.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';

// ══════════════════════════════════════════════════════════════════════════
// LOGO GREENSPACE — utilise le vrai SVG
// ══════════════════════════════════════════════════════════════════════════
class GSLogo extends StatelessWidget {
  final double size;
  final bool horizontal;
  final Color? textColor;
  const GSLogo({super.key, this.size = 32, this.horizontal = true, this.textColor});

  @override
  Widget build(BuildContext context) {
    return GSLogoWidget(
      width: size * 1.2,
      height: size * 1.2,
      horizontal: horizontal,
      textColor: textColor,
      withText: true,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// APP BAR
// ══════════════════════════════════════════════════════════════════════════
class GSAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotif;
  final VoidCallback? onProfile;
  final bool showBack;

  const GSAppBar({super.key, this.onNotif, this.onProfile, this.showBack = false});

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) {
    final gs     = context.gs;
    final app    = context.watch<AppProvider>();
    final unread = app.notifsOn ? AppState.unreadCount : 0;
    return Container(
      color: gs.bg,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              if (showBack)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: gs.surface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: GS.greenDark.withOpacity(0.1), blurRadius: 4)],
                    ),
                    child: Icon(Icons.arrow_back_ios_new, size: 17, color: gs.textDark),
                  ),
                )
              else
                const GSLogo(size: 28),
              const Spacer(),
              // Notification Bell
              GestureDetector(
                onTap: onNotif,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: gs.surface,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: GS.greenDark.withOpacity(0.1), blurRadius: 4)],
                      ),
                      child: Icon(Icons.notifications_outlined, size: 20, color: gs.textDark),
                    ),
                    if (unread > 0)
                      Positioned(
                        top: -3, right: -3,
                        child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(color: GS.statusBad, shape: BoxShape.circle),
                          child: Center(
                            child: Text('$unread',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Profile Avatar
              GestureDetector(
                onTap: onProfile,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [GS.greenMid, GS.greenDark]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: GS.greenDark.withOpacity(0.25), blurRadius: 6, offset: const Offset(0,2))],
                  ),
                  child: Center(
                    child: Text(
                      AppState.user?.initials ?? 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// BOTTOM NAVIGATION BAR
// ══════════════════════════════════════════════════════════════════════════
class GSBottomNav extends StatelessWidget {
  final int current;
  final Function(int) onTap;

  const GSBottomNav({super.key, required this.current, required this.onTap});

  static const _items = [
    (Icons.home_rounded,         Icons.home_outlined,        'Accueil'),
    (Icons.grass_rounded,        Icons.grass_outlined,       'Agriculture'),
    (Icons.groups_rounded,       Icons.groups_outlined,      'Coopérative'),
    (Icons.factory_rounded,      Icons.factory_outlined,     'Transfo.'),
    (Icons.local_shipping_rounded,Icons.local_shipping_outlined,'Export'),
    (Icons.verified_rounded,     Icons.verified_outlined,    'Vérif.'),
  ];

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Container(
      decoration: BoxDecoration(
        color: gs.surface,
        boxShadow: [BoxShadow(color: GS.greenDark.withOpacity(0.12), blurRadius: 16, offset: const Offset(0,-3))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(_items.length, (i) {
              final sel = i == current;
              final (iconSel, icon, label) = _items[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (sel)
                        Container(
                          width: 36, height: 3,
                          decoration: BoxDecoration(
                            color: GS.greenPrimary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      else
                        const SizedBox(height: 3),
                      const SizedBox(height: 4),
                      Icon(sel ? iconSel : icon, size: 20,
                        color: sel ? gs.greenAccent : gs.textLight),
                      const SizedBox(height: 2),
                      Text(label,
                        style: TextStyle(fontSize: 9,
                          color: sel ? gs.greenAccent : gs.textLight,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400),
                        overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// LOT STATUS BADGE
// ══════════════════════════════════════════════════════════════════════════
class StatusBadge extends StatelessWidget {
  final LotStatus status;
  const StatusBadge({super.key, required this.status});

  static Color _color(LotStatus s) => switch(s) {
    LotStatus.nouveau          => GS.statusNew,
    LotStatus.enAttente        => GS.statusWait,
    LotStatus.verifie          => GS.statusOk,
    LotStatus.rejete           => GS.statusBad,
    LotStatus.enTransformation => GS.statusTrans,
    LotStatus.exporte          => GS.greenDark,
  };

  @override
  Widget build(BuildContext context) {
    final c = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Text(status.label,
        style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// LOT CARD
// ══════════════════════════════════════════════════════════════════════════
class LotCard extends StatelessWidget {
  final LotModel lot;
  final Widget? actions;
  final VoidCallback? onTap;

  const LotCard({super.key, required this.lot, this.actions, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: GS.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: GS.greenDark.withOpacity(0.07), blurRadius: 8, offset: const Offset(0,2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lot.lotId,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: GS.textDark)),
                StatusBadge(status: lot.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _chip('Poids', '${lot.poids.toInt()} kg'),
                const SizedBox(width: 16),
                _chip('Culture', lot.culture),
                const SizedBox(width: 16),
                _chip('Région', lot.region),
              ],
            ),
            if (lot.certifications.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: lot.certifications.map((c) => _certBadge(c)).toList()),
            ],
            if (actions != null) ...[const SizedBox(height: 10), actions!],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 9, color: GS.textLight)),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: GS.textMed)),
    ],
  );

  Widget _certBadge(String c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: GS.greenPale,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: GS.greenLight.withOpacity(0.4)),
    ),
    child: Text(c, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GS.greenDark)),
  );
}

// ══════════════════════════════════════════════════════════════════════════
// GREEN BUTTON
// ══════════════════════════════════════════════════════════════════════════
class GSBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? bg;
  final Color? fg;
  final bool outline;
  final bool loading;

  const GSBtn({super.key, required this.label, this.icon, this.onTap,
    this.bg, this.fg, this.outline = false, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final bgC = bg ?? (outline ? Colors.transparent : GS.greenPrimary);
    final fgC = fg ?? (outline ? GS.greenPrimary : GS.white);

    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: bgC,
          borderRadius: BorderRadius.circular(12),
          border: outline ? Border.all(color: GS.greenPrimary, width: 1.5) : null,
          boxShadow: outline ? null : [
            BoxShadow(color: (bg ?? GS.greenDark).withOpacity(0.3), blurRadius: 8, offset: const Offset(0,4)),
          ],
        ),
        child: Center(
          child: loading
              ? SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: fgC))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[Icon(icon, color: fgC, size: 19), const SizedBox(width: 8)],
                    Text(label, style: TextStyle(color: fgC, fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// STAT CARD
// ══════════════════════════════════════════════════════════════════════════
class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final String? delta;
  const StatCard({super.key, required this.label, required this.value, required this.icon, this.delta});

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: gs.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: GS.greenDark.withOpacity(0.07), blurRadius: 6, offset: const Offset(0,2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: gs.greenAccent, size: 18),
              if (delta != null)
                Text(delta!, style: const TextStyle(fontSize: 10, color: GS.statusOk, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: gs.textDark)),
          Text(label, style: TextStyle(fontSize: 10, color: gs.textLight)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ══════════════════════════════════════════════════════════════════════════
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final GSColors? gs;
  const SectionHeader({super.key, required this.title, this.action, this.onAction, this.gs});

  @override
  Widget build(BuildContext context) {
    final c = gs ?? context.gs;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: c.textDark)),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: TextStyle(fontSize: 12, color: c.greenAccent, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// SECTION HEADER BANNER (pour les pages internes)
// ══════════════════════════════════════════════════════════════════════════
class PageBanner extends StatelessWidget {
  final String emoji, title, subtitle;
  const PageBanner({super.key, required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: GS.greenDark.withOpacity(0.07), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: gs.textDark)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: gs.textLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// INPUT FIELD
// ══════════════════════════════════════════════════════════════════════════
class GSInput extends StatelessWidget {
  final TextEditingController? ctrl;
  final String hint;
  final IconData? prefixIcon;
  final bool obscure;
  final TextInputType? type;
  final Color? fillColor;

  const GSInput({super.key, this.ctrl, required this.hint,
    this.prefixIcon, this.obscure = false, this.type, this.fillColor});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: type,
      style: const TextStyle(fontSize: 14, color: GS.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: GS.textLight, fontSize: 13),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: GS.greenMid) : null,
        filled: true,
        fillColor: fillColor ?? GS.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: GS.greenLight, width: 1.5),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ACTION ROW (2 buttons)
// ══════════════════════════════════════════════════════════════════════════
class ActionRow extends StatelessWidget {
  final String label1, label2;
  final Color color1, color2;
  final VoidCallback? onTap1, onTap2;

  const ActionRow({super.key,
    required this.label1, required this.label2,
    required this.color1, required this.color2,
    this.onTap1, this.onTap2,
  });

  @override
  Widget build(BuildContext context) {
    btn(String lbl, Color c, VoidCallback? cb) => Expanded(
      child: GestureDetector(
        onTap: cb,
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            color: lbl == label1 && c == color1 && c == GS.greenPale ? GS.greenPale : c,
            borderRadius: BorderRadius.circular(9),
            border: c == GS.greenPale ? Border.all(color: GS.greenLight.withOpacity(0.4)) : null,
          ),
          child: Center(
            child: Text(lbl, style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: c == GS.greenPale ? GS.greenPrimary : GS.white,
            )),
          ),
        ),
      ),
    );

    return Row(
      children: [btn(label1, color1, onTap1), const SizedBox(width: 10), btn(label2, color2, onTap2)],
    );
  }
}
