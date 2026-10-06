import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomOtpField extends StatelessWidget {
  final int length;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const CustomOtpField({
    super.key,
    this.length = 4,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Color normalBorder = AppColors.isDark
        ? const Color(0xff3A3A3A)
        : const Color(0xffE5E5E5);

    Color hintColor = AppColors.isDark
        ? const Color(0xff6A6A6A)
        : const Color(0xffBBBBBB);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: length,
      textAlign: TextAlign.center,
      onChanged: onChanged,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 8,
        color: AppColors.black,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        counterText: "",
        hintText: "----",
        hintStyle: TextStyle(color: hintColor, letterSpacing: 8),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: normalBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: normalBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
