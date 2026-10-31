import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';

/// یک درس از سرفصل.
class VibeLesson {
  final String title;
  final int minutes;
  final bool done;
  final bool locked;
  final bool current;

  const VibeLesson({required this.title, this.minutes = 0, this.done = false, this.locked = false, this.current = false});
}

/// یک سرفصل دوره.
class VibeCourseSection {
  final String title;
  final List<VibeLesson> lessons;

  const VibeCourseSection({required this.title, required this.lessons});
}

/// طرح دوره — پورت `registry/ui/course-outline.tsx`.
///
/// سرفصل‌ها با شماره‌ی فارسی، وضعیت‌های انجام‌شده/فعلی/قفل‌شده و مدت هر درس.
///
/// ```dart
/// VibeCourseOutline(sections: _sections)
/// ```
class VibeCourseOutline extends StatelessWidget {
  final List<VibeCourseSection> sections;

  const VibeCourseOutline({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    var lessonNumber = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var s = 0; s < sections.length; s++) ...[
          Padding(
            padding: EdgeInsetsDirectional.only(start: 4, bottom: 8, top: s == 0 ? 0 : 16),
            child: Text(
              sections[s].title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.foreground),
            ),
          ),
          for (final lesson in sections[s].lessons)
            _lesson(context, t, lesson, ++lessonNumber),
        ],
      ],
    );
  }

  Widget _lesson(BuildContext context, VibeTokens t, VibeLesson lesson, int number) {
    final icon = lesson.done
        ? Icon(Icons.check_circle, size: 16, color: t.success)
        : lesson.locked
            ? Icon(Icons.lock_outline, size: 16, color: t.mutedForeground.withValues(alpha: 0.6))
            : Icon(Icons.play_circle_outline, size: 16, color: lesson.current ? t.brand : t.mutedForeground);

    return Container(
      margin: const EdgeInsetsDirectional.only(start: 4, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VibeRadius.control),
        color: lesson.current ? t.accent : Colors.transparent,
        border: Border.all(color: lesson.current ? t.border : Colors.transparent),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Container(
            width: 22,
            alignment: Alignment.center,
            child: Text(fa(number), style: TextStyle(fontSize: 12, color: t.mutedForeground)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              lesson.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: lesson.current ? FontWeight.w600 : FontWeight.w400,
                color: lesson.locked ? t.mutedForeground : t.foreground,
              ),
            ),
          ),
          if (lesson.minutes > 0)
            Text("${fa(lesson.minutes)} دقیقه", style: TextStyle(fontSize: 11, color: t.mutedForeground)),
        ],
      ),
    );
  }
}

/// یادداشت درس — پورت `registry/ui/lesson-note.tsx`.
class VibeLessonNote extends StatelessWidget {
  final Widget title;
  final Widget body;

  const VibeLessonNote({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.muted.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(VibeRadius.field),
        border: BorderDirectional(start: BorderSide(color: t.brand, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sticky_note_2_outlined, size: 14, color: t.brand),
              const SizedBox(width: 6),
              DefaultTextStyle.merge(style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.foreground), child: title),
            ],
          ),
          const SizedBox(height: 6),
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 13, height: 1.7, color: t.mutedForeground),
            child: body,
          ),
        ],
      ),
    );
  }
}

/// یک سوال کوییز.
class VibeQuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const VibeQuizQuestion({required this.question, required this.options, required this.correctIndex});
}

/// کوییز — پورت `registry/ui/quiz.tsx`.
///
/// جریان سوال‌به‌سوال: گزینه‌ها، درست/غلط با رنگ‌های تم، شمارنده فارسی و
/// نتیجه‌ی نهایی با «دوباره».
///
/// ```dart
/// VibeQuiz(questions: _questions, onCompleted: (score) => print(score))
/// ```
class VibeQuiz extends StatefulWidget {
  const VibeQuiz({super.key, required this.questions, this.onCompleted, this.onRetry});

  final List<VibeQuizQuestion> questions;
  final ValueChanged<int>? onCompleted;
  final VoidCallback? onRetry;

  @override
  State<VibeQuiz> createState() => _VibeQuizState();
}

class _VibeQuizState extends State<VibeQuiz> {
  int _index = 0;
  int? _picked;
  int _score = 0;
  bool _finished = false;

  void _pick(int option) {
    if (_picked != null) return;
    setState(() => _picked = option);
    if (option == widget.questions[_index].correctIndex) _score++;
  }

  void _next() {
    if (_index + 1 < widget.questions.length) {
      setState(() {
        _index++;
        _picked = null;
      });
    } else {
      setState(() => _finished = true);
      widget.onCompleted?.call(_score);
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _picked = null;
      _score = 0;
      _finished = false;
    });
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;

