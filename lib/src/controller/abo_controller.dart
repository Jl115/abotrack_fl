import 'dart:io';
import 'dart:convert';
import 'package:abotrack_fl/src/models/abo.dart';
import 'package:path_provider/path_provider.dart';

class AboController {
  List<Abo> _abos = [];

  List<Abo> get abos => _abos;

  // Load abos from JSON file
  Future<void> loadAbos() async {
    final file = await _getAboFile();
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
      _abos = jsonList.map((json) => Abo.fromJson(json)).toList();
    }
  }

  // Save abos to JSON file
  Future<void> saveAbos() async {
    final file = await _getAboFile();
    final jsonList = _abos.map((abo) => abo.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  // Add a new Abo
  void addAbo(Abo abo) {
    _abos.add(abo);
    saveAbos();
  }

  // Delete an Abo by ID
  void deleteAbo(String id) {
    _abos.removeWhere((abo) => abo.id == id);
    saveAbos();
  }

  // Helper method to get the file where abos are stored
  Future<File> _getAboFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/abos.json');
  }
}
