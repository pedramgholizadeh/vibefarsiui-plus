/// کتابخانه‌ی انیمیشن وایب‌فارسی — پورت `registry/animations/*`.
///
/// هر انیمیشن وب یک ویجت یا کمکی فلاتری: انیمیشن ۲۰۰ms با منحنی تم، همه
/// بدون وابستگی. این فایل پرمصرف‌ترین‌ها را دارد؛ برای بقیه از Tween
/// استاندارد با [VibeMotion] استفاده کنید.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/* ---------- Reveal / ورود ---------- */

/// ورود محو-بالا — پورت `reveal.tsx`.
///
/// با ورود به viewport (یا بلافاصله) fade+slide پخش می‌کند.
class VibeReveal extends StatefulWidget {
  const VibeReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 16,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final Duration delay;
  final double offset;
  final Duration duration;

  @override
  State<VibeReveal> createState() => _VibeRevealState();
}

class _VibeRevealState extends State<VibeReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = Curves.easeOut.transform(_controller.value);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - v)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// ورود پلکانی فرزندان — پورت `grid-reveal.tsx`.
class VibeGridReveal extends StatelessWidget {
  final List<Widget> children;
  final Duration stagger;
  final double offset;

  const VibeGridReveal({super.key, required this.children, this.stagger = const Duration(milliseconds: 60), this.offset = 12});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++)
          VibeReveal(delay: stagger * i, offset: offset, child: children[i]),
      ],
    );
  }
}

/* ---------- شمارنده ---------- */

/// شمارنده‌ی عددی — پورت `counter.tsx` / `odometer.tsx`.
///
/// عدد با ارقام فارسی به مقدار جدید می‌لغزد.
class VibeCounter extends StatefulWidget {
  const VibeCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 800),
    this.style,
  });

  final double value;
  final Duration duration;
  final TextStyle? style;

  @override
  State<VibeCounter> createState() => _VibeCounterState();
}

class _VibeCounterState extends State<VibeCounter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late double _from;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _from = 0;
    _controller.forward();
  }

  @override
  void didUpdateWidget(VibeCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = oldWidget.value;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final v = Curves.easeOut.transform(_controller.value);
        final current = _from + (widget.value - _from) * v;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            faNumber(current),
            style: widget.style ?? TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: context.vibe.foreground),
          ),
        );
      },
    );
  }
}

/* ---------- متن ---------- */

/// متن تایپ‌شونده — پورت `typewriter.tsx`.
class VibeTypewriter extends StatefulWidget {
  const VibeTypewriter({super.key, required this.text, this.speed = const Duration(milliseconds: 60), this.style, this.loop = false});

  final String text;
  final Duration speed;
  final TextStyle? style;
  final bool loop;

  @override
  State<VibeTypewriter> createState() => _VibeTypewriterState();
}

class _VibeTypewriterState extends State<VibeTypewriter> {
  int _chars = 0;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _step();
  }

  void _step() {
    Future.delayed(widget.speed, () {
      if (!mounted) return;
      setState(() {
        if (!_deleting && _chars < widget.text.length) {
          _chars++;
        } else if (widget.loop) {
          if (!_deleting && _chars == widget.text.length) {
            _deleting = true;
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (mounted) _step();
            });
            return;
          }
          if (_deleting && _chars > 0) {
            _chars--;
          } else {
            _deleting = false;
          }
        }
      });
      if (_chars < widget.text.length || (_deleting && _chars > 0)) _step();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final shown = widget.text.substring(0, _chars);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: shown, style: widget.style ?? TextStyle(fontSize: 14, color: t.foreground)),
          if (_chars < widget.text.length || widget.loop)
            WidgetSpan(
              child: _BlinkingCaret(color: t.brand),
            ),
        ],
      ),
    );
  }
}

class _BlinkingCaret extends StatefulWidget {
  final Color color;
  const _BlinkingCaret({required this.color});

  @override
  State<_BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<_BlinkingCaret> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(width: 2, height: 16, color: widget.color),
    );
  }
}

