import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteServiceException implements Exception {
  final String message;

  const FavoriteServiceException(this.message);

  @override
  String toString() => message;
}

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _favorites(String userId) {
    return _firestore.collection("users").doc(userId).collection("favorites");
  }

  Stream<Set<String>> watchFavoriteIds(String? userId) {
    if (userId == null || userId.isEmpty) {
      return Stream<Set<String>>.value({});
    }

    return _favorites(userId).snapshots().map(
      (snapshot) => snapshot.docs.map((document) => document.id).toSet(),
    );
  }

  Stream<List<Map<String, dynamic>>> watchFavoriteProducts(String? userId) {
    if (userId == null || userId.isEmpty) {
      return Stream<List<Map<String, dynamic>>>.value([]);
    }

    return _favorites(userId).snapshots().map(
      (snapshot) => snapshot.docs
          .map((document) => {...document.data(), "id": document.id})
          .toList(),
    );
  }

  Future<List<Map<String, dynamic>>> fetchFavoriteProducts(String? userId) async {
    if (userId == null || userId.isEmpty) {
      return [];
    }

    try {
      final snapshot = await _favorites(userId).get();
      return snapshot.docs
          .map((document) => {...document.data(), "id": document.id})
          .toList();
    } on FirebaseException catch (e) {
      throw FavoriteServiceException(e.message ?? "Failed to fetch favorites");
    } catch (e) {
      throw FavoriteServiceException("Failed to fetch favorites: $e");
    }
  }

  Future<bool> isFavorite({
    required String? userId,
    required String productId,
  }) async {
    if (userId == null || userId.isEmpty || productId.isEmpty) {
      return false;
    }

    try {
      final doc = await _favorites(userId).doc(productId).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleFavorite({
    required String? userId,
    required Map<String, dynamic> product,
  }) async {
    if (userId == null || userId.isEmpty) {
      return;
    }

    final productId = (product["id"] ?? "").toString();
    if (productId.isEmpty) {
      return;
    }

    try {
      final favorite = _favorites(userId).doc(productId);
      if ((await favorite.get()).exists) {
        await favorite.delete();
      } else {
        await favorite.set({
          ...product,
          "addedAt": FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (e) {
      throw FavoriteServiceException(e.message ?? "Failed to toggle favorite");
    } catch (e) {
      throw FavoriteServiceException("Failed to toggle favorite: $e");
    }
  }

  Future<void> removeFavorite({
    required String? userId,
    required String productId,
  }) async {
    if (userId == null || userId.isEmpty || productId.isEmpty) {
      return;
    }

    try {
      await _favorites(userId).doc(productId).delete();
    } on FirebaseException catch (e) {
      throw FavoriteServiceException(e.message ?? "Failed to remove favorite");
    } catch (e) {
      throw FavoriteServiceException("Failed to remove favorite: $e");
    }
  }
}
