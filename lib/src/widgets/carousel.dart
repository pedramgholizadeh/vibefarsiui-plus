import 'package:flutter/material.dart';

import '../theme.dart';

/// اسلایدر — پورت `registry/ui/carousel.tsx`.
///
/// اسلاید اول سمت راست است (RTL) و «بعدی» به چپ می‌رود؛ [slideWidth]
/// کسری از صفحه برای چند اسلاید هم‌زمان.
///
/// ```dart
/// VibeCarousel(
///   slides: [BannerCard(), BannerCard()],
///   showDots: true,
/// )
/// ```
class VibeCarousel extends StatefulWidget {
  final List<Widget> slides;

  /// کسری از عرض صفحه برای هر اسلاید (1 = تک‌اسلاید، 0.5 = دونفره).
  final double slideWidth;
  final bool showDots;
  final double height;

  const VibeCarousel({
    super.key,
    required this.slides,
    this.slideWidth = 1,
    this.showDots = true,
    this.height = 220,
  });

  @override
  State<VibeCarousel> createState() => _VibeCarouselState();
}

class _VibeCarouselState extends State<VibeCarousel> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.slideWidth.clamp(0.1, 1.0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final count = widget.slides.length;

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            reverse: true, // اسلاید اول سمت راست
            itemCount: count,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(VibeRadius.surface),
                child: widget.slides[i],
              ),
            ),
          ),
        ),
        if (widget.showDots && count > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // «بعدی» به چپ (جهت حرکت در RTL).
                IconButton(
                  onPressed: () {
                    final next = (_controller.page?.round() ?? 0) + 1;
                    if (next < count) _controller.animateToPage(next, duration: VibeMotion.duration, curve: VibeMotion.ease);
                  },
                  icon: const Icon(Icons.chevron_left, size: 16),
                  color: t.mutedForeground,
                  visualDensity: VisualDensity.compact,
                ),
                for (var i = 0; i < count; i++)
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      double page = 0;
                      try {
                        page = _controller.page ?? 0;
                      } catch (_) {}
                      // در reverse، صفحه‌ی نمایشی از انتها می‌شمارد.
                      final shown = count - 1 - page.round();
                      final active = i == shown;
                      return Container(
                        width: active ? 16 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: active ? t.foreground : t.mutedForeground.withValues(alpha: 0.35),
                        ),
                      );
                    },
                  ),
                IconButton(
                  onPressed: () {
                    final next = (_controller.page?.round() ?? 0) - 1;
                    if (next >= 0) _controller.animateToPage(next, duration: VibeMotion.duration, curve: VibeMotion.ease);
                  },
                  icon: const Icon(Icons.chevron_right, size: 16),
                  color: t.mutedForeground,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
