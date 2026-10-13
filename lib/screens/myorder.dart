import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/services/order_service.dart';
import 'package:ecom_app/widgets/custom_card.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';

class MyOrdersPage extends StatelessWidget {
  final AuthService _authService = AuthService();
  final OrderService _orderService = OrderService();

  MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text("My Orders", style: AppTextStyles.title),
          centerTitle: true,
        ),
        body: Center(
          child: Text("Please login first", style: AppTextStyles.body),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: Text("My Orders", style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _orderService.watchUserOrders(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Something went wrong", style: AppTextStyles.body),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(30),
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
                    SizedBox(height: 20),
                    Text(
                      "No Orders Yet",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8),
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

          final double padding = (MediaQuery.of(context).size.width * 0.045)
              .clamp(12.0, 20.0);

          return ListView.builder(
            padding: EdgeInsets.all(padding),
            physics: BouncingScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final order = snapshot.data![index];

              final status = order["status"] ?? "Pending";
              final statusColor = status.toLowerCase() == "pending"
                  ? Colors.orange
                  : status.toLowerCase() == "confirmed"
                  ? Colors.blue
                  : status.toLowerCase() == "delivered"
                  ? Colors.green
                  : status.toLowerCase() == "cancelled"
                  ? Colors.red
                  : AppColors.grey;

              return CustomCard(
                margin: EdgeInsets.only(bottom: 14),
                padding: EdgeInsets.all(12),
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
                            child: (order["imageUrl"] ?? "").toString().isEmpty
                                ? Icon(
                                    Icons.image_outlined,
                                    color: AppColors.grey,
                                  )
                                : Image.network(
                                    (order["imageUrl"] ?? "").toString(),
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
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order["name"] ?? "No Name",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Rs. ${_orderService.getPrice(order).toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Quantity: ${_orderService.getQuantity(order)}",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(color: AppColors.grey.withValues(alpha: 0.12)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 17,
                          color: AppColors.grey,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Color: ",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.grey,
                          ),
                        ),
                        Text(
                          (order["color"] ?? "").toString().isEmpty
                              ? "Not selected"
                              : (order["color"] ?? "").toString(),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 17,
                          color: AppColors.grey,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (order["address"] ?? "").toString().isEmpty
                                ? "No address"
                                : (order["address"] ?? "").toString(),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _orderService.formatDate(order["createdAt"]),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.grey,
                          ),
                        ),
                        Text(
                          "Total: Rs. ${_orderService.getTotalPrice(order).toStringAsFixed(0)}",
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
            },
          );
        },
      ),
    );
  }
}
