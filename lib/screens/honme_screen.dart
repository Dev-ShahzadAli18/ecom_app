import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/services/category_service.dart';
import 'package:ecom_app/services/favorite_service.dart';
import 'package:ecom_app/services/product_service.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
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
  final ProductService _productService = ProductService();
  final FavoriteService _favoriteService = FavoriteService();
  final AuthService _authService = AuthService();
  final CategoryService _categoryService = CategoryService();
  int selectedCategory = 0;

  final List<String> categories = CategoryService.categoriesWithAll;
  final List<IconData> categoryIcons = CategoryService.defaultCategoryIcons;

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

          final products = _categoryService.filterByCategory(
            productSnapshot.data!,
            categories[selectedCategory],
          );

          return StreamBuilder<Set<String>>(
            stream: _favoriteService.watchFavoriteIds(
              _authService.currentUser?.uid,
            ),

            builder: (context, favoriteSnapshot) {
              final favoriteIds = favoriteSnapshot.data ?? <String>{};

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

                            child: CustomButton(
                              text: categories[index],
                              width: 80,
                              height: 95,
                              borderRadius: 12,
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              textColor: AppColors.black,
                              onTap: () {
                                setState(() {
                                  selectedCategory = index;
                                });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    height: 58,
                                    width: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: selectedCategory == index
                                          ? AppColors.primary
                                          : AppColors.lightGrey,
                                      border: Border.all(
                                        color: selectedCategory == index
                                            ? AppColors.primary
                                            : AppColors.lightGrey,
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      categoryIcons[index],
                                      size: 25,
                                      color: selectedCategory == index
                                          ? Colors.white
                                          : AppColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    categories[index],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.body.copyWith(
                                      color: selectedCategory == index
                                          ? AppColors.black
                                          : AppColors.grey,
                                      fontWeight: selectedCategory == index
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
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
                      products: _productService.filterProducts(
                        products,
                        collectionName: "Featured",
                      ),

                      favoriteIds: favoriteIds,

                      onFavorite: (product) => _favoriteService.toggleFavorite(
                        userId: _authService.currentUser?.uid,
                        product: product,
                      ),

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
                      products: _productService.filterProducts(
                        products,
                        collectionName: "Recommended",
                      ),

                      favoriteIds: favoriteIds,

                      onFavorite: (product) => _favoriteService.toggleFavorite(
                        userId: _authService.currentUser?.uid,
                        product: product,
                      ),

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
                      products: _productService.filterProducts(
                        products,
                        collectionName: "Top Collection",
                      ),

                      favoriteIds: favoriteIds,

                      onFavorite: (product) => _favoriteService.toggleFavorite(
                        userId: _authService.currentUser?.uid,
                        product: product,
                      ),

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
