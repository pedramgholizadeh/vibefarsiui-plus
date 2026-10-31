<div dir="rtl">

# وایب‌فارسی

**کامپوننت‌های فارسی، برای توسعه‌دهنده‌ها و وایب‌کدرها.**

ابزارهای هوش مصنوعی و کتابخانه‌های انگلیسی به انگلیسی فکر می‌کنن: فونت Inter می‌گذارن، اعداد را لاتین می‌نویسن و دکمه را چپ‌چین می‌کنن. وایب‌فارسی یک رجیستری از کامپوننت‌های React + Tailwind هست. همه‌شون از پایه راست‌چین هستن و فونت، اعداد فارسی، تومان و تقویم شمسی داخل خودشون هست.

وایب‌فارسی پکیج npm نیست. فایل هر کامپوننت داخل پروژه‌تون نوشته میشه و از همان لحظه مال شماست. هر کامپوننت دو خروجی داره: کد TypeScript که در پروژه می‌گذارید، و یک پرامپت انگلیسی که قوانین راست‌چین و فارسی داخلشه و به Cursor یا Claude می‌دید. سرور MCP هم داره تا ادیتور خودش این قوانین و کدها را بخونه و لازم نباشه چیزی یادآوری کنید.

سایت و مستندات: [vibefarsi.ir](https://vibefarsi.ir)

Next.js و Vite · Tailwind v4 · بدون وابستگی اضافه · رایگان و متن‌باز

</div>

> Persian RTL components for React + Tailwind. Copy the file, run `npx vibefarsi add`, or let Cursor / Claude Code pull it over MCP. The rest of this README is in Persian; the commands are not.
>
> **Flutter:** the whole registry is also ported to Flutter/Dart under [`flutter/`](flutter/) — same design tokens, Persian digits, Jalali calendar and Iranian validation, now as native widgets. See the فلاتر section below.

<div dir="rtl">

## چرا راست‌چین کردن کل صفحه کافی نیست

- **راست‌چین واقعی.** چیدمان و آیکون‌ها از پایه راست‌چین طراحی شدن، چون یک `dir` روی کل صفحه کافی نیست. فقط از ویژگی‌های منطقی CSS استفاده میشه (مثلاً `text-start` به‌جای `text-left`).
- **تایپوگرافی فارسی.** وزن فونت و ارتفاع خط برای فارسی تنظیم شده و `letter-spacing` هم حروف را از هم جدا نمی‌کنه.
- **اعداد و تقویم شمسی.** اعداد فارسی، جداکننده‌ی هزارگان، تومان و تاریخ شمسی همه داخل خود کامپوننت هستن. هفته از شنبه شروع میشه.
- **رنگ از توکن.** هر رنگ از یک متغیر CSS می‌آد. تم تیره پیش‌فرضه و با یک دستور عوضش می‌کنید.

## شروع سریع

روی یک پروژه‌ی Next.js یا Vite که Tailwind v4 داره:

</div>

```bash
npx vibefarsi@latest init
```

<div dir="rtl">

`init` یک‌بار اجرا میشه و این‌ها را می‌نویسه:

- <code dir="ltr">lang="fa" dir="rtl"</code> روی <code dir="ltr">&lt;html&gt;</code>، در Next.js داخل `app/layout.tsx` و در Vite داخل `index.html`
- فونت Vazirmatn، در Next.js با `next/font/google` و `app/fonts.ts`، و در بقیه‌ی پروژه‌ها با import از Google Fonts داخل CSS
- توکن‌های تم گرافیت و نگاشت Tailwind در `globals.css`
- `lib/utils.ts` (اعداد فارسی، `formatToman`، `cn`) و `lib/jalali.ts` (تبدیل شمسی) از رجیستری
- قوانین مدل: یک بلوک فشرده از قوانین فارسی و کرافت رابط داخل `AGENTS.md`، خط `@AGENTS.md` در `CLAUDE.md`، و دو راهنمای کامل [`agents-md-persian`](https://vibefarsi.ir/skills/agents-md-persian) و [`ui-craft-rules`](https://vibefarsi.ir/skills/ui-craft-rules) در `docs/` تا Claude Code، Codex و Cursor از همان اول با راست‌چین، اعداد فارسی، توکن‌ها و اندازه‌های درست شروع کنن
- `vibefarsi.json` و مسیر <code dir="ltr">@/*</code> در tsconfig

بعد کامپوننت‌ها را اضافه کنید:

</div>

```bash
npx vibefarsi add button calendar price
npx vibefarsi list
```

<div dir="rtl">

وابستگی‌های رجیستری خودشون می‌آن (`calendar` خودش `lib/jalali.ts` را می‌آوره) و پکیج‌های npm لازم نصب میشن. مقصد فایل‌ها:

| نوع | مسیر |
| --- | --- |
| کامپوننت | `components/ui` |
| بلاک | `components/blocks` |
| نمودار | `components/charts` |
| تقویم | `components/calendar` |
| انیمیشن | `components/animations` |
| پس‌زمینه | `components/backgrounds` |
| قالب | `components/templates` |
| تم | `app/globals.css` |
| مهارت | `.claude/skills/<slug>/SKILL.md` (راهنماها در `docs/`) |

فلگ‌های پرکاربرد:

| فلگ | کار |
| --- | --- |
| <code dir="ltr">--font iransans</code> | اگر `IRANSans-Reg.woff` در پوشه‌ی `fonts` یا `public` باشه، همان را به‌جای Vazirmatn وصل می‌کنه |
| <code dir="ltr">--theme saffron</code> | تم دیگری به‌جای گرافیت. بعداً هم می‌تونید با `npx vibefarsi add saffron` عوضش کنید |
| <code dir="ltr">--registry &lt;url&gt;</code> | رجیستری دیگری، مثلاً <code dir="ltr">http://localhost:3000/r</code> وقتی روی خود مخزن کار می‌کنید |
| <code dir="ltr">--dry-run</code> | فقط نشون میده چه فایل‌هایی نوشته میشن و چیزی را تغییر نمیده |
| <code dir="ltr">--overwrite</code> | فایل‌های موجود را جایگزین می‌کنه |
| <code dir="ltr">--no-install</code> | پکیج‌های npm را نصب نمی‌کنه |

نصب دستی هم ممکنه: فایل را از سایت کپی کنید و `globals.css` را طبق [مستندات](https://vibefarsi.ir/docs) تنظیم کنید.

## MCP

سرور MCP وایب‌فارسی قوانین طراحی فارسی و کد کامپوننت‌ها را مستقیم به Cursor، Claude Code و Codex میده. یک‌بار آدرس <code dir="ltr">https://vibefarsi.ir/mcp</code> را اضافه کنید و بعد مثل همیشه پرامپت بدید.

</div>

```json
{
  "mcpServers": {
    "vibefarsi": {
      "url": "https://vibefarsi.ir/mcp"
    }
  }
}
```

<div dir="rtl">

| ادیتور | کجا |
| --- | --- |
| Cursor | <code dir="ltr">.cursor/mcp.json</code> در پروژه، یا [افزودن به Cursor](https://cursor.com/en/install-mcp?name=vibefarsi&config=eyJ1cmwiOiJodHRwczovL3ZpYmVmYXJzaS5pci9tY3AifQ==) |
| Claude Code | <code dir="ltr">claude mcp add --transport http vibefarsi https://vibefarsi.ir/mcp</code> |
| Codex | <code dir="ltr">codex mcp add vibefarsi --url https://vibefarsi.ir/mcp</code> |

اگر بخواید سرور روی سیستم خودتون اجرا بشه: <code dir="ltr">npx -y @vibefarsi/mcp</code>.

ابزارهایی که مدل در اختیار داره:

| ابزار | کار |
| --- | --- |
| `get_design_rules` | قوانین راست‌چین، فونت، اعداد و توکن‌ها |
| `search_registry` | جست‌وجو بین کامپوننت‌ها، به فارسی یا انگلیسی |
| `get_component` | کد و پرامپت همان کامپوننت، با وابستگی‌هاش |
| `get_theme` | توکن‌های رنگ و شعاع گوشه‌ی هر تم |
| `scaffold_page` | از توضیح صفحه، یک ترکیب آماده می‌سازه |

یک پرامپت معمولی مثل «یک صفحه‌ی پرداخت با خلاصه‌ی سبد و فرم آدرس بساز» این مسیر را می‌ره:

</div>

```
get_design_rules()
scaffold_page("صفحه‌ی پرداخت")
get_component(["input", "price", "button"])
```

<div dir="rtl">

خروجی همان بار اول درسته: فونت پروژه، چیدمان راست‌چین، مبلغ‌ها با اعداد فارسی و تومان، و رنگ‌ها از توکن‌های تم، نه رنگ دلخواه مدل.

## چه چیزهایی داره

| بخش | تعداد | شامل |
| --- | --- | --- |
| [کامپوننت‌ها](https://vibefarsi.ir/components) | ۶۸ | دکمه، فرم، جدول داده، تقویم شمسی، شماره‌ی موبایل، کد تأیید، شماره‌ی شبا، قیمت به تومان |
| [بلاک‌ها](https://vibefarsi.ir/blocks) | ۸ | هیرو، ویژگی‌ها، ردیف قیمت، پرسش‌های متداول، آمار، نظر مشتریان، کارت ورود، فراخوان پایانی |
| [نمودارها](https://vibefarsi.ir/charts) | ۱۵ | خطی، ناحیه‌ای، میله‌ای، ترکیبی، دایره‌ای، گیج، راداری، پراکندگی، نقشه‌ی حرارتی تقویم شمسی، قیف، نقشه‌ی درختی، آبشاری و شمعی، همه بدون کتابخانه |
| [تقویم](https://vibefarsi.ir/calendar) | ۱۰ | تقویم رویداد با نمای ماه، هفته، روز و فهرست، نمای سال، تعطیلات رسمی ایران با تاریخ قمری، انتخاب نوبت، گانت و برنامه‌ی شیفت |
| [انیمیشن‌ها](https://vibefarsi.ir/animations) | ۳۹ | انیمیشن با CSS و React، بدون کتابخانه‌ی اضافه |
| [پس‌زمینه‌ها](https://vibefarsi.ir/backgrounds) | ۴۴ | الگو و نور کم‌کنتراست که متن روشون خوانا می‌مونه |
| [قالب‌ها](https://vibefarsi.ir/templates) | ۲۴ | صفحه‌های کامل، از همین کامپوننت‌ها |
| [سیستم‌های طراحی](https://vibefarsi.ir/themes) | ۶ | گرافیت (پیش‌فرض)، فیروزه، زعفران، انار، لاجورد، کاغذ (روشن) |
| [مهارت‌ها](https://vibefarsi.ir/skills) | ۱۰ | فایل‌های SKILL.md برای Claude Code، Cursor و Codex: فارسی محاوره‌ای و رسمی، متن رابط کاربری، رابط راست‌چین، تقویم شمسی، اعتبارسنجی ایرانی، سئوی فارسی، و دو راهنما برای CLAUDE.md و تایپوگرافی |

## پشتیبانی فلاتر و دارت 🎯

همان کامپوننت‌های وایب‌فارسی، این بار برای **فلاتر**. کل رجیستری به Dart پورت شده: همان زبان طراحی (توکن‌های گرافیت)، همان اعداد فارسی، همان تقویم شمسی و اعتبارسنجی ایرانی — این بار داخل ویجت‌های بومی فلاتر.

شروع سریع، در یک پروژه‌ی فلاتر:

</div>

```bash
flutter pub add vibefarsi   # یا وابستگی path به flutter/ همین مخزن
```

<div dir="rtl">

تم و جهت را یک‌بار ست کنید؛ از این به بعد همه‌ی ویجت‌ها راست‌چین و فارسی‌اند:

</div>

```dart
import 'package:vibefarsi/vibefarsi.dart';

MaterialApp(
  theme: VibeTheme.dark(),          // یا VibeTheme.light() / VibeTheme.withTokens(VibeTokens.saffron, ...)
  locale: const Locale("fa", "IR"),
  builder: (context, child) => Directionality(
    textDirection: TextDirection.rtl,
    child: child!,
  ),
)
```

<div dir="rtl">

بعد مثل وب از کامپوننت‌ها استفاده کنید:

</div>

```dart
VibeButton(onPressed: submit, child: const Text("ثبت سفارش"))

VibePrice(amount: 12500000)                       // ۱۲٬۵۰۰٬۰۰۰ تومان

VibeDatePicker(
  value: _date,
  onChanged: (d) => setState(() => _date = d),    // تقویم شمسی با تعطیلات رسمی
)

VibeCardNumberInput(onChanged: (digits, valid, bank) { /* … */ })  // تشخیص بانک از BIN
```

<div dir="rtl">

### چه چیزهایی در پکیج فلاتر هست

| بخش | شامل |
| --- | --- |
| پایه | <code dir="ltr">fa / faNumber / formatToman / faFileSize</code> · تقویم شمسی (Borkowski) · هجری قمری با جدول رسمی ایران · تعطیلات رسمی ۱۴۰۴/۱۴۰۵ · اعتبارسنجی موبایل/شبا/کدملی/کارت/پلاک/کدپستی · تقسیمات کشوری ۳۱ استان |
| ویجت‌های UI | دکمه، ورودی، فیلدهای ایرانی (شبا، کدملی، کارت، پلاک با ظاهر پلاک فلزی)، انتخابگر استان/شهر، سلکت، کمبوباکس با تطبیق نرم فارسی، OTP، جدول و جدول داده، تب، آکاردئون، سایدبار، توست، منو، پاپ‌آور، مودال، کروسل و… |
| تقویم | نمای ماه با تعطیلات رنگی و تاریخ قمری دوم، انتخابگر تاریخ و بازه، نمای سال، شمارش معکوس، انتخابگر نوبت، برنامه‌ی شیفت، گانت با ستون‌های تعطیل |
| نمودار | خطی/ناحیه‌ای/میله‌ای/دونات با fl_chart + رادار، گیج، قیف، هیت‌مپ شمسی، اسپارک‌لاین — همه با ارقام فارسی |
| آموزش | طرح دوره، کوییز تعاملی، تصویر نقطه‌دار، پوسته‌ی پخش‌کننده |
| حرکت و پس‌زمینه | ورود پلکانی، شمارنده، تایپ‌رایتر، شیمر، نوار متحرک، لرزش خطا + گرید/نقطه/موج/ستاره/آرورا با CustomPaint |
| تم‌ها | هر ۶ تم رسمی رجیستری: <code dir="ltr">VibeTokens.dark / .light / .lapis / .paper / .pomegranate / .saffron / .turquoise</code> |

قوانین پورت — چیزهایی مثل «رنگ فقط از توکن»، «ارقام عددی LTR داخل RTL» و «فشرده‌ی ۰٫۹۸» — در [`flutter/PORTING.md`](flutter/PORTING.md) مستند است.

اپ نمونه با همه‌ی دسته‌ها: <code dir="ltr">cd flutter/example && flutter run</code> · تست‌ها: <code dir="ltr">cd flutter && flutter test</code>

> **وضعیت:** پکیج فلاتر فعلاً در همین مخزن نگه‌داری می‌شود و هنوز روی pub.dev منتشر نشده؛ تا انتشار، وابستگی را با path به پوشه‌ی <code dir="ltr">flutter/</code> بدهید.

## توسعه روی همین مخزن

سایت، رجیستری، CLI و سرور MCP همه در همین مخزن هستن. همه‌چیز از پوشه‌ی `registry` می‌آد. سایت همان فایل‌ها را نشون میده و مسیر <code dir="ltr">/r</code> هم همان‌ها را به CLI و MCP میده.

برای PR، جزئیات استک، چیزهایی که عمداً نداریم، و چک‌لیست مشارکت در [`CONTRIBUTING.md`](CONTRIBUTING.md) هست.

### استک (خلاصه)

| بخش | ابزار |
| --- | --- |
| سایت / رجیستری | Next.js ۱۶ · React ۱۹ · TypeScript · Tailwind v۴ |
| آیکون رجیستری | فقط `lucide-react` (تقریباً همیشه) |
| سایت | `shiki` برای هایلایت کد · `zod` |
| MCP | `@modelcontextprotocol/server` · پکیج `@vibefarsi/mcp` (Node ۲۰+) |
| CLI | TypeScript خالص · پکیج `vibefarsi` روی npm |
| فلاتر | Dart ۳٫۶+ · Flutter ۳٫۲۷+ · `fl_chart` (فقط نمودارها) |
| استقرار | Liara · پورت ۳۰۰۰ |

انیمیشن‌ها با CSS و React هستن؛ Framer Motion و GSAP داخل رجیستری نمی‌آد. تقویم و اعتبارسنجی ایرانی هم داخل `lib/` خود مخزنه، نه پکیج جدا.

</div>

```
registry/         ui/  blocks/  charts/  calendar/  animations/  backgrounds/  templates/  themes/  skills/
lib/registry/     names, descriptions, prompts, catalog builder
app/r/            GET /r  (catalog)    GET /r/{type}/{slug}.json  (item)
packages/cli/     npx vibefarsi
mcp/              @vibefarsi/mcp
app/  components/ the site
```

```bash
npm install
npm run dev        # site + registry at http://localhost:3000
```

<div dir="rtl">

اجرای CLI از سورس:

</div>

```bash
npm run build:cli
npm run vibefarsi -- init --cwd ../my-app --registry http://localhost:3000/r
```

<div dir="rtl">

اجرای سرور MCP از سورس:

</div>

```bash
npm install --prefix mcp
npm run mcp        # stdio server via tsx
npm run mcp:smoke
```

<div dir="rtl">

سرور MCP رجیستری را از `VIBEFARSI_URL` می‌خونه (پیش‌فرض <code dir="ltr">https://vibefarsi.ir</code>). برای رجیستری محلی آن را روی <code dir="ltr">http://localhost:3000</code> بگذارید. `VIBEFARSI_ROOT` هم برای وقتیه که فایل‌های رجیستری جای دیگری باشن.

روی npm هر دو پکیج هست: `npx vibefarsi` و <code dir="ltr">npx -y @vibefarsi/mcp</code>. دستورهای بالا برای وقتیه که روی سورس همین مخزن کار می‌کنید.

## لایسنس

[MIT](./LICENSE). پلن پولی نداریم و هیچ کامپوننتی قفل نیست. می‌خوایم ساختن یک رابط فارسی خوب، کار ساده‌ای باشه.

برای مشارکت و جزئیات استک: [`CONTRIBUTING.md`](CONTRIBUTING.md).

</div>