    if (_finished) {
      return Column(
        children: [
          Text(
            "نتیجه: ${fa(_score)} از ${fa(widget.questions.length)}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: t.foreground),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _restart,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(VibeRadius.control),
                color: t.primary,
              ),
              child: Text("دوباره", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.primaryForeground)),
            ),
          ),
        ],
      );
    }

    final q = widget.questions[_index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                q.question,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.foreground),
              ),
            ),
            Text(
              "${fa(_index + 1)} از ${fa(widget.questions.length)}",
              style: TextStyle(fontSize: 12, color: t.mutedForeground),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < q.options.length; i++)
          Builder(
            builder: (context) {
              final isCorrect = _picked != null && i == q.correctIndex;
              final isWrong = _picked == i && i != q.correctIndex;
              return GestureDetector(
                onTap: () => _pick(i),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(VibeRadius.control),
                    border: Border.all(
                      color: isCorrect
                          ? t.success
                          : isWrong
                              ? t.destructive
                              : t.input,
                    ),
                    color: isCorrect
                        ? t.success.withValues(alpha: 0.08)
                        : isWrong
                            ? t.destructive.withValues(alpha: 0.08)
                            : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(q.options[i], style: TextStyle(fontSize: 14, color: t.foreground))),
                      if (isCorrect) Icon(Icons.check, size: 16, color: t.success),
                      if (isWrong) Icon(Icons.close, size: 16, color: t.destructive),
                    ],
                  ),
                ),
              );
            },
          ),
        if (_picked != null)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: _next,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(VibeRadius.control),
                  color: t.primary,
                ),
                child: Text(
                  _index + 1 < widget.questions.length ? "بعدی" : "پایان",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.primaryForeground),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// نقطه‌ی تعاملی روی تصویر — پورت `registry/ui/hotspot-figure.tsx`.
class VibeHotspot {
  final double x;
  final double y;
  final Widget label;

  /// مختصات کسری ۰ تا ۱ نسبت به تصویر.
  const VibeHotspot({required this.x, required this.y, required this.label});
}

/// تصویر با نقاط تعاملی شماره‌دار.
class VibeHotspotFigure extends StatefulWidget {
  const VibeHotspotFigure({
    super.key,
    required this.image,
    required this.hotspots,
    this.aspectRatio = 16 / 9,
  });

  final ImageProvider image;
  final List<VibeHotspot> hotspots;
  final double aspectRatio;

  @override
  State<VibeHotspotFigure> createState() => _VibeHotspotFigureState();
}

class _VibeHotspotFigureState extends State<VibeHotspotFigure> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(VibeRadius.surface),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(image: widget.image, fit: BoxFit.cover),
            for (var i = 0; i < widget.hotspots.length; i++)
              Positioned(
                left: widget.hotspots[i].x * 1000,
                top: widget.hotspots[i].y * 1000,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: GestureDetector(
                    onTap: () => setState(() => _open = _open == i ? null : i),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.brand,
                            border: Border.all(color: t.background, width: 2),
                          ),
                          child: Text(fa(i + 1), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: t.brandForeground)),
                        ),
                        if (_open == i)
                          PositionedDirectional(
                            start: 28,
                            top: -4,
                            width: 160,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: t.popover,
                                borderRadius: BorderRadius.circular(VibeRadius.field),
                                border: Border.all(color: t.border),
                              ),
                              child: DefaultTextStyle.merge(
                                style: TextStyle(fontSize: 12, height: 1.5, color: t.popoverForeground),
                                child: widget.hotspots[i].label,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// پوسته‌ی پخش‌کننده‌ی ویدیو — پورت `registry/ui/video-player.tsx`.
///
/// خود فلاتر نیاز به پکیج video_player دارد؛ این ویجت فقط «کروم» پخش‌کننده
/// است و سطح ویدیو از اپ از طریق [player] داده می‌شود.
class VibeVideoPlayer extends StatelessWidget {
  const VibeVideoPlayer({
    super.key,
    this.player,
    this.title,
    this.playing = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.onPlayPause,
    this.onSeek,
  });

  /// سطح ویدیوی خود اپ (مثلاً VideoPlayer(controller) از پکیج video_player).
  final Widget? player;
  final Widget? title;
  final bool playing;
  final Duration position;
  final Duration duration;
  final VoidCallback? onPlayPause;
  final ValueChanged<Duration>? onSeek;

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, "0");
    final s = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    return fa("${d.inHours > 0 ? "${d.inHours}:" : ""}$m:$s");
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final total = duration.inMilliseconds == 0 ? 1.0 : duration.inMilliseconds.toDouble();

    return Container(
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.surface),
        border: Border.all(color: t.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: player ?? Icon(Icons.videocam_off_outlined, size: 32, color: t.mutedForeground),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                if (title != null) Align(alignment: AlignmentDirectional.centerStart, child: title!),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: t.brand,
                    inactiveTrackColor: t.input,
                    thumbColor: t.brand,
                    overlayColor: Colors.transparent,
                  ),
                  child: Slider(
                    value: position.inMilliseconds.clamp(0, duration.inMilliseconds == 0 ? 0 : duration.inMilliseconds).toDouble(),
                    max: total,
                    onChanged: onSeek == null
                        ? null
                        : (v) => onSeek!(Duration(milliseconds: v.round())),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onPlayPause,
                      child: Icon(playing ? Icons.pause : Icons.play_arrow, size: 20, color: t.foreground),
                    ),
                    const SizedBox(width: 8),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        "${_fmt(position)} / ${_fmt(duration)}",
                        style: TextStyle(fontSize: 11, color: t.mutedForeground),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
