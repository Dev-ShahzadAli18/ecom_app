import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? prefixIconWidget;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool showPasswordToggle;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
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
    this.prefixIconWidget,
    this.prefix,
    this.suffix,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.showPasswordToggle = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.textInputAction,
    this.textAlign = TextAlign.start,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.cursorColor,
    this.borderRadius = 14,
    this.showCounterText = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = !widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final Color normalBorder = AppColors.isDark
        ? const Color.fromARGB(255, 58, 58, 58)
        : const Color.fromARGB(255, 229, 229, 229);

    final Color hintColor = AppColors.isDark
        ? const Color.fromARGB(255, 138, 138, 138)
        : const Color.fromARGB(255, 153, 153, 153);

    final Color disabledBorder = AppColors.isDark
        ? const Color.fromARGB(255, 44, 44, 44)
        : const Color.fromARGB(255, 238, 238, 238);

    final bool showPasswordIcon =
        widget.showPasswordToggle && widget.obscureText;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      textAlign: widget.textAlign,
      keyboardType: widget.keyboardType,
      obscureText:
          widget.obscureText && !(showPasswordIcon && _passwordVisible),
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      textInputAction: widget.textInputAction,
      cursorColor: widget.cursorColor ?? AppColors.primary,
      validator: widget.validator,
      style:
          widget.textStyle ??
          TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,
        hintStyle:
            widget.hintStyle ?? TextStyle(fontSize: 14, color: hintColor),
        labelStyle: TextStyle(fontSize: 14, color: AppColors.grey),
        floatingLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: AppColors.grey, size: 21)
            : widget.prefixIconWidget,
        prefix: widget.prefix,
        suffix: widget.suffix,
        suffixIcon: showPasswordIcon
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.grey,
                ),
              )
            : widget.suffixIcon,
        filled: true,
        fillColor: widget.fillColor ?? AppColors.background,
        contentPadding:
            widget.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        counterText: widget.showCounterText ? null : '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? normalBorder,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.borderColor ?? normalBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: AppColors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: AppColors.red, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
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
