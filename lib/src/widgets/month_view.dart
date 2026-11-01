import 'package:flutter/material.dart';

import '../calendar_utils.dart';
import '../hijri.dart';
import '../iran_holidays.dart';
import '../jalali.dart';
import '../persian.dart';
import '../theme.dart';

/// اطلاعات یک روز برای رندر تقویم — پورت `DayInfo`.
class VibeDayInfo {
  final String key;
  final DateTime date;
  final bool isToday;
  final bool isWeekend;
  final List<Occasion> occasions;
  final Occasion? holiday;

  const VibeDayInfo({
    required this.key,
    required this.date,
    required this.isToday,
    required this.isWeekend,
    required this.occasions,
    this.holiday,
  });
}

VibeDayInfo _dayInfo(DateTime date, List<int> weekend, DateTime today) {
  final m = date.month.toString().padLeft(2, "0");
  final d = date.day.toString().padLeft(2, "0");
  final key = "${date.year}-$m-$d";
  final occasions = iranOccasions(key);
  return VibeDayInfo(
    key: key,
    date: date,
    isToday: date.year == today.year && date.month == today.month && date.day == today.day,
    isWeekend: weekend.contains(jalaliWeekday(date)),
    occasions: occasions,
    holiday: occasions.where((o) => o.holiday).firstOrNull,
  );
}

/// نمای ماه — پورت `registry/calendar/month-view.tsx`.
///
/// گرید شمسی با هفته‌های شنبه‌شروع، روزهای تعطیل رنگی، دوتایی دومین تاریخ
/// (قمری/میلادی اختیاری) و روزِ امروز با دایره‌ی برند.
///
/// ```dart
/// VibeMonthView(
///   month: _month,
///   onMonthChange: (m) => setState(() => _month = m),
///   selected: _selected,
///   onDayClick: (date, info) => print(info.key),
///   secondary: VibeSecondary.hijri,
/// )
/// ```
class VibeMonthView extends StatefulWidget {
  const VibeMonthView({
    super.key,
    this.month,
    this.initialMonth,
    this.onMonthChange,
    this.selected,
    this.onDayClick,
    this.secondary = VibeSecondary.hijri,
    this.weekend = const [6],
    this.showToolbar = true,
    this.fixedWeeks = true,
  });

  /// ماهِ نمایشی کنترل‌شده (هر روز از آن ماه).
  final DateTime? month;
  final DateTime? initialMonth;
  final ValueChanged<DateTime>? onMonthChange;

  /// کلید روز انتخابی «YYYY-MM-DD».
  final String? selected;
  final void Function(DateTime date, VibeDayInfo info)? onDayClick;

  /// تاریخ دوم زیر عدد شمسی هر روز.
  final VibeSecondary secondary;

  /// روزهای تعطیل هفته، ۰ = شنبه … ۶ = جمعه.
  final List<int> weekend;
  final bool showToolbar;
  final bool fixedWeeks;

  @override
  State<VibeMonthView> createState() => _VibeMonthViewState();
}

/// تاریخ دوم روزها.
enum VibeSecondary { hijri, gregorian, none }

class _VibeMonthViewState extends State<VibeMonthView> {
  late DateTime _cursor;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _cursor = widget.initialMonth ?? DateTime(n.year, n.month, n.day);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final today = DateTime.now();
    final cursor = widget.month ?? _cursor;
    final j = toJalali(cursor);
    final weeks = monthGrid(j.jy, j.jm, fixedWeeks: widget.fixedWeeks);
    final nowJ = toJalali(today);

    final header = Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                monthTitle(j.jy, j.jm),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.foreground),
              ),
              if (widget.secondary == VibeSecondary.hijri)
                Text(
                  "${formatHijri(toGregorian(j.jy, j.jm, 1), year: false)} – ${formatHijri(toGregorian(j.jy, j.jm, jalaliMonthLength(j.jy, j.jm)))}",
                  style: TextStyle(fontSize: 11, color: t.mutedForeground),
                ),
            ],
          ),
        ),
        _nav(context, t, Icons.chevron_right, () => _go(addJalaliMonths(cursor, -1)), tooltip: "ماه قبل"),
        _nav(context, t, Icons.chevron_left, () => _go(addJalaliMonths(cursor, 1)), tooltip: "ماه بعد"),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showToolbar) Padding(padding: const EdgeInsets.only(bottom: 12), child: header),
        Container(
          decoration: BoxDecoration(
            color: t.card,
            borderRadius: BorderRadius.circular(VibeRadius.surface),
            border: Border.all(color: t.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // سرستون روزهای هفته: شنبه اول.
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: t.muted.withValues(alpha: 0.4),
                child: Row(
                  children: [
                    for (final w in jalaliWeekdaysShort)
                      Expanded(
                        child: Center(
                          child: Text(w, style: TextStyle(fontSize: 12, color: t.mutedForeground)),
                        ),
                      ),
                  ],
                ),
              ),
              for (final week in weeks)
                Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: t.border))),
                  child: Row(
                    children: [
                      for (final date in week)
                        Expanded(child: _dayCell(context, t, date, j, today, nowJ)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _nav(BuildContext context, VibeTokens t, IconData icon, VoidCallback onTap, {required String tooltip}) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      color: t.mutedForeground,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
    );
  }

  void _go(DateTime next) {
    if (widget.month == null) setState(() => _cursor = next);
    widget.onMonthChange?.call(next);
  }

  Widget _dayCell(BuildContext context, VibeTokens t, DateTime date, JalaliDate monthJ, DateTime today, JalaliDate nowJ) {
    final info = _dayInfo(date, widget.weekend, today);
    final dj = toJalali(date);
    final outside = dj.jm != monthJ.jm;
    final selected = widget.selected == info.key;
    final isHolidayCell = info.holiday != null || info.isWeekend;

    final number = Center(
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: info.isToday ? t.brand : (selected ? t.primary : Colors.transparent),
        ),
        child: Text(
          fa(dj.jd),
          style: TextStyle(
            fontSize: 13,
            fontWeight: info.isToday || selected ? FontWeight.w700 : FontWeight.w400,
            color: info.isToday
                ? t.brandForeground
                : selected
                    ? t.primaryForeground
                    : info.holiday != null
                        ? t.destructive
                        : (outside ? t.mutedForeground.withValues(alpha: 0.5) : t.foreground),
          ),
        ),
      ),
    );

    String? secondary;
    if (widget.secondary == VibeSecondary.hijri) {
      final h = toHijri(date);
      secondary = h.hd == 1 ? hijriMonths[h.hm - 1] : fa(h.hd);
    } else if (widget.secondary == VibeSecondary.gregorian) {
      secondary = fa(date.day);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onDayClick?.call(date, info),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: t.border)),
          color: isHolidayCell ? t.destructive.withValues(alpha: 0.04) : Colors.transparent,
        ),
        child: Column(
          children: [
            number,
            if (secondary != null)
              Text(
                secondary,
                style: TextStyle(fontSize: 9, color: t.mutedForeground.withValues(alpha: outside ? 0.4 : 1)),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            if (!outside && info.occasions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  info.occasions.first.title,
                  style: TextStyle(fontSize: 9, height: 1.3, color: info.holiday != null ? t.destructive : t.mutedForeground),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
