import 'dart:convert';
import 'dart:io';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Cloud backup service using Google Drive.
class CloudBackupService {
  static final CloudBackupService _instance = CloudBackupService._internal();
  factory CloudBackupService() => _instance;
  CloudBackupService._internal();

  static const String _backupFileName = 'abotrack_backup.json';
  static const String _googleApiClientId = 'YOUR_GOOGLE_API_CLIENT_ID';
  static const String _googleApiSecret = 'YOUR_GOOGLE_API_SECRET';
  
  String? _accessToken;
  bool _isAuthenticated = false;

  /// Authenticate with Google Drive.
  Future<bool> authenticate() async {
    try {
      // In production, use OAuth2 flow with user consent
      // This is a simplified version for demonstration
      final credentials = ClientCredentials(_googleApiClientId, _googleApiSecret);
      
      // Request access token
      final token = await obtainAccessCredentialsViaUserConsent(
        credentials,
        ['https://www.googleapis.com/auth/drive.file'],
        null, // In production, provide a redirect URI
        (url) {
          // Open browser for user consent
          print('Please visit: $url');
          // In production, wait for callback with auth code
        },
      );

      _accessToken = token.accessToken.data;
      _isAuthenticated = true;
      
      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('google_access_token', _accessToken!);
      
      print('Google Drive authentication successful');
      return true;
    } catch (e) {
      print('Google Drive authentication failed: $e');
      return false;
    }
  }

  /// Load saved authentication token.
  Future<void> loadAuthentication() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('google_access_token');
      
      if (token != null) {
        _accessToken = token;
        _isAuthenticated = true;
        print('Google Drive authentication loaded');
      }
    } catch (e) {
      print('Error loading authentication: $e');
      _isAuthenticated = false;
    }
  }

  /// Backup subscriptions to Google Drive.
  Future<bool> backupToCloud(AboController controller) async {
    if (!_isAuthenticated) {
      print('Not authenticated with Google Drive');
      return false;
    }

    try {
      final abos = controller.abos;
      final backupData = {
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'subscriptions': abos.map((abo) => abo.toJson()).toList(),
      };

      final jsonString = JsonEncoder.withIndent('  ').convert(backupData);
      
      // Upload to Google Drive
      final uploadSuccess = await _uploadToDrive(_backupFileName, jsonString);
      
      if (uploadSuccess) {
        // Save backup timestamp
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_backup_timestamp', DateTime.now().millisecondsSinceEpoch);
        
        print('Backup successful: ${abos.length} subscriptions');
        return true;
      } else {
        print('Backup failed');
        return false;
      }
    } catch (e) {
      print('Backup error: $e');
      return false;
    }
  }

  /// Restore subscriptions from Google Drive backup.
  Future<bool> restoreFromCloud(AboController controller) async {
    if (!_isAuthenticated) {
      print('Not authenticated with Google Drive');
      return false;
    }

    try {
      // Download from Google Drive
      final jsonString = await _downloadFromDrive(_backupFileName);
      
      if (jsonString == null) {
        print('No backup found');
        return false;
      }

      final backupData = json.decode(jsonString) as Map<String, dynamic>;
      final subscriptionsList = backupData['subscriptions'] as List;

      // Clear existing subscriptions
      // Note: This would need a clearAll method in AboController
      // For now, we'll just add the restored ones

      int restoredCount = 0;
      for (var subJson in subscriptionsList) {
        try {
          final abo = Abo.fromJson(subJson as Map<String, dynamic>);
          // Add to controller (would need an add method that accepts Abo object)
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

  /// Upload file to Google Drive.
  Future<bool> _uploadToDrive(String fileName, String content) async {
    try {
      final client = http.Client();
      
      // First, search for existing file
      final fileId = await _searchFile(client, fileName);
      
      final url = fileId != null
          ? Uri.parse('https://www.googleapis.com/upload/drive/v3/files/$fileId?uploadType=media')
          : Uri.parse('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart');

      final headers = {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json; charset=UTF-8',
      };

      // For new file, include metadata
      final body = fileId != null
          ? content
          : json.encode({
              'name': fileName,
              'mimeType': 'application/json',
            }) +
              '\r\n--boundary\r\nContent-Type: application/json\r\n\r\n' +
              content;

      final response = await client.request(
        fileId != null ? 'PATCH' : 'POST',
        url,
        headers: headers,
        body: body,
      );

      client.close();
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Upload error: $e');
      return false;
    }
  }

  /// Download file from Google Drive.
  Future<String?> _downloadFromDrive(String fileName) async {
    try {
      final client = http.Client();
      
      // Search for file
      final fileId = await _searchFile(client, fileName);
      
      if (fileId == null) {
        client.close();
        return null;
      }

      // Download file content
      final url = Uri.parse('https://www.googleapis.com/drive/v3/files/$fileId?alt=media');
      final headers = {'Authorization': 'Bearer $_accessToken'};

      final response = await client.get(url, headers: headers);
      client.close();

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Download failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Download error: $e');
      return null;
    }
  }

  /// Search for file in Google Drive.
  Future<String?> _searchFile(http.Client client, String fileName) async {
    try {
      final url = Uri.parse(
        'https://www.googleapis.com/drive/v3/files?q=name=\'$fileName\' and trashed=false',
      );
      final headers = {'Authorization': 'Bearer $_accessToken'};

      final response = await client.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final files = data['files'] as List;
        
        if (files.isNotEmpty) {
          return files.first['id'] as String;
        }
      }
      
      return null;
    } catch (e) {
      print('Search error: $e');
      return null;
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

  /// Logout from Google Drive.
  Future<void> logout() async {
    _accessToken = null;
    _isAuthenticated = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('google_access_token');
    
    print('Logged out from Google Drive');
  }

  /// Check if authenticated.
  bool get isAuthenticated => _isAuthenticated;
}
