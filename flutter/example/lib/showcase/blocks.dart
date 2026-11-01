import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// دسته‌ی «بلاک‌ها» مثل سایت اصلی: هیرو، ویژگی‌ها، قیمت، سؤالات متداول و…
class BlocksShowcase extends StatelessWidget {
  const BlocksShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowSection(
          title: "هیرو",
          child: VibeHero(
            title: const Text("فروشگاهت رو آنلاین کن"),
            description: const Text("از سبد خرید تا درگاه پرداخت، همه‌چیز با رابط فارسی و راست‌چین."),
            primaryLabel: "شروع کنید",
            onPrimary: () {},
            secondaryLabel: "دمو",
            onSecondary: () {},
          ),
        ),
        const ShowSection(
          title: "ویژگی‌ها",
          child: VibeFeatures(features: [
            VibeFeature(icon: Icons.bolt_outlined, title: "راه‌اندازی سریع", description: "چند دقیقه‌ای فروشگاهت را بساز."),
            VibeFeature(icon: Icons.credit_card_outlined, title: "پرداخت امن", description: "اتصال به درگاه‌های ایرانی."),
            VibeFeature(icon: Icons.support_agent_outlined, title: "پشتیبانی فارسی", description: "تیم پاسخ‌گو در تمام ساعات."),
          ]),
        ),
        const ShowSection(
          title: "قیمت‌گذاری",
          child: VibePricing(plans: [
            VibePricingPlan(name: "پایه", monthlyPrice: 290000, features: ["۱۰۰ سفارش در ماه", "یک فروشگاه"]),
            VibePricingPlan(name: "حرفه‌ای", monthlyPrice: 890000, features: ["سفارش نامحدود", "سه فروشگاه", "پشتیبانی ویژه"], highlighted: true),
          ]),
        ),
        const ShowSection(
          title: "سؤالات پرتکرار",
          child: VibeFaq(items: [
            VibeFaqItem(question: "می‌توانم بعداً پلن را عوض کنم؟", answer: "بله، هر زمان از پنل مدیریت امکان‌پذیر است."),
            VibeFaqItem(question: "درگاه پرداخت چه بانک‌هایی پشتیبانی می‌شود؟", answer: "همه‌ی درگاه‌های شاپرک با شبا و کارت ایرانی."),
            VibeFaqItem(question: "اگر راضی نباشم؟", answer: "تا ۱۴ روز وجه کامل برمی‌گردد."),
          ]),
        ),
        const ShowSection(
          title: "آمار",
          child: VibeStats(stats: [
            ("فروش امروز", 18450000, 12.4),
            ("سفارش‌ها", 356, 4.2),
            ("بازدید", 12500, -2.1),
          ]),
        ),
        const ShowSection(
          title: "نظرات مشتریان",
          child: VibeTestimonials(testimonials: [
            VibeTestimonial(quote: "فروشگاه‌مون در یک هفته راه افتاد.", name: "سارا محمدی", role: "مدیر فروش"),
            VibeTestimonial(quote: "درگاه پرداخت بدون دردسر وصل شد.", name: "امیر رضایی", role: "بنیان‌گذار"),
          ]),
        ),
        ShowSection(
          title: "فراخوان پایانی",
          child: VibeCallToAction(
            title: const Text("امروز شروع کنید"),
            description: const Text("۱۴ روز رایگان، بدون کارت بانکی."),
            buttonLabel: "ساخت فروشگاه",
            onButton: () {},
          ),
        ),
      ],
    );
  }
}
