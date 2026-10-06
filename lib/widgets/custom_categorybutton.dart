import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  CategoryButton({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: SizedBox(
        width: 80,

        child: Column(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),

              height: 58,
              width: 58,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: isSelected ? AppColors.primary : AppColors.lightGrey,

                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.lightGrey,

                  width: 1,
                ),
              ),

              child: Icon(
                icon,

                size: 25,

                color: isSelected ? Colors.white : AppColors.black,
              ),
            ),

            SizedBox(height: 8),

            Text(
              title,

              maxLines: 1,
              overflow: TextOverflow.ellipsis,

              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.black : AppColors.grey,

                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),

              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
