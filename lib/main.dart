import 'dart:io';

import 'package:flutter_clock_helper/customizer.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'digital_clock.dart';


void main() {
  if (!kIsWeb && Platform.isMacOS) {
    // TODO(gspencergoog): Update this when TargetPlatform includes macOS.
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }

  runApp(ClockCustomizer((ClockModel model) =>  DigitalClock(model)));
}
