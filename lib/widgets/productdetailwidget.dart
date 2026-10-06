import 'package:flutter/material.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';

class CustomProductDetailImage extends StatelessWidget {
  final String imageUrl;
  final double? height;

  CustomProductDetailImage({super.key, required this.imageUrl, this.height});

  @override
  Widget build(BuildContext context) {
    final double responsiveHeight =
        height ??
        (MediaQuery.of(context).size.height * 0.38).clamp(240.0, 380.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: responsiveHeight,
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return CustomProductImageError();
                },
              )
            : CustomProductImageError(),
      ),
    );
  }
}

class CustomProductImageError extends StatelessWidget {
  CustomProductImageError({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lightGrey,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey,
        size: 60,
      ),
    );
  }
}

class CustomProductDetailHeader extends StatelessWidget {
  final String name;
  final double price;

  CustomProductDetailHeader({
    super.key,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(name, style: AppTextStyles.title.copyWith(fontSize: 22)),
        ),
        SizedBox(width: 10),
        Text(
          "\$${price.toStringAsFixed(2)}",
          style: AppTextStyles.title.copyWith(
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class CustomProductInfo extends StatelessWidget {
  final String category;
  final String collection;

  CustomProductInfo({
    super.key,
    required this.category,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (category.isNotEmpty) CustomProductInfoChip(text: category),
        if (collection.isNotEmpty) CustomProductInfoChip(text: collection),
      ],
    );
  }
}

class CustomProductInfoChip extends StatelessWidget {
  final String text;

  CustomProductInfoChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: AppTextStyles.body.copyWith(fontSize: 12)),
    );
  }
}

class CustomProductDescription extends StatelessWidget {
  final String description;

  CustomProductDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description", style: AppTextStyles.title.copyWith(fontSize: 17)),
        SizedBox(height: 8),
        Text(
          description.isEmpty ? "No description available" : description,
          style: AppTextStyles.body.copyWith(fontSize: 13.5, height: 1.45),
        ),
      ],
    );
  }
}

class CustomOrderAvailability extends StatelessWidget {
  final bool orderAvailable;

  CustomOrderAvailability({super.key, required this.orderAvailable});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            orderAvailable ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: orderAvailable ? Colors.green : Colors.red,
          ),
          SizedBox(width: 10),
          Text(
            orderAvailable
                ? "In Stock (Orders Available)"
                : "Out of Stock (Orders Unavailable)",
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAdminButtons extends StatelessWidget {
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final bool isDeleting;

  CustomAdminButtons({
    super.key,
    required this.onUpdate,
    required this.onDelete,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onUpdate,
            icon: Icon(Icons.edit_outlined),
            label: Text("Edit / Update"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isDeleting ? null : onDelete,
            icon: Icon(Icons.delete_outline),
            label: Text(isDeleting ? "Deleting..." : "Delete"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomUserButtons extends StatelessWidget {
  final VoidCallback onAddToCart;
  final VoidCallback onOrderNow;
  final bool isAddingToCart;
  final bool isOrdering;
  final bool orderAvailable;

  CustomUserButtons({
    super.key,
    required this.onAddToCart,
    required this.onOrderNow,
    required this.isAddingToCart,
    required this.isOrdering,
    required this.orderAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isAddingToCart ? null : onAddToCart,
            icon: Icon(Icons.shopping_cart_outlined),
            label: Text(isAddingToCart ? "Adding to Cart..." : "Add to Cart"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: orderAvailable && !isOrdering ? onOrderNow : null,
            icon: Icon(Icons.shopping_bag_outlined),
            label: Text(isOrdering ? "Processing..." : "Order Now"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppColors.lightGrey,
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
