class OrderItem {
  final int id;
  final String name;
  final double quantity;
  final String unit;
  final double price;

  OrderItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    int parseId(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return OrderItem(
      id: parseId(json['id']),
      name: json['product_name']?.toString() ?? json['name']?.toString() ?? '',
      quantity: parseDouble(json['quantity']),
      unit: json['unit']?.toString() ?? 'kg',
      price: parseDouble(json['price']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
    };
  }
}

class Order {
  final String id;
  final String customerName;
  final String mobile;
  final String address;
  final String specialNote;
  final String status; // Pending, Accepted, Packing, Ready For Pickup, Completed, Rejected
  final List<OrderItem> items;
  final double totalAmount;
  final String createdAt;

  Order({
    required this.id,
    required this.customerName,
    required this.mobile,
    required this.address,
    required this.specialNote,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<OrderItem> itemList = list.map((i) => OrderItem.fromJson(i as Map<String, dynamic>)).toList();

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return Order(
      id: json['id']?.toString() ?? '',
      customerName: json['customer_name'] ?? json['customer']?['name']?.toString() ?? '',
      mobile: json['customer_mobile']?.toString() ?? json['mobile']?.toString() ?? json['customer']?['mobile']?.toString() ?? '',
      address: json['delivery_address']?.toString() ?? json['address']?.toString() ?? json['customer']?['address']?.toString() ?? '',
      specialNote: json['special_note']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      items: itemList,
      totalAmount: parseDouble(json['subtotal'] ?? json['total_amount'] ?? json['total']),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'mobile': mobile,
      'address': address,
      'special_note': specialNote,
      'status': status,
      'items': items.map((i) => i.toJson()).toList(),
      'total_amount': totalAmount,
      'created_at': createdAt,
    };
  }

  Order copyWith({
    String? id,
    String? customerName,
    String? mobile,
    String? address,
    String? specialNote,
    String? status,
    List<OrderItem>? items,
    double? totalAmount,
    String? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      specialNote: specialNote ?? this.specialNote,
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
