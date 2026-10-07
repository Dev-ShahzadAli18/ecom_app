import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecom_app/theme/app_colors.dart';

import 'package:ecom_app/theme/app_textstyle.dart';

import 'package:ecom_app/widgets/custom_container.dart';

import 'package:flutter/material.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final String orderId;
  final String buyerId;
  final Map<String, dynamic> order;

  AdminOrderDetailsPage({
    super.key,
    required this.orderId,
    required this.buyerId,
    required this.order,
  });

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  Future<Map<String, dynamic>>? customerFuture;

  @override
  void initState() {
    super.initState();
    customerFuture = _loadCustomer();
  }

  Future<Map<String, dynamic>> _loadCustomer() async {
    if (widget.buyerId.isEmpty) {
      return {};
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.buyerId)
        .get();
    return snapshot.data() ?? {};
  }

  double _number(dynamic value) {
    return value is num ? value.toDouble() : 0;
  }

  int _quantity(dynamic value) {
    return value is num ? value.toInt() : 1;
  }

  String _display(dynamic orderValue, dynamic profileValue) {
    final orderText = orderValue?.toString().trim() ?? "";
    if (orderText.isNotEmpty) {
      return orderText;
    }

    final profileText = profileValue?.toString().trim() ?? "";
    return profileText.isEmpty ? "Not provided" : profileText;
  }

  String _formatDate(dynamic value) {
    if (value is! Timestamp) {
      return "Date pending";
    }

    final date = value.toDate();
    return "${date.day.toString().padLeft(2, "0")}/${date.month.toString().padLeft(2, "0")}/${date.year}  ${date.hour.toString().padLeft(2, "0")}:${date.minute.toString().padLeft(2, "0")}";
  }

  Widget _detailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: AppColors.grey),
            SizedBox(width: 10),
          ],
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final quantity = _quantity(order["quantity"]);
    final price = _number(order["price"]);
    final total = order["totalPrice"] is num
        ? _number(order["totalPrice"])
        : price * quantity;
    final padding = (MediaQuery.sizeOf(context).width * 0.05).clamp(14.0, 24.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: Text("Order Details", style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: customerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final customer = snapshot.data ?? {};
          final customerName = _display(
            order["customerName"],
            customer["name"],
          );
          final phone = _display(
            order["phone"],
            customer["Phone Number"] ?? customer["phone"],
          );
          final address = _display(order["address"], customer["address"]);
          final email = _display(order["email"], customer["email"]);
          final productName = (order["name"] ?? "Order item").toString();
          final imageUrl = (order["imageUrl"] ?? "").toString();

          return ListView(
            padding: EdgeInsets.all(padding),
            children: [
              CustomContainer(
                padding: EdgeInsets.all(14),
                borderRadius: 12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 94,
                      width: 82,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imageUrl.isEmpty
                          ? Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.grey,
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppColors.grey,
                                  ),
                            ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(productName, style: AppTextStyles.title),
                          SizedBox(height: 8),
                          Text(
                            "Order #${widget.orderId}",
                            style: AppTextStyles.body.copyWith(fontSize: 12),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "${(order["status"] ?? "Pending")} · ${_formatDate(order["createdAt"])}",
                            style: AppTextStyles.body.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              CustomContainer(
                padding: EdgeInsets.all(16),
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Customer", style: AppTextStyles.title),
                    SizedBox(height: 8),
                    _detailRow(
                      "Name",
                      customerName,
                      icon: Icons.person_outline,
                    ),
                    _detailRow("Phone", phone, icon: Icons.phone_outlined),
                    _detailRow("Email", email, icon: Icons.email_outlined),
                    _detailRow(
                      "Address",
                      address,
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              CustomContainer(
                padding: EdgeInsets.all(16),
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order", style: AppTextStyles.title),
                    SizedBox(height: 8),
                    _detailRow("Product", productName),
                    _detailRow("Quantity", quantity.toString()),
                    _detailRow("Color", _display(order["color"], null)),
                    _detailRow("Unit price", "Rs. ${price.toStringAsFixed(0)}"),
                    Divider(color: AppColors.grey.withValues(alpha: 0.15)),
                    _detailRow("Total", "Rs. ${total.toStringAsFixed(0)}"),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
