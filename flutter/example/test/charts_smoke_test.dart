import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'package:vibefarsi_example/showcase/charts_page.dart';

void main() {
  testWidgets("charts full page", (tester) async {
    FlutterError.onError = (details) {
      // ignore: avoid_print
      print("=== EXC: ${details.exception.toString().split("\n").take(2).join(" | ")}");
      // ignore: avoid_print
      print("=== WIDGET: ${details.informationCollector?.call().join(" / ").split("\n").take(4).join(" / ")}");
    };
    await tester.pumpWidget(MaterialApp(
      theme: VibeTheme.dark(fontFamily: "IRANSans"),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const Scaffold(body: SingleChildScrollView(child: ChartsShowcase())),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(seconds: 1));
    // ignore: avoid_print
    print("DONE");
  });
}
