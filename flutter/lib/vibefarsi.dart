/// وایب‌فارسی برای فلاتر — کامپوننت‌های فارسی راست‌چین با اعداد فارسی،
/// تومان و تقویم شمسی داخل خود ویجت‌ها.
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

export 'src/persian.dart';
export 'src/jalali.dart';
export 'src/iran.dart';
export 'src/iran_divisions.dart';
export 'src/theme.dart';
export 'src/widgets/button.dart';
