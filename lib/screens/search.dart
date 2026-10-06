import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_allproductcard.dart';

class SearchPage extends StatefulWidget {
  final String role;

  const SearchPage({super.key, this.role = "user"});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getProducts() {
    return FirebaseFirestore.instance
        .collection("products")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getFavorites() {
    final user = FirebaseAuth.instance.currentUser;
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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final productId = product["id"] as String;
    final favoriteRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .doc(productId);
    final favorite = await favoriteRef.get();

    if (favorite.exists) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = (screenWidth * 0.045).clamp(12.0, 20.0);
    final childAspectRatio = screenWidth < 360 ? 0.60 : 0.65;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text("Search", style: AppTextStyles.title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(padding, 4, padding, 12),
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search products",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: "Clear search",
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getProducts(),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (productSnapshot.hasError) {
                  return Center(
                    child: Text(
                      "Could not load products",
                      style: AppTextStyles.body,
                    ),
                  );
                }

                final query = searchController.text.trim().toLowerCase();
                final products =
                    productSnapshot.data?.docs
                        .map(
                          (document) => {...document.data(), "id": document.id},
                        )
                        .where((product) {
                          if (query.isEmpty) {
                            return true;
                          }

                          final searchableText = [
                            product["name"],
                            product["description"],
                            product["category"],
                          ].whereType<String>().join(" ").toLowerCase();
                          return searchableText.contains(query);
                        })
                        .toList() ??
                    <Map<String, dynamic>>[];

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      query.isEmpty
                          ? "No products available"
                          : "No products found",
                      style: AppTextStyles.body,
                    ),
                  );
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: getFavorites(),
                  builder: (context, favoriteSnapshot) {
                    final favoriteIds =
                        favoriteSnapshot.data?.docs
                            .map((document) => document.id)
                            .toSet() ??
                        <String>{};

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
                        final product = products[index];
                        final productId = product["id"] as String;

                        return AllProductsCard(
                          product: product,
                          isFavorite: favoriteIds.contains(productId),
                          onFavorite: () => toggleFavorite(product),
                          role: widget.role,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
