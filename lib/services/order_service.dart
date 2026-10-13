import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/services/auth_service.dart';
import 'package:flutter/material.dart';

class OrderServiceException implements Exception {
  final String message;

  const OrderServiceException(this.message);

  @override
  String toString() => message;
}

class OrderService {
  final FirebaseFirestore? _firestoreInstance;
  final AuthService _authService;

  FirebaseFirestore get _firestore =>
      _firestoreInstance ?? FirebaseFirestore.instance;

  OrderService({
    FirebaseFirestore? firestore,
    AuthService? authService,
  })  : _firestoreInstance = firestore,
        _authService = authService ?? AuthService();

  CollectionReference<Map<String, dynamic>> _orders(String userId) {
    return _firestore.collection("users").doc(userId).collection("orders");
  }

  CollectionReference<Map<String, dynamic>> _cart(String userId) {
    return _firestore.collection("users").doc(userId).collection("cart");
  }

  Stream<List<Map<String, dynamic>>> watchUserOrders(String? userId) {
    if (userId == null || userId.isEmpty) {
      return Stream.value([]);
    }

    return _orders(userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapOrder).toList());
  }

  Future<List<Map<String, dynamic>>> fetchUserOrders(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return [];
    }

    try {
      final snapshot = await _orders(userId)
          .orderBy("createdAt", descending: true)
          .get();
      return snapshot.docs.map(_mapOrder).toList();
    } on FirebaseException catch (e) {
      throw OrderServiceException(e.message ?? "Failed to fetch orders");
    } catch (e) {
      throw OrderServiceException("Failed to fetch orders: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> watchAllOrders() {
    return _firestore
        .collectionGroup("orders")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapOrder).toList());
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    try {
      final snapshot = await _firestore
          .collectionGroup("orders")
          .orderBy("createdAt", descending: true)
          .get();
      return snapshot.docs.map(_mapOrder).toList();
    } on FirebaseException catch (e) {
      throw OrderServiceException(e.message ?? "Failed to fetch all orders");
    } catch (e) {
      throw OrderServiceException("Failed to fetch all orders: $e");
    }
  }

  Future<Map<String, dynamic>?> getOrderById({
    required String userId,
    required String orderId,
  }) async {
    if (userId.isEmpty || orderId.isEmpty) {
      return null;
    }
    try {
      final doc = await _orders(userId).doc(orderId).get();
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return {...doc.data()!, "orderId": doc.id, "buyerId": userId};
    } on FirebaseException catch (e) {
      throw OrderServiceException(e.message ?? "Failed to fetch order");
    } catch (e) {
      throw OrderServiceException("Failed to fetch order: $e");
    }
  }

  Map<String, dynamic> _mapOrder(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return {
      ...document.data(),
      "orderId": document.id,
      "buyerId": document.reference.parent.parent?.id ?? "",
    };
  }

  double getPrice(Map<String, dynamic> data) {
    return data["price"] is num ? (data["price"] as num).toDouble() : 0;
  }

  int getQuantity(Map<String, dynamic> data) {
    return data["quantity"] is num ? (data["quantity"] as num).toInt() : 1;
  }

  double getTotalPrice(Map<String, dynamic> data) {
    if (data["totalPrice"] is num) {
      return (data["totalPrice"] as num).toDouble();
    }
    return getPrice(data) * getQuantity(data);
  }

  double getProductTotal(Map<String, dynamic> product, int quantity) {
    return getPrice(product) * quantity;
  }

  String formatDate(dynamic value, {String fallback = "Date not available"}) {
    if (value == null) {
      return fallback;
    }

    DateTime? date;
    if (value is Timestamp) {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value);
    }

    if (date == null) {
      return fallback;
    }

    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");

    return "$day/$month/$year $hour:$minute";
  }

  Color getStatusColor(String? status) {
    return switch (status?.trim().toLowerCase()) {
      "pending" => Colors.orange,
      "processing" || "confirmed" => Colors.blue,
      "delivered" || "completed" => Colors.green,
      "cancelled" => Colors.red,
      _ => Colors.grey,
    };
  }

  Future<bool> createOrder({
    required Map<String, dynamic> product,
    required int quantity,
    required String color,
    required String customerName,
    required String phone,
    required String address,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw const OrderServiceException("Please login first to place an order");
    }

    final price = getPrice(product);
    try {
      await _orders(user.uid).add({
        "productId": product["id"] ?? "",
        "name": product["name"] ?? "",
        "price": price,
        "imageUrl": product["imageUrl"] ?? "",
        "quantity": quantity,
        "totalPrice": getProductTotal(product, quantity),
        "color": color,
        "customerName": customerName,
        "phone": phone,
        "address": address,
        "email": user.email ?? "",
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(),
      });
      return true;
    } on FirebaseException catch (e) {
      throw OrderServiceException(e.message ?? "Failed to place order");
    } catch (e) {
      throw OrderServiceException("Failed to place order: $e");
    }
  }

  Future<bool> createOrdersFromCart({
    required List<Map<String, dynamic>> products,
    required Map<String, String> deliveryDetails,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw const OrderServiceException("Please login first to place orders");
    }
    if (products.isEmpty) {
      return false;
    }

    final userId = user.uid;
    final cart = _cart(userId);
    final orders = _orders(userId);

    try {
      for (final product in products) {
        final price = getPrice(product);
        final quantity = getQuantity(product);
        final productId =
            (product["productId"] ?? product["documentId"] ?? "").toString();

        await orders.add({
          "productId": productId,
          "name": product["name"] ?? "",
          "price": price,
          "imageUrl": product["imageUrl"] ?? "",
          "quantity": quantity,
          "totalPrice": getProductTotal(product, quantity),
          "customerName": deliveryDetails["customerName"] ?? "",
          "phone": deliveryDetails["phone"] ?? "",
          "address": deliveryDetails["address"] ?? "",
          "email": user.email ?? "",
          "status": "Pending",
          "createdAt": FieldValue.serverTimestamp(),
        });

        if (productId.isNotEmpty) {
          await cart.doc(productId).delete();
        }
      }
      return true;
    } on FirebaseException catch (e) {
      throw OrderServiceException(e.message ?? "Failed to process orders");
    } catch (e) {
      throw OrderServiceException("Failed to process orders: $e");
    }
  }

  Future<void> updateOrderStatus({
    required String userId,
    required String orderId,
    required String newStatus,
  }) async {
    if (userId.isEmpty || orderId.isEmpty) {
      throw const OrderServiceException("User ID and Order ID are required");
    }

    try {
      await _orders(userId).doc(orderId).update({
        "status": newStatus,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw OrderServiceException(e.message ?? "Failed to update order status");
    } catch (e) {
      throw OrderServiceException("Failed to update order status: $e");
    }
  }

  Future<void> cancelOrder({
    required String userId,
    required String orderId,
  }) async {
    await updateOrderStatus(
      userId: userId,
      orderId: orderId,
      newStatus: "Cancelled",
    );
  }

  Future<void> deleteOrder({
    required String userId,
    required String orderId,
  }) async {
    if (userId.isEmpty || orderId.isEmpty) {
      throw const OrderServiceException("User ID and Order ID are required");
    }

    try {
      await _orders(userId).doc(orderId).delete();
    } on FirebaseException catch (e) {
      throw OrderServiceException(e.message ?? "Failed to delete order");
    } catch (e) {
      throw OrderServiceException("Failed to delete order: $e");
    }
  }
}
