import 'package:ecom_app/services/auth_service.dart';
import 'package:ecom_app/services/cart_service.dart';
import 'package:ecom_app/services/category_service.dart';
import 'package:ecom_app/services/order_service.dart';
import 'package:ecom_app/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryService Tests', () {
    final categoryService = CategoryService();

    test('getCategories returns correct default list', () {
      final categories = categoryService.getCategories(includeAll: false);
      expect(categories, contains('Women'));
      expect(categories, contains('Men'));
      expect(categories, isNot(contains('All')));

      final allCategories = categoryService.getCategories(includeAll: true);
      expect(allCategories.first, 'All');
    });

    test('filterByCategory filters products accurately', () {
      final products = [
        {'id': '1', 'name': 'Dress', 'category': 'Women'},
        {'id': '2', 'name': 'Shirt', 'category': 'Men'},
      ];

      final women = categoryService.filterByCategory(products, 'Women');
      expect(women.length, 1);
      expect(women.first['name'], 'Dress');

      final all = categoryService.filterByCategory(products, 'All');
      expect(all.length, 2);
    });

    test('filterByCollection filters products accurately', () {
      final products = [
        {'id': '1', 'name': 'Watch', 'collection': 'Featured'},
        {'id': '2', 'name': 'Ring', 'collection': 'Recommended'},
      ];

      final featured =
          categoryService.filterByCollection(products, 'Featured');
      expect(featured.length, 1);
      expect(featured.first['name'], 'Watch');
    });
  });

  group('StorageService Tests', () {
    final storageService = StorageService();

    test('validates image URLs correctly', () {
      expect(storageService.isValidImageUrl('https://example.com/img.jpg'), isTrue);
      expect(storageService.isValidImageUrl('http://example.com/img.png'), isTrue);
      expect(storageService.isValidImageUrl('invalid-url'), isFalse);
      expect(storageService.isValidImageUrl(''), isFalse);
      expect(storageService.isValidImageUrl(null), isFalse);
    });

    test('resolves fallback image URL when URL is empty or invalid', () {
      expect(
        storageService.resolveImageUrl(''),
        storageService.defaultProductImage,
      );
      expect(
        storageService.resolveImageUrl('https://example.com/item.png'),
        'https://example.com/item.png',
      );
    });
  });

  group('CartService Calculations Tests', () {
    final cartService = CartService();

    test('calculates total cart price properly', () {
      final items = [
        {'price': 100, 'quantity': 2},
        {'price': 50.5, 'quantity': 1},
      ];

      expect(cartService.calculateTotal(items), 250.5);
    });
  });

  group('OrderService Calculations and Formatting Tests', () {
    final orderService = OrderService();

    test('calculates product totals correctly', () {
      final product = {'price': 250};
      expect(orderService.getProductTotal(product, 3), 750);
    });

    test('formatDate handles null and DateTime values gracefully', () {
      expect(orderService.formatDate(null), 'Date not available');
      final date = DateTime(2026, 10, 13, 15, 30);
      expect(orderService.formatDate(date), '13/10/2026 15:30');
    });
  });

  group('AuthService Role Resolution Tests', () {
    final authService = AuthService();

    test('resolveRole parses admin and user roles', () {
      expect(authService.resolveRole({'role': 'admin'}), 'admin');
      expect(authService.resolveRole({'role': 'ADMIN'}), 'admin');
      expect(authService.resolveRole({'role': 'user'}), 'user');
      expect(authService.resolveRole(null), 'user');
    });
  });
}
