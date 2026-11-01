/// وایب‌فارسی برای فلاتر — پورت رجیستری vibefarsi.ir به Dart.
///
/// کامپوننت‌های فارسی راست‌چین با اعداد فارسی، تومان و تقویم شمسی داخل خود
/// ویجت‌ها. شروع:
///
/// ```dart
/// import 'package:vibefarsi/vibefarsi.dart';
///
/// MaterialApp(
///   theme: VibeTheme.dark(),
///   builder: (context, child) => Directionality(
///     textDirection: TextDirection.rtl, child: child!),
/// )
/// ```
library;

/* ---------- پایه ---------- */
export 'src/persian.dart';
export 'src/jalali.dart';
export 'src/hijri.dart';
export 'src/iran.dart';
export 'src/iran_divisions.dart';
export 'src/iran_holidays.dart';
export 'src/calendar_utils.dart';
export 'src/theme.dart';

/* ---------- ویجت‌های UI ---------- */
export 'src/widgets/accordion.dart';
export 'src/widgets/address_picker.dart';
export 'src/widgets/amount_input.dart';
export 'src/widgets/animations.dart';
export 'src/widgets/avatar.dart';
export 'src/widgets/backgrounds.dart';
export 'src/widgets/badge.dart';
export 'src/widgets/blocks.dart';
export 'src/widgets/breadcrumb.dart';
export 'src/widgets/button.dart';
export 'src/widgets/card.dart';
export 'src/widgets/card_number_input.dart';
export 'src/widgets/carousel.dart';
export 'src/widgets/charts.dart';
export 'src/widgets/charts_extra.dart';
export 'src/widgets/checkbox.dart';
export 'src/widgets/collapsible.dart';
export 'src/widgets/combobox.dart';
export 'src/widgets/combobox_async.dart';
export 'src/widgets/command.dart';
export 'src/widgets/context_menu.dart';
export 'src/widgets/data_table.dart';
export 'src/widgets/date_picker.dart';
export 'src/widgets/dialog.dart';
export 'src/widgets/dropdown_menu.dart';
export 'src/widgets/education.dart';
export 'src/widgets/empty_state.dart';
export 'src/widgets/event_calendar.dart';
export 'src/widgets/file_upload.dart';
export 'src/widgets/form.dart';
export 'src/widgets/hover_card.dart';
export 'src/widgets/iban_input.dart';
export 'src/widgets/input.dart';
export 'src/widgets/kbd.dart';
export 'src/widgets/month_view.dart';
export 'src/widgets/multi_select.dart';
export 'src/widgets/national_id_input.dart';
export 'src/widgets/notification_inbox.dart';
export 'src/widgets/number_field.dart';
export 'src/widgets/otp_field.dart';
export 'src/widgets/pagination.dart';
export 'src/widgets/password_input.dart';
export 'src/widgets/phone_input.dart';
export 'src/widgets/plate_input.dart';
export 'src/widgets/popover.dart';
export 'src/widgets/postal_code_input.dart';
export 'src/widgets/price.dart';
export 'src/widgets/progress.dart';
export 'src/widgets/prompt_input.dart';
export 'src/widgets/radio_group.dart';
export 'src/widgets/range_slider.dart';
export 'src/widgets/rating.dart';
export 'src/widgets/scheduling.dart';
export 'src/widgets/scroll_area.dart';
export 'src/widgets/search_input.dart';
export 'src/widgets/segmented_control.dart';
export 'src/widgets/select.dart';
export 'src/widgets/separator.dart';
export 'src/widgets/sheet.dart';
export 'src/widgets/sidebar.dart';
export 'src/widgets/skeleton.dart';
export 'src/widgets/slider.dart';
export 'src/widgets/spinner.dart';
export 'src/widgets/stat.dart';
export 'src/widgets/stepper.dart';
export 'src/widgets/switch.dart';
export 'src/widgets/table.dart';
export 'src/widgets/tabs.dart';
export 'src/widgets/tags_input.dart';
export 'src/widgets/textarea.dart';
export 'src/widgets/time_picker.dart';
export 'src/widgets/timeline.dart';
export 'src/widgets/toast.dart';
export 'src/widgets/toggle.dart';
export 'src/widgets/tooltip.dart';
export 'src/widgets/year_view.dart';
