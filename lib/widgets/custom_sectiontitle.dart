import 'package:ecom_app/screens/all_product.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:flutter/material.dart';

class CustomSectionTitle extends StatelessWidget {
  final String title;
  final String collectionName;
  final String category;
  final String role;

  const CustomSectionTitle({
    super.key,
    required this.title,
    required this.collectionName,
    required this.category,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return AllProductsPage(
                    collectionName: collectionName,
                    category: category,
                    role: role,
                  );
                },
              ),
            );
          },
          child: Text(
            "See All",
            style: AppTextStyles.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
