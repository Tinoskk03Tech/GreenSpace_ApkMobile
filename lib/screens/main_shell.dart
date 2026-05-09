import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import 'dashboard_screen.dart';
import 'agriculteur_screen.dart';
import 'cooperative_screen.dart';
import 'transformateur_screen.dart';
import 'exportateur_screen.dart';
import 'verificateur_screen.dart';
import 'notifications_screen.dart';
import 'compte_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Chaque écran est accessible mais les actions sensibles sont protégées
  static const _screens = [
    DashboardScreen(),
    AgriculteurScreen(),
    CooperativeScreen(),
    TransformateurScreen(),
    ExportateurScreen(),
    VerificateurScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final gs  = context.gs;
    final app = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: gs.bg,
      appBar: GSAppBar(
        onNotif:    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        onProfile:  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompteScreen())),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeIn,
        child: KeyedSubtree(key: ValueKey(_index), child: _screens[_index]),
      ),
      bottomNavigationBar: _BottomNav(
        current: _index,
        onTap: (i) => setState(() => _index = i),
        app: app,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int current;
  final Function(int) onTap;
  final AppProvider app;
  const _BottomNav({required this.current, required this.onTap, required this.app});

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    final role = AppState.user?.role;

    final items = [
      (Icons.home_rounded,           Icons.home_outlined,            app.t('nav_home')),
      (Icons.grass_rounded,          Icons.grass_outlined,           app.t('nav_agri')),
      (Icons.groups_rounded,         Icons.groups_outlined,          app.t('nav_coop')),
      (Icons.factory_rounded,        Icons.factory_outlined,         app.t('nav_transfo')),
      (Icons.local_shipping_rounded, Icons.local_shipping_outlined,  app.t('nav_export')),
      (Icons.verified_rounded,       Icons.verified_outlined,        app.t('nav_verif')),
    ];

    // Quelles tabs sont "propriétaires" (action exclusive)
    final ownerMap = {
      1: UserRole.agriculteur,
      2: UserRole.cooperative,
      3: UserRole.transformateur,
      4: UserRole.exportateur,
      5: UserRole.verificateur,
    };

    return Container(
      decoration: BoxDecoration(
        color: gs.surface,
        boxShadow: [BoxShadow(color: gs.shadow, blurRadius: 16, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: items.asMap().entries.map((e) {
              final i = e.key;
              final (iconSel, icon, label) = e.value;
              final sel = i == current;
              // Indicateur si tab "étrangère" (pas le rôle courant, pas l'accueil)
              final isOwner = ownerMap[i] == null || ownerMap[i] == role;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 3,
                        child: sel ? Container(
                          width: 32, height: 3,
                          decoration: BoxDecoration(
                            color: gs.greenAccent,
                            borderRadius: BorderRadius.circular(2)),
                        ) : const SizedBox()),
                      const SizedBox(height: 4),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(sel ? iconSel : icon, size: 22,
                            color: sel ? gs.greenAccent : gs.textLight),
                          // Petit badge "vue seule" si pas owner
                          if (!isOwner && i != 0)
                            Positioned(
                              top: -3, right: -3,
                              child: Container(
                                width: 7, height: 7,
                                decoration: BoxDecoration(
                                  color: GS.statusWait.withOpacity(0.85),
                                  shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(label,
                        style: TextStyle(
                          fontSize: 9,
                          color: sel ? gs.greenAccent : gs.textLight,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w400),
                        overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
