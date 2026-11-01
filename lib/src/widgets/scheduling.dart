import 'package:flutter/material.dart';

import '../jalali.dart';
import '../persian.dart';
import '../theme.dart';
import 'event_calendar.dart';

/// نمودار گانت — پورت `registry/calendar/gantt-chart.tsx`.
///
/// ردیف‌های کار با نوار بازه روی محور روزهای شمسی؛ روزهای تعطیل ستون رنگی.
///
/// ```dart
/// VibeGanttChart(rows: [VibeGanttRow(title: Text("طراحی"), start: d1, end: d2)])
/// ```
class VibeGanttChart extends StatelessWidget {
  const VibeGanttChart({
    super.key,
    required this.rows,
    this.start,
    this.end,
    this.rowHeight = 40,
    this.labelWidth = 140,
  });

  final List<VibeGanttRow> rows;

  /// بازه‌ی محور؛ پیش‌فرض از کمینه تا بیشینه‌ی کارها.
  final DateTime? start;
  final DateTime? end;
  final double rowHeight;
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final lo = start ?? rows.map((r) => r.start).reduce((a, b) => a.isBefore(b) ? a : b);
    final hi = end ?? rows.map((r) => r.end).reduce((a, b) => a.isAfter(b) ? a : b);
    final totalDays = hi.difference(lo).inDays + 1;
    final today = DateTime.now();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // سرستون روزها.
          Row(
            children: [
              SizedBox(
                width: labelWidth,
                child: Text("کار", style: TextStyle(fontSize: 11, color: t.mutedForeground)),
              ),
              for (var d = 0; d < totalDays; d++)
                SizedBox(
                  width: 28,
                  child: Center(
                    child: Text(
                      fa(toJalali(lo.add(Duration(days: d))).jd),
                      style: TextStyle(
                        fontSize: 10,
                        color: _isWeekendOrHoliday(lo.add(Duration(days: d))) ? t.destructive : t.mutedForeground,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          for (final row in rows)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8, start: 4),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(fontSize: 13, color: t.foreground),
                      overflow: TextOverflow.ellipsis,
                      child: row.title,
                    ),
                  ),
                ),
                for (var d = 0; d < totalDays; d++)
                  Builder(
                    builder: (context) {
                      final day = lo.add(Duration(days: d));
                      final inBar = !day.isBefore(DateTime(row.start.year, row.start.month, row.start.day)) && !day.isAfter(DateTime(row.end.year, row.end.month, row.end.day));
                      final isToday = day.year == today.year && day.month == today.month && day.day == today.day;
                      final weekendCol = _isWeekendOrHoliday(day);
                      return Container(
                        width: 28,
                        height: rowHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday
                              ? t.brand.withValues(alpha: 0.12)
                              : weekendCol
                                  ? t.destructive.withValues(alpha: 0.04)
                                  : null,
                          border: BorderDirectional(start: BorderSide(color: t.border.withValues(alpha: 0.5))),
                        ),
                        child: inBar
                            ? Container(
                                height: 14,
                                decoration: BoxDecoration(
                                  color: t.brand,
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(d == totalDays - 1 || !_prevInBar(row, lo, d) ? 999 : 0),
                                    right: Radius.circular(!_nextInBar(row, lo, d, totalDays) ? 999 : 0),
                                  ),
                                ),
                              )
                            : null,
                      );
                    },
                  ),
              ],
            ),
        ],
      ),
    );
  }

  bool _prevInBar(VibeGanttRow row, DateTime lo, int d) {
    final prev = lo.add(Duration(days: d - 1));
    return !prev.isBefore(DateTime(row.start.year, row.start.month, row.start.day));
  }

  bool _nextInBar(VibeGanttRow row, DateTime lo, int d, int totalDays) {
    final next = lo.add(Duration(days: d + 1));
    return !next.isAfter(DateTime(row.end.year, row.end.month, row.end.day)) && d + 1 < totalDays;
  }

  bool _isWeekendOrHoliday(DateTime day) => jalaliWeekday(day) == 6;
}

/// یک ردیف گانت.
class VibeGanttRow {
  final Widget title;
  final DateTime start;
  final DateTime end;

