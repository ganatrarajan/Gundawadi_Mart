import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

class MockInterceptor extends Interceptor {
  // Store dynamic state in-memory during session
  static final List<Map<String, dynamic>> _mockOrders = [
    {
      'id': 1001,
      'vendor_name': 'Green Leaf Organics',
      'vendor_owner': 'Rajesh Kumar',
      'shop_photo': 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=400',
      'total_amount': 280.0,
      'delivery_charge': 30.0,
      'status': 'Accepted',
      'date': '2026-07-13 10:15 AM',
      'special_instructions': 'Send green chillies separately please.',
      'delivery_address': 'Flat 304, Green Meadows, Sector 12, Gandhinagar',
      'items': [
        {'name': 'Fresh Spinach (Palak)', 'price': 40.0, 'quantity': 2, 'unit': '500g'},
        {'name': 'Organic Tomatoes', 'price': 60.0, 'quantity': 1, 'unit': '1kg'},
        {'name': 'Green Peas', 'price': 70.0, 'quantity': 2, 'unit': '1kg'},
      ],
      'timeline': [
        {'status': 'Pending', 'time': '10:15 AM', 'is_completed': true},
        {'status': 'Accepted', 'time': '10:20 AM', 'is_completed': true},
        {'status': 'Packing', 'time': '', 'is_completed': false},
        {'status': 'Ready For Pickup', 'time': '', 'is_completed': false},
        {'status': 'Out For Delivery', 'time': '', 'is_completed': false},
        {'status': 'Delivered', 'time': '', 'is_completed': false},
      ]
    },
    {
      'id': 998,
      'vendor_name': 'Fresh & Fast Veggies',
      'vendor_owner': 'Amit Shah',
      'shop_photo': 'https://images.unsplash.com/photo-1573245782232-9d41b8e624e3?auto=format&fit=crop&q=80&w=400',
      'total_amount': 150.0,
      'delivery_charge': 25.0,
      'status': 'Delivered',
      'date': '2026-07-12 04:30 PM',
      'special_instructions': 'Deliver at the security gate.',
      'delivery_address': 'Plot 45, Sector 5, Gandhinagar',
      'items': [
        {'name': 'Potatoes (Aloo)', 'price': 30.0, 'quantity': 3, 'unit': '1kg'},
        {'name': 'Onions (Pyaz)', 'price': 35.0, 'quantity': 1, 'unit': '1kg'},
      ],
      'timeline': [
        {'status': 'Pending', 'time': '04:00 PM', 'is_completed': true},
        {'status': 'Accepted', 'time': '04:05 PM', 'is_completed': true},
        {'status': 'Packing', 'time': '04:10 PM', 'is_completed': true},
        {'status': 'Ready For Pickup', 'time': '04:15 PM', 'is_completed': true},
        {'status': 'Out For Delivery', 'time': '04:20 PM', 'is_completed': true},
        {'status': 'Delivered', 'time': '04:30 PM', 'is_completed': true},
      ]
    }
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!ApiEndpoints.useMockApis) {
      return super.onRequest(options, handler);
    }

    // Simulate network delay of 800ms to show loading state animations
    await Future.delayed(const Duration(milliseconds: 800));

    final path = options.path;
    final method = options.method;

