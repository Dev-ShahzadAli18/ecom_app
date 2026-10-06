import 'package:ecom_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomMyOrderCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final double price;
  final double totalPrice;
  final int quantity;
  final String color;
  final String status;
  final String address;
  final String date;

  const CustomMyOrderCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.totalPrice,
    required this.quantity,
    required this.color,
    required this.status,
    required this.address,
    required this.date,
  });

  Color getStatusColor() {
    if (status.toLowerCase() == "pending") {
      return Colors.orange;
    } else if (status.toLowerCase() == "confirmed") {
      return Colors.blue;
    } else if (status.toLowerCase() == "delivered") {
      return Colors.green;
    } else if (status.toLowerCase() == "cancelled") {
      return Colors.red;
    }

    return AppColors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 85,
                width: 75,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: imageUrl.isEmpty
                      ? Icon(Icons.image_outlined, color: AppColors.grey)
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_outlined,
                              color: AppColors.grey,
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      "Rs. ${price.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Quantity: $quantity",
                      style: TextStyle(fontSize: 12.5, color: AppColors.grey),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor().withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: getStatusColor(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Divider(color: AppColors.grey.withValues(alpha: 0.12)),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.palette_outlined, size: 17, color: AppColors.grey),

              const SizedBox(width: 6),

              Text(
                "Color: ",
                style: TextStyle(fontSize: 12.5, color: AppColors.grey),
              ),

              Text(
                color.isEmpty ? "Not selected" : color,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 17, color: AppColors.grey),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  address.isEmpty ? "No address" : address,
                  style: TextStyle(fontSize: 12.5, color: AppColors.grey),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: TextStyle(fontSize: 11.5, color: AppColors.grey)),

              Text(
                "Total: Rs. ${totalPrice.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomEmptyOrders extends StatelessWidget {
  const CustomEmptyOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 50,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "No Orders Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Your placed orders will appear here",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
