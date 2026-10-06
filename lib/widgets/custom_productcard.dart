import 'package:ecom_app/screens/product_detail.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:flutter/material.dart';

class CustomProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final String role;

  const CustomProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = (screenWidth * 0.44).clamp(150.0, 190.0);

    String imageUrl = product["imageUrl"] ?? "";
    String name = product["name"] ?? "No Name";
    String description = product["description"] ?? "";

    double price = 0;
    if (product["price"] is num) {
      price = (product["price"] as num).toDouble();
    }

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ProductDetailPage(
                product: product,
                isFavorite: isFavorite,
                onFavorite: onFavorite,
                role: role,
              );
            },
          ),
        );
      },
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.grey.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Proportional flexible image
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _imageError();
                              },
                            )
                          : _imageError(),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: AppColors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onFavorite,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFavorite ? Colors.red : AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card text info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                    Text(
                      "\$${price.toStringAsFixed(2)}",
                      style: AppTextStyles.title.copyWith(
                        fontSize: 14.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageError() {
    return Container(
      color: AppColors.lightGrey,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey,
        size: 36,
      ),
    );
  }
}
