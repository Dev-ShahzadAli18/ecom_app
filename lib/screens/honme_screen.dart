import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_categorybutton.dart';
import 'package:ecom_app/widgets/custom_drwaer.dart';
import 'package:ecom_app/widgets/custom_productsection.dart';
import 'package:ecom_app/widgets/custom_sectiontitle.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  final String role;

  HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;

  final List<String> categories = [
    "All",
    "Women",
    "Men",
    "Accessories",
    "Beauty",
  ];

  final List<IconData> categoryIcons = [
    Icons.apps,
    Icons.woman,
    Icons.man,
    Icons.watch_outlined,
    Icons.face_retouching_natural,
  ];

  Stream<QuerySnapshot> getProducts() {
    return FirebaseFirestore.instance
        .collection("products")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getFavorites() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .snapshots();
  }

  Future toggleFavorite(Map<String, dynamic> product) async {
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

  bool categoryMatches(Map<String, dynamic> product) {
    if (selectedCategory == 0) {
      return true;
    }

    String selected = categories[selectedCategory];

    return product["category"] == selected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      drawer: CustomDrawer(role: widget.role),

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu, color: AppColors.black, size: 28),
            );
          },
        ),

        title: Text("GemStore", style: AppTextStyles.title),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: () {
              // Search baad mein add karenge
            },
            icon: Icon(Icons.search, color: AppColors.black),
          ),
        ],
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

            if (categoryMatches(product)) {
              products.add(product);
            }
          }

          return StreamBuilder<QuerySnapshot>(
            stream: getFavorites(),

            builder: (context, favoriteSnapshot) {
              Set<String> favoriteIds = {};

              if (favoriteSnapshot.hasData) {
                for (var document in favoriteSnapshot.data!.docs) {
                  favoriteIds.add(document.id);
                }
              }

              final double horizontalPadding =
                  (MediaQuery.of(context).size.width * 0.045).clamp(14.0, 24.0);

              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 30,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(height: 10),

                    Text("Categories", style: AppTextStyles.title),

                    SizedBox(height: 16),

                    SizedBox(
                      height: 95,

                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,

                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 12),

                            child: CategoryButton(
                              title: categories[index],
                              icon: categoryIcons[index],
                              isSelected: selectedCategory == index,

                              onTap: () {
                                setState(() {
                                  selectedCategory = index;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 25),

                    CustomSectionTitle(
                      title: "Featured",
                      collectionName: "Featured",
                      category: categories[selectedCategory],
                      role: widget.role,
                    ),

                    SizedBox(height: 15),

                    CustomProductSection(
                      products: products
                          .where(
                            (product) => product["collection"] == "Featured",
                          )
                          .toList(),

                      favoriteIds: favoriteIds,

                      onFavorite: toggleFavorite,

                      role: widget.role,
                    ),

                    SizedBox(height: 30),

                    CustomSectionTitle(
                      title: "Recommended",
                      collectionName: "Recommended",
                      category: categories[selectedCategory],
                      role: widget.role,
                    ),

                    SizedBox(height: 15),

                    CustomProductSection(
                      products: products
                          .where(
                            (product) => product["collection"] == "Recommended",
                          )
                          .toList(),

                      favoriteIds: favoriteIds,

                      onFavorite: toggleFavorite,

                      role: widget.role,
                    ),

                    SizedBox(height: 30),

                    CustomSectionTitle(
                      title: "Top Collection",
                      collectionName: "Top Collection",
                      category: categories[selectedCategory],
                      role: widget.role,
                    ),

                    SizedBox(height: 15),

                    CustomProductSection(
                      products: products
                          .where(
                            (product) =>
                                product["collection"] == "Top Collection",
                          )
                          .toList(),

                      favoriteIds: favoriteIds,

                      onFavorite: toggleFavorite,

                      role: widget.role,
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
