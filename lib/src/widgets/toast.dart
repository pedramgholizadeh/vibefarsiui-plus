import 'dart:async';

import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// واریانت اعلان.
enum VibeToastVariant { info, success, error }

/// یک اعلان — پورت `Toast` وب.
class VibeToastData {
  final Widget title;
  final Widget? description;
  final VibeToastVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;

  const VibeToastData({
    required this.title,
    this.description,
    this.variant = VibeToastVariant.info,
    this.actionLabel,
    this.onAction,
  });
}

/// سرویس اعلان — پورت `ToastProvider`/`useToast` وب.
///
/// یک‌بار [VibeToasts] را بالای MaterialApp بگذارید و هر جا با
/// `VibeToast.of(context).show(...)` اعلان بدهید. جدیدترین نزدیک لبه است.
///
/// ```dart
/// VibeToast.of(context).show(
///   const VibeToastData(
///     title: Text("ذخیره شد"),
///     variant: VibeToastVariant.success,
///   ),
/// );
/// ```
class VibeToast {
  // ignore: library_private_types_in_public_api
  static _VibeToastsState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_VibeToastsState>();
    if (state == null) {
      throw StateError("VibeToast باید داخل <VibeToasts> استفاده شود.");
    }
    return state;
  }
}

/// عرض کارت اعلان.
const double _kToastWidth = 360;

/// Wrapper برای اپ: فرزند + پشته‌ی اعلان‌ها.
class VibeToasts extends StatefulWidget {
  final Widget child;

  /// حداکثر اعلان هم‌زمان؛ قدیمی‌ها می‌افتند.
  final int max;
  final Duration duration;

  const VibeToasts({super.key, required this.child, this.max = 3, this.duration = const Duration(milliseconds: 4000)});

  @override
  State<VibeToasts> createState() => _VibeToastsState();
}

class _VibeToastsState extends State<VibeToasts> {
  final List<({int id, VibeToastData data})> _items = [];
  final Map<int, Timer> _timers = {};
  int _nextId = 0;

  int show(VibeToastData data, {Duration? duration}) {
    final id = ++_nextId;
    setState(() {
      _items.add((id: id, data: data));
      if (_items.length > widget.max) _items.removeRange(0, _items.length - widget.max);
    });
    _timers[id] = Timer(duration ?? widget.duration, () => dismiss(id));
    return id;
  }

  void dismiss(int id) {
    _timers.remove(id)?.cancel();
    setState(() => _items.removeWhere((t) => t.id == id));
  }

  void dismissAll() {
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
    setState(_items.clear);
  }

  @override
  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        PositionedDirectional(
          start: 16,
          bottom: 16,
          width: _kToastWidth.clamp(0, MediaQuery.sizeOf(context).width - 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in _items.reversed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ToastCard(data: item.data, onClose: () => dismiss(item.id)),
                ),
              if (_items.length > 1)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: GestureDetector(
                    onTap: dismissAll,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        "بستن همه (${fa(_items.length)})",
                        style: TextStyle(fontSize: 11, color: muted(context)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  static Color muted(BuildContext context) => VibeTokens.of(context).mutedForeground;
}

/// کارت اعلان — همان استایل وب: آیکون دایره‌ای، عنوان و توضیح و اکشن.
class _ToastCard extends StatelessWidget {
  final VibeToastData data;
  final VoidCallback onClose;

  const _ToastCard({required this.data, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final t = VibeTokens.of(context);
    final iconColor = data.variant == VibeToastVariant.error ? Colors.white : t.background;
    final iconBg = data.variant == VibeToastVariant.error ? t.destructive : t.foreground;
    final icon = switch (data.variant) {
      VibeToastVariant.success => Icons.check,
      VibeToastVariant.error => Icons.priority_high_rounded,
      VibeToastVariant.info => Icons.info_outline,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.popover,
        borderRadius: BorderRadius.circular(VibeRadius.overlay),
        border: Border.all(color: t.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
            child: Icon(icon, size: 12, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle.merge(
                  style: const TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w500),
                  child: data.title,
                ),
                if (data.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(fontSize: 12, height: 1.5, color: t.mutedForeground),
                      child: data.description!,
                    ),
                  ),
              ],
            ),
          ),
          if (data.actionLabel != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                data.onAction?.call();
                onClose();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: t.border),
                ),
                child: Text(data.actionLabel!, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onClose,
            child: Icon(Icons.close, size: 14, color: t.mutedForeground),
          ),
        ],
      ),
    );
  }
}
