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
  /// Converts this [Abo] object to a JSON-serializable map.
  ///
  /// The map contains the following keys:
  ///
  /// - 'id': The unique identifier of the Abo object.
  /// - 'startDate': The start date of the Abo in ISO8601 format.
  /// - 'endDate': The end date of the Abo in ISO8601 format.
  /// - 'price': The monthly cost of the Abo.
  /// - 'isMonthly': A boolean indicating whether the Abo is a monthly or yearly subscription.
  ///
  /// The map can be serialized to JSON using [jsonEncode].
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
