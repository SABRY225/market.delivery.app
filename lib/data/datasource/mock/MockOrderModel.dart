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
      time: "منذ 5 دقائق",
      storeName: "ماكدونالدز - فرع وسط البلد",
      customerAddress: "شارع التحرير، بناء رقم ٢٤، الدور الرابع",
    ),
    MockOrderModel(
      id: 8433,
      price: 75.50,
      time: "منذ ١٢ دقيقة",
      storeName: "صيدلية العزبي - فرع الميرغني",
      customerAddress: "شارع الثورة، بجوار مسجد الصديق",
    ),
    MockOrderModel(
      id: 8434,
      price: 320.00,
      time: "منذ ٢0 دقيقة",
      storeName: "سوبرماركت خير زمان",
      customerAddress: "شارع عباس العقاد، برج الياسمين",
    ),
  ];
}
