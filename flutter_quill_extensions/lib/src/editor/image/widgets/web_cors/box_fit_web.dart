import 'package:flutter/material.dart';

abstract class BoxFitWeb {
  /// Abstract const constructor to enable subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const BoxFitWeb();

  static const Fit fill = Fit('fill');
  static const Fit cover = Fit('cover');
  static const Fit contain = Fit('contain');
  static const Fit scaleDown = Fit('scale-down');

  /// Convert BoxFit enum to CSS object-fit value
  static BoxFitWeb fromBoxFit(BoxFit boxFit) {
    switch (boxFit) {
      case BoxFit.cover:
        return BoxFitWeb.cover;
      case BoxFit.contain:
        return BoxFitWeb.contain;
      case BoxFit.fill:
        return BoxFitWeb.fill;
      case BoxFit.scaleDown:
        return BoxFitWeb.scaleDown;
      default:
        return BoxFitWeb.contain;
    }
  }

  String name(Fit instance) => instance.fit;
}

class Fit extends BoxFitWeb {
  /// Creates a fit String.
  const Fit(this.fit);
  final String fit;
}
