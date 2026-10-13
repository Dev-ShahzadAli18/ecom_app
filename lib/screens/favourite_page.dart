import 'package:ecom_app/screens/product_detail.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/services/favorite_service.dart';
import 'package:ecom_app/widgets/custom_card.dart';

class FavouritePage extends StatelessWidget {
  final String role;
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();

  FavouritePage({super.key, required this.role});

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

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _favoriteService.watchFavoriteProducts(
          _authService.currentUser?.uid,
        ),

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

          final favorites = snapshot.data!;

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

              return CustomCard.product(
                product: product,
                isFavorite: true,
                onFavorite: () => _favoriteService.removeFavorite(
                  userId: _authService.currentUser?.uid,
                  productId: product["id"],
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        product: product,
                        isFavorite: true,
                        onFavorite: () => _favoriteService.removeFavorite(
                          userId: _authService.currentUser?.uid,
                          productId: product["id"],
                        ),
                        role: role,
                      ),
                    ),
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
