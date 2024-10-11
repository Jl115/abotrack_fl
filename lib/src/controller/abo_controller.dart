import 'dart:convert';
import 'dart:io';
import 'package:abotrack_fl/main.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  /// Converts this [Abo] object to a JSON-serializable map.
  ///
  /// The map contains the following keys:
  ///
  /// - 'id': The unique identifier of the Abo object.
  /// - 'startDate': The start date of the Abo in ISO8601 format.
  /// - 'endDate': The end date of the Abo in ISO8601 format.
  /// - 'price': The monthly cost of the Abo.
  /// - 'isMonthly': A boolean indicating whether the Abo is a monthly or yearly subscription.
  /// - 'name': The name of the Abo.
  ///
  /// The map can be serialized to JSON using [jsonEncode].
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

  /// Returns a [File] object pointing to the file that contains the app's
  /// abos. The file is named "abos.json" and is located in the app's
  /// application document directory.
  Future<File> _getAboFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/abos.json');
  }

  /// Loads the app's abos from the JSON file in the app's application document
  /// directory. If the file does not exist, the method does nothing and prints
  /// a message to the console. If the file exists, the method reads it and
  /// converts its contents to a list of [Abo] objects, replacing the existing
  /// list. The method also clears any previous filters and notifies the UI to
  /// update.
  Future<void> loadAbos() async {
    try {
      final file = await _getAboFile();
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = json.decode(jsonString);
        _abos = jsonList.map((json) => Abo.fromJson(json)).toList();
        _filteredAbos.clear(); // Clear any previous filters
        notifyListeners(); // Notify to update the UI
        print("Abos loaded successfully: ${_abos.length} entries");
      } else {
        print("No existing Abo file found.");
      }
    } catch (e) {
      print("Error loading Abos: $e");
    }
  }

  /// Calculates the total monthly cost of all abos in the app.
  ///
  /// This method iterates over the list of abos and adds the monthly cost of each
  /// abo to a running total. If an abo is a yearly subscription, the method
  /// estimates the monthly cost by dividing the price by 12. The final total is
  /// returned as a double.
  double getMonthlyCost() {
    double total = 0.0;
    for (var abo in _abos) {
      if (abo.isMonthly) {
        total += abo.price;
      } else {
        total +=
            (abo.price / 12); // Estimate monthly cost for yearly subscriptions
      }
    }
    return total;
  }

  /// Saves the list of abos to the app's application document directory.
  ///
  /// This method takes the list of [Abo] objects and converts it to a JSON-serializable
  /// list. The list is then written to a file named "abos.json" in the app's
  /// application document directory. If the file does not exist, it is created.
  /// If there is an error writing to the file, the error is not propagated.
  Future<void> saveAbos() async {
    try {
      final file = await _getAboFile();
      final jsonList = _abos.map((abo) => abo.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
      print("Abos saved successfully to ${file.path}");
    } catch (e) {
      print("Error saving Abos: $e");
    }
  }

  /// Adds a new [Abo] to the list of abos.
  ///
  /// This method takes the name, price, isMonthly flag, start date, and end date of
  /// the new abo, and creates a new [Abo] object with these values. The method
  /// then adds the new abo to the list of abos and saves the list to the app's
  /// application document directory. Finally, the method notifies the UI to
  /// update.
  void addAbo(String name, double price, bool isMonthly, DateTime startDate,
      DateTime endDate) {
    var uuid = const Uuid();
    final newAbo = Abo(
      id: uuid.v4(), // Generate a unique ID
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

  /// Edits an existing [Abo] in the list of abos.
  ///
  /// This method takes the unique ID of the abo to edit, as well as the new
  /// name, price, isMonthly flag, start date, and end date of the abo. The
  /// method then finds the abo with the given ID and updates its fields with the
  /// provided values. Finally, the method saves the list of abos to the app's
  /// application document directory and notifies the UI to update. If the abo
  /// with the given ID is not found, no changes are made.
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

  /// Deletes the [Abo] with the given [id] from the list of abos.
  ///
  /// This method removes the abo with the given ID from the list of abos,
  /// saves the updated list to the app's application document directory,
  /// and notifies the UI to update. If the abo with the given ID is not
  /// found, no changes are made.
  void deleteAbo(String id) {
    _abos.removeWhere((abo) => abo.id == id);
    saveAbos();
    notifyListeners();
  }

  void showEditAboDialog(BuildContext context, Abo abo) {
    final TextEditingController nameController =
        TextEditingController(text: abo.name);
    final TextEditingController priceController =
        TextEditingController(text: abo.price.toString());
    bool isMonthly = abo.isMonthly;
    DateTime startDate = abo.startDate;
    DateTime endDate = abo.endDate;
    final theme = Theme.of(context); // Get current theme

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Edit Subscription',
                style: theme.textTheme.headlineSmall,
              ),
              backgroundColor: theme.dialogBackgroundColor,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      labelStyle: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Subscription Type:',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<bool>(
                        dropdownColor: theme.cardColor,
                        value: isMonthly,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              isMonthly = value;
                            });
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: true,
                            child: Text(
                              'Monthly',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(
                              'Yearly',
                              style: theme.textTheme.bodyLarge,
                            ),
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
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                        ),
                        child: Text(
                          'Start Date: ${startDate.toLocal().toString().split(' ')[0]}',
                          style: theme.textTheme.labelSmall,
                        ),
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
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                        ),
                        child: Text(
                          'End Date: ${endDate.toLocal().toString().split(' ')[0]}',
                          style: theme.textTheme.labelSmall,
                        ),
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
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                  ),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text;
                    final priceText = priceController.text;

                    if (name.isEmpty || priceText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter all fields',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      );
                    } else {
                      final price = double.tryParse(priceText);
                      if (price == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Invalid price value',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        );
                      } else {
                        editAbo(
                            abo.id, name, price, isMonthly, startDate, endDate);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Subscription updated successfully',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Shows a dialog for adding a new subscription.
  ///
  /// This dialog allows the user to input the name, price, isMonthly flag, start
  /// date, and end date of the new subscription. If the user presses the "Cancel"
  /// button, the dialog is simply closed.
  ///
  /// If the user presses the "Add" button, the user is prompted to enter all
  /// required fields. If any field is empty, the user is shown a snackbar error
  /// message. If the price is not a valid number, the user is also shown a
  /// snackbar error message. If all fields are valid, the subscription is added
  /// and the user is shown a snackbar success message. The dialog is then closed.
  void showAddAboDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    bool isMonthly = true;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));
    final theme = Theme.of(context); // Get current theme

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Add New Subscription',
                style: theme.textTheme.headlineSmall,
              ),
              backgroundColor: theme.dialogBackgroundColor,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      labelStyle: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Subscription Type:',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 10),
                      DropdownButton<bool>(
                        dropdownColor: theme.cardColor,
                        value: isMonthly,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              isMonthly = value;
                            });
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: true,
                            child: Text(
                              'Monthly',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(
                              'Yearly',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Column(
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
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                        ),
                        child: Text(
                          'Start Date: ${startDate.toLocal().toString().split(' ')[0]}',
                          style: theme.textTheme.bodyLarge,
                        ),
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
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                        ),
                        child: Text(
                          'End Date: ${endDate.toLocal().toString().split(' ')[0]}',
                          style: theme.textTheme.labelSmall,
                        ),
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
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.secondary,
                  ),
                  child: Text(
                    'Cancel',
                    style: theme.textTheme.labelSmall,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text;
                    final priceText = priceController.text;

                    if (name.isEmpty || priceText.isEmpty) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(navigatorKey.currentContext!)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please enter all fields',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      );
                    } else {
                      final price = double.tryParse(priceText);
                      if (price == null) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(navigatorKey.currentContext!)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Invalid price value',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        );
                      } else {
                        addAbo(name, price, isMonthly, startDate, endDate);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(navigatorKey.currentContext!)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Subscription added successfully',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Add',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Sorts the list of abos by their start date in ascending order.
  ///
  /// This will cause the UI to display the abos in the order of their start date,
  /// with the oldest first.
  void filterByOldest() {
    _filteredAbos = List.from(_abos)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    notifyListeners();
  }

  /// Sorts the list of abos by their start date in descending order.
  ///
  /// This will cause the UI to display the abos in the order of their start date,
  /// with the newest first.
  void filterByNewest() {
    _filteredAbos = List.from(_abos)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    notifyListeners();
  }

  /// Clears the current filter and displays all abos in the list.
  ///
  /// This will cause the UI to display all abos in the list, without any filtering.
  void clearFilter() {
    _filteredAbos.clear();
    notifyListeners();
  }
}
