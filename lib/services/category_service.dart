import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryService {
  final FirebaseFirestore? _firestoreInstance;
  FirebaseFirestore get _firestore =>
      _firestoreInstance ?? FirebaseFirestore.instance;

  CategoryService({FirebaseFirestore? firestore})
      : _firestoreInstance = firestore;

  static const List<String> categories = [
    "Women",
    "Men",
    "Accessories",
    "Beauty",
  ];

  static const List<String> categoriesWithAll = [
    "All",
    "Women",
    "Men",
    "Accessories",
    "Beauty",
  ];

  static const List<String> collections = [
    "Featured",
    "Recommended",
    "Top Collection",
  ];

  static const List<IconData> defaultCategoryIcons = [
    Icons.apps,
    Icons.woman,
    Icons.man,
    Icons.watch_outlined,
    Icons.face_retouching_natural,
  ];

  static final Map<String, IconData> categoryIconMap = {
    "All": Icons.apps,
    "Women": Icons.woman,
    "Men": Icons.man,
    "Accessories": Icons.watch_outlined,
    "Beauty": Icons.face_retouching_natural,
  };

  List<String> getCategories({bool includeAll = false}) {
    return includeAll ? categoriesWithAll : categories;
  }

  List<String> getCollections() {
    return collections;
  }

  IconData getIconForCategory(String category) {
    return categoryIconMap[category] ?? Icons.category_outlined;
  }

  Stream<List<String>> watchCategories({bool includeAll = false}) {
    return _firestore.collection("categories").snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return getCategories(includeAll: includeAll);
      }
      final firestoreCategories = snapshot.docs
          .map((doc) => (doc.data()["name"] ?? doc.id).toString())
          .toList();
      if (includeAll && !firestoreCategories.contains("All")) {
        return ["All", ...firestoreCategories];
      }
      return firestoreCategories;
    }).handleError((_) => getCategories(includeAll: includeAll));
  }

  Future<List<String>> fetchCategories({bool includeAll = false}) async {
    try {
      final snapshot = await _firestore.collection("categories").get();
      if (snapshot.docs.isEmpty) {
        return getCategories(includeAll: includeAll);
      }
      final firestoreCategories = snapshot.docs
          .map((doc) => (doc.data()["name"] ?? doc.id).toString())
          .toList();
      if (includeAll && !firestoreCategories.contains("All")) {
        return ["All", ...firestoreCategories];
      }
      return firestoreCategories;
    } catch (_) {
      return getCategories(includeAll: includeAll);
    }
  }

  List<Map<String, dynamic>> filterByCategory(
    List<Map<String, dynamic>> products,
    String category,
  ) {
    if (category.trim().isEmpty || category == "All") {
      return products;
    }
    return products
        .where((product) => product["category"] == category)
        .toList();
  }

  List<Map<String, dynamic>> filterByCollection(
    List<Map<String, dynamic>> products,
    String collection,
  ) {
    if (collection.trim().isEmpty || collection == "All") {
      return products;
    }
    return products
        .where((product) => product["collection"] == collection)
        .toList();
  }
}
