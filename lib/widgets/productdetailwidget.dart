import 'package:flutter/material.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_card.dart';
import 'package:ecom_app/widgets/custom_container.dart';

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
    return CustomContainer(
      color: AppColors.lightGrey,
      padding: EdgeInsets.zero,
      boxShadow: [],
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
    return CustomCard(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      radius: 20,
      backgroundColor: AppColors.lightGrey,
      border: Border.all(color: Colors.transparent),
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
    return CustomCard(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      radius: 12,
      border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
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