    // Route Mocking Logic
    if (path.contains(ApiEndpoints.register)) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: {
          'success': true,
          'message': 'Your account has been submitted successfully. Please wait until the admin verifies your address and approves your account.'
        },
      ));
      return;
    }

    if (path.contains(ApiEndpoints.addresses)) {
      if (method == 'POST') {
        final body = options.data as Map<String, dynamic>;
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: {
            'success': true,
            'message': 'Address change request submitted successfully. Pending Admin review.',
            'data': {
              'id': 123,
              'full_name': body['full_name'],
              'mobile': body['mobile'],
              'house_number': body['house_number'],
              'street': body['street'],
              'area': body['area'],
              'landmark': body['landmark'],
              'city': body['city'],
              'pincode': body['pincode'],
              'status': 'pending',
            }
          },
        ));
        return;
      }

      // GET addresses
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            {
              'id': 1,
              'full_name': 'Rahul Sharma',
              'mobile': '9876543210',
              'house_number': 'Flat 304',
              'street': 'Green Meadows',
              'area': 'Sector 12',
              'landmark': 'Near Central Park',
              'city': 'Rajkot',
              'pincode': '360001',
              'status': 'approved',
              'delivery_km': 2.5,
              'delivery_charge': 30.0,
            }
          ]
        },
      ));
      return;
    }

    if (path.contains(ApiEndpoints.login)) {
      final body = options.data as Map<String, dynamic>;
      final mobile = body['mobile'] ?? '';
      if (mobile.length != 10) {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 400,
              data: {'message': 'Invalid mobile number. Must be 10 digits.'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'message': 'OTP sent successfully to $mobile. Use mock code 123456.'},
      ));
      return;
    }

    if (path.contains(ApiEndpoints.verifyOtp)) {
      final body = options.data as Map<String, dynamic>;
      final otp = body['otp'] ?? '';
      final mobile = body['mobile'] ?? '';
      
      if (otp != '123456') {
        handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 400,
              data: {'message': 'Incorrect OTP. Please enter 123456.'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }
      
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'token': 'mock_jwt_token_fresh_mandi_xyz123',
          'user': {
            'id': 42,
            'name': 'Rahul Sharma',
            'mobile': mobile,
            'address': {
              'house_number': 'Flat 304',
              'street': 'Green Meadows',
              'area': 'Sector 12',
              'landmark': 'Near Central Park',
            }
          }
        },
      ));
      return;
    }

    if (path.contains(ApiEndpoints.vendors)) {
      // Check if we are looking for vendor details (e.g., /vendors/1)
      final urlParts = path.split('/');
      final vendorIdStr = urlParts.last;
      final isDetails = int.tryParse(vendorIdStr) != null;

      if (isDetails) {
        final id = int.parse(vendorIdStr);
        final vendor = _getMockVendors().firstWhere(
          (v) => v['id'] == id,
          orElse: () => _getMockVendors().first,
        );
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: vendor,
        ));
        return;
      } else {
        // Vendor Listing
        final queryParams = options.queryParameters;
        final search = (queryParams['search'] ?? '').toString().toLowerCase();
        final page = int.tryParse(queryParams['page']?.toString() ?? '1') ?? 1;

        List<Map<String, dynamic>> filtered = _getMockVendors();
        if (search.isNotEmpty) {
          filtered = filtered.where((v) {
            final shopName = v['shop_name'].toString().toLowerCase();
            final ownerName = v['owner_name'].toString().toLowerCase();
            return shopName.contains(search) || ownerName.contains(search);
          }).toList();
        }

        // Simulating pagination
        final itemsPerPage = 5;
        final startIndex = (page - 1) * itemsPerPage;
        final endIndex = startIndex + itemsPerPage;
        
        List<Map<String, dynamic>> paginated = [];
        if (startIndex < filtered.length) {
          paginated = filtered.sublist(
            startIndex,
            endIndex > filtered.length ? filtered.length : endIndex,
          );
        }

        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'data': paginated,
            'current_page': page,
            'last_page': (filtered.length / itemsPerPage).ceil(),
            'total': filtered.length,
          },
        ));
        return;
      }
    }

    if (path.contains(ApiEndpoints.orders)) {
      final urlParts = path.split('/');
      final lastPart = urlParts.last;
      
      // Cancel Order
      if (lastPart == 'cancel') {
        final id = int.tryParse(urlParts[urlParts.length - 2]);
        final index = _mockOrders.indexWhere((o) => o['id'] == id);
        if (index != -1) {
          _mockOrders[index]['status'] = 'Cancelled';
          // Update timeline
          final list = List<Map<String, dynamic>>.from(_mockOrders[index]['timeline']);
          for (var item in list) {
            if (item['status'] == 'Delivered') {
              item['status'] = 'Cancelled';
              item['time'] = '11:30 AM';
              item['is_completed'] = true;
            }
          }
          _mockOrders[index]['timeline'] = list;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: _mockOrders[index],
          ));
          return;
        }
      }

      final isOrderDetails = int.tryParse(lastPart) != null;
      if (isOrderDetails) {
        final id = int.parse(lastPart);
        final order = _mockOrders.firstWhere(
          (o) => o['id'] == id,
          orElse: () => _mockOrders.first,
        );
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: order,
        ));
        return;
      }

      if (method == 'POST') {
        final body = options.data as Map<String, dynamic>;
        final newId = 1000 + _mockOrders.length + 1;
        final deliveryAddressMap = body['address'] as Map<String, dynamic>;
        final addressString = '${deliveryAddressMap['house_number'] ?? ''}, ${deliveryAddressMap['street'] ?? ''}, ${deliveryAddressMap['area'] ?? ''}, ${deliveryAddressMap['landmark'] ?? ''}';
        
        final cartItems = body['items'] as List<dynamic>;
        final parsedItems = cartItems.map((c) => {
          'name': c['name'],
          'price': c['price'],
          'quantity': c['quantity'],
          'unit': c['unit'],
        }).toList();

        final vendorId = body['vendor_id'];
        final vendor = _getMockVendors().firstWhere(
          (v) => v['id'] == vendorId,
          orElse: () => _getMockVendors().first,
        );

        final newOrder = {
          'id': newId,
          'vendor_name': vendor['shop_name'],
          'vendor_owner': vendor['owner_name'],
          'shop_photo': vendor['shop_photo'],
          'total_amount': body['total_amount'],
          'delivery_charge': body['delivery_charge'] ?? 20.0,
          'status': 'Pending',
          'date': 'Just Now',
          'special_instructions': body['special_instructions'] ?? '',
          'delivery_address': addressString,
          'items': parsedItems,
          'timeline': [
            {'status': 'Pending', 'time': 'Just Now', 'is_completed': true},
            {'status': 'Accepted', 'time': '', 'is_completed': false},
            {'status': 'Packing', 'time': '', 'is_completed': false},
            {'status': 'Ready For Pickup', 'time': '', 'is_completed': false},
            {'status': 'Out For Delivery', 'time': '', 'is_completed': false},
            {'status': 'Delivered', 'time': '', 'is_completed': false},
          ]
        };

        _mockOrders.insert(0, newOrder);
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 201,
          data: newOrder,
        ));
        return;
      }

      // Get Orders list
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: _mockOrders,
      ));
      return;
    }

    if (path.contains(ApiEndpoints.profile)) {
      if (method == 'POST') {
        // Update profile
        final body = options.data as Map<String, dynamic>;
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'user': {
              'id': 42,
              'name': body['name'] ?? 'Rahul Sharma',
              'mobile': body['mobile'] ?? '9876543210',
              'address': body['address'] ?? {},
            }
          },
        ));
        return;
      }

      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'id': 42,
          'name': 'Rahul Sharma',
          'mobile': '9876543210',
          'address': {
            'house_number': 'Flat 304',
            'street': 'Green Meadows',
            'area': 'Sector 12',
            'landmark': 'Near Central Park',
          }
        },
      ));
      return;
    }

    // Default route error if not caught
    handler.reject(
      DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 404,
          data: {'message': 'Mock Route Not Found ($path)'},
        ),
        type: DioExceptionType.badResponse,
      ),
    );
  }

  // Pre-configured list of mock vendors and products
  List<Map<String, dynamic>> _getMockVendors() {
    return [
      {
        'id': 1,
        'shop_name': 'Green Leaf Organics',
        'owner_name': 'Rajesh Kumar',
        'shop_photo': 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=600',
        'is_open': true,
        'products': [
          {
            'id': 101,
            'name': 'Fresh Tomatoes',
            'image_url': 'https://images.unsplash.com/photo-1595855759920-86582396756a?auto=format&fit=crop&q=80&w=300',
            'today_price': 40.0,
            'unit': 'kg',
            'category': 'Daily Essentials'
          },
          {
            'id': 102,
            'name': 'Green Spinach (Palak)',
            'image_url': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&q=80&w=300',
            'today_price': 25.0,
            'unit': '500g',
            'category': 'Leafy Greens'
          },
          {
            'id': 103,
            'name': 'Potatoes (Aloo)',
            'image_url': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&q=80&w=300',
            'today_price': 30.0,
            'unit': 'kg',
            'category': 'Daily Essentials'
          },
          {
            'id': 104,
            'name': 'Fresh Onions (Pyaz)',
            'image_url': 'https://images.unsplash.com/photo-1508747703725-719777637510?auto=format&fit=crop&q=80&w=300',
            'today_price': 35.0,
            'unit': 'kg',
            'category': 'Daily Essentials'
          },
          {
            'id': 105,
            'name': 'Organic Cauliflower',
            'image_url': 'https://images.unsplash.com/photo-1568584711291-750c3127522a?auto=format&fit=crop&q=80&w=300',
            'today_price': 50.0,
            'unit': 'piece',
            'category': 'Veggies'
          },
        ]
      },
      {
        'id': 2,
        'shop_name': 'Fresh & Fast Veggies',
        'owner_name': 'Amit Shah',
        'shop_photo': 'https://images.unsplash.com/photo-1573245782232-9d41b8e624e3?auto=format&fit=crop&q=80&w=600',
        'is_open': true,
        'products': [
          {
            'id': 201,
            'name': 'Green Peas (Matar)',
            'image_url': 'https://images.unsplash.com/photo-1592394503753-4074f8298904?auto=format&fit=crop&q=80&w=300',
            'today_price': 70.0,
            'unit': 'kg',
            'category': 'Seasonal'
          },
          {
            'id': 202,
            'name': 'Carrots (Gajar)',
            'image_url': 'https://images.unsplash.com/photo-1598170845058-32b996a7ad43?auto=format&fit=crop&q=80&w=300',
            'today_price': 45.0,
            'unit': 'kg',
            'category': 'Daily Essentials'
          },
          {
            'id': 203,
            'name': 'Fresh Cucumber (Kheera)',
            'image_url': 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?auto=format&fit=crop&q=80&w=300',
            'today_price': 30.0,
            'unit': '500g',
            'category': 'Salads'
          },
        ]
      },
      {
        'id': 3,
        'shop_name': 'Organic Basket',
        'owner_name': 'Sanjay Patel',
        'shop_photo': 'https://images.unsplash.com/photo-1488459718432-01055e67e44a?auto=format&fit=crop&q=80&w=600',
        'is_open': false,
        'products': [
          {
            'id': 301,
            'name': 'Broccoli',
            'image_url': 'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a05?auto=format&fit=crop&q=80&w=300',
            'today_price': 90.0,
            'unit': 'piece',
            'category': 'Exotic Veggies'
          },
          {
            'id': 302,
            'name': 'Red & Yellow Bell Peppers',
            'image_url': 'https://images.unsplash.com/photo-1563565312870-83569fb27a05?auto=format&fit=crop&q=80&w=300',
            'today_price': 120.0,
            'unit': '500g',
            'category': 'Exotic Veggies'
          },
        ]
      },
      {
        'id': 4,
        'shop_name': 'Gandhinagar Veg Mart',
        'owner_name': 'Hasmukh Bhai',
        'shop_photo': 'https://images.unsplash.com/photo-1608686207856-001b95cf60ca?auto=format&fit=crop&q=80&w=600',
        'is_open': true,
        'products': [
          {
            'id': 401,
            'name': 'Fresh Garlic (Lahsun)',
            'image_url': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&q=80&w=300',
            'today_price': 180.0,
            'unit': '250g',
            'category': 'Daily Essentials'
          },
          {
            'id': 402,
            'name': 'Ginger (Adrak)',
            'image_url': 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&q=80&w=300',
            'today_price': 80.0,
            'unit': '250g',
            'category': 'Daily Essentials'
          },
          {
            'id': 403,
            'name': 'Green Chillies (Hari Mirch)',
            'image_url': 'https://images.unsplash.com/photo-1588252399612-42e61911910f?auto=format&fit=crop&q=80&w=300',
            'today_price': 20.0,
            'unit': '250g',
            'category': 'Daily Essentials'
          },
        ]
      },
      {
        'id': 5,
        'shop_name': 'Farm Fresh Store',
        'owner_name': 'Deepak Prajapati',
        'shop_photo': 'https://images.unsplash.com/photo-1516594798947-e65505dbb29d?auto=format&fit=crop&q=80&w=600',
        'is_open': true,
        'products': [
          {
            'id': 501,
            'name': 'Ladies Finger (Bhindi)',
            'image_url': 'https://images.unsplash.com/photo-1625938146369-adc83368bda7?auto=format&fit=crop&q=80&w=300',
            'today_price': 40.0,
            'unit': '500g',
            'category': 'Veggies'
          },
          {
            'id': 502,
            'name': 'Bottle Gourd (Lauki)',
            'image_url': 'https://images.unsplash.com/photo-1594282486552-05b4d80fbb9f?auto=format&fit=crop&q=80&w=300',
            'today_price': 25.0,
            'unit': 'piece',
            'category': 'Veggies'
          },
        ]
      }
    ];
  }
}
