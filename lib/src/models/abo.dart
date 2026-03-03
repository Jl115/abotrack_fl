class Abo {
  String id;
  DateTime startDate;
  DateTime endDate;
  double price;
  bool isMonthly; // True for monthly, false for yearly
  String name;
  String? category; // Optional category (e.g., "Streaming", "Software", "Gym")
  String? notes; // Optional notes about the subscription

  Abo({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.isMonthly,
    required this.name,
    this.category,
    this.notes,
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
  /// - 'category': Optional category of the subscription.
  /// - 'notes': Optional notes about the subscription.
  ///
  /// The map can be serialized to JSON using [jsonEncode].
  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'price': price,
        'isMonthly': isMonthly,
        'name': name,
        if (category != null) 'category': category,
        if (notes != null) 'notes': notes,
      };

  // Convert JSON to Abo object
  factory Abo.fromJson(Map<String, dynamic> json) {
    return Abo(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      price: json['price'],
      isMonthly: json['isMonthly'],
      name: json['name'],
      category: json['category'],
      notes: json['notes'],
    );
  }
  
  /// Check if this subscription is active (not expired).
  bool get isActive => endDate.isAfter(DateTime.now());
  
  /// Get days until expiration.
  int get daysUntilExpiration => endDate.difference(DateTime.now()).inDays;
  
  /// Check if this subscription expires soon (within 7 days).
  bool get expiresSoon => daysUntilExpiration >= 0 && daysUntilExpiration <= 7;
}
