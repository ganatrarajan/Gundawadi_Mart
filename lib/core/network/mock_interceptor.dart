import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

class MockInterceptor extends Interceptor {
  // In-memory mock database state
  static final Map<String, dynamic> _db = {
    'profile': {
      'shop_name': 'Fresh Green Vegetables',
      'owner_name': 'Ramesh Patel',
      'mobile': '9876543210',
      'address': 'Shop No. 12, Gundawadi Market, Rajkot',
      'opening_time': '06:00 AM',
      'closing_time': '08:00 PM',
      'shop_photo': 'https://images.unsplash.com/photo-1542838132-92c53300491e',
    },
    'products': [
      {
        'id': 1,
        'name': 'Tomato (टमाटर)',
        'price': 40.0,
        'unit': 'kg',
        'is_enabled': true,
        'image_url': 'https://images.unsplash.com/photo-1595855759920-86582396756a',
      },
      {
        'id': 2,
        'name': 'Potato (आलू)',
        'price': 25.0,
        'unit': 'kg',
        'is_enabled': true,
        'image_url': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655',
      },
      {
        'id': 3,
        'name': 'Onion (प्याज़)',
        'price': 35.0,
        'unit': 'kg',
        'is_enabled': false,
        'image_url': 'https://images.unsplash.com/photo-1508747702725-c19959ff9790',
      },
      {
        'id': 4,
        'name': 'Coriander (धनिया)',
        'price': 10.0,
        'unit': 'bunch',
        'is_enabled': true,
        'image_url': 'https://images.unsplash.com/photo-1614088924043-433cfdf92b02',
      },
    ],
    'orders': [
      {
        'id': 'ORD-5015',
        'customer_name': 'Anita Sharma',
        'mobile': '9898767654',
        'address': 'A-404, Shanti Nagar, Rajkot',
        'special_note': 'Deliver only fresh green leafy coriander.',
        'status': 'Pending',
        'items': [
          {'name': 'Tomato (टमाटर)', 'quantity': 2.0, 'unit': 'kg', 'price': 40.0},
          {'name': 'Potato (आलू)', 'quantity': 5.0, 'unit': 'kg', 'price': 25.0},
          {'name': 'Coriander (धनिया)', 'quantity': 2.0, 'unit': 'bunch', 'price': 10.0},
        ],
        'total_amount': 225.0,
        'created_at': '2026-07-13 09:30 AM',
      },
      {
        'id': 'ORD-5014',
        'customer_name': 'Vijay Mehta',
        'mobile': '9911223344',
        'address': 'Flat 102, Green Avenue, Rajkot',
        'special_note': 'Call before delivery.',
        'status': 'Accepted',
        'items': [
          {'name': 'Onion (प्याज़)', 'quantity': 3.0, 'unit': 'kg', 'price': 35.0},
          {'name': 'Potato (आलू)', 'quantity': 2.0, 'unit': 'kg', 'price': 25.0},
        ],
        'total_amount': 155.0,
        'created_at': '2026-07-13 09:15 AM',
      },
      {
        'id': 'ORD-5013',
        'customer_name': 'Sanjay Shah',
        'mobile': '9879001122',
        'address': 'Plot 45, Kalawad Road, Rajkot',
        'special_note': 'Leave at the gate if not home.',
        'status': 'Packing',
        'items': [
          {'name': 'Tomato (टमाटर)', 'quantity': 4.0, 'unit': 'kg', 'price': 40.0},
        ],
        'total_amount': 160.0,
        'created_at': '2026-07-13 08:45 AM',
      },
      {
        'id': 'ORD-5012',
        'customer_name': 'Pooja Joshi',
        'mobile': '9426543210',
        'address': '15, Yogi Nagar, Rajkot',
        'special_note': '',
        'status': 'Ready For Pickup',
        'items': [
          {'name': 'Onion (प्याज़)', 'quantity': 1.0, 'unit': 'kg', 'price': 35.0},
          {'name': 'Tomato (टमाटर)', 'quantity': 1.0, 'unit': 'kg', 'price': 40.0},
        ],
        'total_amount': 75.0,
        'created_at': '2026-07-13 08:30 AM',
      },
      {
        'id': 'ORD-5011',
        'customer_name': 'Ketan Dave',
        'mobile': '9825098765',
        'address': '202, Radhe Apartments, Rajkot',
        'special_note': 'Deliver fresh items.',
        'status': 'Completed',
        'items': [
          {'name': 'Potato (आलू)', 'quantity': 10.0, 'unit': 'kg', 'price': 25.0},
        ],
        'total_amount': 250.0,
        'created_at': '2026-07-12 06:15 PM',
      }
    ],
    'notifications': [
      {
        'id': 1,
        'title': 'New Order Received',
        'body': 'You received a new order ORD-5015 for Anita Sharma.',
        'time': '10 mins ago',
        'type': 'new_order'
      },
      {
        'id': 2,
        'title': 'Order Cancelled',
        'body': 'Order ORD-5009 was cancelled by customer.',
        'time': '2 hours ago',
        'type': 'cancelled'
      }
    ]
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;
    final method = options.method;

    // Simulate network latency (300ms)
    await Future.delayed(const Duration(milliseconds: 300));

    // Helper to build success response
    Response successResponse(dynamic data) {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: data,
      );
    }

