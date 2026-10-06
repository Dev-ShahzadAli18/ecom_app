import 'package:flutter/material.dart';

class AppColors {
  static bool isDark = false;

  static Color primary = Color(0xffF5B700);

  static Color get background {
    if (isDark) {
      return Color(0xff121212);
    } else {
      return Color(0xffF8F8F8);
    }
  }

  static Color get white {
    if (isDark) {
      return Color(0xff1E1E1E);
    } else {
      return Colors.white;
    }
  }

  static Color get black {
    if (isDark) {
      return Color(0xffFFFFFF);
    } else {
      return Color(0xff111111);
    }
  }

  static Color get grey {
    if (isDark) {
      return Color(0xffB0B0B0);
    } else {
      return Color(0xff777777);
    }
  }

  static Color get lightGrey {
    if (isDark) {
      return Color(0xff2C2C2C);
    } else {
      return Color(0xffEEEEEE);
    }
  }

  static Color red = Color(0xffE53935);

  static Color green = Color(0xff2E7D32);
}
