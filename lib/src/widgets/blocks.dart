import 'package:flutter/material.dart';

import '../persian.dart';
import '../theme.dart';
import 'button.dart';

/// هیرو — پورت `registry/blocks/hero.tsx`.
///
/// تیتر بزرگ، توضیح، دو دکمه و یک اسلات ویژوال.
class VibeHero extends StatelessWidget {
  const VibeHero({
    super.key,
    required this.title,
    this.description,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.visual,
  });

  final Widget title;
  final Widget? description;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? visual;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DefaultTextStyle.merge(
          style: TextStyle(fontSize: 32, height: 1.3, fontWeight: FontWeight.w700, color: t.foreground),
          child: title,
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: 16, height: 1.8, color: t.mutedForeground),
              child: description!,
            ),
          ),
        if (primaryLabel != null || secondaryLabel != null) ...[
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              if (primaryLabel != null)
                VibeButton(onPressed: onPrimary, child: Text(primaryLabel!)),
              if (secondaryLabel != null)
                VibeButton(variant: VibeButtonVariant.outline, onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ),
        ],
        if (visual != null) ...[
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(VibeRadius.surface),
            child: visual,
          ),
        ],
      ],
    );
  }
}

/// نوار ویژگی — پورت `registry/blocks/features.tsx`.
class VibeFeature {
  final IconData icon;
  final String title;
  final String description;

  const VibeFeature({required this.icon, required this.title, required this.description});
}

/// شبکه‌ی ویژگی‌ها — پورت `registry/blocks/features.tsx`.
class VibeFeatures extends StatelessWidget {
  const VibeFeatures({super.key, required this.features, this.columns = 3});

  final List<VibeFeature> features;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final f in features)
          Container(
            width: columns == 1 ? double.infinity : 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(VibeRadius.field),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(f.icon, size: 20, color: t.brand),
                const SizedBox(height: 10),
                Text(f.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  f.description,
                  style: TextStyle(fontSize: 13, height: 1.7, color: t.mutedForeground),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// پلن قیمت — پورت `registry/blocks/pricing.tsx`.
class VibePricingPlan {
  final String name;
  final double monthlyPrice;
  final List<String> features;
  final bool highlighted;
  final String ctaLabel;
  final VoidCallback? onCta;

  const VibePricingPlan({
    required this.name,
    required this.monthlyPrice,
    required this.features,
    this.highlighted = false,
    this.ctaLabel = "انتخاب پلن",
    this.onCta,
  });
}

/// شبکه‌ی قیمت‌گذاری — پورت `registry/blocks/pricing.tsx`.
class VibePricing extends StatelessWidget {
  const VibePricing({super.key, required this.plans, this.currencyLabel = "تومان در ماه"});

  final List<VibePricingPlan> plans;
  final String currencyLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final plan in plans)
          Container(
            width: 280,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: plan.highlighted ? t.accent : t.card,
              borderRadius: BorderRadius.circular(VibeRadius.surface),
              border: Border.all(color: plan.highlighted ? t.brand : t.border, width: plan.highlighted ? 2 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.mutedForeground)),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    formatToman(plan.monthlyPrice),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: t.foreground),
                  ),
                ),
                Text(currencyLabel, style: TextStyle(fontSize: 12, color: t.mutedForeground)),
                const SizedBox(height: 16),
                for (final f in plan.features)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 14, color: t.success),
                        const SizedBox(width: 8),
                        Expanded(child: Text(f, style: TextStyle(fontSize: 13, color: t.foreground))),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: VibeButton(
                    variant: plan.highlighted ? VibeButtonVariant.brand : VibeButtonVariant.outline,
                    onPressed: plan.onCta,
                    child: Text(plan.ctaLabel),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// CTA — پورت `registry/blocks/cta.tsx`.
class VibeCallToAction extends StatelessWidget {
  const VibeCallToAction({
    super.key,
    required this.title,
    this.description,
    this.buttonLabel,
    this.onButton,
  });

  final Widget title;
  final Widget? description;
  final String? buttonLabel;
  final VoidCallback? onButton;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(VibeRadius.surface),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle.merge(
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: t.foreground, height: 1.4),
            child: title,
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: 14, height: 1.7, color: t.mutedForeground),
                child: description!,
              ),
            ),
          if (buttonLabel != null) ...[
            const SizedBox(height: 16),
            VibeButton(variant: VibeButtonVariant.brand, onPressed: onButton, child: Text(buttonLabel!)),
          ],
        ],
      ),
    );
  }
}

/// گواهی مشتری — پورت `registry/blocks/testimonials.tsx`.
class VibeTestimonial {
  final String quote;
  final String name;
  final String role;
  final ImageProvider? avatar;

  const VibeTestimonial({required this.quote, required this.name, required this.role, this.avatar});
}

