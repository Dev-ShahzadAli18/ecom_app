import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductServiceException implements Exception {
  final String message;

  const ProductServiceException(this.message);

  @override
  String toString() => message;
}

class ProductService {
  final FirebaseFirestore? _firestoreInstance;
  final FirebaseAuth? _authInstance;

  FirebaseFirestore get _firestore =>
      _firestoreInstance ?? FirebaseFirestore.instance;
  FirebaseAuth get _auth => _authInstance ?? FirebaseAuth.instance;

  ProductService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestoreInstance = firestore,
        _authInstance = auth;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection("products");

  Stream<List<Map<String, dynamic>>> watchProducts() {
    return _productsRef
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((document) => {...document.data(), "id": document.id})
              .toList(),
        );
  }

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    try {
      final snapshot =
          await _productsRef.orderBy("createdAt", descending: true).get();
      return snapshot.docs
          .map((document) => {...document.data(), "id": document.id})
          .toList();
    } on FirebaseException catch (e) {
      throw ProductServiceException(e.message ?? "Failed to fetch products");
    } catch (e) {
      throw ProductServiceException("Failed to fetch products: $e");
    }
  }

  Future<Map<String, dynamic>?> getProductById(String productId) async {
    if (productId.trim().isEmpty) {
      return null;
    }
    try {
      final doc = await _productsRef.doc(productId.trim()).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return {...doc.data()!, "id": doc.id};
    } on FirebaseException catch (e) {
      throw ProductServiceException(e.message ?? "Failed to fetch product");
    } catch (e) {
      throw ProductServiceException("Failed to fetch product: $e");
    }
  }

  Stream<Map<String, dynamic>?> watchProductById(String productId) {
    if (productId.trim().isEmpty) {
      return Stream.value(null);
    }
    return _productsRef
        .doc(productId.trim())
        .snapshots()
        .map((doc) => doc.exists && doc.data() != null
            ? {...doc.data()!, "id": doc.id}
            : null);
  }

  List<Map<String, dynamic>> filterProducts(
    List<Map<String, dynamic>> products, {
    String? collectionName,
    String? category,
  }) {
    return products.where((product) {
      final matchesCollection =
          collectionName == null ||
          collectionName == "All" ||
          product["collection"] == collectionName;
      final matchesCategory =
          category == null ||
          category == "All" ||
          product["category"] == category;
      return matchesCollection && matchesCategory;
    }).toList();
  }

  List<Map<String, dynamic>> searchProducts(
    List<Map<String, dynamic>> products,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return products;
    }

    return products.where((product) {
      final searchableText = [
        product["name"],
        product["description"],
        product["category"],
        product["collection"],
      ].whereType<String>().join(" ").toLowerCase();
      return searchableText.contains(normalizedQuery);
    }).toList();
  }

  Future<void> addProduct({
    String? name,
    String? price,
    String? image,
    String? imageUrl,
    String? category,
    String? description,
    String collection = "Featured",
    bool orderAvailable = true,
    String? userId,
    Map<String, dynamic>? product,
  }) async {
    // If called with a prebuilt product map (legacy usage)
    if (product != null) {
      final effectiveUserId = userId ?? _auth.currentUser?.uid;
      if (effectiveUserId == null) {
        throw const ProductServiceException("Please login first");
      }
      try {
        await _productsRef.add({
          ...product,
          "userId": effectiveUserId,
          "createdAt": FieldValue.serverTimestamp(),
        });
        return;
      } on FirebaseException catch (e) {
        throw ProductServiceException(e.message ?? "Failed to add product");
      } catch (e) {
        throw ProductServiceException("Failed to add product: $e");
      }
    }

    // Called with individual named parameters (e.g. from UI)
    final resolvedImage = (image ?? imageUrl ?? "").trim();
    await saveProduct(
      isEdit: false,
      productId: null,
      name: name ?? "",
      price: price ?? "",
      imageUrl: resolvedImage,
      description: description ?? "",
      category: category ?? "Women",
      collection: collection,
      orderAvailable: orderAvailable,
    );
  }

  Future<bool> saveProduct({
    required bool isEdit,
    required String? productId,
    required String name,
    required String price,
    required String imageUrl,
    required String description,
    required String category,
    required String collection,
    required bool orderAvailable,
  }) async {
    final normalizedName = name.trim();
    final normalizedPrice = price.trim();
    final normalizedImageUrl = imageUrl.trim();
    final normalizedDescription = description.trim();

    if (normalizedName.isEmpty ||
        normalizedPrice.isEmpty ||
        normalizedImageUrl.isEmpty ||
        normalizedDescription.isEmpty) {
      throw const ProductServiceException("Please fill all fields");
    }

    final parsedPrice = double.tryParse(normalizedPrice);
    if (parsedPrice == null || parsedPrice < 0) {
      throw const ProductServiceException("Please enter a valid price");
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw const ProductServiceException("Please login first");
    }

    final productData = <String, dynamic>{
      "name": normalizedName,
      "price": parsedPrice,
      "imageUrl": normalizedImageUrl,
      "description": normalizedDescription,
      "category": category,
      "collection": collection,
      "orderAvailable": orderAvailable,
      "updatedAt": FieldValue.serverTimestamp(),
    };

    try {
      if (isEdit) {
        if (productId == null || productId.trim().isEmpty) {
          throw const ProductServiceException(
            "Product ID is required for editing",
          );
        }
        await updateProduct(productId: productId.trim(), product: productData);
        return true;
      }

      await _productsRef.add({
        ...productData,
        "userId": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
      });
      return false;
    } on FirebaseException catch (e) {
      throw ProductServiceException(e.message ?? "Failed to save product");
    } catch (e) {
      if (e is ProductServiceException) rethrow;
      throw ProductServiceException("Failed to save product: $e");
    }
  }

  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> product,
  }) async {
    final id = productId.trim();
    if (id.isEmpty) {
      throw const ProductServiceException("Invalid product ID");
    }
    try {
      await _productsRef.doc(id).update({
        ...product,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ProductServiceException(e.message ?? "Failed to update product");
    } catch (e) {
      throw ProductServiceException("Failed to update product: $e");
    }
  }

  Future<bool> deleteProduct(String? productId) async {
    if (productId == null || productId.trim().isEmpty) {
      return false;
    }

    try {
      await _productsRef.doc(productId.trim()).delete();
      return true;
    } on FirebaseException catch (e) {
      throw ProductServiceException(e.message ?? "Failed to delete product");
    } catch (e) {
      throw ProductServiceException("Failed to delete product: $e");
    }
  }

  ({
    String name,
    String price,
    String imageUrl,
    String description,
    String category,
    String collection,
    bool orderAvailable,
  }) extractFormData(Map<String, dynamic>? product) {
    if (product == null) {
      return (
        name: "",
        price: "",
        imageUrl: "",
        description: "",
        category: "Women",
        collection: "Featured",
        orderAvailable: true,
      );
    }

    return (
      name: (product["name"] ?? "").toString(),
      price: product["price"]?.toString() ?? "",
      imageUrl: (product["imageUrl"] ?? "").toString(),
      description: (product["description"] ?? "").toString(),
      category: (product["category"] ?? "Women").toString(),
      collection: (product["collection"] ?? "Featured").toString(),
      orderAvailable: product["orderAvailable"] ?? true,
    );
  }
}
