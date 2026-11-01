import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibefarsi/vibefarsi.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: VibeTheme.dark(),
        builder: (context, inner) => Directionality(textDirection: TextDirection.rtl, child: inner!),
        home: Scaffold(body: SingleChildScrollView(child: Column(children: [child]))),
      );

  testWidgets("VibeInput renders", (tester) async {
    await tester.pumpWidget(wrap(const VibeInput(hintText: "نام")));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets("VibePasswordInput renders", (tester) async {
    await tester.pumpWidget(wrap(const VibePasswordInput(showStrength: true)));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets("VibeOtpField renders", (tester) async {
    await tester.pumpWidget(wrap(VibeOtpField(value: "", onChanged: (_) {})));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets("input row group renders", (tester) async {
    await tester.pumpWidget(wrap(const Column(children: [
      VibeInput(hintText: "مثلاً: سارا محمدی"),
      SizedBox(height: 12),
      VibeInput(hintText: "912 345 6789", textDirection: TextDirection.ltr, startAddon: Text("+98")),
      SizedBox(height: 12),
      VibeInput(error: "این فیلد الزامی است"),
      SizedBox(height: 12),
      VibePasswordInput(showStrength: true),
    ])));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
