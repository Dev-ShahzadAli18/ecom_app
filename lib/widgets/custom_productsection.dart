import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_productcard.dart';
import 'package:flutter/material.dart';

class CustomProductSection extends StatelessWidget {
  final String role;
  final List<Map<String, dynamic>> products;
  final Set<String> favoriteIds;
  final Future<void> Function(Map<String, dynamic>) onFavorite;

  CustomProductSection({
    super.key,
    required this.products,
    required this.favoriteIds,
    required this.onFavorite,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            "No products in this collection",
            style: AppTextStyles.body,
          ),
        ),
      );
    }

    final double sectionHeight = (MediaQuery.of(context).size.height * 0.36)
        .clamp(260.0, 300.0);

    return SizedBox(
      height: sectionHeight,
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> product = products[index];

          return CustomProductCard(
            product: product,
            isFavorite: favoriteIds.contains(product["id"]),
            onFavorite: () {
              onFavorite(product);
            },
            role: role,
          );
        },
      ),
    );
  }
}
