class CartItem {
  final String id;
  final String name;
  final String material;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.material,
    required this.price,
    required this.image,
    this.quantity = 1,
  });
}