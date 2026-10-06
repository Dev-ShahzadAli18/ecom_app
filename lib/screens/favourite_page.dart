import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/widgets/custom_allproductcard.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';

class FavouritePage extends StatelessWidget {
  final String role;

  FavouritePage({super.key, required this.role});

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

  Future<void> removeFavorite(String productId) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .doc(productId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text("Favourite Products", style: AppTextStyles.title),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: getFavorites(),

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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 70, color: AppColors.grey),

                  SizedBox(height: 15),

                  Text("No Favourite Products", style: AppTextStyles.title),

                  SizedBox(height: 5),

                  Text(
                    "Products you favourite will appear here",
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          List<Map<String, dynamic>> favorites = [];

          for (var document in snapshot.data!.docs) {
            Map<String, dynamic> product =
                document.data() as Map<String, dynamic>;

            product["id"] = document.id;

            favorites.add(product);
          }

          final mediaQuery = MediaQuery.of(context);
          final double screenWidth = mediaQuery.size.width;
          final double padding = (screenWidth * 0.045).clamp(12.0, 20.0);
          final double childAspectRatio = screenWidth < 360 ? 0.60 : 0.65;

          return GridView.builder(
            padding: EdgeInsets.all(padding),
            physics: BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 15,
              childAspectRatio: childAspectRatio,
            ),

            itemCount: favorites.length,

            itemBuilder: (context, index) {
              Map<String, dynamic> product = favorites[index];

              return AllProductsCard(
                product: product,
                isFavorite: true,

                onFavorite: () {
                  removeFavorite(product["id"]);
                },

                role: role,
              );
            },
          );
        },
      ),
    );
  }
}
