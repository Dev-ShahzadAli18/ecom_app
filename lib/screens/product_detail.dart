import 'package:ecom_app/screens/add_product.dart';
import 'package:ecom_app/screens/order.dart';
import 'package:ecom_app/services/cart_service.dart';
import 'package:ecom_app/services/product_service.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/productdetailwidget.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final String role;

  ProductDetailPage({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavorite,
    required this.role,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final CartService _cartService = CartService();
  final ProductService _productService = ProductService();
  bool isDeleting = false;
  bool isAddingToCart = false;

  String get normalizedRole => widget.role.trim().toLowerCase();

  bool get canManage {
    return normalizedRole == "admin";
  }

  Future<void> editProduct() async {
    bool? updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddProductPage(product: widget.product);
        },
      ),
    );

    if (updated == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _handleDeleteProduct() async {
    try {
      setState(() {
        isDeleting = true;
      });

      final deleted = await _productService.deleteProduct(
        widget.product["id"]?.toString(),
      );

      if (!mounted || !deleted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isDeleting = false;
      });

      showMessage("Failed to delete product: $e");
    }
  }

  void showDeleteDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Delete Product", style: AppTextStyles.title),
          content: Text(
            "Are you sure you want to delete this product?",
            style: AppTextStyles.body,
          ),
          actions: [
            CustomButton(
              text: "Cancel",
              fitContent: true,
              height: 40,
              borderRadius: 8,
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              textColor: AppColors.primary,
              onTap: () {
                Navigator.pop(dialogContext);
              },
            ),
            CustomButton(
              text: "Delete",
              fitContent: true,
              height: 40,
              borderRadius: 8,
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(dialogContext);
                _handleDeleteProduct();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAddToCart() async {
    try {
      setState(() {
        isAddingToCart = true;
      });

      final result = await _cartService.addProduct(product: widget.product);

      if (!mounted) {
        return;
      }

      setState(() {
        isAddingToCart = false;
      });

      if (result == AddToCartResult.requiresLogin) {
        showMessage("Please login first");
      } else if (result == AddToCartResult.added) {
        showMessage("Product added to cart");
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isAddingToCart = false;
      });

      showMessage("Failed to add product to cart");
    }
  }

  void openOrderPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return OrderNowPage(product: widget.product);
        },
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double horizontalPadding = (screenWidth * 0.045).clamp(14.0, 24.0);
    final double imageHeight = (mediaQuery.size.height * 0.38).clamp(
      240.0,
      380.0,
    );

    String imageUrl = widget.product["imageUrl"] ?? "";
    String name = widget.product["name"] ?? "No Name";
    String description = widget.product["description"] ?? "";
    String category = widget.product["category"] ?? "";
    String collection = widget.product["collection"] ?? "";
    bool orderAvailable = widget.product["orderAvailable"] ?? true;

    double price = 0;
    if (widget.product["price"] is num) {
      price = (widget.product["price"] as num).toDouble();
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
        title: Text("Product Details", style: AppTextStyles.title),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.onFavorite,
            icon: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? Colors.red : AppColors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: horizontalPadding,
          right: horizontalPadding,
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),

            // Responsive image
            CustomProductDetailImage(imageUrl: imageUrl, height: imageHeight),

            SizedBox(height: 20),

            CustomProductDetailHeader(name: name, price: price),

            SizedBox(height: 14),

            CustomProductInfo(category: category, collection: collection),

            SizedBox(height: 22),

            CustomProductDescription(description: description),

            SizedBox(height: 22),

            CustomOrderAvailability(orderAvailable: orderAvailable),

            SizedBox(height: 28),

            // Seller / Admin Management Actions
            if (canManage) ...[
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: "Edit / Update",
                      icon: Icons.edit_outlined,
                      onTap: editProduct,
                      height: 52,
                      borderRadius: 12,
                      backgroundColor: AppColors.white,
                      textColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: isDeleting ? "Deleting..." : "Delete",
                      icon: Icons.delete_outline,
                      onTap: isDeleting ? null : showDeleteDialog,
                      height: 52,
                      borderRadius: 12,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      enabled: !isDeleting,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
            ],

            // Cart and order actions are only available to buyers.
            if (normalizedRole == "user") ...[
              CustomButton(
                text: isAddingToCart ? "Adding to Cart..." : "Add to Cart",
                icon: Icons.shopping_cart_outlined,
                onTap: isAddingToCart ? null : _handleAddToCart,
                height: 52,
                borderRadius: 12,
                backgroundColor: AppColors.white,
                textColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                enabled: !isAddingToCart,
              ),
              SizedBox(height: 12),
              CustomButton(
                text: "Order Now",
                icon: Icons.shopping_bag_outlined,
                onTap: orderAvailable ? openOrderPage : null,
                height: 52,
                borderRadius: 12,
                backgroundColor: AppColors.primary,
                textColor: Colors.black,
                enabled: orderAvailable,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
