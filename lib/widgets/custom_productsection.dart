import 'package:ecom_app/screens/product_detail.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_card.dart';
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
      return CustomCard(
        height: 120,
        width: double.infinity,
        radius: 12,
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

          final isFavorite = favoriteIds.contains(product["id"]);

          return CustomCard.product(
            product: product,
            isFavorite: isFavorite,
            onFavorite: () => onFavorite(product),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(
                    product: product,
                    isFavorite: isFavorite,
                    onFavorite: () => onFavorite(product),
                    role: role,
                  ),
                ),
              );
            },
            width: 170,
            margin: EdgeInsets.only(right: 14),
          );
        },
      ),
    );
  }
}
