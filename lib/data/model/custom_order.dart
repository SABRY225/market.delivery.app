class CustomOrder {
  final String? id;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String description;
  final String? imagePath;
  final String? price;
  final String status;

  CustomOrder({
    this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.description,
    this.imagePath,
    this.price,
    this.status = 'new',
  });

  factory CustomOrder.fromJson(Map<String, dynamic> json) {
    return CustomOrder(
      id: json['id'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
      customerAddress: json['customerAddress'],
      description: json['description'],
      imagePath: json['imagePath'],
      price: json['price'],
      status: json['status'],
    );
  }
}