class Abo {
  String id;
  DateTime startDate;
  DateTime endDate;
  double price;
  bool isMonthly; // True for monthly, false for yearly

  Abo({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.isMonthly,
  });

  // Convert Abo object to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'price': price,
        'isMonthly': isMonthly,
      };

  // Convert JSON to Abo object
  factory Abo.fromJson(Map<String, dynamic> json) {
    return Abo(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      price: json['price'],
      isMonthly: json['isMonthly'],
    );
  }
}
