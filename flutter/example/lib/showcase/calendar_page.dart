import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// دسته‌ی «تقویم» مثل سایت اصلی: ماه، انتخابگر، سال، رویداد، شیفت، گانت.
class CalendarShowcase extends StatefulWidget {
  const CalendarShowcase({super.key});

  @override
  State<CalendarShowcase> createState() => _CalendarShowcaseState();
}

class _CalendarShowcaseState extends State<CalendarShowcase> {
  DateTime? _picked;
  DateTime _month = DateTime(2025, 10, 22); // ۳۰ مهر ۱۴۰۴ — جدول رسمی تعطیلات
  int? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowSection(
          title: "نمای ماه با تعطیلات رسمی",
          child: VibeMonthView(
            month: _month,
            onMonthChange: (m) => setState(() => _month = m),
            selected: _picked == null ? null : _keyOf(_picked!),
            onDayClick: (date, info) => setState(() => _picked = date),
            secondary: VibeSecondary.hijri,
          ),
        ),
        ShowSection(
          title: "انتخابگر تاریخ",
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 260,
                child: VibeDatePicker(value: _picked, onChanged: (d) => setState(() => _picked = d)),
              ),
              SizedBox(
                width: 320,
                child: VibeDateRangePicker(onChanged: (_) {}),
              ),
            ],
          ),
        ),
        ShowSection(
          title: "انتخابگر زمان و شمارش معکوس",
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VibeTimePicker(onChanged: (_) {}),
              const SizedBox(width: 24),
              VibeCountdown(
                target: DateTime(2026, 3, 21), // نوروز ۱۴۰۵
                label: const Text("تا نوروز ۱۴۰۵"),
              ),
            ],
          ),
        ),
        ShowSection(
          title: "رویدادها",
          child: VibeEventCalendar(
            initialMonth: _month,
            events: [
              VibeCalendarEvent(
                id: "e1",
                title: "جلسه‌ی تیم محصول",
                start: DateTime(2025, 10, 22, 10),
                end: DateTime(2025, 10, 22, 11, 30),
                location: "اتاق جلسات",
              ),
              VibeCalendarEvent(
                id: "e2",
                title: "انتشار نسخه",
                start: DateTime(2025, 10, 22, 14),
                end: DateTime(2025, 10, 22, 15),
              ),
            ],
          ),
        ),
        ShowSection(
          title: "انتخاب نوبت",
          child: VibeSlotPicker(
            day: DateTime(2025, 10, 22),
            slots: const [
              VibeTimeSlot(startHour: 9, endHour: 10),
              VibeTimeSlot(startHour: 10, endHour: 11),
              VibeTimeSlot(startHour: 14, endHour: 15),
              VibeTimeSlot(startHour: 16, endHour: 17),
            ],
          ),
        ),
        ShowSection(
          title: "برنامه‌ی شیفت هفتگی",
          child: VibeShiftScheduler(
            selectedDay: _selectedDay,
            onDaySelect: (d) => setState(() => _selectedDay = d),
            weekShifts: const {
              0: [VibeShift(startHour: 9, endHour: 14, label: "صبح")],
              1: [VibeShift(startHour: 9, endHour: 14, label: "صبح"), VibeShift(startHour: 16, endHour: 20, label: "عصر")],
              3: [VibeShift(startHour: 16, endHour: 20, label: "عصر")],
            },
          ),
        ),
        ShowSection(
          title: "گانت",
          child: VibeGanttChart(rows: [
            VibeGanttRow(
              title: const Text("طراحی رابط"),
              start: DateTime(2025, 10, 20),
              end: DateTime(2025, 10, 23),
            ),
            VibeGanttRow(
              title: const Text("پیاده‌سازی"),
              start: DateTime(2025, 10, 22),
              end: DateTime(2025, 10, 27),
            ),
            VibeGanttRow(
              title: const Text("تست و انتشار"),
              start: DateTime(2025, 10, 26),
              end: DateTime(2025, 10, 29),
            ),
          ]),
        ),
      ],
    );
  }

  static String _keyOf(DateTime d) {
    final m = d.month.toString().padLeft(2, "0");
    final day = d.day.toString().padLeft(2, "0");
    return "${d.year}-$m-$day";
  }
}
