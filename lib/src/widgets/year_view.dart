import 'package:flutter/material.dart';

import '../hijri.dart';
import '../iran_holidays.dart';
import '../jalali.dart';
import '../persian.dart';
import '../theme.dart';
import '../calendar_utils.dart';

/// نمای سال — پورت `registry/calendar/year-view.tsx`.
///
/// دوازده ماه کوچک؛ هر روز تعطیل رنگ destructive و امروز دایره‌ی برند.
///
/// ```dart
/// VibeYearView(year: 1405, selected: _day, onDayClick: (d) => …)
/// ```
class VibeYearView extends StatelessWidget {
  const VibeYearView({
    super.key,
    required this.year,
    this.selected,
    this.onDayClick,
    this.showHijriLabel = false,
  });

  /// سال شمسی نمایشی.
  final int year;

  /// روز انتخابی کنترل‌شده.
  final DateTime? selected;
  final ValueChanged<DateTime>? onDayClick;

  /// برچسب قمری زیر عنوان ماه.
  final bool showHijriLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final today = DateTime.now();

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (var jm = 1; jm <= 12; jm++)
          _miniMonth(context, t, jm, today),
      ],
    );
  }

  Widget _miniMonth(BuildContext context, VibeTokens t, int jm, DateTime today) {
    final weeks = monthGrid(year, jm);
    final length = jalaliMonthLength(year, jm);
    final first = toGregorian(year, jm, 1);

    return Container(
      width: 232,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.field),
        border: Border.all(color: t.border),
      ),
      child: Column(
        children: [
          Text(
            showHijriLabel
                ? "${jalaliMonths[jm - 1]} ${fa(year)}"
                : "${jalaliMonths[jm - 1]} ${fa(year)}",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.foreground),
          ),
          if (showHijriLabel)
            Text(
              formatHijri(first, year: false),
              style: TextStyle(fontSize: 10, color: t.mutedForeground),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final w in jalaliWeekdaysShort)
                Expanded(
                  child: Center(
                    child: Text(w, style: TextStyle(fontSize: 9, color: t.mutedForeground)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          for (final week in weeks)
            Row(
              children: [
                for (final date in week)
                  Expanded(
                    child: _day(context, t, date, jm, length, today),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _day(BuildContext context, VibeTokens t, DateTime date, int monthNum, int monthLen, DateTime today) {
    final j = toJalali(date);
    final outside = j.jm != monthNum;
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
    final isSelected = selected != null &&
        selected!.year == date.year &&
        selected!.month == date.month &&
        selected!.day == date.day;
    final key = _keyOf(date);
    final holiday = iranOccasions(key).where((o) => o.holiday).isNotEmpty;
    final weekend = j.jd >= 1 && j.jd <= monthLen && jalaliWeekday(date) == 6;

    return GestureDetector(
      onTap: outside || onDayClick == null ? null : () => onDayClick!(date),
      child: Container(
        height: 24,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isToday
              ? t.brand
              : isSelected
                  ? t.primary
                  : null,
        ),
        child: Text(
          outside ? "" : fa(j.jd),
          style: TextStyle(
            fontSize: 10,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            color: outside
                ? Colors.transparent
                : isToday
                    ? t.brandForeground
                    : isSelected
                        ? t.primaryForeground
                        : holiday || weekend
                            ? t.destructive
                            : t.foreground,
          ),
        ),
      ),
    );
  }

  static String _keyOf(DateTime d) {
    final m = d.month.toString().padLeft(2, "0");
    final day = d.day.toString().padLeft(2, "0");
    return "${d.year}-$m-$day";
  }
}

/// فهرست مناسبت‌ها — پورت `registry/calendar/occasions-list.tsx`.
///
/// مناسبت‌های یک بازه‌ی شمسی با نشان تعطیل/غیرتعطیل و تاریخ قمریِ
/// مناسبت‌های مذهبی.
///
/// ```dart
/// VibeOccasionsList(fromJalali: JalaliDate.now(), months: 6)
/// ```
class VibeOccasionsList extends StatelessWidget {
  const VibeOccasionsList({
    super.key,
    this.fromJalali,
    this.months = 12,
    this.holidaysOnly = false,
  });

  /// شروع بازه؛ پیش‌فرض اول امسال.
  final JalaliDate? fromJalali;

  /// چند ماه جلوتر را بپوشاند.
  final int months;

  /// فقط تعطیلات رسمی.
  final bool holidaysOnly;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final start = fromJalali ?? JalaliDate.now();
    // سال کامل از فروردین برای پوشش مناسبت‌ها.
    final occasions = occasionsOf(start.jy).where((o) => holidaysOnly ? o.holiday : true).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final o in occasions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: o.holiday ? t.destructive : t.mutedForeground.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: o.holiday ? t.destructive : t.foreground,
                        ),
                      ),
                      Text(
                        formatJalali(o.date, weekday: true) + (o.approximate ? " (تقریبی)" : ""),
                        style: TextStyle(fontSize: 11, color: t.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
