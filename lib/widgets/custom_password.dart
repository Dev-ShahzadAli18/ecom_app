import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_validator.dart';
import 'package:flutter/material.dart';

class CustomPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  CustomPasswordField({
    super.key,
    this.controller,
    this.hintText = "Password",
    this.labelText,
    this.validator,
    this.textInputAction,
    this.onChanged,
    this.focusNode,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    Color normalBorder = AppColors.isDark
        ? Color(0xff3A3A3A)
        : Color(0xffE5E5E5);

    Color hintColor = AppColors.isDark ? Color(0xff8A8A8A) : Color(0xff999999);

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: !isVisible,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      validator: widget.validator ?? Validators.password,

      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),

      cursorColor: AppColors.primary,

      decoration: InputDecoration(
        hintText: widget.hintText,
        labelText: widget.labelText,

        hintStyle: TextStyle(color: hintColor, fontSize: 14),

        labelStyle: TextStyle(color: AppColors.grey),

        prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey, size: 21),

        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              isVisible = !isVisible;
            });
          },
          icon: Icon(
            isVisible
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.grey,
          ),
        ),

        filled: true,
        fillColor: AppColors.background,

        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 17),

        errorStyle: TextStyle(color: AppColors.red, fontSize: 12),

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

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
    );
  }
}