    // 1. Auth Endpoint - Direct Login
    if (path.endsWith(ApiEndpoints.login)) {
      final mobile = options.data['mobile'] ?? '';
      final password = options.data['password'] ?? '';
      
      if (mobile.length == 10 && password.isNotEmpty) {
        final profile = _db['profile'];
        return handler.resolve(successResponse({
          'success': true,
          'token': 'mock-jwt-token-987654321',
          'vendor': {
            'shop_name': profile['shop_name'],
            'owner_name': profile['owner_name'],
            'mobile': mobile,
            'address': profile['address'],
            'opening_time': profile['opening_time'],
            'closing_time': profile['closing_time'],
            'shop_photo': profile['shop_photo'],
          }
        }));
      } else {
        return handler.reject(DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 400,
            data: {'success': false, 'message': 'Invalid credentials. Enter 10-digit mobile and password.'},
          ),
        ));
      }
    }

    // 3. Dashboard Endpoint
    if (path.endsWith(ApiEndpoints.dashboard)) {
      final List orders = _db['orders'];
      final todayOrders = orders.length;
      final pendingOrders = orders.where((o) => o['status'] == 'Pending').length;
      final completedOrders = orders.where((o) => o['status'] == 'Completed').length;
      
      // Calculate sales
      double todaySales = 0.0;
      for (var o in orders) {
        if (o['status'] == 'Completed' || o['status'] == 'Ready For Pickup' || o['status'] == 'Packing' || o['status'] == 'Accepted') {
          todaySales += (o['total_amount'] as num).toDouble();
        }
      }

      return handler.resolve(successResponse({
        'today_orders': todayOrders,
        'pending_orders': pendingOrders,
        'completed_orders': completedOrders,
        'today_sales': todaySales,
      }));
    }

    // 4. Products List & Operations
    if (path.endsWith(ApiEndpoints.products)) {
      if (method == 'GET') {
        return handler.resolve(successResponse(_db['products']));
      } else if (method == 'POST') {
        // Add product
        final newProd = Map<String, dynamic>.from(options.data);
        final int newId = (_db['products'] as List).map((p) => p['id'] as int).fold(0, (max, id) => id > max ? id : max) + 1;
        newProd['id'] = newId;
        newProd['is_enabled'] = true;
        newProd['image_url'] = newProd['image_url'] ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e';
        
        _db['products'].add(newProd);
        return handler.resolve(successResponse(newProd));
      } else if (method == 'PUT') {
        // Edit product
        final updatedProd = Map<String, dynamic>.from(options.data);
        final int id = updatedProd['id'];
        final index = (_db['products'] as List).indexWhere((p) => p['id'] == id);
        if (index != -1) {
          _db['products'][index] = updatedProd;
          return handler.resolve(successResponse(updatedProd));
        }
      }
    }

    // Product toggle
    if (path.endsWith(ApiEndpoints.toggleProduct)) {
      final id = options.data['id'];
      final index = (_db['products'] as List).indexWhere((p) => p['id'] == id);
      if (index != -1) {
        final currentVal = _db['products'][index]['is_enabled'] as bool;
        _db['products'][index]['is_enabled'] = !currentVal;
        return handler.resolve(successResponse(_db['products'][index]));
      }
    }

    // Product price update
    if (path.endsWith(ApiEndpoints.updatePrice)) {
      final id = options.data['id'];
      final price = (options.data['price'] as num).toDouble();
      final index = (_db['products'] as List).indexWhere((p) => p['id'] == id);
      if (index != -1) {
        _db['products'][index]['price'] = price;
        return handler.resolve(successResponse(_db['products'][index]));
      }
    }

    // Product Image Upload (multipart)
    if (path.endsWith(ApiEndpoints.uploadProductImage)) {
      return handler.resolve(successResponse({
        'success': true,
        'image_url': 'https://images.unsplash.com/photo-1601648767791-af55d490298a',
      }));
    }

    // Delete Product
    if (path.contains('${ApiEndpoints.products}/')) {
      if (method == 'DELETE') {
        final parts = path.split('/');
        final idStr = parts.last;
        final id = int.tryParse(idStr);
        if (id != null) {
          _db['products'].removeWhere((p) => p['id'] == id);
          return handler.resolve(successResponse({'success': true}));
        }
      }
    }

    // 5. Orders List & Operations
    if (path.endsWith(ApiEndpoints.orders)) {
      return handler.resolve(successResponse(_db['orders']));
    }

    // Order status update
    if (path.endsWith(ApiEndpoints.orderStatusUpdate)) {
      final id = options.data['id'];
      final newStatus = options.data['status'];
      final index = (_db['orders'] as List).indexWhere((o) => o['id'] == id);
      if (index != -1) {
        _db['orders'][index]['status'] = newStatus;
        return handler.resolve(successResponse(_db['orders'][index]));
      }
    }

    // 6. Profile Endpoint
    if (path.endsWith(ApiEndpoints.profile)) {
      if (method == 'GET') {
        return handler.resolve(successResponse(_db['profile']));
      } else if (method == 'PUT') {
        _db['profile'] = options.data;
        return handler.resolve(successResponse(_db['profile']));
      }
    }

    // Shop photo upload
    if (path.endsWith(ApiEndpoints.uploadShopPhoto)) {
      return handler.resolve(successResponse({
        'success': true,
        'shop_photo': 'https://images.unsplash.com/photo-1542838132-92c53300491e',
      }));
    }

    // 7. Notifications Endpoint
    if (path.endsWith(ApiEndpoints.notifications)) {
      return handler.resolve(successResponse(_db['notifications']));
    }

    // FCM token save
    if (path.endsWith(ApiEndpoints.updateFcmToken)) {
      return handler.resolve(successResponse({'success': true}));
    }

    // Catch-all
    return handler.next(options);
  }
}
