import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/settings_controller.dart';
import '../../service/biometric_service.dart';

/// Security settings component for biometric authentication.
class SecuritySettingsComponent extends StatefulWidget {
  const SecuritySettingsComponent({super.key});

  @override
  State<SecuritySettingsComponent> createState() => _SecuritySettingsComponentState();
}

class _SecuritySettingsComponentState extends State<SecuritySettingsComponent> {
  final BiometricService _biometricService = BiometricService();
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final available = await _biometricService.isBiometricAvailable();
      final enrolled = await _biometricService.isBiometricEnrolled();
      final enabled = await _biometricService.isBiometricLockEnabled();
      
      setState(() {
        _isBiometricAvailable = available && enrolled;
        _isBiometricEnabled = enabled;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading biometric status: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBiometricLock() async {
    if (!_isBiometricAvailable) {
      _showBiometricNotAvailableDialog();
      return;
    }

    if (!_isBiometricEnabled) {
      // Enable biometric lock - require authentication first
      final result = await _biometricService.authenticateWithResult();
      
      if (!result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.error ?? 'Authentication failed'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }
    }

    // Toggle the setting
    await _biometricService.setBiometricLockEnabled(!_isBiometricEnabled);
    
    if (mounted) {
      setState(() {
        _isBiometricEnabled = !_isBiometricEnabled;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBiometricEnabled 
                ? 'Biometric lock enabled' 
                : 'Biometric lock disabled',
          ),
        ),
      );
    }
  }

  void _showBiometricNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Biometric Not Available'),
        content: const Text(
          'No biometric credentials enrolled. Please set up fingerprint or face recognition in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fingerprint,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Biometric Lock',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Require biometric authentication to open the app',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isBiometricEnabled 
                              ? Icons.lock 
                              : Icons.lock_open,
                          color: _isBiometricEnabled 
                              ? theme.primaryColor 
                              : theme.disabledColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isBiometricEnabled ? 'Enabled' : 'Disabled',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isBiometricEnabled 
                                ? theme.primaryColor 
                                : theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isBiometricEnabled,
                      onChanged: (_) => _toggleBiometricLock(),
                      activeColor: theme.primaryColor,
                    ),
                  ],
                ),
                
                if (!_isBiometricAvailable) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Biometric authentication not available. Please set up fingerprint or face recognition in device settings.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
