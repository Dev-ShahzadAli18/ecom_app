import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/screens/add_product.dart';
import 'package:ecom_app/screens/order.dart';
import 'package:ecom_app/theme/app_colors.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/productdetailwidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future deleteProduct() async {
    String productId = widget.product["id"] ?? "";

    if (productId.isEmpty) {
      return;
    }

    try {
      setState(() {
        isDeleting = true;
      });

      await FirebaseFirestore.instance
          .collection("products")
          .doc(productId)
          .delete();

      if (!mounted) {
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
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                deleteProduct();
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> addToCart() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage("Please login first");
      return;
    }

    String productId = widget.product["id"] ?? "";

    if (productId.isEmpty) {
      return;
    }

    try {
      setState(() {
        isAddingToCart = true;
      });

      DocumentReference cartRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("cart")
          .doc(productId);

      DocumentSnapshot cartItem = await cartRef.get();

      if (cartItem.exists) {
        int quantity = 1;

        Map<String, dynamic> data = cartItem.data() as Map<String, dynamic>;

        if (data["quantity"] is num) {
          quantity = (data["quantity"] as num).toInt();
        }

        await cartRef.update({"quantity": quantity + 1});
      } else {
        await cartRef.set({
          "productId": productId,
          "name": widget.product["name"] ?? "",
          "price": widget.product["price"] ?? 0,
          "imageUrl": widget.product["imageUrl"] ?? "",
          "quantity": 1,
          "addedAt": FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) {
        return;
      }

      setState(() {
        isAddingToCart = false;
      });

      showMessage("Product added to cart");
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
              CustomAdminButtons(
                onUpdate: editProduct,
                onDelete: showDeleteDialog,
                isDeleting: isDeleting,
              ),
              SizedBox(height: 14),
            ],

            // Cart and order actions are only available to buyers.
            if (normalizedRole == "user")
              CustomUserButtons(
                onAddToCart: addToCart,
                onOrderNow: openOrderPage,
                isAddingToCart: isAddingToCart,
                isOrdering: false,
                orderAvailable: orderAvailable,
              ),
          ],
        ),
      ),
    );
  }
}
