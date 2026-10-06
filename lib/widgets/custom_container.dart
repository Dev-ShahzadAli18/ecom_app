import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget? child;
  final double? height;
  final double? width;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  final Color? color;

  final double borderRadius;

  final Border? border;

  final List<BoxShadow>? boxShadow;

  final VoidCallback? onTap;
  final BoxShape? shape;

  const CustomContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = 16,
    this.border,
    this.boxShadow,
    this.onTap,
    this.height,
    this.width,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    double shadowOpacity = AppColors.isDark ? 0.0 : 0.04;

    Widget container = Container(
      margin: margin,
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
        border: border,
        shape: shape ?? BoxShape.rectangle,
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: shadowOpacity),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }

    return container;
  }
}
