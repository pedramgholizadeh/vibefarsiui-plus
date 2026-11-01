# قرارداد پورت وایب‌فارسی به فلاتر

این سند قانون پورت کامپوننت‌های `registry/*.tsx` وب به `lib/src/widgets/` است (ساختار فعلی مخزن در AGENTS.md).
هر ویجت باید «مثل یک ویجت بومی فلاتر» باشد، نه ترجمه‌ی واژه‌به‌واژه‌ی DOM.

## ساختار پکیج

```
lib/
    vibefarsi.dart            ← barrel؛ فقط اینجا export می‌شود (ایجنت‌ها دست نمی‌زنند)
    src/
      theme.dart              ← VibeTokens (ThemeExtension)، VibeTheme.dark/light، VibeRadius/Motion/Press
      persian.dart            ← fa، en، faNumber، formatToman، faPercent، faFileSize، mulberry32
      jalali.dart             ← JalaliDate، toJalali/toGregorian، jalaliMonths، jalaliWeekday (۰=شنبه)
      iran.dart               ← موبایل/شبا/کدملی/کارت/پلاک/کدپستی/timeAgo
      iran_divisions.dart     ← provinces، citiesOf
      widgets/<slug>.dart     ← یک کامپوننت در هر فایل، هم‌نام با فایل TSX
```

## قوانین اجباری

1. **راست‌چین واقعی.** هیچ `Alignment.left`/`EdgeInsets.only(left:)`/`TextAlign.left` نوشته نشود؛
   `AlignmentDirectional`، `EdgeInsetsDirectional`، `TextAlign.start`، `Row` (که خودش جهت‌آگاه است).
   فرم‌های عددی (موبایل، شبا، کارت، OTP، کد پستی) داخل `Directionality(textDirection: TextDirection.ltr)` قرار می‌گیرند.
2. **اعداد فارسی.** هیچ عدد لاتینی در UI نمایش داده نشود: `fa(...)`، `faNumber(...)`، `formatToman(...)` از `persian.dart`.
   ورودی کاربر با `en(...)` نرمال می‌شود. متن‌ها و ثابت‌های فارسی مستقیم از فایل TSX کپی می‌شوند (ترجمه مجدد ممنوع).
3. **رنگ فقط از توکن.** `context.vibe` (از `theme.dart`)؛ هیچ رنگ هاردکد جز `Colors.transparent`/`Colors.white`
   (جایی که نسخه‌ی وب هم سفید مطلق دارد، مثل متن روی destructive). رنگ‌ها: `background, foreground, card, popover,
   primary, secondary, muted, mutedForeground, accent, destructive, success, warning, brand, brandForeground, ring, border, input`.
4. **شکل و حرکت از زبان طراحی**: `VibeRadius.control/field/surface/overlay`، `VibeMotion.duration/ ease`،
   `VibePress.scale` (۰٫۹۸). انیمیشن ورودی/خروجی ۲۰۰ms با `VibeMotion.ease`.
5. **بدون وابستگی جدید** جز `fl_chart` (فقط دسته‌ی charts). آیکون به‌صورت `Widget? icon` از بیرون گرفته می‌شود
   (پیش‌فرض Material Icons در مثال‌ها) — پکیج آیکون اضافه نمی‌شود. وب از lucide استفاده می‌کند؛ معادل مفهومی کافی است.
6. **API فلتر-بومی**: سازنده‌ی `const` تا جایی که ممکن است، `super.key`، پارامترها `required` برای چیزهایی که
   بی‌معنی خالی‌اند، callbackها `ValueChanged<T>?`/`VoidCallback?`. کامپوننت‌های controlled وب (مثل OTP) در فلاتر
   `ValueNotifier` یا callback + state داخلی می‌شوند؛ همیشه راه unset/خالی‌کردن وجود داشته باشد.
   کنترلر لازم نیست؛ state داخلی + onChange کافی است مگر آنکه وب کنترلر داشته باشد.
7. **دسترس‌پذیری**: Semantics برای نقش‌های مهم (slider، progress، switch)، `excludeSemantics` برای تزئینات.
8. **نام‌گذاری**: کلاس‌ها `Vibe` پیشوند دارند وقتی نام عمومی است (`VibeButton`)؛ اگر وب چند خروجی دارد
   (مثل `Field` + `Input`) همه در همان یک فایل می‌مانند. نام فایل = slug رجیستری با تبدیل خط تیره به زیرخط
   (`empty-state` → `empty_state.dart`).
9. **داک‌کامنت فارسی** بالای هر کلاس عمومی: یک خط توضیح + ارجاع به فایل مبدأ (`پورت registry/ui/x.tsx`) + یک مثال کوتاه اگر استفاده‌اش بدیهی نیست.
10. **حالت‌ها**: هر ویجت باید disabled، خالی (بدون داده) و سرریز متن طولانی فارسی را بدون خطا رندر کند.
    متن طولانی با `maxLines`/`overflow` مهار می‌شود اگر چیدمان وب هم همین کار را می‌کرد.

## نشانه‌های نگاشت

| وب (Tailwind) | فلاتر |
| --- | --- |
| `bg-card text-card-foreground rounded-surface border-line` | `Container(color: t.card, decoration: … VibeRadius.surface, Border.all(t.border))` |
| `text-muted-foreground text-sm` | `TextStyle(color: t.mutedForeground, fontSize: 13)` |
| `h-10` | `SizedBox(height: 40)` (rem×16)؛ `text-sm`=13، `text-base`=14، `text-lg`=16، `text-xl`=18 |
| `gap-2` | `SizedBox(width: 8)` داخل Row |
| `shadow-overlay` | `boxShadow: [BoxShadow(color: Color(0xCC000000), blurRadius: 50, offset: Offset(0, 20), spreadRadius: -20)]` |
| hover در فلاتر | `MouseRegion` فقط وقتی رفتار معناداری دارد؛ حالت pressed/selected مهم‌تر است |
| Radix/CVA | StatefulWidget دستی یا ویجت بومی معادل (showDialog، MenuAnchor، Tooltip …) |

## دام‌های API فلاتر (واقعاً تست‌شده)

- `Transform.skewX` وجود ندارد — از `Transform(transform: Matrix4.skewX(x), child: …)` استفاده کنید.
- `Semantics.value` از نوع `String?` است (عدد ندهید) و پارامتر `separator` ندارد.
- `BackdropFilter` برای `ImageFilter.blur` به `import 'dart:ui' show ImageFilter;` نیاز دارد.
- سازنده‌های redirecting فلاتر نمی‌توانند هم initializer بگیرند هم `this.` برای همان فیلد — ساده نگه دارید.

## قبل از تحویل

- `dart analyze .` در ریشه‌ی مخزن باید بدون error و بدون warning جدید باشد.
- هیچ `// TODO` یا کد کامنت‌شده باقی نماند.
- فایل‌های دیگران (barrel، theme، foundation) ویرایش نشوند؛ اگر چیزی در foundation کم است، در گزارش بنویسید.
