import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  final double? height;
  final double? width;
  final bool fitContent;
  final double borderRadius;

  final bool loading;
  final bool enabled;

  final IconData? icon;
  final Widget? child;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? disabledTextColor;
  final Color? disabledBackgroundColor;
  final BorderSide? side;
  final EdgeInsetsGeometry? padding;

  final double fontSize;

  CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.height,
    this.width,
    this.fitContent = false,
    this.borderRadius = 15,
    this.loading = false,
    this.enabled = true,
    this.icon,
    this.child,
    this.backgroundColor,
    this.textColor,
    this.disabledTextColor,
    this.disabledBackgroundColor,
    this.side,
    this.padding,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final preferredHeight = height ?? (viewportWidth < 360 ? 48.0 : 54.0);
    final foregroundColor = textColor ?? AppColors.black;

    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonHeight = constraints.hasBoundedHeight
            ? preferredHeight.clamp(0.0, constraints.maxHeight).toDouble()
            : preferredHeight;
        final buttonWidth = width != null && constraints.hasBoundedWidth
            ? width!.clamp(0.0, constraints.maxWidth).toDouble()
            : width ?? double.infinity;

        final button = ElevatedButton(
          onPressed: enabled && !loading ? onTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            foregroundColor: foregroundColor,
            disabledBackgroundColor:
                disabledBackgroundColor ?? AppColors.lightGrey,
            disabledForegroundColor: disabledTextColor ?? AppColors.grey,
            elevation: 0,
            padding: padding ?? EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: side ?? BorderSide.none,
            ),
          ),
          child: loading
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: foregroundColor,
                  ),
                )
              : child ??
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: foregroundColor),
                          SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: foregroundColor,
                              fontSize: viewportWidth < 360
                                  ? fontSize * 0.92
                                  : fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
        );

        if (fitContent) {
          return IntrinsicWidth(
            child: SizedBox(height: buttonHeight, child: button),
          );
        }

        return SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: button,
        );
      },
    );
  }
}
