import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/widgets/custom_allproductcard.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';

class AllProductsPage extends StatefulWidget {
  final String collectionName;
  final String category;
  final String role;

  const AllProductsPage({
    super.key,
    required this.collectionName,
    this.category = "All",
    required this.role,
  });

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  Stream<QuerySnapshot> getProducts() {
    return FirebaseFirestore.instance
        .collection("products")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getFavorites() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .snapshots();
  }

  Future<void> toggleFavorite(Map<String, dynamic> product) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    String productId = product["id"];

    DocumentReference favoriteRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .doc(productId);

    DocumentSnapshot favorite = await favoriteRef.get();

    if (favorite.exists) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set(product);
    }
  }

  @override
  Widget build(BuildContext context) {
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

        title: Text(widget.collectionName, style: AppTextStyles.title),

        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: getProducts(),

        builder: (context, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (productSnapshot.hasError) {
            return Center(
              child: Text("Something went wrong", style: AppTextStyles.body),
            );
          }

          if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No products available", style: AppTextStyles.body),
            );
          }

          List<Map<String, dynamic>> products = [];

          for (var document in productSnapshot.data!.docs) {
            Map<String, dynamic> product =
                document.data() as Map<String, dynamic>;

            product["id"] = document.id;

            String productCollection = product["collection"] ?? "";

            String productCategory = product["category"] ?? "";

            bool collectionMatch =
                widget.collectionName == "All" ||
                productCollection == widget.collectionName;

            bool categoryMatch =
                widget.category == "All" || productCategory == widget.category;

            if (collectionMatch && categoryMatch) {
              products.add(product);
            }
          }

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 60,
                    color: AppColors.grey,
                  ),

                  SizedBox(height: 15),

                  Text("No products found", style: AppTextStyles.title),

                  SizedBox(height: 5),

                  Text(
                    widget.category == "All"
                        ? "No products in this collection"
                        : "No ${widget.category} products in this collection",
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<QuerySnapshot>(
            stream: getFavorites(),

            builder: (context, favoriteSnapshot) {
              if (favoriteSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              Set<String> favoriteIds = {};

              if (favoriteSnapshot.hasData) {
                for (var document in favoriteSnapshot.data!.docs) {
                  favoriteIds.add(document.id);
                }
              }

              final mediaQuery = MediaQuery.of(context);
              final double screenWidth = mediaQuery.size.width;
              final double padding = (screenWidth * 0.045).clamp(12.0, 20.0);
              final double childAspectRatio = screenWidth < 360 ? 0.60 : 0.65;

              return GridView.builder(
                padding: EdgeInsets.all(padding),
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 15,
                  childAspectRatio: childAspectRatio,
                ),

                itemCount: products.length,

                itemBuilder: (context, index) {
                  Map<String, dynamic> product = products[index];

                  String productId = product["id"];

                  return AllProductsCard(
                    product: product,
                    isFavorite: favoriteIds.contains(productId),

                    onFavorite: () {
                      toggleFavorite(product);
                    },

                    role: widget.role,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
