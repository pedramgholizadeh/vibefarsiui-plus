import 'package:flutter/material.dart';

import '../theme.dart';

/// یک ردیف آکاردئون: شناسه، عنوان و محتوا.
class VibeAccordionItem {
  const VibeAccordionItem({required this.id, required this.title, required this.content});

  /// شناسه‌ی یکتا برای حالت باز/بسته.
  final String id;

  /// عنوان ردیف؛ در دکمه‌ی سربرگ می‌نشیند.
  final Widget title;

  /// بدنه‌ی ردیف؛ فقط وقتی باز است دیده می‌شود ولی state آن حفظ می‌شود.
  final Widget content;
}

/// آکاردئون — پورت `registry/ui/accordion.tsx`.
///
/// زبانه در سمت انتهای خط (چپ در RTL)؛ باز و بسته‌شدن با انیمیشن ارتفاعِ
/// ۲۰۰ میلی‌ثانیه‌ای زبان طراحی. با `multiple` چند پنل هم‌زمان باز می‌مانند.
///
/// ```dart
/// VibeAccordion(items: [
///   VibeAccordionItem(id: "a", title: Text("ارسال"), content: Text("چطور بفرستیم؟")),
///   VibeAccordionItem(id: "b", title: Text("بازگشت"), content: Text("شرط بازگشت…")),
/// ])
/// ```
class VibeAccordion extends StatefulWidget {
  const VibeAccordion({
    super.key,
    required this.items,
    this.multiple = false,
    this.defaultOpen = const [],
  });

  final List<VibeAccordionItem> items;

  /// اجازه‌ی باز بودن چند پنل هم‌زمان.
  final bool multiple;

  /// شناسه‌ی ردیف‌هایی که از اول باز‌اند.
  final List<String> defaultOpen;

  @override
  State<VibeAccordion> createState() => _VibeAccordionState();
}

class _VibeAccordionState extends State<VibeAccordion> {
  late final Set<String> _open = widget.defaultOpen.toSet();

  void _toggle(String id) {
    setState(() {
      if (_open.contains(id)) {
        _open.remove(id);
      } else {
        if (!widget.multiple) _open.clear();
        _open.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.overlay), // rounded-xl
        border: Border.all(color: t.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.items.length; i++)
            _AccordionPanel(
              item: widget.items[i],
              open: _open.contains(widget.items[i].id),
              showDivider: i > 0, // divide-y وب
              onToggle: () => _toggle(widget.items[i].id),
            ),
        ],
      ),
    );
  }
}

class _AccordionPanel extends StatelessWidget {
  const _AccordionPanel({
    required this.item,
    required this.open,
    required this.showDivider,
    required this.onToggle,
  });

  final VibeAccordionItem item;
  final bool open;
  final bool showDivider;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDivider) Divider(height: 1, thickness: 1, color: t.border),
        _RevealHeader(
          open: open,
          onToggle: onToggle,
          child: item.title,
        ),
        _AnimatedReveal(open: open, child: item.content),
      ],
    );
  }
}

/// دکمه‌ی سربرگ: px-4 py-3، متن sm/medium و زبانه‌ی چرخان در انتها.
class _RevealHeader extends StatefulWidget {
  const _RevealHeader({required this.open, required this.onToggle, required this.child});

  final bool open;
  final VoidCallback onToggle;
  final Widget child;

  @override
  State<_RevealHeader> createState() => _RevealHeaderState();
}

class _RevealHeaderState extends State<_RevealHeader> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onToggle,
        child: Semantics(
          button: true,
          expanded: widget.open,
          child: AnimatedContainer(
            duration: VibeMotion.duration,
            curve: VibeMotion.ease,
            color: _hovering ? t.accent.withValues(alpha: 0.40) : Colors.transparent,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: t.foreground,
                    ),
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    child: widget.child,
                  ),
                ),
                const SizedBox(width: 12),
                ExcludeSemantics(
                  child: AnimatedRotation(
                    turns: widget.open ? 0.5 : 0,
                    duration: VibeMotion.duration,
                    curve: VibeMotion.ease,
                    child: Icon(Icons.expand_more, size: 16, color: t.mutedForeground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// انیمیشن باز/بسته با ضریب ارتفاع؛ محتوا در درخت می‌ماند و state حفظ می‌شود
/// (معادل grid-rows-[0fr→1fr] وب).
class _AnimatedReveal extends StatelessWidget {
  const _AnimatedReveal({required this.open, required this.child});

  final bool open;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: open ? 1 : 0),
      duration: VibeMotion.duration,
      curve: VibeMotion.ease,
      builder: (context, v, content) {
        // حتی در حالت بسته (v=0) فرزند در درخت می‌ماند تا state آن حفظ شود
        return ClipRect(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            heightFactor: v,
            child: content,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16), // px-4 pb-4
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: 13,
            color: t.mutedForeground,
            height: 28 / 13, // leading-7
          ),
          child: child,
        ),
      ),
    );
  }
}
