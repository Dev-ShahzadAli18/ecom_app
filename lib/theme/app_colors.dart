import 'package:flutter/material.dart';

class AppColors {
  static bool isDark = false;

  static Color primary = Color.fromARGB(255, 245, 183, 0);

  static Color get background {
    if (isDark) {
      return Color.fromARGB(255, 18, 18, 18);
    } else {
      return Color.fromARGB(255, 248, 248, 248);
    }
  }

  static Color get white {
    if (isDark) {
      return Color.fromRGBO(30, 30, 30, 1);
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
      return Color.fromARGB(255, 176, 176, 176);
    } else {
      return Color.fromARGB(255, 119, 119, 119);
    }
  }

  static Color get lightGrey {
    if (isDark) {
      return Color.fromARGB(255, 44, 44, 44);
    } else {
      return Color.fromARGB(255, 238, 238, 238);
    }
  }

  static Color red = Color.fromARGB(255, 229, 57, 53);

  static Color green = Color.fromARGB(255, 46, 125, 50);
}
