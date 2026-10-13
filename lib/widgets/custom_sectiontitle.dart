import 'package:ecom_app/screens/all_product.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:flutter/material.dart';

class CustomSectionTitle extends StatelessWidget {
  final String title;
  final String collectionName;
  final String category;
  final String role;

  CustomSectionTitle({
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

        CustomButton(
          text: "See All",
          height: 34,
          fitContent: true,
          borderRadius: 0,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          textColor: AppColors.primary,
          fontSize: 14,
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
        ),
      ],
    );
  }
}