  const VibeGanttRow({required this.title, required this.start, required this.end});
}

/// شیفت کاری — پورت `registry/calendar/shift-scheduler.tsx`.
class VibeShift {
  final int startHour;
  final int endHour;
  final String label;

  const VibeShift({required this.startHour, required this.endHour, required this.label});
}

/// برنامه‌ی هفتگی شیفت‌ها؛ هر روز فهرستی از شیفت‌ها دارد.
class VibeShiftScheduler extends StatelessWidget {
  const VibeShiftScheduler({
    super.key,
    required this.weekShifts,
    this.selectedDay,
    this.onDaySelect,
  });

  /// برای هر روز هفته (شنبه=۰) فهرست شیفت‌ها.
  final Map<int, List<VibeShift>> weekShifts;
  final int? selectedDay;
  final ValueChanged<int>? onDaySelect;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;

    return Column(
      children: [
        Row(
          children: [
            for (var d = 0; d < 7; d++)
              Expanded(
                child: GestureDetector(
                  onTap: onDaySelect == null ? null : () => onDaySelect!(d),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(VibeRadius.control),
                      color: selectedDay == d ? t.primary : t.muted,
                    ),
                    child: Text(
                      jalaliWeekdaysShort[d],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selectedDay == d ? t.primaryForeground : t.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        for (final entry in weekShifts.entries)
          if (selectedDay == null || selectedDay == entry.key)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(jalaliWeekdaysShort[entry.key], style: TextStyle(fontSize: 12, color: t.mutedForeground)),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      children: [
                        for (final shift in entry.value)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(VibeRadius.control),
                              color: t.card,
                              border: Border.all(color: t.border),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                "${fa(shift.startHour)}:۰۰ – ${fa(shift.endHour)}:۰۰",
                                style: TextStyle(fontSize: 12, color: t.foreground),
                              ),
                            ),
                          ),
                        if (entry.value.isEmpty)
                          Text("شیفت ثبت نشده", style: TextStyle(fontSize: 12, color: t.mutedForeground)),
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

/// شبکه‌ی زمانی روز — پورت `registry/calendar/time-grid.tsx`.
class VibeTimeGrid extends StatelessWidget {
  const VibeTimeGrid({
    super.key,
    this.startHour = 8,
    this.endHour = 20,
    this.events = const [],
    this.day,
    this.hourHeight = 48,
    this.onEventClick,
  });

  final int startHour;
  final int endHour;
  final List<VibeCalendarEvent> events;
  final DateTime? day;
  final double hourHeight;
  final ValueChanged<VibeCalendarEvent>? onEventClick;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final hours = endHour - startHour;

    return SizedBox(
      height: hours * hourHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Column(
              children: [
                for (var h = startHour; h < endHour; h++)
                  SizedBox(
                    height: hourHeight,
                    child: Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 6, top: 0),
                        child: Transform.translate(
                          offset: const Offset(0, -8),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text("${fa(h)}:۰۰", style: TextStyle(fontSize: 10, color: t.mutedForeground)),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
          ),
          ),
          Expanded(
            child: Stack(
              children: [
                Column(
                  children: [
                    for (var h = startHour; h < endHour; h++)
                      Container(
                        height: hourHeight,
                        decoration: BoxDecoration(border: Border(top: BorderSide(color: t.border))),
                      ),
                  ],
                ),
                for (final e in events.where((e) => day == null || e.coversDay(day!)))
                  Builder(
                    builder: (context) {
                      final startMinutes = (e.start.hour * 60 + e.start.minute) - startHour * 60;
                      final durationMinutes = e.end.difference(e.start).inMinutes.clamp(30, hours * 60);
                      if (startMinutes < 0) return const SizedBox.shrink();
                      return PositionedDirectional(
                        top: startMinutes / 60 * hourHeight,
                        start: 4,
                        end: 4,
                        height: durationMinutes / 60 * hourHeight - 4,
                        child: GestureDetector(
                          onTap: onEventClick == null ? null : () => onEventClick!(e),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: t.brand.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: BorderDirectional(start: BorderSide(color: t.brand, width: 3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: t.foreground), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(e.timeRange, style: TextStyle(fontSize: 10, color: t.mutedForeground)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
