# AGENTS.md — راهنمای ایجنت‌ها برای مخزن وایب‌فارسی (فلاتر)

این مخزن **پکیج فلاتر وایب‌فارسی** است: پورت کامپوننت‌های [vibefarsi.ir](https://vibefarsi.ir) (React + Tailwind) به Dart. هر کامپوننت راست‌چین است، اعداد را فارسی نشان می‌دهد و تقویم شمسی و اعتبارسنجی ایرانی داخل خودش دارد. اگر کسی مخزن را کلون کند، باید بدون هیچ تنظیم اضافه‌ای بتواند در پروژه فلاتر خودش از آن استفاده کند.

هر تغییر کد باید این قوانین را رعایت کند. قبل از کامیت، بخش «تعریف اتمام کار» را کامل کن.

## چیدمان مخزن

```
pubspec.yaml            پکیج اصلی (name: vibefarsi)
lib/
  vibefarsi.dart        barrel — تنها نقطه‌ی export؛ هیچ فایل دیگری export نمی‌شود
  src/
    theme.dart          VibeTokens (ThemeExtension) + ۶ تم رسمی + VibeTheme/Motion/Radius/Press
    persian.dart        fa، en، faNumber، formatToman، faPercent، faFileSize، mulberry32
    jalali.dart         JalaliDate، toJalali/toGregorian (Borkowski)، ماه‌ها و روزهای هفته
    hijri.dart          هجری قمری با جدول رسمی ماه‌های ایران (۱۴۴۶–۱۴۴۸) + fallback تقریبی
    iran_holidays.dart  تعطیلات رسمی ۱۴۰۴/۱۴۰۵ (۱۳ قاعده خورشیدی + ۱۸ قاعده قمری + چهارشنبه‌سوری)
    iran.dart           اعتبارسنجی موبایل/شبا/کدملی/کارت/پلاک/کدپستی + timeAgo
    iran_divisions.dart ۳۱ استان و شهرها (مرتب‌شده با collator فارسی)
    calendar_utils.dart monthGrid (شنبه‌شروع)، addJalaliMonths، startOfJalaliWeek
    widgets/            همه‌ی ویجت‌ها — یک فایل به ازای هر slug رجیستری وب
example/                اپ نمایشی با دسته‌بندی سایت اصلی (وب + macOS)
test/                   تست‌های foundation + ویجتِ صفحات showcase
docs/
  PORTING.md            قرارداد کامل پورت وب → فلاتر و نگاشت کلاس‌ها
  screenshots/          ۸ اسکرین‌شات دسته‌بندی‌ها (در README استفاده می‌شود)
```

## دستورها

```bash
flutter pub get                    # اگر pub.dev در دسترس نبود: PUB_HOSTED_URL=https://pub.flutter-io.cn flutter pub get
dart analyze .                     # در ریشه؛ باید «No issues found!» بدهد
flutter test                       # تست‌های پکیج (foundation + ویجت)
cd example && flutter pub get && flutter test   # تست‌های اپ نمایشی (صفحات واقعی showcase)
cd example && flutter run -d chrome             # اجرای اپ نمایشی روی وب
cd example && flutter build web --release       # بیلد وب (برای اسکرین‌شات/استقرار)
```

هیچ‌وقت `dart pub add` بدون به‌روزرسانی هم‌زمان pubspec و barrel اجرا نکن؛ وابستگی جدید فقط با دلیل قوی (قانون «بدون وابستگی جدید» را ببین).

## قوانین طلایی طراحی — در هر ویجت، بدون استثنا

1. **راست‌چین واقعی.** هیچ `Alignment.left`، `EdgeInsets.only(left:)`، `TextAlign.left` ممنوع. به‌جایش `AlignmentDirectional`، `EdgeInsetsDirectional`، `TextAlign.start`، و `Row` (خودش جهت‌آگاه است). فرم‌های عددی (موبایل، شبا، کارت، OTP، کد پستی، پلاک) داخل `Directionality(textDirection: TextDirection.ltr)` قرار می‌گیرند تا ارقام ترتیب طبیعی خود را نگه دارند.
2. **اعداد فارسی.** هیچ عدد لاتینی در UI نمایش داده نمی‌شود: `fa`، `faNumber`، `formatToman` از `src/persian.dart`. ورودی کاربر با `en` نرمال می‌شود. متن‌ها و ثابت‌های فارسی از TSX وب کپی می‌شوند — بازنویسی ممنوع.
3. **رنگ فقط از توکن.** `context.vibe` (از `theme.dart`). رنگ هاردکد فقط `Colors.transparent` و `Colors.white` جایی که وب هم سفید مطلق دارد (مثل متن روی destructive). توکن‌ها: `background, foreground, card, popover, primary, secondary, muted, mutedForeground, accent, destructive, success, warning, brand, brandForeground, ring, border, input`.
4. **شکل و حرکت از زبان طراحی:** `VibeRadius.control/field/surface/overlay`، `VibeMotion.duration/ease` (۲۰۰ms، cubic(0.2,0,0,1))، `VibePress.scale` (۰٫۹۸). هیچ انیمیشنی با duration دلخواه نوشته نمی‌شود.
5. **بدون وابستگی جدید** جز `fl_chart` (فقط نمودارها). آیکون همیشه `IconData`/`Widget` از بیرون می‌آید؛ پکیج آیکون اضافه نمی‌شود.
6. **API فلاتر-بومی:** سازنده‌ی `const` تا جای ممکن، `super.key`، `required` برای پارامترهای بی‌بدیل، callbackها `ValueChanged<T>?`/`VoidCallback?`. کنترل‌شده/غیرکنترل‌شده مثل وب: پارامتر `value?` + `initialValue` + state داخلی؛ اگر `value` داده شد، state داخلی فقط mirror می‌شود (الگوی `didUpdateWidget` در `input.dart`).
7. **حالت‌ها:** هر ویجت باید disabled، خالی (بدون داده) و سرریزِ متن فارسی طولانی را بدون خطا رندر کند.

## قرارداد افزودن/تغییر ویجت

- نام فایل = slug رجیستری وب با خط تیره → زیرخط: `date-range-picker` → `date_picker.dart`. یک کامپوننت = یک فایل.
- کلاس‌های عمومی پیشوند `Vibe` می‌گیرند (`VibeButton`)؛ خروجی‌های چندگانه‌ی یک فایل وب (مثل `Field` + `Input`) همه در همان فایل Dart می‌مانند.
- dartdoc فارسی بالای هر کلاس عمومی: یک خط توضیح + ارجاع به فایل مبدأ (`پورت registry/ui/x.tsx`) + مثال کوتاه اگر API بدیهی نیست.
- بعد از نوشتن: export در `lib/vibefarsi.dart` (فقط همین‌جا)، سپس `dart analyze` روی فایل.
- هر باگ رندری که پیدا شد به «دام‌های API فلاتر» در `docs/PORTING.md` اضافه شود تا تکرار نشود.

## تست — حداقل الزامات

- **foundation:** هر تابع محض (اعتبارسنجی، تقویم، قالب‌بندی) تست دارد؛ تغییر رفتار بدون به‌روزرسانی تست ممنوع. مقادیر مرجع `mulberry32` از اجرای Node می‌آیند — از حفظ نوشته نشود.
- **ویجت:** برای هر صفحه‌ی showcase یک تست pump وجود دارد (`example/test/showcase_test.dart`, `charts_smoke_test.dart`). اگر صفحه‌ی جدیدی اضافه شد، تستش را هم اضافه کن: pump صفحه با `FlutterError.onError` که چاپ می‌کند و انتظارِ صفر استثنا.
- **دیباگ باکس خاکستری release:** خطای release در تست دیده نمی‌شود اگر تست همان ترکیب را pump نکرده باشد. اولین اقدام همیشه: تستِ همان صفحه را اجرا کن و متن استثنا را بخوان، نه حدس زدن.

## دام‌های شناخته‌شده (دوباره تکرار نکن)

- `Container` با `alignment` داخل `Wrap`/`Row` با عرض شل تا max گسترش می‌یابد → `IntrinsicWidth`.
- `Expanded` داخل `Row` زیر اسکرول افقی (عرض بی‌کران) غیرمجاز است → جدول با `LayoutBuilder` دو-مد (اسکرول فقط وقتی سرریز).
- `fl_chart` (Line/Bar/Pie/Radar) والدِ محدود-ارتفاع می‌خواهد → همیشه `SizedBox(height: …)` داخلی.
- اپ با `locale: fa_IR` باید `flutter_localizations` ثبت کند وگرنه TextField در release کرش می‌کند؛ در تست بدون locale این خطا دیده نمی‌شود.
- `Transform.skewX` وجود ندارد → `Transform(transform: Matrix4.skewX(x))`. `Semantics.value` از نوع `String?` است و `separator` ندارد. `BackdropFilter` به `import 'dart:ui' show ImageFilter` نیاز دارد.
- `flutter create` همیشه از داخل پوشه‌ی مقصد اجرا شود؛ از ریشه‌ی مخزن نه.

## اپ نمایشی (example/)

دسته‌بندی‌ها باید مثل سایت اصلی بماند: کامپوننت‌ها، فیلدهای ایرانی، بلاک‌ها، نمودارها، تقویم، انیمیشن‌ها، پس‌زمینه‌ها، سیستم‌های طراحی. هر ویجت تازه‌ای که به پکیج اضافه می‌شود، در صفحه‌ی دسته‌ی مربوطش با داده‌ی واقعی فارسی هم نمایش داده شود — showcase سند زنده‌ی پکیج است و اسکرین‌شات‌های README از همین اپ گرفته می‌شوند (۱۴۴۰×۹۰۰، تم گرافیت تیره).

## تعریف اتمام کار

- [ ] `dart analyze .` در ریشه و `dart analyze .` در `example/` هر دو «No issues found!»
- [ ] `flutter test` در ریشه و `example/` سبز
- [ ] ویجت جدید در barrel export شده و در showcase دیده می‌شود
- [ ] هیچ `TODO`، کد کامنت‌شده، یا رنگ/عدد هاردکد باقی نمانده
- [ ] dartdoc فارسی و ارجاع به TSX مبدأ نوشته شده
- [ ] اگر رفتار تازه‌ای اضافه شد، تستش هم هست

## انتشار

پکیج فعلاً با وابستگی path استفاده می‌شود:

```yaml
dependencies:
  vibefarsi:
    path: /path/to/vibefarsi-plus
```

پیش از انتشار روی pub.dev: `name`، `version`، `homepage/repository` در `pubspec.yaml` بررسی شود و `flutter pub publish --dry-run` بدون هشدار بگذرد.
