import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// دسته‌ی «کامپوننت‌ها» مثل سایت اصلی: دکمه، ورودی، انتخاب، بازخورد،
/// نمایش داده، ناوبری و پنجره.
class ComponentsShowcase extends StatefulWidget {
  const ComponentsShowcase({super.key});

  @override
  State<ComponentsShowcase> createState() => _ComponentsShowcaseState();
}

class _ComponentsShowcaseState extends State<ComponentsShowcase> {
  bool _switchOn = true;
  bool _checkOn = true;
  int _tab = 0;
  double _slider = 40;
  double _rating = 4;
  String? _city = "teh";
  List<String> _tags = const ["فروشگاه", "ارسال سریع"];
  final _otp = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---------- دکمه ----------
        ShowSection(
          title: "دکمه",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              VibeButton(onPressed: () {}, child: const Text("ثبت سفارش")),
              VibeButton(
                variant: VibeButtonVariant.secondary,
                onPressed: () {},
                child: const Text("ذخیره"),
              ),
              VibeButton(
                variant: VibeButtonVariant.outline,
                onPressed: () {},
                child: const Text("انصراف"),
              ),
              VibeButton(
                variant: VibeButtonVariant.brand,
                onPressed: () {},
                leading: const Icon(Icons.add),
                child: const Text("محصول جدید"),
              ),
              VibeButton(
                variant: VibeButtonVariant.destructive,
                onPressed: () {},
                child: const Text("حذف"),
              ),
              const VibeButton(onPressed: null, child: Text("غیرفعال")),
              VibeButton(
                size: VibeButtonSize.small,
                onPressed: () {},
                child: const Text("کوچک"),
              ),
              VibeButton(
                size: VibeButtonSize.icon,
                onPressed: () {},
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),

        // ---------- ورودی ----------
        const ShowSection(
          title: "ورودی",
          child: Column(
            children: [
              VibeInput(hintText: "مثلاً: سارا محمدی"),
              SizedBox(height: 12),
              VibeInput(
                hintText: "912 345 6789",
                textDirection: TextDirection.ltr,
                startAddon: Text("+98"),
              ),
              SizedBox(height: 12),
              VibeInput(error: "این فیلد الزامی است"),
              SizedBox(height: 12),
              VibePasswordInput(showStrength: true),
            ],
          ),
        ),

        // ---------- کد تأیید ----------
        ShowSection(
          title: "کد تأیید",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder(
                valueListenable: _otp,
                builder: (context, value, _) => VibeOtpField(
                  length: 6,
                  value: value,
                  onChanged: (v) => _otp.value = v,
                ),
              ),
            ],
          ),
        ),

        // ---------- انتخاب ----------
        ShowSection(
          title: "انتخاب",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VibeSelect(
                options: const [
                  VibeSelectOption(value: "teh", label: "تهران"),
                  VibeSelectOption(value: "esf", label: "اصفهان"),
                  VibeSelectOption(value: "shz", label: "شیراز"),
                  VibeSelectOption(value: "msh", label: "مشهد"),
                ],
                value: _city,
                onChanged: (v) => setState(() => _city = v),
                hint: "شهر را انتخاب کنید",
              ),
              const SizedBox(height: 12),
              VibeTagsInput(
                value: _tags,
                onChanged: (v) => setState(() => _tags = v),
                max: 5,
              ),
              const SizedBox(height: 12),
              VibeCheckbox(
                value: _checkOn,
                onChanged: (v) => setState(() => _checkOn = v),
                label: const Text("قوانین را می‌پذیرم"),
                description: const Text("شرایط استفاده از سرویس"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  VibeSwitch(value: _switchOn, onChanged: (v) => setState(() => _switchOn = v)),
                  const SizedBox(width: 8),
                  Text("اعلان‌ها ${_switchOn ? "روشن" : "خاموش"}"),
                ],
              ),
              const SizedBox(height: 12),
              VibeSlider(
                value: _slider,
                min: 0,
                max: 100,
                onChanged: (v) => setState(() => _slider = v),
                label: const Text("درصد تخفیف"),
              ),
            ],
          ),
        ),

        // ---------- بازخورد ----------
        ShowSection(
          title: "بازخورد",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VibeProgress(value: 68, max: 100),
              const SizedBox(height: 12),
              const VibeSkeleton(width: 240, height: 12),
              const SizedBox(height: 8),
              const VibeSkeleton(width: 180, height: 12),
              const SizedBox(height: 12),
              VibeRating(value: _rating, onChanged: (v) => setState(() => _rating = v), showValue: true),
              const SizedBox(height: 12),
              const VibeSpinner(label: Text("در حال بارگذاری")),
            ],
          ),
        ),

        // ---------- ناوبری ----------
        ShowSection(
          title: "ناوبری",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VibeBreadcrumb(items: [
                VibeCrumb(label: const Text("فروشگاه"), onTap: () {}),
                VibeCrumb(label: const Text("لپ‌تاپ"), onTap: () {}),
                const VibeCrumb(label: Text("مک‌بوک ایر")),
              ]),
              const SizedBox(height: 12),
              VibeTabs(
                tabs: const [
                  VibeTab(value: "all", label: Text("همه")),
                  VibeTab(value: "open", label: Text("باز")),
                  VibeTab(value: "done", label: Text("تحویل‌شده")),
                ],
                value: _tab == 0 ? "all" : (_tab == 1 ? "open" : "done"),
                onChanged: (v) => setState(() => _tab = v == "all" ? 0 : (v == "open" ? 1 : 2)),
              ),
              const SizedBox(height: 12),
              VibePagination(page: 2, total: 9, onChange: (_) {}),
            ],
          ),
        ),

        // ---------- نمایش داده ----------
        ShowSection(
          title: "نمایش داده",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  VibeBadge(child: Text("جدید")),
                  VibeBadge(variant: VibeBadgeVariant.brand, child: Text("پرفروش")),
                  VibeBadge(variant: VibeBadgeVariant.destructive, child: Text("ناموجود")),
                  VibeBadge(variant: VibeBadgeVariant.success, child: Text("پرداخت شد")),
                ],
              ),
              const SizedBox(height: 12),
              const VibePrice(amount: 2450000, original: 3200000),
              const SizedBox(height: 12),
              const VibeStat(
                label: Text("فروش امروز"),
                value: Text("۱۸٬۴۵۰٬۰۰۰"),
                unit: Text("تومان"),
                delta: 12.4,
              ),
              const SizedBox(height: 12),
              VibeTable(
                columns: const [
                  VibeTableColumn(header: Text("محصول")),
                  VibeTableColumn(header: Text("قیمت"), numeric: true),
                ],
                rows: [
                  VibeTableRowData(cells: [const Text("کیف چرم"), Text(formatToman(2400000))]),
                  VibeTableRowData(cells: [const Text("عینک آفتابی"), Text(formatToman(1850000))]),
                  VibeTableRowData(cells: [const Text("ساعت مچی"), Text(formatToman(5200000))]),
                ],
              ),
              const SizedBox(height: 12),
              const VibeTimeline(items: [
                VibeTimelineItem(date: JalaliDate(1405, 8, 7), title: Text("ثبت سفارش")),
                VibeTimelineItem(date: JalaliDate(1405, 8, 8), title: Text("پرداخت")),
                VibeTimelineItem(date: JalaliDate(1405, 8, 9), title: Text("ارسال"), description: Text("پست پیشتاز")),
              ], activeIndex: 1),
              const SizedBox(height: 12),
              const VibeEmptyState(
                title: "سفارشی ثبت نشده",
                description: "اولین خریدتان را انجام دهید.",
              ),
            ],
          ),
        ),

        // ---------- پنجره و منو ----------
        ShowSection(
          title: "پنجره و منو",
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              VibeButton(
                variant: VibeButtonVariant.outline,
                onPressed: () async {
                  await VibeDialog.show<void>(
                    context,
                    title: const Text("حذف حساب"),
                    description: const Text("این کار برگشت‌پذیر نیست."),
                  );
                },
                child: const Text("پنجره"),
              ),
              VibeButton(
                variant: VibeButtonVariant.outline,
                onPressed: () async {
                  await VibeAlertDialog.show(
                    context,
                    title: const Text("حذف سفارش؟"),
                    description: const Text("این کار برگشت‌پذیر نیست."),
                    destructive: true,
                    onConfirm: () async {},
                  );
                },
                child: const Text("تأیید عمل"),
              ),
              VibeButton(
                variant: VibeButtonVariant.outline,
                onPressed: () {
                  VibeToast.of(context).show(
                    const VibeToastData(
                      title: Text("ذخیره شد"),
                      description: Text("تغییرات با موفقیت ذخیره شد."),
                      variant: VibeToastVariant.success,
                    ),
                  );
                },
                child: const Text("اعلان"),
              ),
              VibeTooltip(
                content: const Text("ذخیره پیش‌نویس"),
                child: VibeButton(
                  variant: VibeButtonVariant.ghost,
                  onPressed: () {},
                  child: const Icon(Icons.info_outline),
                ),
              ),
            ],
          ),
        ),

        // ---------- بازه‌ها ----------
        ShowSection(
          title: "بازه و مراحل",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VibeRangeSlider(
                value: const RangeValues(1500000, 4800000),
                min: 0,
                max: 6000000,
                onChanged: (_) {},
                label: const Text("محدوده قیمت"),
                format: formatToman,
                fullRangeLabel: const Text("همه قیمت‌ها"),
              ),
              const SizedBox(height: 16),
              const VibeStepper(
                steps: [
                  VibeStep(label: Text("سبد خرید")),
                  VibeStep(label: Text("پرداخت")),
                  VibeStep(label: Text("ارسال")),
                ],
                current: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
