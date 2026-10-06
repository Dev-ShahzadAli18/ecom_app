import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onTap;

  final Color? iconColor;
  final Color? backgroundColor;

  final double? size;
  final double? iconSize;

  CustomIconButton({
    super.key,
    this.icon,
    this.onTap,
    this.iconColor,
    this.backgroundColor,
    this.size = 45,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    Color defaultBg = AppColors.isDark ? Color(0xff2C2C2C) : Color(0xffF5F5F5);

    return Material(
      color: backgroundColor ?? defaultBg,
      borderRadius: BorderRadius.circular(14),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(14),

        child: SizedBox(
          height: size,
          width: size,

          child: Icon(
            icon,
            size: iconSize,
            color: iconColor ?? AppColors.black,
          ),
        ),
      ),
    );
  }
}
