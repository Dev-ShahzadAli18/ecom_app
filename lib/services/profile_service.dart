import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileServiceException implements Exception {
  final String message;

  const ProfileServiceException(this.message);

  @override
  String toString() => message;
}

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection("users");

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final trimmedId = userId.trim();
    if (trimmedId.isEmpty) {
      return {};
    }

    try {
      final snapshot = await _usersRef.doc(trimmedId).get();
      return snapshot.data() ?? {};
    } on FirebaseException catch (e) {
      throw ProfileServiceException(
        e.message ?? "Failed to fetch user profile",
      );
    } catch (e) {
      throw ProfileServiceException("Failed to fetch user profile: $e");
    }
  }

  Future<Map<String, dynamic>> getCustomerProfile(String userId) {
    if (userId.trim().isEmpty) {
      return Future.value(<String, dynamic>{});
    }
    return getUserProfile(userId);
  }

  String resolveOrderProfileValue(dynamic orderValue, dynamic profileValue) {
    final orderText = orderValue?.toString().trim() ?? "";
    if (orderText.isNotEmpty) {
      return orderText;
    }

    final profileText = profileValue?.toString().trim() ?? "";
    return profileText.isEmpty ? "Not provided" : profileText;
  }

  Future<Map<String, dynamic>> getAuthenticatedProfile(User user) async {
    try {
      final data = await getUserProfile(user.uid);
      if (data.isNotEmpty) {
        return {
          "name": data["name"] ?? user.displayName ?? "User",
          "email": data["email"] ?? user.email ?? "",
          "role": _authService.resolveRole(data),
        };
      }
    } catch (error) {
      debugPrint("Error fetching user data in AuthGate: $error");
    }

    return {
      "name": user.displayName ?? "User",
      "email": user.email ?? "",
      "role": "user",
    };
  }

  Future<Map<String, dynamic>> prepareUserSession(User user) async {
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    return getAuthenticatedProfile(user);
  }

  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw const ProfileServiceException("User is not logged in");
    }
    return getUserProfile(user.uid);
  }

  Stream<Map<String, dynamic>?> watchUserProfile(String userId) {
    final trimmedId = userId.trim();
    if (trimmedId.isEmpty) {
      return Stream.value(null);
    }
    return _usersRef
        .doc(trimmedId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  Stream<Map<String, dynamic>?> watchCurrentUserProfile() {
    final user = _authService.currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    return watchUserProfile(user.uid);
  }

  Future<void> updateProfileValue({
    required String label,
    required String value,
  }) async {
    final user = _authService.currentUser;
    if (user == null) {
      throw const ProfileServiceException("User not logged in");
    }

    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      throw const ProfileServiceException("Value cannot be empty");
    }

    final field = switch (label.trim().toLowerCase()) {
      "email" => "email",
      "phone" => "Phone Number",
      "gender" => "gender",
      _ => "name",
    };

    try {
      await _usersRef.doc(user.uid).set({
        field: trimmedValue,
      }, SetOptions(merge: true));

      if (field == "name") {
        await user.updateDisplayName(trimmedValue);
      }
    } on FirebaseException catch (e) {
      throw ProfileServiceException(e.message ?? "Failed to update profile");
    } catch (e) {
      throw ProfileServiceException("Failed to update profile: $e");
    }
  }

  Future<void> updateProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    final trimmedId = userId.trim();
    if (trimmedId.isEmpty) {
      throw const ProfileServiceException("User ID is required");
    }

    try {
      await _usersRef.doc(trimmedId).set(data, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw ProfileServiceException(e.message ?? "Failed to update profile");
    } catch (e) {
      throw ProfileServiceException("Failed to update profile: $e");
    }
  }
}
