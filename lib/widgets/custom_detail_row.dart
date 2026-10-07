import 'package:flutter/material.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';

class CustomDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final double labelWidth;

  CustomDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.labelWidth = 92,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.grey),
            SizedBox(width: 10),
          ],
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }
}
