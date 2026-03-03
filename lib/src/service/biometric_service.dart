import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing biometric authentication.
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if biometric authentication is available on the device.
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Check if biometrics are enrolled on the device.
  Future<bool> isBiometricEnrolled() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('Error checking biometric enrollment: $e');
      return false;
    }
  }

  /// Get available biometric types.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate user with biometrics.
  Future<bool> authenticate({
    String reason = 'Please authenticate to access AboTrack',
    String? localizedReason,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('Biometric authentication not available');
        return false;
      }

      final enrolled = await isBiometricEnrolled();
      if (!enrolled) {
        print('No biometric credentials enrolled');
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason ?? reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }

  /// Check if biometric lock is enabled.
  Future<bool> isBiometricLockEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('biometric_lock_enabled') ?? false;
    } catch (e) {
      print('Error checking biometric lock status: $e');
      return false;
    }
  }

  /// Enable or disable biometric lock.
  Future<void> setBiometricLockEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_lock_enabled', enabled);
    } catch (e) {
      print('Error setting biometric lock status: $e');
      rethrow;
    }
  }

  /// Authenticate with biometrics and return success status.
  Future<BiometricAuthResult> authenticateWithResult() async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return BiometricAuthResult(
          success: false,
          error: 'Biometric authentication not available on this device',
        );
      }

      final enrolled = await isBiometricEnrolled();
      if (!enrolled) {
        return BiometricAuthResult(
          success: false,
          error: 'No biometric credentials enrolled. Please set up fingerprint or face recognition in device settings.',
        );
      }

      final didAuthenticate = await authenticate();
      
      if (didAuthenticate) {
        return BiometricAuthResult(success: true);
      } else {
        return BiometricAuthResult(
          success: false,
          error: 'Authentication failed. Please try again.',
        );
      }
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        error: 'Authentication error: ${e.toString()}',
      );
    }
  }
}

/// Result of biometric authentication attempt.
class BiometricAuthResult {
  final bool success;
  final String? error;

  BiometricAuthResult({
    required this.success,
    this.error,
  });
}
