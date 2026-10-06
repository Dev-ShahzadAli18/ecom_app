import 'package:flutter/material.dart';
class Responsive {
  final BuildContext context;

  Responsive(this.context);

  static Responsive of(BuildContext context) => Responsive(context);

  MediaQueryData get mediaQuery => MediaQuery.of(context);
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;
  double get textScale => mediaQuery.textScaler.scale(1.0);
  EdgeInsets get padding => mediaQuery.padding;

  bool get isSmallMobile => width < 360;
  bool get isMediumMobile => width >= 360 && width < 420;
  bool get isLargeMobile => width >= 420 && width < 600;
  bool get isTablet => width >= 600;
  double wp(double percentage) => width * (percentage / 100);
  double hp(double percentage) => height * (percentage / 100);

  double clamp(double value, double min, double max) {
    return value.clamp(min, max);
  }
  double sp(double fontSize) {
    if (isSmallMobile) {
      return (fontSize * 0.9).clamp(10.0, 32.0);
    } else if (isTablet) {
      return (fontSize * 1.15).clamp(12.0, 40.0);
    }
    return fontSize;
  }
  double get drawerWidth {
    return (width * 0.78).clamp(270.0, 340.0);
  }

  double get gridAspectRatio {
    if (isSmallMobile) {
      return 0.58;
    } else if (width < 390) {
      return 0.62;
    } else if (isTablet) {
      return 0.75;
    }
    return 0.64;
  }
}

extension ResponsiveExtension on BuildContext {
  Responsive get responsive => Responsive.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isSmallScreen => screenWidth < 360;
}
