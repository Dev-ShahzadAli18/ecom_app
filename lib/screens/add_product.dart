import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_container.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:ecom_app/widgets/listtile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/theme/app_colors.dart';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController productNameController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final TextEditingController imageUrlController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  bool orderAvailable = true;

  String selectedCategory = "Women";

  String selectedCollection = "Featured";

  bool isSaving = false;

  final List<String> categories = ["Women", "Men", "Accessories", "Beauty"];

  final List<String> collections = [
    "Featured",
    "Recommended",
    "Top Collection",
  ];

  bool get isEditMode {
    return widget.product != null;
  }

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      loadOldProductData();
    }
  }

  void loadOldProductData() {
    Map<String, dynamic> product = widget.product!;

    productNameController.text = product["name"] ?? "";

    priceController.text = product["price"]?.toString() ?? "";

    imageUrlController.text = product["imageUrl"] ?? "";

    descriptionController.text = product["description"] ?? "";

    selectedCategory = product["category"] ?? "Women";

    selectedCollection = product["collection"] ?? "Featured";

    orderAvailable = product["orderAvailable"] ?? true;
  }

  Future<void> saveProduct() async {
    String productName = productNameController.text.trim();

    String priceText = priceController.text.trim();

    String imageUrl = imageUrlController.text.trim();

    String description = descriptionController.text.trim();

    if (productName.isEmpty ||
        priceText.isEmpty ||
        imageUrl.isEmpty ||
        description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please fill all fields")));

      return;
    }

    double? price = double.tryParse(priceText);

    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please enter a valid price")));

      return;
    }

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please login first")));

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      if (isEditMode) {
        await updateProduct(price: price, productId: widget.product!["id"]);
      } else {
        await FirebaseFirestore.instance.collection("products").add({
          "name": productName,
          "price": price,
          "imageUrl": imageUrl,
          "description": description,
          "category": selectedCategory,
          "collection": selectedCollection,
          "orderAvailable": orderAvailable,
          "userId": user.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Product added successfully")));

        clearFields();
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> updateProduct({
    required double price,
    required String productId,
  }) async {
    await FirebaseFirestore.instance
        .collection("products")
        .doc(productId)
        .update({
          "name": productNameController.text.trim(),
          "price": price,
          "imageUrl": imageUrlController.text.trim(),
          "description": descriptionController.text.trim(),
          "category": selectedCategory,
          "collection": selectedCollection,
          "orderAvailable": orderAvailable,
        });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Product updated successfully")));

    Navigator.pop(context, true);
  }

  void clearFields() {
    productNameController.clear();
    priceController.clear();
    imageUrlController.clear();
    descriptionController.clear();

    setState(() {
      selectedCategory = "Women";
      selectedCollection = "Featured";
      orderAvailable = true;
    });
  }

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    descriptionController.dispose();

    super.dispose();
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

        title: Text(
          isEditMode ? "Edit Product" : "Add Product",
          style: AppTextStyles.title,
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Product Name",
              style: AppTextStyles.title.copyWith(fontSize: 16),
            ),

            SizedBox(height: 8),

            CustomTextField(
              controller: productNameController,
              hintText: "Enter product name",
              prefixIcon: Icons.shopping_bag_outlined,
            ),

            SizedBox(height: 20),

            Text("Price", style: AppTextStyles.title.copyWith(fontSize: 16)),

            SizedBox(height: 8),

            CustomTextField(
              controller: priceController,
              hintText: "Enter price",
              prefixIcon: Icons.currency_exchange,
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 20),

            Text(
              "Product Image URL",
              style: AppTextStyles.title.copyWith(fontSize: 16),
            ),

            SizedBox(height: 8),

            CustomTextField(
              controller: imageUrlController,
              hintText: "Paste image URL",
              prefixIcon: Icons.image_outlined,
              keyboardType: TextInputType.url,
            ),

            SizedBox(height: 8),

            Text(
              "Paste a direct image URL from Google or another image hosting website.",
              style: AppTextStyles.body,
            ),

            SizedBox(height: 20),

            Text(
              "Description",
              style: AppTextStyles.title.copyWith(fontSize: 16),
            ),

            SizedBox(height: 8),

            CustomTextField(
              controller: descriptionController,
              hintText: "Enter product description",
              prefixIcon: Icons.description_outlined,
              maxLines: 4,
            ),

            SizedBox(height: 25),

            Text("Category", style: AppTextStyles.title.copyWith(fontSize: 16)),

            SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,

              children: categories.map((category) {
                bool isSelected = selectedCategory == category;

                return CustomContainer(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },

                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: 25,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.lightGrey,
                  ),
                  child: Text(
                    category,
                    style: AppTextStyles.body.copyWith(
                      color: isSelected ? Colors.white : AppColors.black,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 25),

            Text(
              "Show Product In",
              style: AppTextStyles.title.copyWith(fontSize: 16),
            ),

            SizedBox(height: 12),

            Wrap(
              spacing: 10,
              runSpacing: 10,

              children: collections.map((collection) {
                bool isSelected = selectedCollection == collection;

                return CustomContainer(
                  onTap: () {
                    setState(() {
                      selectedCollection = collection;
                    });
                  },

                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: 25,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.lightGrey,
                  ),
                  child: Text(
                    collection,
                    style: AppTextStyles.body.copyWith(
                      color: isSelected ? Colors.white : AppColors.black,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 35),

            Text(
              "Order Available",
              style: AppTextStyles.title.copyWith(fontSize: 16),
            ),

            SizedBox(height: 12),

            CustomContainer(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              color: AppColors.white,
              borderRadius: 12,
              child: CustomListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  setState(() {
                    orderAvailable = !orderAvailable;
                  });
                },
                title: Text(
                  orderAvailable
                      ? "Orders are available"
                      : "Orders are unavailable",
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  orderAvailable
                      ? "Customers can order this product"
                      : "Customers cannot order this product",
                  style: AppTextStyles.body,
                ),
                trailing: Switch(
                  value: orderAvailable,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      orderAvailable = value;
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 25),

            CustomButton(
              text: isEditMode ? "Update Product" : "Add Product",
              onTap: saveProduct,
              loading: isSaving,
              height: 55,
              borderRadius: 12,
              textColor: Colors.white,
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
