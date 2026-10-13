import 'package:flutter/material.dart';

import 'package:ecom_app/screens/product_detail.dart';
import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/services/favorite_service.dart';
import 'package:ecom_app/services/product_service.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_card.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';

class SearchPage extends StatefulWidget {
  final String role;

  SearchPage({super.key, this.role = "user"});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
            child: CustomTextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              hintText: "Search products",
              prefixIcon: Icons.search,
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: "Clear search",
                      onPressed: () {
                        searchController.clear();
                        setState(() {});
                      },
                      icon: Icon(Icons.close),
                    ),
              fillColor: AppColors.white,
              borderColor: Colors.transparent,
              focusedBorderColor: AppColors.primary,
              borderRadius: 12,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _productService.watchProducts(),
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
                final products = _productService.searchProducts(
                  productSnapshot.data ?? <Map<String, dynamic>>[],
                  query,
                );

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

                return StreamBuilder<Set<String>>(
                  stream: _favoriteService.watchFavoriteIds(
                    _authService.currentUser?.uid,
                  ),
                  builder: (context, favoriteSnapshot) {
                    final favoriteIds = favoriteSnapshot.data ?? <String>{};

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
                        final product = products[index];
                        final productId = product["id"] as String;

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
                                  onFavorite: () =>
                                      _favoriteService.toggleFavorite(
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
          ),
        ],
      ),
    );
  }
}
