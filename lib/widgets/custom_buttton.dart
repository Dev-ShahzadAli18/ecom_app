import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  final double height;
  final double borderRadius;

  final bool loading;
  final bool enabled;

  final IconData? icon;
  final Widget? child;

  final Color? backgroundColor;
  final Color? textColor;

  final double fontSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.height = 54,
    this.borderRadius = 15,
    this.loading = false,
    this.enabled = true,
    this.icon,
    this.child,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: enabled && !loading ? onTap : null,

        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color.fromARGB(255, 245, 183, 0),

          disabledBackgroundColor: Color(0xffDDDDDD),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),

        child: loading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : child ??
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: textColor ?? Colors.white),
                        SizedBox(width: 8),
                      ],

                      Text(
                        text,
                        style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
