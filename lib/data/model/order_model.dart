class OrderModel {
  final int? id;
  final String? customer;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String? payment;
  final String? date;
  final int? deliveryTime;
  final double? deliveryFee;
  final List<OrderItem>? items;
  final double? total;

  OrderModel({
    this.id,
    this.customer,
    this.phone,
    this.latitude,
    this.longitude,
    this.payment,
    this.date,
    this.deliveryTime,
    this.deliveryFee,
    this.items,
    this.total,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int?,
      customer: json['customer'] as String?,
      phone: json['phone']?.toString(), // Safely handles numbers or strings
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      payment: json['payment'] as String?,
      date: json['date'] as String?,
      deliveryTime: json['deliveryTime'] as int?,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'payment': payment,
      'date': date,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'total': total,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final String? name;
  final double? price;

  OrderItem({this.name, this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}