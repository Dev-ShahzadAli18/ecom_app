import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/widgets/my_cartwidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';

class MyCartPage extends StatefulWidget {
  MyCartPage({super.key});

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  User? get user {
    return FirebaseAuth.instance.currentUser;
  }

  CollectionReference? get cartCollection {
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .collection("cart");
  }

  Stream<QuerySnapshot> getCart() {
    final collection = cartCollection;
    if (collection == null) {
      return Stream.empty();
    }

    return collection.snapshots();
  }

  Future increaseQuantity(String productId, int quantity) async {
    final collection = cartCollection;
    if (collection == null) return;
    await collection.doc(productId).update({"quantity": quantity + 1});
  }

  Future<void> decreaseQuantity(String productId, int quantity) async {
    if (quantity <= 1) {
      await removeFromCart(productId);
      return;
    }

    final collection = cartCollection;
    if (collection == null) return;
    await collection.doc(productId).update({"quantity": quantity - 1});
  }

  Future removeFromCart(String productId) async {
    final collection = cartCollection;
    if (collection == null) return;
    await collection.doc(productId).delete();
  }

  double getPrice(Map<String, dynamic> product) {
    if (product["price"] is num) {
      return (product["price"] as num).toDouble();
    }

    return 0;
  }

  int getQuantity(Map<String, dynamic> product) {
    if (product["quantity"] is num) {
      return (product["quantity"] as num).toInt();
    }

    return 1;
  }

  Future<Map<String, String>?> _collectDeliveryDetails() async {
    final currentUser = user;
    if (currentUser == null) {
      return null;
    }

    Map<String, dynamic> profile = {};
    try {
      final profileSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser.uid)
          .get();
      profile = profileSnapshot.data() ?? {};
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
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState?.validate() != true) {
                    return;
                  }

                  Navigator.pop(dialogContext, {
                    "customerName": nameController.text.trim(),
                    "phone": phoneController.text.trim(),
                    "address": addressController.text.trim(),
                  });
                },
                child: Text("Continue"),
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: AppColors.primary,
      style: TextStyle(color: AppColors.black, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.grey),
        floatingLabelStyle: TextStyle(color: AppColors.primary),
        hintStyle: TextStyle(color: AppColors.grey),
        prefixIcon: Icon(icon, color: AppColors.grey),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? "Enter your $label" : null,
    );
  }

  Future<void> orderAllProducts(List<Map<String, dynamic>> products) async {
    final currentUser = user;
    if (currentUser == null || products.isEmpty) {
      return;
    }

    final deliveryDetails = await _collectDeliveryDetails();
    if (deliveryDetails == null) {
      return;
    }

    try {
      for (final product in products) {
        final price = getPrice(product);
        final quantity = getQuantity(product);
        final productId = (product["productId"] ?? product["documentId"] ?? "")
            .toString();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .collection("orders")
            .add({
              "productId": productId,
              "name": product["name"] ?? "",
              "price": price,
              "imageUrl": product["imageUrl"] ?? "",
              "quantity": quantity,
              "totalPrice": price * quantity,
              "customerName": deliveryDetails["customerName"],
              "phone": deliveryDetails["phone"],
              "address": deliveryDetails["address"],
              "email": currentUser.email ?? "",
              "status": "Pending",
              "createdAt": FieldValue.serverTimestamp(),
            });

        await cartCollection?.doc(productId).delete();
      }

      if (!mounted) {
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
    if (user == null) {
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
          onPressed: () {
            Navigator.pop(context);
          },

          icon: Icon(Icons.arrow_back, color: AppColors.black),
        ),

        title: Text("My Cart", style: AppTextStyles.title),

        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: getCart(),

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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return CustomEmptyCart();
          }

          List<Map<String, dynamic>> cartItems = [];

          for (var document in snapshot.data!.docs) {
            Map<String, dynamic> product =
                document.data() as Map<String, dynamic>;

            product["documentId"] = document.id;

            cartItems.add(product);
          }

          double grandTotal = 0;

          for (var product in cartItems) {
            double price = getPrice(product);
            int quantity = getQuantity(product);

            grandTotal += price * quantity;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),

                  itemCount: cartItems.length,

                  itemBuilder: (context, index) {
                    Map<String, dynamic> product = cartItems[index];

                    String productId =
                        product["productId"] ?? product["documentId"];

                    return CustomCartItem(
                      name: product["name"] ?? "No Name",

                      imageUrl: product["imageUrl"] ?? "",

                      price: getPrice(product),

                      quantity: getQuantity(product),

                      onIncrease: () {
                        increaseQuantity(productId, getQuantity(product));
                      },

                      onDecrease: () {
                        decreaseQuantity(productId, getQuantity(product));
                      },

                      onDelete: () {
                        removeFromCart(productId);
                      },
                    );
                  },
                ),
              ),

              CustomCartBottom(
                total: grandTotal,

                onOrder: () {
                  orderAllProducts(cartItems);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
