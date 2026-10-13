import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/services/cart_service.dart';
import 'package:ecom_app/services/order_service.dart';
import 'package:ecom_app/services/user_service.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_card.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';

class MyCartPage extends StatefulWidget {
  MyCartPage({super.key});

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final UserService _userService = UserService();

  Future<Map<String, String>?> _collectDeliveryDetails() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return null;
    }

    Map<String, dynamic> profile = {};
    try {
      profile = await _userService.getUserProfile(currentUser.uid);
    } catch (_) {}

    if (!mounted) {
      return null;
    }

    final nameController = TextEditingController(
      text: (profile["name"] ?? "").toString(),
    );
    final phoneController = TextEditingController(
      text: (profile["Phone Number"] ?? profile["phone"] ?? "").toString(),
    );
    final addressController = TextEditingController(
      text: (profile["address"] ?? "").toString(),
    );
    final formKey = GlobalKey<FormState>();

    try {
      return await showDialog<Map<String, String>>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text("Delivery details", style: AppTextStyles.title),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _deliveryField(
                      controller: nameController,
                      label: "Full name",
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 12),
                    _deliveryField(
                      controller: phoneController,
                      label: "Phone number",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12),
                    _deliveryField(
                      controller: addressController,
                      label: "Delivery address",
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              CustomButton(
                text: "Cancel",
                onTap: () => Navigator.pop(dialogContext),
                fitContent: true,
                height: 40,
                borderRadius: 8,
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                textColor: AppColors.primary,
              ),
              CustomButton(
                text: "Continue",
                onTap: () {
                  if (formKey.currentState?.validate() != true) {
                    return;
                  }

                  Navigator.pop(dialogContext, {
                    "customerName": nameController.text.trim(),
                    "phone": phoneController.text.trim(),
                    "address": addressController.text.trim(),
                  });
                },
                fitContent: true,
                height: 40,
                borderRadius: 8,
                backgroundColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                textColor: AppColors.primary,
              ),
            ],
          );
        },
      );
    } finally {
      nameController.dispose();
      phoneController.dispose();
      addressController.dispose();
    }
  }

  Widget _deliveryField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return CustomTextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      labelText: label,
      prefixIcon: icon,
      fillColor: AppColors.white,
      borderColor: AppColors.grey.withValues(alpha: 0.2),
      focusedBorderColor: AppColors.primary,
      borderRadius: 12,
      validator: (value) =>
          value == null || value.trim().isEmpty ? "Enter your $label" : null,
    );
  }

  Future<void> orderAllProducts(List<Map<String, dynamic>> products) async {
    final deliveryDetails = await _collectDeliveryDetails();
    if (deliveryDetails == null) {
      return;
    }

    try {
      final orderCreated = await _orderService.createOrdersFromCart(
        products: products,
        deliveryDetails: deliveryDetails,
      );

      if (!mounted || !orderCreated) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Order placed successfully")));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to place all orders")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authService.currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text("My Cart", style: AppTextStyles.title),
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
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),
        title: Text("My Cart", style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cartService.watchCart(_authService.currentUser?.uid),
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
                        Icons.shopping_cart_outlined,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Your Cart is Empty",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Products you add to cart will appear here",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final cartItems = snapshot.data!;
          final grandTotal = _cartService.calculateTotal(cartItems);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final product = cartItems[index];
                    final productId =
                        (product["productId"] ?? product["documentId"] ?? "")
                            .toString();
                    final itemQuantity = _cartService.getItemQuantity(product);
                    final itemPrice = _cartService.getItemPrice(product);

                    return CustomCard(
                      margin: EdgeInsets.only(bottom: 14),
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            height: 90,
                            width: 75,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child:
                                  (product["imageUrl"] ?? "").toString().isEmpty
                                  ? Icon(
                                      Icons.image_outlined,
                                      color: AppColors.grey,
                                    )
                                  : Image.network(
                                      product["imageUrl"].toString(),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                  product["name"] ?? "No Name",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Rs. ${itemPrice.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _cartService.decrementQuantity(
                                            userId:
                                                _authService.currentUser?.uid,
                                            productId: productId,
                                            quantity: itemQuantity,
                                          ),
                                      child: Container(
                                        height: 28,
                                        width: 28,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: AppColors.background,
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      itemQuantity.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () =>
                                          _cartService.incrementQuantity(
                                            userId:
                                                _authService.currentUser?.uid,
                                            productId: productId,
                                            quantity: itemQuantity,
                                          ),
                                      child: Container(
                                        height: 28,
                                        width: 28,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          color: AppColors.primary,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () => _cartService.removeItem(
                                  userId: _authService.currentUser?.uid,
                                  productId: productId,
                                ),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.red,
                                ),
                              ),
                              Text(
                                "Rs. ${(itemPrice * itemQuantity).toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 15,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Rs. ${grandTotal.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14),
                    CustomButton(
                      text: "Order Now",
                      onTap: () => orderAllProducts(cartItems),
                      height: 50,
                      borderRadius: 15,
                      textColor: Colors.white,
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