/// متن درخشان — پورت `text-shimmer.tsx`.
class VibeTextShimmer extends StatelessWidget {
  const VibeTextShimmer({super.key, required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: [t.mutedForeground, t.foreground, t.mutedForeground],
        stops: const [0.35, 0.5, 0.65],
      ).createShader(bounds),
      child: Text(text, style: style ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

/// چرخش کلمات — پورت `text-swap.tsx` / `word-rotate.tsx`.
class VibeWordRotate extends StatefulWidget {
  const VibeWordRotate({super.key, required this.words, this.interval = const Duration(seconds: 2), this.style});

  final List<String> words;
  final Duration interval;
  final TextStyle? style;

  @override
  State<VibeWordRotate> createState() => _VibeWordRotateState();
}

class _VibeWordRotateState extends State<VibeWordRotate> {
  int _index = 0;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _cycle();
  }

  void _cycle() {
    Future.delayed(widget.interval, () {
      if (!mounted) return;
      setState(() => _visible = false);
      Future.delayed(VibeMotion.duration, () {
        if (!mounted) return;
        setState(() {
          _index = (_index + 1) % widget.words.length;
          _visible = true;
        });
        _cycle();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: VibeMotion.duration,
      curve: VibeMotion.ease,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.2),
        duration: VibeMotion.duration,
        curve: VibeMotion.ease,
        child: Text(
          widget.words[_index],
          style: widget.style ?? TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.brand),
        ),
      ),
    );
  }
}

/* ---------- دکمه ---------- */

/// دکمه‌ی برقی — پورت `shine-button.tsx`.
class VibeShineButton extends StatefulWidget {
  const VibeShineButton({super.key, required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  State<VibeShineButton> createState() => _VibeShineButtonState();
}

class _VibeShineButtonState extends State<VibeShineButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(from: 0),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(VibeRadius.control),
          child: Stack(
            children: [
              widget.child,
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    if (_controller.status != AnimationStatus.forward) return const SizedBox.shrink();
                    return Transform.translate(
                      offset: Offset((_controller.value * 2 - 0.5) * 220, 0),
                      child: Transform.rotate(
                        angle: 0.5,
                        child: Container(width: 24, color: Colors.white.withValues(alpha: 0.35)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// دکمه‌ی ریپل — پورت `ripple-button.tsx`.
class VibeRippleButton extends StatefulWidget {
  const VibeRippleButton({super.key, required this.child, this.onPressed, this.color});

  final Widget child;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  State<VibeRippleButton> createState() => _VibeRippleButtonState();
}

class _VibeRippleButtonState extends State<VibeRippleButton> {
  final List<Widget> _ripples = [];
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return GestureDetector(
      key: _key,
      onTap: () {
        widget.onPressed?.call();
        setState(() {
          final ripple = KeyedSubtree(
            key: UniqueKey(),
            child: const _Ripple(),
          );
          _ripples.add(ripple);
        });
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) setState(() {});
        });
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(VibeRadius.control),
        child: Stack(
          children: [
            Container(
              color: (widget.color ?? t.primary).withValues(alpha: 0.0),
              child: widget.child,
            ),
            ..._ripples,
          ],
        ),
      ),
    );
  }
}

class _Ripple extends StatefulWidget {
  const _Ripple();

  @override
  State<_Ripple> createState() => _RippleState();
}

class _RippleState extends State<_Ripple> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: (1 - _controller.value) * 0.3,
          child: LayoutBuilder(
            builder: (context, constraints) => Container(
              width: math.max(constraints.maxWidth, constraints.maxHeight) * 2 * _controller.value,
              height: math.max(constraints.maxWidth, constraints.maxHeight) * 2 * _controller.value,
              decoration: BoxDecoration(shape: BoxShape.circle, color: t.foreground),
            ),
          ),
        );
      },
    );
  }
}

/* ---------- وضعیت ---------- */

/// اسکلت لرزان — کمک عمومی برای انیمیشن pulse وب.
class VibePulse extends StatefulWidget {
  const VibePulse({super.key, required this.child, this.min = 0.5, this.max = 1.0, this.period = const Duration(milliseconds: 1000)});

  final Widget child;
  final double min;
  final double max;
  final Duration period;

  @override
  State<VibePulse> createState() => _VibePulseState();
}

class _VibePulseState extends State<VibePulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: widget.min, end: widget.max).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

/// لرزش خطا — پورت `error-shake.tsx`.
class VibeErrorShake extends StatefulWidget {
  const VibeErrorShake({super.key, required this.child, this.trigger});

  /// برای لرزان‌دن، شناسه‌ی این فیلد را عوض کنید.
  final Object? trigger;
  final Widget child;

  @override
  State<VibeErrorShake> createState() => _VibeErrorShakeState();
}

class _VibeErrorShakeState extends State<VibeErrorShake> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void didUpdateWidget(VibeErrorShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final v = _controller.value;
        final shake = v < 1 ? math.sin(v * 3 * math.pi) * 6 * (1 - v) : 0.0;
        return Transform.translate(offset: Offset(shake, 0), child: child);
      },
      child: widget.child,
    );
  }
}

/* ---------- اسکرول ---------- */

/// نوار پیشرفت مطالعه — پورت `scroll-progress.tsx`.
class VibeScrollProgress extends StatelessWidget {
  const VibeScrollProgress({super.key, required this.scrollController, this.height = 3, this.color});

  final ScrollController scrollController;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        double progress = 0;
        if (scrollController.hasClients && scrollController.position.maxScrollExtent > 0) {
          progress = (scrollController.offset / scrollController.position.maxScrollExtent).clamp(0.0, 1.0);
        }
        return Container(
          height: height,
          width: double.infinity,
          color: Colors.transparent,
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: progress,
            child: Container(color: color ?? t.brand),
          ),
        );
      },
    );
  }
}

/* ---------- نوار متحرک ---------- */

/// نوار بی‌پایان — پورت `marquee.tsx`.
class VibeMarquee extends StatefulWidget {
  const VibeMarquee({super.key, required this.children, this.speed = 40.0, this.reverse = false});

  final List<Widget> children;
  final double speed;
  final bool reverse;

  @override
  State<VibeMarquee> createState() => _VibeMarqueeState();
}

class _VibeMarqueeState extends State<VibeMarquee> with SingleTickerProviderStateMixin {
  late final ScrollController _controller;
  late final AnimationController _anim;
  bool _userScrolling = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _anim.addListener(_tick);
  }

  void _tick() {
    if (_userScrolling || !_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    if (max <= 0) return;
    final next = _controller.offset + (widget.reverse ? -1 : 1) * widget.speed / 60;
    _controller.jumpTo(next > max ? 0 : (next < 0 ? max : next));
  }

  @override
  void dispose() {
    _anim.removeListener(_tick);
    _anim.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _userScrolling = true,
      onPointerUp: (_) => _userScrolling = false,
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        reverse: widget.reverse,
        child: Row(
          children: [
            ...widget.children,
            ...widget.children,
          ],
        ),
      ),
    );
  }
}
