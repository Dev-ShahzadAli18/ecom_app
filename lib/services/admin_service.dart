import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/services/order_service.dart';
import 'package:ecom_app/services/product_service.dart';

class AdminServiceException implements Exception {
  final String message;

  const AdminServiceException(this.message);

  @override
  String toString() => message;
}

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();

  Future<bool> isCurrentUserAdmin() async {
    final role = await _authService.getCurrentUserRole();
    return role.toLowerCase() == "admin";
  }

  // Admin Orders Management
  Stream<List<Map<String, dynamic>>> watchAllOrders() {
    return _orderService.watchAllOrders();
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders() {
    return _orderService.fetchAllOrders();
  }

  Future<void> updateOrderStatus({
    required String buyerId,
    required String orderId,
    required String newStatus,
  }) {
    return _orderService.updateOrderStatus(
      userId: buyerId,
      orderId: orderId,
      newStatus: newStatus,
    );
  }

  Future<void> deleteOrder({
    required String buyerId,
    required String orderId,
  }) {
    return _orderService.deleteOrder(
      userId: buyerId,
      orderId: orderId,
    );
  }

  // Admin Products Management
  Future<void> addProduct({
    required String name,
    required String price,
    required String image,
    required String category,
    required String description,
    String collection = "Featured",
    bool orderAvailable = true,
  }) {
    return _productService.addProduct(
      name: name,
      price: price,
      image: image,
      category: category,
      description: description,
      collection: collection,
      orderAvailable: orderAvailable,
    );
  }

  Future<void> updateProduct({
    required String productId,
    required Map<String, dynamic> product,
  }) {
    return _productService.updateProduct(
      productId: productId,
      product: product,
    );
  }

  Future<bool> deleteProduct(String? productId) {
    return _productService.deleteProduct(productId);
  }

  // Admin Users Management
  Stream<List<Map<String, dynamic>>> watchAllUsers() {
    return _firestore.collection("users").snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), "id": doc.id})
              .toList(),
        );
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final snapshot = await _firestore.collection("users").get();
      return snapshot.docs
          .map((doc) => {...doc.data(), "id": doc.id})
          .toList();
    } on FirebaseException catch (e) {
      throw AdminServiceException(e.message ?? "Failed to fetch users");
    } catch (e) {
      throw AdminServiceException("Failed to fetch users: $e");
    }
  }

  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      await _firestore.collection("users").doc(userId).update({
        "role": role.trim().toLowerCase(),
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AdminServiceException(e.message ?? "Failed to update user role");
    } catch (e) {
      throw AdminServiceException("Failed to update user role: $e");
    }
  }

  // Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final ordersSnapshot = await _firestore.collectionGroup("orders").get();
      final productsSnapshot = await _firestore.collection("products").get();
      final usersSnapshot = await _firestore.collection("users").get();

      double totalRevenue = 0;
      int pendingOrders = 0;

      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();
        final status = (data["status"] ?? "").toString().toLowerCase();
        if (status == "pending") {
          pendingOrders++;
        }
        final total = _orderService.getTotalPrice(data);
        totalRevenue += total;
      }

      return {
        "totalOrders": ordersSnapshot.docs.length,
        "pendingOrders": pendingOrders,
        "totalRevenue": totalRevenue,
        "totalProducts": productsSnapshot.docs.length,
        "totalUsers": usersSnapshot.docs.length,
      };
    } catch (e) {
      return {
        "totalOrders": 0,
        "pendingOrders": 0,
        "totalRevenue": 0.0,
        "totalProducts": 0,
        "totalUsers": 0,
      };
    }
  }

  String formatDate(dynamic timestamp) {
    return _orderService.formatDate(timestamp, fallback: "Date pending");
  }
}
