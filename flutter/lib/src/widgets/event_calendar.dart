import 'package:flutter/material.dart';

import '../jalali.dart';
import '../persian.dart';
import '../theme.dart';
import 'month_view.dart';

/// یک رویداد تقویم — پورت `CalendarEvent`.
class VibeCalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime end;

  /// تمام‌روز: زیر عدد روز می‌نشیند.
  final bool allDay;
  final String? location;

  const VibeCalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.allDay = false,
    this.location,
  });

  bool coversDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return start.isBefore(dayEnd) && (end.isAfter(dayStart) || (allDay && !end.isBefore(dayEnd)));
  }

  String get timeRange {
    if (allDay) return "تمام‌روز";
    String pad(DateTime d) => d.minute.toString().padLeft(2, "0");
    String hh(DateTime d) => d.hour.toString().padLeft(2, "0");
    return "${fa(hh(start))}:${fa(pad(start))} تا ${fa(hh(end))}:${fa(pad(end))}";
  }
}

/// تقویم رویداد — پورت `registry/calendar/event-calendar.tsx`.
///
/// نمای ماه با چیپ‌های رویداد زیر هر روز و لیست رویدادهای روز انتخابی.
///
/// ```dart
/// VibeEventCalendar(
///   events: _events,
///   onEventClick: (e) => openEvent(e),
/// )
/// ```
class VibeEventCalendar extends StatefulWidget {
  const VibeEventCalendar({
    super.key,
    this.events = const [],
    this.initialMonth,
    this.onEventClick,
    this.onDayClick,
  });

  final List<VibeCalendarEvent> events;
  final DateTime? initialMonth;
  final ValueChanged<VibeCalendarEvent>? onEventClick;
  final void Function(DateTime date, List<VibeCalendarEvent> events)? onDayClick;

  @override
  State<VibeEventCalendar> createState() => _VibeEventCalendarState();
}

class _VibeEventCalendarState extends State<VibeEventCalendar> {
  late DateTime _month;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = widget.initialMonth ?? DateTime(n.year, n.month, n.day);
  }

  List<VibeCalendarEvent> _eventsOf(DateTime day) =>
      widget.events.where((e) => e.coversDay(day)).toList();

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final selected = _selected;
    final selectedEvents = selected == null ? const <VibeCalendarEvent>[] : _eventsOf(selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VibeMonthView(
          month: _month,
          onMonthChange: (m) => setState(() => _month = m),
          selected: selected == null ? null : _keyOf(selected),
          onDayClick: (date, info) => setState(() => _selected = date),
          secondary: VibeSecondary.none,
        ),
        if (selected != null) ...[
          const SizedBox(height: 16),
          Text(
            "رویدادهای ${formatJalali(selected, weekday: true)}",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.foreground),
          ),
          const SizedBox(height: 8),
          if (selectedEvents.isEmpty)
            Text("رویدادی ثبت نشده", style: TextStyle(fontSize: 13, color: t.mutedForeground))
          else
            for (final e in selectedEvents)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: t.card,
                  borderRadius: BorderRadius.circular(VibeRadius.field),
                  border: Border.all(color: t.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: t.brand,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(
                            "${e.timeRange}${e.location != null ? " · ${e.location}" : ""}",
                            style: TextStyle(fontSize: 11, color: t.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onEventClick != null)
                      GestureDetector(
                        onTap: () => widget.onEventClick!(e),
                        child: Icon(Icons.chevron_left, size: 16, color: t.mutedForeground),
                      ),
                  ],
                ),
              ),
        ],
      ],
    );
  }

  static String _keyOf(DateTime d) {
    final m = d.month.toString().padLeft(2, "0");
    final day = d.day.toString().padLeft(2, "0");
    return "${d.year}-$m-$day";
  }
}

/// پیکر نوبت — پورت `registry/calendar/slot-picker.tsx`.
///
/// شبکه‌ی بازه‌های زمانی یک روز؛ بازه‌های رفته و گرفته غیرفعال‌اند.
///
/// ```dart
/// VibeSlotPicker(
///   day: DateTime.now(),
///   slots: [TimeSlotRange(start: 9, end: 10)],
///   selected: _slot,
///   onChanged: (s) => setState(() => _slot = s),
/// )
/// ```
class VibeSlotPicker extends StatelessWidget {
  const VibeSlotPicker({
    super.key,
    required this.day,
    required this.slots,
    this.selected,
    this.onChanged,
  });

  /// روزی که نوبت گرفته می‌شود.
  final DateTime day;
  final List<VibeTimeSlot> slots;

  /// بازه‌ی انتخابی کنترل‌شده.
  final VibeTimeSlot? selected;
  final ValueChanged<VibeTimeSlot>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatJalali(day, weekday: true),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.foreground),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final slot in slots)
              Builder(builder: (context) {
                final slotStart = DateTime(day.year, day.month, day.day, slot.startHour, slot.startMinute);
                final past = slotStart.isBefore(now);
                final active = identical(selected, slot) || (selected != null && selected!.startHour == slot.startHour && selected!.startMinute == slot.startMinute);
                return GestureDetector(
                  onTap: past ? null : () => onChanged?.call(slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(VibeRadius.control),
                      border: Border.all(color: active ? t.primary : t.input),
                      color: active ? t.primary : (past ? t.muted : Colors.transparent),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        slot.label,
                        style: TextStyle(
                          fontSize: 13,
                          color: past
                              ? t.mutedForeground.withValues(alpha: 0.5)
                              : active
                                  ? t.primaryForeground
                                  : t.foreground,
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ],
    );
  }
}

/// یک بازه‌ی زمانی نوبت.
class VibeTimeSlot {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const VibeTimeSlot({required this.startHour, this.startMinute = 0, required this.endHour, this.endMinute = 0});

  String get label {
    String f(int v) => v.toString().padLeft(2, "0");
    return "${fa(f(startHour))}:${fa(f(startMinute))} – ${fa(f(endHour))}:${fa(f(endMinute))}";
  }
}

/// برنامه‌ی روز — پورت `registry/calendar/agenda-view.tsx`.
///
/// رویدادهای یک روز به ترتیب زمانی با خط زمان.
///
/// ```dart
/// VibeAgendaView(day: DateTime.now(), events: _events)
/// ```
class VibeAgendaView extends StatelessWidget {
  const VibeAgendaView({super.key, required this.day, this.events = const [], this.onEventClick});

  final DateTime day;
  final List<VibeCalendarEvent> events;
  final ValueChanged<VibeCalendarEvent>? onEventClick;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    final sorted = [...events.where((e) => e.coversDay(day))]
      ..sort((a, b) => a.start.compareTo(b.start));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatJalali(day, weekday: true),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.foreground),
        ),
        const SizedBox(height: 12),
        if (sorted.isEmpty)
          Text("برنامه‌ای برای این روز نیست", style: TextStyle(fontSize: 13, color: t.mutedForeground))
        else
          for (final e in sorted)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 76,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          e.allDay ? "همه" : e.timeRange.split(" تا ").first,
                          style: TextStyle(fontSize: 11, color: t.mutedForeground),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(margin: const EdgeInsets.only(top: 4), width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: t.brand)),
                      Expanded(child: Container(width: 1, color: t.border)),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: onEventClick == null ? null : () => onEventClick!(e),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            if (!e.allDay)
                              Text(e.timeRange, style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                            if (e.location != null)
                              Text(e.location!, style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                          ],
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
}
