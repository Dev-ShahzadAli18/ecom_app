import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

export 'package:firebase_auth/firebase_auth.dart' show User, FirebaseAuthException;

class AuthServiceException implements Exception {
  final String message;

  const AuthServiceException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth? _authInstance;
  final FirebaseFirestore? _firestoreInstance;

  FirebaseAuth get _auth => _authInstance ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _firestoreInstance ?? FirebaseFirestore.instance;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _authInstance = auth,
        _firestoreInstance = firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  String _mapAuthException(FirebaseAuthException error, String fallback) {
    return switch (error.code) {
      "user-not-found" => "No account found with this email.",
      "wrong-password" => "Incorrect password. Please try again.",
      "invalid-credential" => "Invalid email or password.",
      "email-already-in-use" => "An account already exists with this email.",
      "invalid-email" => "Please enter a valid email address.",
      "weak-password" => "Password should be at least 6 characters.",
      "user-disabled" => "This account has been disabled.",
      "too-many-requests" => "Too many attempts. Please try again later.",
      "network-request-failed" =>
        "Network connection failed. Please check your internet.",
      _ => error.message ?? fallback,
    };
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw const AuthServiceException("Email and password cannot be empty");
    }

    final UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_mapAuthException(error, "Login failed"));
    } catch (e) {
      throw AuthServiceException("Login failed: $e");
    }

    final userId = credential.user?.uid;
    if (userId == null) {
      throw const AuthServiceException("Firebase user is unavailable");
    }

    try {
      final userDoc = await _firestore.collection("users").doc(userId).get();
      return resolveRole(userDoc.data());
    } catch (error) {
      return "user";
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required String role,
    String? gender,
    String? phoneNumber,
  }) async {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();

    if (trimmedName.isEmpty) {
      throw const AuthServiceException("Name cannot be empty");
    }
    if (trimmedEmail.isEmpty) {
      throw const AuthServiceException("Email cannot be empty");
    }
    if (password.isEmpty) {
      throw const AuthServiceException("Password cannot be empty");
    }
    if (password != confirmPassword) {
      throw const AuthServiceException("Passwords do not match");
    }
    if (password.length < 6) {
      throw const AuthServiceException(
        "Password must be at least 6 characters",
      );
    }

    final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(_mapAuthException(error, "Sign up failed"));
    } catch (e) {
      throw AuthServiceException("Sign up failed: $e");
    }

    final user = credential.user;
    final userId = user?.uid;
    if (userId == null) {
      throw const AuthServiceException("Firebase user is unavailable");
    }

    try {
      await user?.updateDisplayName(trimmedName);
    } catch (_) {}

    final userData = <String, dynamic>{
      "id": userId,
      "name": trimmedName,
      "email": trimmedEmail,
      "role": role.trim().toLowerCase() == "admin" ? "admin" : "user",
      "gender": gender,
      "Phone Number": phoneNumber?.trim(),
      "createdAt": FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection("users").doc(userId).set(userData);
    } on FirebaseException catch (error) {
      throw AuthServiceException(
        error.message ?? "Failed to save user profile data",
      );
    } catch (e) {
      throw AuthServiceException("Failed to save user profile data: $e");
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      throw const AuthServiceException("Please enter your email address");
    }

    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
    } on FirebaseAuthException catch (error) {
      throw AuthServiceException(
        _mapAuthException(error, "Failed to send password reset email"),
      );
    } catch (e) {
      throw AuthServiceException("Failed to send password reset email: $e");
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) {
      return null;
    }

    final doc = await _firestore.collection("users").doc(user.uid).get();
    return doc.data();
  }

  Future<String> getCurrentUserRole() async {
    final profile = await getCurrentUserProfile();
    return resolveRole(profile);
  }

  String resolveRole(Map<String, dynamic>? userData) {
    final role = (userData?["role"] ?? "user").toString().trim().toLowerCase();
    return role == "admin" ? "admin" : "user";
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthServiceException("Failed to log out: $e");
    }
  }
}
