import 'package:flutter/material.dart';

/// Configuration for animation properties
class WebImageAnimationConfig {
  const WebImageAnimationConfig({
    this.duration = 500,
    this.curve = Curves.easeIn,
  });

  final int duration;
  final Curve curve;
}
