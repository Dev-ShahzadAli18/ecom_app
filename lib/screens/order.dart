import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/services/order_service.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_orderwodget.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';

class OrderNowPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final int initialQuantity;

  OrderNowPage({super.key, required this.product, this.initialQuantity = 1});

  @override
  State<OrderNowPage> createState() => _OrderNowPageState();
}

class _OrderNowPageState extends State<OrderNowPage> {
  final AuthService _authService = AuthService();
  final OrderService _orderService = OrderService();
  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  int quantity = 1;

  String selectedColor = "Black";

  bool isOrdering = false;

  List<String> availableColors = [
    "Black",
    "White",
    "Red",
    "Blue",
    "Green",
    "Yellow",
    "Grey",
    "Pink",
    "Purple",
  ];

  @override
  void initState() {
    super.initState();

    quantity = widget.initialQuantity;

    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      nameController.text = currentUser.displayName ?? "";
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();

    super.dispose();
  }

  Future placeOrder() async {
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String address = addressController.text.trim();

    if (name.isEmpty) {
      showMessage("Please enter your name");
      return;
    }

    if (phone.isEmpty) {
      showMessage("Please enter your phone number");
      return;
    }

    if (address.isEmpty) {
      showMessage("Please enter your delivery address");
      return;
    }

    if (selectedColor.isEmpty) {
      showMessage("Please select a color");
      return;
    }

    try {
      setState(() {
        isOrdering = true;
      });

      final orderCreated = await _orderService.createOrder(
        product: widget.product,
        quantity: quantity,
        color: selectedColor,
        customerName: name,
        phone: phone,
        address: address,
      );

      if (!mounted || !orderCreated) {
        return;
      }

      setState(() {
        isOrdering = false;
      });

      showMessage("Order placed successfully");

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isOrdering = false;
      });

      showMessage("Failed to place order");
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final price = _orderService.getPrice(widget.product);
    final total = _orderService.getProductTotal(widget.product, quantity);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text("Order Now", style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: (MediaQuery.of(context).size.width * 0.045).clamp(
            14.0,
            24.0,
          ),
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomOrderProduct(
              name: widget.product["name"] ?? "No Name",
              imageUrl: widget.product["imageUrl"] ?? "",
              price: price,
              quantity: quantity,
            ),

            SizedBox(height: 25),

            Text(
              "Select Color",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),

            SizedBox(height: 12),

            CustomColorSelector(
              colors: availableColors,
              selectedColor: selectedColor,
              onColorSelected: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),

            SizedBox(height: 25),

            Text(
              "Quantity",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),

            SizedBox(height: 12),

            CustomQuantitySelector(
              quantity: quantity,
              onIncrease: () {
                setState(() {
                  quantity++;
                });
              },
              onDecrease: () {
                if (quantity > 1) {
                  setState(() {
                    quantity--;
                  });
                }
              },
            ),

            SizedBox(height: 25),

            Text(
              "Delivery Information",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
              ),
            ),

            SizedBox(height: 12),

            CustomTextField(
              controller: nameController,
              labelText: "Full Name",
              hintText: "Enter your name",
              fillColor: AppColors.white,
              borderColor: AppColors.grey.withValues(alpha: 0.15),
            ),

            SizedBox(height: 12),

            CustomTextField(
              controller: phoneController,
              labelText: "Phone Number",
              hintText: "03XX XXXXXXX",
              keyboardType: TextInputType.phone,
              fillColor: AppColors.white,
              borderColor: AppColors.grey.withValues(alpha: 0.15),
            ),

            SizedBox(height: 12),

            CustomTextField(
              controller: addressController,
              labelText: "Delivery Address",
              hintText: "Enter your complete address",
              maxLines: 3,
              fillColor: AppColors.white,
              borderColor: AppColors.grey.withValues(alpha: 0.15),
            ),

            SizedBox(height: 25),

            CustomOrderTotal(total: total),

            SizedBox(height: 18),

            CustomButton(
              text: "Place Order",
              onTap: placeOrder,
              loading: isOrdering,
              height: 54,
              borderRadius: 15,
              disabledBackgroundColor: AppColors.grey,
              textColor: Colors.white,
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
