class StorageServiceException implements Exception {
  final String message;

  const StorageServiceException(this.message);

  @override
  String toString() => message;
}

class StorageService {
  static const String fallbackProductImage =
      "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop&q=60";

  static const String fallbackAvatarImage =
      "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=60";

  bool isValidImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(url.trim());
    if (uri == null) {
      return false;
    }
    return uri.hasScheme && (uri.scheme == "http" || uri.scheme == "https");
  }

  String resolveImageUrl(String? url, {String? fallback}) {
    if (isValidImageUrl(url)) {
      return url!.trim();
    }
    return fallback ?? fallbackProductImage;
  }

  String get defaultProductImage => fallbackProductImage;

  String get defaultAvatarImage => fallbackAvatarImage;
}
