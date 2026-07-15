import 'package:flutter_test/flutter_test.dart';
import 'package:mart/features/auth/domain/entities/user.dart';
import 'package:mart/features/products/domain/entities/product.dart';

void main() {
  group('Gmart Partner Model Serialization Tests', () {
    test('User.fromJson should correctly parse a vendor profile', () {
      final json = {
        'shop_name': 'Gundawadi Market Veggies',
        'owner_name': 'Ramesh Bhai',
        'mobile': '9876543210',
        'address': 'Gundawadi Market, Shop 4',
        'opening_time': '06:00 AM',
        'closing_time': '08:00 PM',
        'shop_photo': 'https://example.com/photo.jpg',
        'is_closed': true,
      };

      final user = User.fromJson(json);

      expect(user.shopName, 'Gundawadi Market Veggies');
      expect(user.ownerName, 'Ramesh Bhai');
      expect(user.mobile, '9876543210');
      expect(user.address, 'Gundawadi Market, Shop 4');
      expect(user.openingTime, '06:00 AM');
      expect(user.closingTime, '08:00 PM');
      expect(user.shopPhoto, 'https://example.com/photo.jpg');
      expect(user.isClosed, true);
    });

    test('Product.fromJson and copyWith should function correctly', () {
      final json = {
        'id': 101,
        'name': 'Fresh Tomato (टमाटर)',
        'price': 40.0,
        'unit': 'kg',
        'is_enabled': true,
        'image_url': 'https://example.com/tomato.jpg',
      };

      final product = Product.fromJson(json);

      expect(product.id, 101);
      expect(product.name, 'Fresh Tomato (टमाटर)');
      expect(product.price, 40.0);
      expect(product.unit, 'kg');
      expect(product.isEnabled, true);
      expect(product.imageUrl, 'https://example.com/tomato.jpg');

      final updatedProduct = product.copyWith(price: 45.0, isEnabled: false);
      expect(updatedProduct.price, 45.0);
      expect(updatedProduct.isEnabled, false);
      expect(updatedProduct.name, 'Fresh Tomato (टमाटर)'); // Unchanged
    });
  });
}
