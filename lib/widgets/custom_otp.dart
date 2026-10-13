import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomOtpField extends StatelessWidget {
  final int length;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  CustomOtpField({super.key, this.length = 4, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    Color hintColor = AppColors.isDark ? Color(0xff6A6A6A) : Color(0xffBBBBBB);

    return CustomTextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: length,
      textAlign: TextAlign.center,
      onChanged: onChanged,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 8,
        color: AppColors.black,
      ),
      hintText: "----",
      hintStyle: TextStyle(color: hintColor, letterSpacing: 8),
      fillColor: AppColors.background,
      borderColor: AppColors.isDark ? Color(0xff3A3A3A) : Color(0xffE5E5E5),
      focusedBorderColor: AppColors.primary,
      contentPadding: EdgeInsets.symmetric(vertical: 18),
      borderRadius: 14,
      showCounterText: false,
    );
  }
}
