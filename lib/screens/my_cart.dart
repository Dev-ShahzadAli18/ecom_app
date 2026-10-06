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

  Future<void> increaseQuantity(String productId, int quantity) async {
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

  Future<void> removeFromCart(String productId) async {
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

  Future<void> orderProduct(Map<String, dynamic> product) async {
    if (user == null) {
      return;
    }

    double price = getPrice(product);
    int quantity = getQuantity(product);

    double totalPrice = price * quantity;

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("orders")
          .add({
            "productId": product["productId"] ?? "",
            "name": product["name"] ?? "",
            "price": price,
            "imageUrl": product["imageUrl"] ?? "",
            "quantity": quantity,
            "totalPrice": totalPrice,
            "status": "Pending",
            "createdAt": FieldValue.serverTimestamp(),
          });

      await cartCollection?.doc(product["productId"]).delete();

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
      ).showSnackBar(SnackBar(content: Text("Failed to place order")));
    }
  }

  Future<void> orderAllProducts(List<Map<String, dynamic>> products) async {
    for (var product in products) {
      await orderProduct(product);
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
