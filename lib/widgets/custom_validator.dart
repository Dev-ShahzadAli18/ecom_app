class Validators {
  static String? required(String? value, {String fieldName = "This field"}) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }

    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }

    if (value.trim().length < 2) {
      return "Name must be at least 2 characters";
    }

    if (value.trim().length > 50) {
      return "Name is too long";
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }

    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter a valid email address";
    }

    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < minLength) {
      return "Password must be at least $minLength characters";
    }

    return null;
  }

  static String? number(String? value, {int minLength = 11}) {
    if (value == null || value.isEmpty) {
      return "number is required";
    }

    if (value.length < minLength) {
      return "Number must be at least $minLength characters";
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }

    if (value != password) {
      return "Passwords do not match";
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }

    final phoneRegex = RegExp(r'^[0-9]{10,15}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return "Enter a valid phone number";
    }

    return null;
  }

  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Address is required";
    }

    if (value.trim().length < 10) {
      return "Please enter a complete address";
    }

    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return "OTP is required";
    }

    if (value.length != 6) {
      return "Enter a valid 6-digit OTP";
    }

    return null;
  }
}
