class MockOrderModel {
  final int id;
  final double price;
  final String time;
  final String storeName;
  final String customerAddress;

  MockOrderModel({
    required this.id,
    required this.price,
    required this.time,
    required this.storeName,
    required this.customerAddress,
  });

  static List<MockOrderModel> get sampleOrders => [
    MockOrderModel(
      id: 8432,
      price: 150.00,
      time: "5 mins ago",
      storeName: "McDonalds",
      customerAddress: "Tahrir St, Bldg 24",
    ),
    MockOrderModel(
      id: 8433,
      price: 75.50,
      time: "12 mins ago",
      storeName: "El Ezaby Pharmacy",
      customerAddress: "Thawra St",
    ),
    MockOrderModel(
      id: 8434,
      price: 320.00,
      time: "20 mins ago",
      storeName: "Kheir Zaman Supermarket",
      customerAddress: "Abbas El Akkad St",
    ),
  ];
}