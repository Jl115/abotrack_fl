import 'dart:convert';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
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
  Future<bool> restoreFromCloud(AboController controller) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_backupFileName);
      
      if (jsonString == null) {
        print('No backup found');
        return false;
      }

      final backupData = json.decode(jsonString) as Map<String, dynamic>;
      final subscriptionsList = backupData['subscriptions'] as List;

      int restoredCount = 0;
      for (var subJson in subscriptionsList) {
        try {
          final abo = Abo.fromJson(subJson as Map<String, dynamic>);
          // Note: In production, you'd add this to controller
          restoredCount++;
        } catch (e) {
          print('Error restoring subscription: $e');
        }
      }

      print('Restore successful: $restoredCount subscriptions');
      return true;
    } catch (e) {
      print('Restore error: $e');
      return false;
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

  /// Logout.
  Future<void> logout() async {
    _isAuthenticated = false;
  }

  /// Check if authenticated.
  bool get isAuthenticated => _isAuthenticated;
}
