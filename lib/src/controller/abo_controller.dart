import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Abo {
  String id;
  DateTime startDate;
  DateTime endDate;
  double price;
  bool isMonthly;
  String name;

  Abo({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.isMonthly,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'price': price,
        'isMonthly': isMonthly,
        'name': name,
      };

  factory Abo.fromJson(Map<String, dynamic> json) {
    return Abo(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      price: json['price'],
      isMonthly: json['isMonthly'],
      name: json['name'],
    );
  }
}

class AboController with ChangeNotifier {
  List<Abo> _abos = [];
  List<Abo> _filteredAbos = [];

  List<Abo> get abos => _filteredAbos.isNotEmpty ? _filteredAbos : _abos;

  Future<void> loadAbos() async {
    final file = await _getAboFile();
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      _abos = jsonList.map((json) => Abo.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> saveAbos() async {
    final file = await _getAboFile();
    final jsonList = _abos.map((abo) => abo.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  void addAbo(String name, double price, bool isMonthly, DateTime startDate,
      DateTime endDate) {
    final newAbo = Abo(
      id: DateTime.now().toString(),
      startDate: startDate,
      endDate: endDate,
      price: price,
      isMonthly: isMonthly,
      name: name,
    );
    _abos.add(newAbo);
    saveAbos();
    notifyListeners();
  }

  void editAbo(String id, String name, double price, bool isMonthly,
      DateTime startDate, DateTime endDate) {
    final aboIndex = _abos.indexWhere((abo) => abo.id == id);
    if (aboIndex != -1) {
      _abos[aboIndex]
        ..name = name
        ..price = price
        ..isMonthly = isMonthly
        ..startDate = startDate
        ..endDate = endDate;
      saveAbos();
      notifyListeners();
    }
  }

  void deleteAbo(String id) {
    _abos.removeWhere((abo) => abo.id == id);
    saveAbos();
    notifyListeners();
  }

  Future<File> _getAboFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/abos.json');
  }

  void showEditAboDialog(BuildContext context, Abo abo) {
    final TextEditingController nameController =
        TextEditingController(text: abo.name);
    final TextEditingController priceController =
        TextEditingController(text: abo.price.toString());
    bool isMonthly = abo.isMonthly;
    DateTime startDate = abo.startDate;
    DateTime endDate = abo.endDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Subscription'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Subscription Type:'),
                      const SizedBox(width: 10),
                      DropdownButton<bool>(
                        value: isMonthly,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              isMonthly = value;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text('Monthly'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Yearly'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              startDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                            'Start Date: ${startDate.toLocal()}'.split(' ')[0]),
                      ),
                      TextButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              endDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                            'End Date: ${endDate.toLocal()}'.split(' ')[0]),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text;
                    final priceText = priceController.text;

                    if (name.isEmpty || priceText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter all fields'),
                        ),
                      );
                    } else {
                      final price = double.tryParse(priceText);
                      if (price == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid price value'),
                          ),
                        );
                      } else {
                        editAbo(
                            abo.id, name, price, isMonthly, startDate, endDate);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Subscription updated successfully'),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddAboDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    bool isMonthly = true;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Subscription'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('Subscription Type:'),
                      const SizedBox(width: 10),
                      DropdownButton<bool>(
                        value: isMonthly,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              isMonthly = value;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text('Monthly'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Yearly'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              startDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                            'Start Date: ${startDate.toLocal()}'.split(' ')[0]),
                      ),
                      TextButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              endDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                            'End Date: ${endDate.toLocal()}'.split(' ')[0]),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text;
                    final priceText = priceController.text;

                    if (name.isEmpty || priceText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter all fields'),
                        ),
                      );
                    } else {
                      final price = double.tryParse(priceText);
                      if (price == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid price value'),
                          ),
                        );
                      } else {
                        addAbo(name, price, isMonthly, startDate, endDate);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Subscription added successfully'),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void filterByOldest() {
    _filteredAbos = List.from(_abos)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    notifyListeners();
  }

  void filterByNewest() {
    _filteredAbos = List.from(_abos)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    notifyListeners();
  }

  void clearFilter() {
    _filteredAbos.clear();
    notifyListeners();
  }
}
