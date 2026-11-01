import 'package:flutter/material.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'parts.dart';

/// دسته‌ی «انیمیشن‌ها» مثل سایت اصلی.
class AnimationsShowcase extends StatefulWidget {
  const AnimationsShowcase({super.key});

  @override
  State<AnimationsShowcase> createState() => _AnimationsShowcaseState();
}

class _AnimationsShowcaseState extends State<AnimationsShowcase> {
  int _shakeTrigger = 0;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShowSection(
          title: "ورود پلکانی",
          child: VibeGridReveal(children: [
            _demoBox(t, "یک"),
            _demoBox(t, "دو"),
            _demoBox(t, "سه"),
          ]),
        ),
        const ShowSection(
          title: "شمارنده",
          child: Row(
            children: [
              VibeCounter(value: 12500000),
              SizedBox(width: 12),
              Text("بازدید این ماه", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const ShowSection(
          title: "تایپ‌رایتر",
          child: VibeTypewriter(text: "کامپوننت فارسی برای فلاتر", loop: true),
        ),
        const ShowSection(
          title: "چرخش کلمات و شیمر",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VibeWordRotate(words: ["سریع", "زیبا", "فارسی", "راست‌چین"]),
              SizedBox(height: 12),
              VibeTextShimmer(text: "در حال بارگذاری مدل…"),
            ],
          ),
        ),
        ShowSection(
          title: "لرزش خطا",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VibeErrorShake(
                trigger: _shakeTrigger,
                child: const VibeInput(error: "رمز عبور اشتباه است"),
              ),
              const SizedBox(height: 12),
              VibeButton(
                variant: VibeButtonVariant.outline,
                onPressed: () => setState(() => _shakeTrigger++),
                child: const Text("امتحان دوباره"),
              ),
            ],
          ),
        ),
        ShowSection(
          title: "نوار متحرک",
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VibeRadius.field),
              border: Border.all(color: t.border),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: VibeMarquee(children: [
              for (final word in ["ارسال رایگان بالای ۵۰۰ هزار تومان", "تخفیف پاییزه", "۷ روز ضمانت بازگشت", "پرداخت امن"])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(word, style: TextStyle(fontSize: 13, color: t.mutedForeground)),
                ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _demoBox(VibeTokens t, String label) {
    return Container(
      width: 120,
      height: 72,
      alignment: Alignment.center,
      margin: const EdgeInsetsDirectional.only(end: 12, bottom: 12),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.field),
        border: Border.all(color: t.border),
      ),
      child: Text(label, style: TextStyle(fontSize: 14, color: t.mutedForeground)),
    );
  }
}
