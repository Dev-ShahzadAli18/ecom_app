import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/services/auth_service.dart';

enum AddToCartResult { added, requiresLogin, invalidProduct }

class CartServiceException implements Exception {
  final String message;

  const CartServiceException(this.message);

  @override
  String toString() => message;
}

class CartService {
  final FirebaseFirestore? _firestoreInstance;
  final AuthService _authService;

  FirebaseFirestore get _firestore =>
      _firestoreInstance ?? FirebaseFirestore.instance;

  CartService({
    FirebaseFirestore? firestore,
    AuthService? authService,
  })  : _firestoreInstance = firestore,
        _authService = authService ?? AuthService();

  double getItemPrice(Map<String, dynamic> item) {
    return item["price"] is num ? (item["price"] as num).toDouble() : 0;
  }

  int getItemQuantity(Map<String, dynamic> item) {
    return item["quantity"] is num ? (item["quantity"] as num).toInt() : 1;
  }

  double calculateTotal(List<Map<String, dynamic>> items) {
    return items.fold(
      0.0,
      (total, item) => total + getItemPrice(item) * getItemQuantity(item),
    );
  }

  CollectionReference<Map<String, dynamic>> _cart(String userId) {
    return _firestore.collection("users").doc(userId).collection("cart");
  }

  Stream<List<Map<String, dynamic>>> watchCart(String? userId) {
    if (userId == null || userId.isEmpty) {
      return Stream<List<Map<String, dynamic>>>.value([]);
    }

    return _cart(userId).snapshots().map(
      (snapshot) => snapshot.docs
          .map((document) => {...document.data(), "documentId": document.id})
          .toList(),
    );
  }

  Future<List<Map<String, dynamic>>> fetchCart(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return [];
    }

    try {
      final snapshot = await _cart(userId).get();
      return snapshot.docs
          .map((document) => {...document.data(), "documentId": document.id})
          .toList();
    } on FirebaseException catch (e) {
      throw CartServiceException(e.message ?? "Failed to fetch cart");
    } catch (e) {
      throw CartServiceException("Failed to fetch cart: $e");
    }
  }

  Future<void> incrementQuantity({
    required String? userId,
    required String productId,
    required int quantity,
  }) async {
    if (userId == null || userId.isEmpty || productId.isEmpty) {
      return;
    }

    try {
      await _cart(userId).doc(productId).update({"quantity": quantity + 1});
    } on FirebaseException catch (e) {
      throw CartServiceException(e.message ?? "Failed to increment quantity");
    } catch (e) {
      throw CartServiceException("Failed to increment quantity: $e");
    }
  }

  Future<void> decrementQuantity({
    required String? userId,
    required String productId,
    required int quantity,
  }) async {
    if (userId == null || userId.isEmpty || productId.isEmpty) {
      return;
    }

    if (quantity <= 1) {
      await removeItem(userId: userId, productId: productId);
      return;
    }

    try {
      await _cart(userId).doc(productId).update({"quantity": quantity - 1});
    } on FirebaseException catch (e) {
      throw CartServiceException(e.message ?? "Failed to decrement quantity");
    } catch (e) {
      throw CartServiceException("Failed to decrement quantity: $e");
    }
  }

  Future<void> removeItem({
    required String? userId,
    required String productId,
  }) async {
    if (userId == null || userId.isEmpty || productId.isEmpty) {
      return;
    }

    try {
      await _cart(userId).doc(productId).delete();
    } on FirebaseException catch (e) {
      throw CartServiceException(e.message ?? "Failed to remove item");
    } catch (e) {
      throw CartServiceException("Failed to remove item: $e");
    }
  }

  Future<void> clearCart(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      final snapshot = await _cart(userId).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } on FirebaseException catch (e) {
      throw CartServiceException(e.message ?? "Failed to clear cart");
    } catch (e) {
      throw CartServiceException("Failed to clear cart: $e");
    }
  }

  Future<AddToCartResult> addProduct({
    required Map<String, dynamic> product,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      return AddToCartResult.requiresLogin;
    }

    final productId = (product["id"] ?? "").toString();
    if (productId.isEmpty) {
      return AddToCartResult.invalidProduct;
    }

    try {
      final cartItem = _cart(user.uid).doc(productId);
      final snapshot = await cartItem.get();
      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        final quantity = data["quantity"] is num
            ? (data["quantity"] as num).toInt()
            : 1;
        await cartItem.update({"quantity": quantity + 1});
        return AddToCartResult.added;
      }

      await cartItem.set({
        "productId": productId,
        "name": product["name"] ?? "",
        "price": product["price"] ?? 0,
        "imageUrl": product["imageUrl"] ?? "",
        "quantity": 1,
        "addedAt": FieldValue.serverTimestamp(),
      });
      return AddToCartResult.added;
    } on FirebaseException catch (e) {
      throw CartServiceException(e.message ?? "Failed to add product to cart");
    } catch (e) {
      throw CartServiceException("Failed to add product to cart: $e");
    }
  }
}
