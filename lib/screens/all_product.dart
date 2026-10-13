import 'package:flutter/material.dart';

import 'package:ecom_app/screens/product_detail.dart';
import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/services/favorite_service.dart';
import 'package:ecom_app/services/product_service.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_card.dart';

class AllProductsPage extends StatefulWidget {
  final String collectionName;
  final String category;
  final String role;

  AllProductsPage({
    super.key,
    required this.collectionName,
    this.category = "All",
    required this.role,
  });

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();

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

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _productService.watchProducts(),

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

          if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
            return Center(
              child: Text("No products available", style: AppTextStyles.body),
            );
          }

          final products = _productService.filterProducts(
            productSnapshot.data!,
            collectionName: widget.collectionName,
            category: widget.category,
          );

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

          return StreamBuilder<Set<String>>(
            stream: _favoriteService.watchFavoriteIds(
              _authService.currentUser?.uid,
            ),

            builder: (context, favoriteSnapshot) {
              if (favoriteSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final favoriteIds = favoriteSnapshot.data ?? <String>{};

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

                itemCount: products.length,

                itemBuilder: (context, index) {
                  Map<String, dynamic> product = products[index];

                  String productId = product["id"];

                  final isFavorite = favoriteIds.contains(productId);

                  return CustomCard.product(
                    product: product,
                    isFavorite: isFavorite,
                    onFavorite: () => _favoriteService.toggleFavorite(
                      userId: _authService.currentUser?.uid,
                      product: product,
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            product: product,
                            isFavorite: isFavorite,
                            onFavorite: () => _favoriteService.toggleFavorite(
                              userId: _authService.currentUser?.uid,
                              product: product,
                            ),
                            role: widget.role,
                          ),
                        ),
                      );
                    },
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
