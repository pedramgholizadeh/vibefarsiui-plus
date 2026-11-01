import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vibefarsi/vibefarsi.dart';

import 'package:vibefarsi_example/showcase/components.dart';

Future<void> loadRealFonts() async {
  final loader = FontLoader("IRANSans");
  loader.addFont(Future.value(File("assets/fonts/IRANSans-Reg.ttf").readAsBytesSync().buffer.asByteData()));
  await loader.load();
}

void main() {
  testWidgets("full page with REAL font", (tester) async {
    await loadRealFonts();
    FlutterError.onError = (details) {
      // ignore: avoid_print
      print("EXCEPTION: ${details.exception.toString().split("\n").take(4).join(" | ")}");
      // ignore: avoid_print
      print("LIB: ${details.library}  CONTEXT: ${details.context}");
    };
    await tester.pumpWidget(MaterialApp(
      theme: VibeTheme.dark(fontFamily: "IRANSans"),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const Scaffold(body: SingleChildScrollView(child: ComponentsShowcase())),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));
    // ignore: avoid_print
    print("PAGE DONE");
  });
}
