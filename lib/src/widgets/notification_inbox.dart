import 'package:flutter/material.dart';

import '../iran.dart';
import '../persian.dart';
import '../theme.dart';

/// یک اعلان صندوق.
class VibeNotification {
  final String id;
  final Widget title;
  final Widget? description;
  final DateTime date;
  final bool read;
  final IconData? icon;
  final VoidCallback? onTap;

  const VibeNotification({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.read = false,
    this.icon,
    this.onTap,
  });
}

String _bucket(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(d.year, d.month, d.day);
  final days = today.difference(day).inDays;
  return days <= 0 ? "امروز" : days == 1 ? "دیروز" : "قدیمی‌تر";
}

/// صندوق اعلان — پورت `registry/ui/notification-inbox.tsx`.
///
/// زنگ با نشان نخوانده؛ پنل گروه‌بندی امروز/دیروز/قدیمی‌تر با تب‌های «همه»
/// و «نخوانده».
///
/// ```dart
/// VibeNotificationInbox(
///   items: notifications,
///   onRead: markRead,
///   onReadAll: markAllRead,
/// )
/// ```
class VibeNotificationInbox extends StatefulWidget {
  const VibeNotificationInbox({
    super.key,
    required this.items,
    this.onRead,
    this.onReadAll,
  });

  final List<VibeNotification> items;
  final ValueChanged<String>? onRead;
  final VoidCallback? onReadAll;

  @override
  State<VibeNotificationInbox> createState() => _VibeNotificationInboxState();
}

class _VibeNotificationInboxState extends State<VibeNotificationInbox> {
  final _layerLink = LayerLink();
  OverlayEntry? _entry;
  bool _open = false;
  bool _unreadOnly = false;

  int get _unread => widget.items.where((i) => !i.read).length;

  void _set(bool v) {
    if (v == _open) return;
    setState(() => _open = v);
    if (v) {
      _entry = OverlayEntry(builder: _panel);
      Overlay.of(context).insert(_entry!);
    } else {
      _entry?.remove();
      _entry = null;
    }
  }

  @override
  void dispose() {
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () => _set(!_open),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: t.border),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(Icons.notifications_none, size: 16, color: t.mutedForeground),
              if (_unread > 0)
                PositionedDirectional(
                  end: -4,
                  top: -4,
                  child: Container(
                    height: 16,
                    constraints: const BoxConstraints(minWidth: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: t.brand,
                    ),
                    child: Text(
                      fa(_unread),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: t.brandForeground),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final t = context.vibe;
    final list = _unreadOnly ? widget.items.where((i) => !i.read).toList() : widget.items;
    final groups = <String, List<VibeNotification>>{};
    for (final g in ["امروز", "دیروز", "قدیمی‌تر"]) {
      final bucket = list.where((i) => _bucket(i.date) == g).toList();
      if (bucket.isNotEmpty) groups[g] = bucket;
    }

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _set(false),
          ),
        ),
        Positioned(
          width: 320,
          child: CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 4),
            showWhenUnlinked: false,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 420),
                decoration: BoxDecoration(
                  color: t.popover,
                  borderRadius: BorderRadius.circular(VibeRadius.field),
                  border: Border.all(color: t.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          _tab(context, t, all: true),
                          const SizedBox(width: 4),
                          _tab(context, t, all: false),
                          const Spacer(),
                          GestureDetector(
                            onTap: _unread == 0 ? null : widget.onReadAll,
                            child: Opacity(
                              opacity: _unread == 0 ? 0.4 : 1,
                              child: Row(
                                children: [
                                  Icon(Icons.done_all, size: 12, color: t.mutedForeground),
                                  const SizedBox(width: 4),
                                  Text("خواندن همه", style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: t.border),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 8),
                        children: [
                          for (final entry in groups.entries) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                              child: Text(entry.key, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: t.mutedForeground)),
                            ),
                            for (final n in entry.value)
                              InkWell(
                                onTap: () {
                                  widget.onRead?.call(n.id);
                                  n.onTap?.call();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: n.read ? t.muted : t.accent,
                                        ),
                                        child: Icon(n.icon ?? Icons.notifications_none, size: 14, color: n.read ? t.mutedForeground : t.foreground),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: DefaultTextStyle.merge(
                                                    style: TextStyle(fontSize: 13, height: 1.4, fontWeight: n.read ? FontWeight.w400 : FontWeight.w600),
                                                    child: n.title,
                                                  ),
                                                ),
                                                if (!n.read)
                                                  Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: t.brand)),
                                              ],
                                            ),
                                            if (n.description != null)
                                              DefaultTextStyle.merge(
                                                style: TextStyle(fontSize: 12, height: 1.5, color: t.mutedForeground),
                                                child: n.description!,
                                              ),
                                            Text(
                                              timeAgo(n.date),
                                              style: TextStyle(fontSize: 11, color: t.mutedForeground),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                          if (list.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text("اعلانی نیست", style: TextStyle(fontSize: 13, color: t.mutedForeground)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _tab(BuildContext context, VibeTokens t, {required bool all}) {
    final active = all ? !_unreadOnly : _unreadOnly;
    final label = all ? "همه" : "نخوانده (${fa(_unread)})";
    return GestureDetector(
      onTap: () => setState(() => _unreadOnly = !all),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: active ? t.secondary : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? t.secondaryForeground : t.mutedForeground),
        ),
      ),
    );
  }
}
