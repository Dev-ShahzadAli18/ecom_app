import 'package:ecom_app/services/category_service.dart';
import 'package:ecom_app/services/product_service.dart';
import 'package:ecom_app/theme/app_textstyle.dart';
import 'package:ecom_app/widgets/custom_buttton.dart';
import 'package:ecom_app/widgets/custom_container.dart';
import 'package:ecom_app/widgets/custom_textfield.dart';
import 'package:ecom_app/widgets/listtile.dart';
import 'package:flutter/material.dart';

import 'package:ecom_app/theme/app_colors.dart';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;
  AddProductPage({super.key, this.product});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final ProductService _productService = ProductService();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool orderAvailable = true;
  String selectedCategory = "Women";
  String selectedCollection = "Featured";
  bool isSaving = false;
  final List<String> categories = CategoryService.categories;
  final List<String> collections = CategoryService.collections;
  bool get isEditMode {
    return widget.product != null;
  }

  @override
  void initState() {
    super.initState();
    final data = _productService.extractFormData(widget.product);
    productNameController.text = data.name;
    priceController.text = data.price;
    imageUrlController.text = data.imageUrl;
    descriptionController.text = data.description;
    selectedCategory = data.category;
    selectedCollection = data.collection;
    orderAvailable = data.orderAvailable;
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
              loading: isSaving,
              height: 55,
              borderRadius: 12,
              textColor: Colors.white,
              onTap: isSaving
                  ? null
                  : () async {
                      setState(() => isSaving = true);
                      try {
                        final wasUpdated = await _productService.saveProduct(
                          isEdit: isEditMode,
                          productId: widget.product?["id"]?.toString(),
                          name: productNameController.text,
                          price: priceController.text,
                          imageUrl: imageUrlController.text,
                          description: descriptionController.text,
                          category: selectedCategory,
                          collection: selectedCollection,
                          orderAvailable: orderAvailable,
                        );

                        if (!context.mounted) return;

                        if (wasUpdated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Product updated successfully"),
                            ),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Product added successfully"),
                            ),
                          );
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
                      } on ProductServiceException catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message)),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Something went wrong: $e")),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => isSaving = false);
                      }
                    },
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
