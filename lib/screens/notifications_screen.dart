import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/gs_theme.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotifsState();
}

class _NotifsState extends State<NotificationsScreen> {
  void _markAllRead() => setState(() {
        for (final n in AppState.notifications) n.isRead = true;
      });

  void _markRead(NotifModel n) => setState(() => n.isRead = true);

  void _delete(NotifModel n) =>
      setState(() => AppState.notifications.remove(n));

  Color _iconColor(String type) => switch (type) {
        'success' => GS.statusOk,
        'cert' => GS.gold,
        'reminder' => GS.statusWait,
        _ => GS.statusNew,
      };

  IconData _icon(String type) => switch (type) {
        'success' => Icons.check_circle_rounded,
        'cert' => Icons.workspace_premium_rounded,
        'reminder' => Icons.alarm_rounded,
        _ => Icons.info_rounded,
      };

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    final app = context.watch<AppProvider>();
    final unread = AppState.notifications.where((n) => !n.isRead).toList();
    final read = AppState.notifications.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: gs.bg,
      appBar: AppBar(
        backgroundColor: gs.bg,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: gs.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: GS.greenDark.withOpacity(0.1), blurRadius: 4)
              ],
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: gs.textDark),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: GS.textDark)),
            if (unread.isNotEmpty)
              Text('${unread.length} non lue${unread.length > 1 ? 's' : ''}',
                  style: const TextStyle(fontSize: 11, color: GS.statusBad)),
          ],
        ),
        actions: [
          if (unread.isNotEmpty)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Tout lire',
                  style: TextStyle(
                      color: GS.greenPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: !app.notifsOn
          ? _NotifDisabledBanner(gs: gs, app: app)
          : AppState.notifications.isEmpty
              ? const _EmptyNotifs()
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    if (unread.isNotEmpty) ...[
                      _GroupLabel(label: 'Nouvelles', count: unread.length),
                      const SizedBox(height: 8),
                      ...unread.map((n) => _NotifTile(
                            notif: n,
                            iconColor: _iconColor(n.type),
                            icon: _icon(n.type),
                            timeAgo: _timeAgo(n.date),
                            onTap: () => _markRead(n),
                            onDelete: () => _delete(n),
                          )),
                      const SizedBox(height: 16),
                    ],
                    if (read.isNotEmpty) ...[
                      _GroupLabel(label: 'Lues', count: read.length),
                      const SizedBox(height: 8),
                      ...read.map((n) => _NotifTile(
                            notif: n,
                            iconColor: _iconColor(n.type),
                            icon: _icon(n.type),
                            timeAgo: _timeAgo(n.date),
                            onTap: () {},
                            onDelete: () => _delete(n),
                            isRead: true,
                          )),
                    ],
                  ],
                ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  final int count;
  const _GroupLabel({required this.label, required this.count});
  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: gs.textDark)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: GS.greenCard, borderRadius: BorderRadius.circular(20)),
          child: Text('$count',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: GS.greenDark)),
        ),
      ],
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotifModel notif;
  final Color iconColor;
  final IconData icon;
  final String timeAgo;
  final VoidCallback onTap, onDelete;
  final bool isRead;

  const _NotifTile({
    required this.notif,
    required this.iconColor,
    required this.icon,
    required this.timeAgo,
    required this.onTap,
    required this.onDelete,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final gs = context.gs;
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: GS.statusBad,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? gs.surface : gs.greenBg,
            borderRadius: BorderRadius.circular(14),
            border: isRead
                ? Border.all(color: GS.divider.withOpacity(0.5))
                : Border.all(color: GS.greenLight.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                  color: GS.greenDark.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notif.titre,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                  color: GS.textDark)),
                        ),
                        if (!isRead)
                          Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: GS.greenPrimary,
                                  shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif.message,
                        style: const TextStyle(
                            fontSize: 12, color: GS.textMed, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(timeAgo,
                        style:
                            const TextStyle(fontSize: 11, color: GS.textLight)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifs extends StatelessWidget {
  const _EmptyNotifs();
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration:
                  BoxDecoration(color: GS.greenPale, shape: BoxShape.circle),
              child: const Icon(Icons.notifications_none_rounded,
                  size: 40, color: GS.textLight),
            ),
            const SizedBox(height: 16),
            const Text('Aucune notification',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: GS.textDark)),
            const SizedBox(height: 6),
            const Text('Vous êtes à jour !',
                style: TextStyle(fontSize: 13, color: GS.textLight)),
          ],
        ),
      );
}

class _NotifDisabledBanner extends StatelessWidget {
  final GSColors gs;
  final AppProvider app;
  const _NotifDisabledBanner({required this.gs, required this.app});

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: gs.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: GS.greenDark.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Notifications désactivées',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: gs.textDark)),
              const SizedBox(height: 12),
              Text(
                  'Activez les notifications pour recevoir les dernières alertes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: gs.textLight)),
              const SizedBox(height: 16),
              GSBtn(
                  label: 'Activer',
                  icon: Icons.notifications_active,
                  onTap: app.toggleNotifs),
            ],
          ),
        ),
      );
}
