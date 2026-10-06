import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String? hintText;
  final String? labelText;

  final String? Function(String?)? validator;

  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;

  final TextInputType keyboardType;

  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  final TextCapitalization textCapitalization;

  final List<TextInputFormatter>? inputFormatters;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  final TextInputAction? textInputAction;

  final EdgeInsetsGeometry? contentPadding;

  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? cursorColor;

  final double borderRadius;

  final bool showCounterText;

  const CustomTextField({
    super.key,

    this.controller,
    this.focusNode,

    this.hintText,
    this.labelText,

    this.validator,

    this.prefixIcon,
    this.prefix,
    this.suffix,

    this.keyboardType = TextInputType.text,

    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,

    this.maxLines = 1,
    this.minLines,
    this.maxLength,

    this.textCapitalization = TextCapitalization.none,

    this.inputFormatters,

    this.onChanged,
    this.onSubmitted,
    this.onTap,

    this.textInputAction,

    this.contentPadding,

    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.cursorColor,

    this.borderRadius = 14,

    this.showCounterText = false,
  });

  @override
  Widget build(BuildContext context) {
    Color normalBorder = AppColors.isDark
        ? Color(0xff3A3A3A)
        : Color(0xffE5E5E5);

    Color hintColor = AppColors.isDark ? Color(0xff8A8A8A) : Color(0xff999999);

    Color disabledBorder = AppColors.isDark
        ? Color(0xff2C2C2C)
        : Color(0xffEEEEEE);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,

      keyboardType: keyboardType,

      obscureText: obscureText,

      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,

      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,

      textCapitalization: textCapitalization,

      inputFormatters: inputFormatters,

      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,

      textInputAction: textInputAction,

      cursorColor: cursorColor ?? AppColors.primary,

      validator: validator,

      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),

      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,

        hintStyle: TextStyle(fontSize: 14, color: hintColor),

        labelStyle: TextStyle(fontSize: 14, color: AppColors.grey),

        floatingLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),

        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.grey, size: 21)
            : null,

        prefix: prefix,

        suffix: suffix,

        filled: true,

        fillColor: fillColor ?? AppColors.background,

        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 16, vertical: 17),

        counterText: showCounterText ? null : '',

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor ?? normalBorder, width: 1),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor ?? normalBorder, width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: focusedBorderColor ?? AppColors.primary,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.red, width: 1),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.red, width: 1.5),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: disabledBorder),
        ),

        errorStyle: TextStyle(
          fontSize: 12,
          color: AppColors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