/// شبکه‌ی گواهی‌ها — پورت `registry/blocks/testimonials.tsx`.
class VibeTestimonials extends StatelessWidget {
  const VibeTestimonials({super.key, required this.testimonials, this.columns = 3});

  final List<VibeTestimonial> testimonials;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final item in testimonials)
          Container(
            width: columns == 1 ? double.infinity : 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(VibeRadius.field),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "«${item.quote}»",
                  style: TextStyle(fontSize: 14, height: 1.8, color: t.foreground),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (item.avatar != null)
                      CircleAvatar(radius: 14, backgroundImage: item.avatar)
                    else
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: t.muted,
                        child: Text(item.name.substring(0, 1), style: TextStyle(fontSize: 12, color: t.foreground)),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(item.role, style: TextStyle(fontSize: 11, color: t.mutedForeground)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// سؤالات پرتکرار — پورت `registry/blocks/faq.tsx`.
class VibeFaqItem {
  final String question;
  final String answer;

  const VibeFaqItem({required this.question, required this.answer});
}

/// فهرست سؤالات پرتکرار با آکاردئون.
class VibeFaq extends StatefulWidget {
  const VibeFaq({super.key, required this.items});

  final List<VibeFaqItem> items;

  @override
  State<VibeFaq> createState() => _VibeFaqState();
}

class _VibeFaqState extends State<VibeFaq> {
  final Set<int> _open = {};

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Column(
      children: [
        for (var i = 0; i < widget.items.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VibeRadius.field),
              border: Border.all(color: t.border),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _open.contains(i) ? _open.remove(i) : _open.add(i)),
                  borderRadius: BorderRadius.circular(VibeRadius.field),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.items[i].question,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        AnimatedRotation(
                          turns: _open.contains(i) ? 0.5 : 0,
                          duration: VibeMotion.duration,
                          child: Icon(Icons.expand_more, size: 16, color: t.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  duration: VibeMotion.duration,
                  sizeCurve: VibeMotion.ease,
                  crossFadeState: _open.contains(i) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 14, end: 14, bottom: 14),
                    child: Text(
                      widget.items[i].answer,
                      style: TextStyle(fontSize: 13, height: 1.8, color: t.mutedForeground),
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

/// آمار — پورت `registry/blocks/stats.tsx`.
class VibeStats extends StatelessWidget {
  const VibeStats({super.key, required this.stats});

  /// (برچسب، مقدار، دلتای اختیاری مثبت/منفی)
  final List<(String, double, double?)> stats;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final (label, value, delta) in stats)
          Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(VibeRadius.field),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: t.mutedForeground)),
                const SizedBox(height: 6),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(faNumber(value), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: t.foreground)),
                ),
                if (delta != null)
                  Row(
                    children: [
                      Icon(
                        delta >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: delta >= 0 ? t.success : t.destructive,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        faPercent(delta.abs(), digits: 1),
                        style: TextStyle(fontSize: 12, color: delta >= 0 ? t.success : t.destructive),
                      ),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// گام‌ها — پورت `registry/blocks/steps.tsx`.
class VibeBlockSteps extends StatelessWidget {
  const VibeBlockSteps({super.key, required this.titles, required this.descriptions});

  final List<String> titles;
  final List<String> descriptions;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: [
        for (var i = 0; i < titles.length; i++)
          SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: t.muted),
                  child: Text(fa(i + 1), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: t.foreground)),
                ),
                const SizedBox(height: 10),
                Text(titles[i], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(descriptions[i], style: TextStyle(fontSize: 13, height: 1.7, color: t.mutedForeground)),
              ],
            ),
          ),
      ],
    );
  }
}

/// امضای تیم — پورت `registry/blocks/team.tsx`.
class VibeTeamMember {
  final String name;
  final String role;
  final ImageProvider? avatar;

  const VibeTeamMember({required this.name, required this.role, this.avatar});
}

/// شبکه‌ی تیم — پورت `registry/blocks/team.tsx`.
class VibeTeam extends StatelessWidget {
  const VibeTeam({super.key, required this.members});

  final List<VibeTeamMember> members;

  @override
  Widget build(BuildContext context) {
    final t = context.vibe;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final m in members)
          SizedBox(
            width: 160,
            child: Column(
              children: [
                m.avatar != null
                    ? CircleAvatar(radius: 32, backgroundImage: m.avatar)
                    : CircleAvatar(
                        radius: 32,
                        backgroundColor: t.muted,
                        child: Text(m.name.substring(0, 1), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: t.foreground)),
                      ),
                const SizedBox(height: 8),
                Text(m.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(m.role, style: TextStyle(fontSize: 12, color: t.mutedForeground)),
              ],
            ),
          ),
      ],
    );
  }
}
