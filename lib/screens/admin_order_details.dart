import 'package:ecom_app/services/admin_service.dart';
import 'package:ecom_app/services/order_service.dart';
import 'package:ecom_app/services/user_service.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_container.dart';
import 'package:ecom_app/widgets/custom_detail_row.dart';

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
  final UserService _userService = UserService();
  final OrderService _orderService = OrderService();
  final AdminService _adminService = AdminService();
  Future<Map<String, dynamic>>? customerFuture;
  late String currentStatus;
  bool isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    customerFuture = _userService.getCustomerProfile(widget.buyerId);
    currentStatus = (widget.order["status"] ?? "Pending").toString();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final quantity = _orderService.getQuantity(order);
    final price = _orderService.getPrice(order);
    final total = _orderService.getTotalPrice(order);

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
        actions: [
          PopupMenuButton<String>(
            tooltip: "Update Status",
            icon: isUpdatingStatus
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(Icons.more_vert, color: AppColors.black),
            onSelected: isUpdatingStatus
                ? null
                : (newStatus) async {
                    if (newStatus == currentStatus) return;
                    setState(() => isUpdatingStatus = true);
                    try {
                      await _adminService.updateOrderStatus(
                        buyerId: widget.buyerId,
                        orderId: widget.orderId,
                        newStatus: newStatus,
                      );
                      if (!context.mounted) return;
                      setState(() {
                        currentStatus = newStatus;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Order status changed to $newStatus"),
                        ),
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to update status: $e"),
                          ),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => isUpdatingStatus = false);
                    }
                  },
            itemBuilder: (context) => [
              PopupMenuItem(value: "Pending", child: Text("Set as Pending")),
              PopupMenuItem(
                value: "Processing",
                child: Text("Set as Processing"),
              ),
              PopupMenuItem(
                value: "Delivered",
                child: Text("Set as Delivered"),
              ),
              PopupMenuItem(
                value: "Cancelled",
                child: Text("Set as Cancelled"),
              ),
            ],
          ),
        ],
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

          final customerName = _userService.resolveOrderProfileValue(
            order["customerName"],
            customer["name"],
          );

          final phone = _userService.resolveOrderProfileValue(
            order["phone"],
            customer["Phone Number"] ?? customer["phone"],
          );

          final address = _userService.resolveOrderProfileValue(
            order["address"],
            customer["address"],
          );

          final email = _userService.resolveOrderProfileValue(
            order["email"],
            customer["email"],
          );

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
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.grey,
                                );
                              },
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
                            "$currentStatus · "
                            "${_adminService.formatDate(order["createdAt"])}",
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

                    CustomDetailRow(
                      label: "Name",
                      value: customerName,
                      icon: Icons.person_outline,
                    ),

                    CustomDetailRow(
                      label: "Phone",
                      value: phone,
                      icon: Icons.phone_outlined,
                    ),

                    CustomDetailRow(
                      label: "Email",
                      value: email,
                      icon: Icons.email_outlined,
                    ),

                    CustomDetailRow(
                      label: "Address",
                      value: address,
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

                    CustomDetailRow(label: "Product", value: productName),

                    CustomDetailRow(
                      label: "Quantity",
                      value: quantity.toString(),
                    ),

                    CustomDetailRow(
                      label: "Color",
                      value: _userService.resolveOrderProfileValue(
                        order["color"],
                        null,
                      ),
                    ),

                    CustomDetailRow(
                      label: "Unit price",
                      value: "Rs. ${price.toStringAsFixed(0)}",
                    ),

                    Divider(color: AppColors.grey.withValues(alpha: 0.15)),

                    CustomDetailRow(
                      label: "Total",
                      value: "Rs. ${total.toStringAsFixed(0)}",
                    ),
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
