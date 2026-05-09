import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';

/// Widget qui affiche soit [child] (si le rôle correspond),
/// soit un écran "accès refusé" personnalisé.
class RoleGuard extends StatelessWidget {
  final UserRole required;
  final Widget child;
  final String? permissionKey; // clé traduction pour le message

  const RoleGuard({
    super.key,
    required this.required,
    required this.child,
    this.permissionKey,
  });

  @override
  Widget build(BuildContext context) {
    final userRole = AppState.user?.role;
    if (userRole == required) return child;
    return _AccessDenied(
      required: required,
      current: userRole,
      permissionKey: permissionKey,
    );
  }
}

class _AccessDenied extends StatelessWidget {
  final UserRole required;
  final UserRole? current;
  final String? permissionKey;
  const _AccessDenied({required this.required, this.current, this.permissionKey});

  @override
  Widget build(BuildContext context) {
    final gs  = context.gs;
    final app = context.watch<AppProvider>();

    final msgKey = permissionKey ?? _defaultKey(required);
    final msg    = app.t(msgKey);

    return Container(
      color: gs.bg,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône cadenas animée
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, v, __) => Transform.scale(
              scale: v,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: GS.statusWait.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: GS.statusWait.withOpacity(0.3), width: 2)),
                child: const Icon(Icons.lock_outline_rounded,
                  color: GS.statusWait, size: 42),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(app.t('no_permission'),
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800, color: gs.textDark)),
          const SizedBox(height: 12),
          Text(msg,
            style: TextStyle(fontSize: 14, color: gs.textMed, height: 1.5),
            textAlign: TextAlign.center),
          const SizedBox(height: 20),
          // Afficher quel profil est requis
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: gs.greenBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gs.greenAccent.withOpacity(0.3))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(required.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(required.label,
                style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: gs.greenAccent)),
            ]),
          ),
          const SizedBox(height: 12),
          // Profil actuel
          if (current != null)
            Text(
              '${app.t("my_profile")}: ${current!.label}',
              style: TextStyle(fontSize: 12, color: gs.textLight),
            ),
        ],
      ),
    );
  }

  String _defaultKey(UserRole r) {
    switch (r) {
      case UserRole.agriculteur:    return 'agri_only';
      case UserRole.verificateur:   return 'verif_only';
      case UserRole.transformateur: return 'transfo_only';
      case UserRole.exportateur:    return 'export_only';
      case UserRole.cooperative:    return 'coop_only';
    }
  }
}
