import 'package:flutter/material.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_card.dart';
import 'package:ecom_app/widgets/custom_container.dart';

class CustomOrderProduct extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;

  CustomOrderProduct({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(12),
      border: Border.all(color: Colors.transparent),
      child: Row(
        children: [
          CustomContainer(
            height: 90,
            width: 80,
            padding: EdgeInsets.zero,
            color: AppColors.background,
            borderRadius: 14,
            boxShadow: [],
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl.isEmpty
                  ? Icon(Icons.image_outlined, color: AppColors.grey, size: 35)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_outlined,
                          color: AppColors.grey,
                          size: 35,
                        );
                      },
                    ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Rs. ${price.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Quantity: $quantity",
                  style: TextStyle(fontSize: 13, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomColorSelector extends StatelessWidget {
  final List<String> colors;
  final String selectedColor;
  final Function(String) onColorSelected;

  CustomColorSelector({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  Color getColor(String colorName) {
    if (colorName == "Black") {
      return Colors.black;
    } else if (colorName == "White") {
      return Colors.white;
    } else if (colorName == "Red") {
      return Colors.red;
    } else if (colorName == "Blue") {
      return Colors.blue;
    } else if (colorName == "Green") {
      return Colors.green;
    } else if (colorName == "Yellow") {
      return Colors.yellow;
    } else if (colorName == "Grey") {
      return Colors.grey;
    } else if (colorName == "Pink") {
      return Colors.pink;
    } else if (colorName == "Purple") {
      return Colors.purple;
    }

    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((colorName) {
        bool isSelected = selectedColor == colorName;

        return CustomButton(
          text: colorName,
          onTap: () => onColorSelected(colorName),
          fitContent: true,
          height: 40,
          borderRadius: 12,
          padding: EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: isSelected
              ? AppColors.primary.withValues(alpha: 0.10)
              : AppColors.white,
          textColor: AppColors.black,
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withValues(alpha: 0.20),
            width: isSelected ? 2 : 1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomContainer(
                height: 22,
                width: 22,
                padding: EdgeInsets.zero,
                color: getColor(colorName),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.30),
                ),
                boxShadow: [],
                child: SizedBox.shrink(),
              ),
              SizedBox(width: 7),
              Text(
                colorName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class CustomQuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  CustomQuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CustomButton(
          text: "",
          onTap: onDecrease,
          width: 38,
          height: 38,
          borderRadius: 10,
          padding: EdgeInsets.zero,
          backgroundColor: AppColors.background,
          child: Icon(Icons.remove, size: 19, color: AppColors.black),
        ),
        SizedBox(width: 18),
        Text(
          quantity.toString(),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
        SizedBox(width: 18),
        CustomButton(
          text: "",
          onTap: onIncrease,
          width: 38,
          height: 38,
          borderRadius: 10,
          padding: EdgeInsets.zero,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          child: Icon(Icons.add, size: 19, color: Colors.white),
        ),
      ],
    );
  }
}

class CustomOrderTotal extends StatelessWidget {
  final double total;

  CustomOrderTotal({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: EdgeInsets.all(18),
      border: Border.all(color: Colors.transparent),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total Amount",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
            ),
          ),
          Text(
            "Rs. ${total.toStringAsFixed(0)}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
