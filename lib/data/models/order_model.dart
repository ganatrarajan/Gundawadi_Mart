import '../../core/constants/api_endpoints.dart';

class OrderModel {
  final int id;
  final String vendorName;
  final String vendorOwner;
  final String shopPhoto;
  final double totalAmount;
  final double deliveryCharge;
  final double handlingCharge;
  final double platformFee;
  final String status;
  final String date;
  final String specialInstructions;
  final String deliveryAddress;
  final List<OrderItemModel> items;
  final List<OrderStatusHistory> timeline;

  OrderModel({
    required this.id,
    required this.vendorName,
    required this.vendorOwner,
    required this.shopPhoto,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.handlingCharge,
    required this.platformFee,
    required this.status,
    required this.date,
    required this.specialInstructions,
    required this.deliveryAddress,
    required this.items,
    required this.timeline,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List?;
    List<OrderItemModel> parsedItems = itemsList != null
        ? itemsList.map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>)).toList()
        : [];

    var timelineList = json['timeline'] as List?;
    List<OrderStatusHistory> parsedTimeline = timelineList != null
        ? timelineList.map((t) => OrderStatusHistory.fromJson(t as Map<String, dynamic>)).toList()
        : [];

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

    return OrderModel(
      id: parseId(json['id']),
      vendorName: json['vendor_name'] ?? json['vendor']?['shop_name']?.toString() ?? '',
      vendorOwner: json['vendor_owner'] ?? json['vendor']?['owner_name']?.toString() ?? '',
      shopPhoto: ApiEndpoints.formatImageUrl(json['shop_photo'] ?? json['vendor']?['shop_photo']?.toString()),
      totalAmount: parseDouble(json['total_amount'] ?? json['total']),
      deliveryCharge: parseDouble(json['delivery_charge']),
      handlingCharge: parseDouble(json['handling_charge']),
      platformFee: parseDouble(json['platform_fee']),
      status: json['status']?.toString() ?? 'Pending',
      date: json['date'] ?? json['created_at']?.toString() ?? '',
      specialInstructions: json['special_instructions']?.toString() ?? json['special_note']?.toString() ?? '',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      items: parsedItems,
      timeline: parsedTimeline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vendor_name': vendorName,
      'vendor_owner': vendorOwner,
      'shop_photo': shopPhoto,
      'total_amount': totalAmount,
      'delivery_charge': deliveryCharge,
      'handling_charge': handlingCharge,
      'platform_fee': platformFee,
      'status': status,
      'date': date,
      'special_instructions': specialInstructions,
      'delivery_address': deliveryAddress,
      'items': items.map((e) => e.toJson()).toList(),
      'timeline': timeline.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderItemModel {
  final String name;
  final double price;
  final int quantity;
  final String unit;
  final String vendorName;

  OrderItemModel({
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.vendorName,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseQuantity(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return OrderItemModel(
      name: json['product_name']?.toString() ?? json['name']?.toString() ?? json['product']?['name']?.toString() ?? '',
      price: parseDouble(json['price']),
      quantity: parseQuantity(json['quantity']),
      unit: json['unit']?.toString() ?? json['product']?['unit']?.toString() ?? 'kg',
      vendorName: json['vendor_name']?.toString() ?? 'Unknown Vendor',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'vendor_name': vendorName,
    };
  }
}

class OrderStatusHistory {
  final String status;
  final String time;
  final bool isCompleted;

  OrderStatusHistory({
    required this.status,
    required this.time,
    required this.isCompleted,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is int) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return false;
    }

    return OrderStatusHistory(
      status: json['status']?.toString() ?? '',
      time: json['time'] ?? json['created_at']?.toString() ?? '',
      isCompleted: parseBool(json['is_completed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'time': time,
      'is_completed': isCompleted,
    };
  }
}
