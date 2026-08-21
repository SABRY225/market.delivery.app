class OrderWeeletModel {
  final String orderId;
  final String time;
  final bool isToday;
  final String restaurantName;
  final double totalPaidToRestaurant;

  OrderWeeletModel({
    required this.orderId,
    required this.time,
    required this.isToday,
    required this.restaurantName,
    required this.totalPaidToRestaurant,
  });

  factory OrderWeeletModel.fromJson(Map<String, dynamic> json) {
    return OrderWeeletModel(
      orderId: json['orderId']?.toString() ?? 'N/A',
      time: json['time']?.toString() ?? '',
      isToday: json['isToday'] ?? false,
      restaurantName: json['restaurantName'] ?? 'Unknown restaurant',
      totalPaidToRestaurant:
          (json['totalPaidToRestaurant'] as num?)?.toDouble() ?? 0.0,
    );
  }
}