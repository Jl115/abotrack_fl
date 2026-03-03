import 'dart:convert';
import 'dart:io';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cloud backup service using local storage (simplified version).
/// Full Google Drive integration requires OAuth setup.
class CloudBackupService {
  static final CloudBackupService _instance = CloudBackupService._internal();
  factory CloudBackupService() => _instance;
  CloudBackupService._internal();

  static const String _backupFileName = 'abotrack_backup.json';
  
  bool _isAuthenticated = false;

  /// Authenticate (simplified - always succeeds for local backup).
  Future<bool> authenticate() async {
    _isAuthenticated = true;
    print('Cloud backup authenticated (local storage)');
    return true;
  }

  /// Load saved authentication.
  Future<void> loadAuthentication() async {
    _isAuthenticated = true;
  }

  /// Backup subscriptions to local storage.
  Future<bool> backupToCloud(AboController controller) async {
    try {
      final abos = controller.abos;
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'subscriptions': abos.map((abo) => abo.toJson()).toList(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(backupData);
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_backupFileName, jsonString);
      await prefs.setInt('last_backup_timestamp', DateTime.now().millisecondsSinceEpoch);
      
      print('Backup successful: ${abos.length} subscriptions');
      return true;
    } catch (e) {
      print('Backup error: $e');
      return false;
    }
  }

  /// Restore subscriptions from local backup.
  Future<int> restoreFromCloud(AboController controller) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_backupFileName);
      
      if (jsonString == null) {
        print('No backup found');
        return 0;
      }

      final backupData = json.decode(jsonString) as Map<String, dynamic>;
      final subscriptionsList = backupData['subscriptions'] as List;

      int restoredCount = 0;
      for (var subJson in subscriptionsList) {
        try {
          final abo = Abo.fromJson(subJson as Map<String, dynamic>);
          // Add to controller if not already exists
          final exists = controller.abos.any((a) => a.id == abo.id);
          if (!exists) {
            controller.addAbo(
              abo.name,
              abo.price,
              abo.isMonthly,
              abo.startDate,
              abo.endDate,
              category: abo.category,
              notes: abo.notes,
            );
            restoredCount++;
          }
        } catch (e) {
          print('Error restoring subscription: $e');
        }
      }

      print('Restore successful: $restoredCount subscriptions');
      return restoredCount;
    } catch (e) {
      print('Restore error: $e');
      return 0;
    }
  }

  /// Check if auto-backup is enabled.
  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auto_backup_enabled') ?? false;
  }

  /// Enable or disable auto-backup.
  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_backup_enabled', enabled);
  }

  /// Get last backup timestamp.
  Future<DateTime?> getLastBackupTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_backup_timestamp');
    
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    return null;
  }

  /// Export backup to file.
  Future<String> exportToFile(AboController controller) async {
    try {
      final abos = controller.abos;
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'subscriptions': abos.map((abo) => abo.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      
      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'abotrack_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);
      
      print('Export successful: ${file.path}');
      return file.path;
    } catch (e) {
      print('Export error: $e');
      rethrow;
    }
  }

  /// Import backup from file.
  Future<int> importFromFile(String filePath, AboController controller) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final jsonString = await file.readAsString();
      final backupData = json.decode(jsonString) as Map<String, dynamic>;
      final subscriptionsList = backupData['subscriptions'] as List;

      int importedCount = 0;
      for (var subJson in subscriptionsList) {
        try {
          final abo = Abo.fromJson(subJson as Map<String, dynamic>);
          // Add to controller if not already exists
          final exists = controller.abos.any((a) => a.id == abo.id);
          if (!exists) {
            controller.addAbo(
              abo.name,
              abo.price,
              abo.isMonthly,
              abo.startDate,
              abo.endDate,
              category: abo.category,
              notes: abo.notes,
            );
            importedCount++;
          }
        } catch (e) {
          print('Error importing subscription: $e');
        }
      }

      print('Import successful: $importedCount subscriptions');
      return importedCount;
    } catch (e) {
      print('Import error: $e');
      rethrow;
    }
  }

  /// Get backup file size.
  Future<int> getBackupSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_backupFileName);
      
      if (jsonString == null) {
        return 0;
      }
      
      return jsonString.length; // Approximate size in bytes
    } catch (e) {
      return 0;
    }
  }

  /// Logout.
  Future<void> logout() async {
    _isAuthenticated = false;
  }

  /// Check if authenticated.
  bool get isAuthenticated => _isAuthenticated;
}
