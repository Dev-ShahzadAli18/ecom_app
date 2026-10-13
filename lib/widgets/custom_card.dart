import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_container.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.radius = 18,
    this.width,
    this.height,
    this.backgroundColor,
    this.border,
    this.boxShadow,
  });

  factory CustomCard.product({
    Key? key,
    required Map<String, dynamic> product,
    required bool isFavorite,
    required VoidCallback onFavorite,
    required VoidCallback onTap,
    double? width,
    EdgeInsetsGeometry? margin,
  }) {
    final imageUrl = product["imageUrl"]?.toString() ?? "";
    final name = product["name"]?.toString() ?? "No Name";
    final description = product["description"]?.toString() ?? "";
    final price = product["price"] is num
        ? (product["price"] as num).toDouble()
        : 0.0;

    return CustomCard(
      key: key,
      width: width,
      margin: margin,
      padding: EdgeInsets.zero,
      radius: 14,
      border: Border.all(color: AppColors.grey.withValues(alpha: 0.08)),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: imageUrl.isEmpty
                      ? _productImagePlaceholder()
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _productImagePlaceholder(),
                        ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: CustomButton(
                    text: "",
                    onTap: onFavorite,
                    width: 32,
                    height: 32,
                    borderRadius: 16,
                    padding: EdgeInsets.zero,
                    backgroundColor: AppColors.white.withValues(alpha: 0.9),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isFavorite ? Colors.red : AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                      SizedBox(height: 2),
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
    );
  }

  static Widget _productImagePlaceholder() {
    return CustomContainer(
      color: AppColors.lightGrey,
      padding: EdgeInsets.zero,
      boxShadow: [],
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey,
        size: 36,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        border:
            border ?? Border.all(color: AppColors.grey.withValues(alpha: 0.12)),
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}
