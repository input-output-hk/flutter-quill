import 'package:flutter/material.dart';

import 'box_fit_web.dart';

/// Configuration for the image display properties
class WebImageConfig {
  const WebImageConfig({
    this.fitAndroidIos = BoxFit.cover,
    this.fitWeb = BoxFitWeb.cover,
    this.borderRadius = BorderRadius.zero,
    this.backgroundColor,
    this.onPointer = false,
  });

  final BoxFit fitAndroidIos;
  final BoxFitWeb fitWeb;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final bool onPointer;
}
