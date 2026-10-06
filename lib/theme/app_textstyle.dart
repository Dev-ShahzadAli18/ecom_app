import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle get heading {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    );
  }

  static TextStyle get title {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    );
  }

  static TextStyle get body {
    return TextStyle(fontSize: 15, color: AppColors.grey);
  }

  static TextStyle get button {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }
}
