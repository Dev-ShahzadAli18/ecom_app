import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_container.dart';

import 'package:ecom_app/screens/admin_order_details.dart';
import 'package:flutter/material.dart';

class AdminOrdersPage extends StatelessWidget {
  final String role;

  AdminOrdersPage({super.key, required this.role});

  Stream<QuerySnapshot<Map<String, dynamic>>> getOrders() {
    return FirebaseFirestore.instance
        .collectionGroup("orders")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) {
      return "Date pending";
    }

    final date = value.toDate();
    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");
    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");
    return "$day/$month/${date.year} $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    if (role.trim().toLowerCase() != "admin") {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Text("Orders", style: AppTextStyles.title),
        ),
        body: Center(
          child: Text("Admin access required", style: AppTextStyles.body),
        ),
      );
    }

    final padding = (MediaQuery.sizeOf(context).width * 0.045).clamp(
      12.0,
      20.0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: Text("Customer Orders", style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            return Center(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Text(
                  "Unable to load orders.\n$error",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body,
                ),
              ),
            );
          }

          final orders = snapshot.data?.docs ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Text("No customer orders yet", style: AppTextStyles.body),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(padding),
            physics: BouncingScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (context, index) => SizedBox(height: 10),
            itemBuilder: (context, index) {
              final document = orders[index];
              final order = document.data();
              final buyerId = document.reference.parent.parent?.id ?? "";
              final productName = (order["name"] ?? "Order item").toString();
              final customerName = (order["customerName"] ?? "Customer")
                  .toString();
              final status = (order["status"] ?? "Pending").toString();
              final quantity = order["quantity"] is num
                  ? (order["quantity"] as num).toInt()
                  : 1;
              final total = order["totalPrice"] is num
                  ? (order["totalPrice"] as num).toDouble()
                  : (order["price"] is num
                        ? (order["price"] as num).toDouble() * quantity
                        : 0.0);

              return CustomContainer(
                padding: EdgeInsets.all(14),
                borderRadius: 12,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminOrderDetailsPage(
                        orderId: document.id,
                        buyerId: buyerId,
                        order: order,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Container(
                      height: 58,
                      width: 58,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: (order["imageUrl"] ?? "").toString().isEmpty
                          ? Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.grey,
                            )
                          : Image.network(
                              order["imageUrl"].toString(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppColors.grey,
                                  ),
                            ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.title.copyWith(fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "$customerName · Qty $quantity",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Rs. ${total.toStringAsFixed(0)} · ${_formatDate(order["createdAt"])}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          status,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Icon(Icons.chevron_right, color: AppColors.grey),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
