class DashboardStats {
  final int todayOrders;
  final int pendingOrders;
  final int completedOrders;
  final double todaySales;

  DashboardStats({
    required this.todayOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.todaySales,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is double) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double toDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return DashboardStats(
      todayOrders: toInt(json['today_orders']),
      pendingOrders: toInt(json['pending_orders']),
      completedOrders: toInt(json['completed_orders']),
      todaySales: toDouble(json['today_sales']),
    );
  }
}
