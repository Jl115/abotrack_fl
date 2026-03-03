import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:abotrack_fl/src/service/cloud_backup_service.dart';
import 'package:intl/intl.dart';

/// Cloud backup settings component.
class CloudBackupSettingsComponent extends StatefulWidget {
  const CloudBackupSettingsComponent({super.key});

  @override
  State<CloudBackupSettingsComponent> createState() => _CloudBackupSettingsComponentState();
}

class _CloudBackupSettingsComponentState extends State<CloudBackupSettingsComponent> {
  final CloudBackupService _backupService = CloudBackupService();
  bool _isAuthenticated = false;
  bool _isAutoBackupEnabled = false;
  bool _isLoading = true;
  DateTime? _lastBackupDate;

  @override
  void initState() {
    super.initState();
    _loadBackupSettings();
  }

  Future<void> _loadBackupSettings() async {
    setState(() => _isLoading = true);
    
    try {
      await _backupService.loadAuthentication();
      final isAuthenticated = _backupService.isAuthenticated;
      final isAutoBackup = await _backupService.isAutoBackupEnabled();
      final lastBackup = await _backupService.getLastBackupTimestamp();
      
      setState(() {
        _isAuthenticated = isAuthenticated;
        _isAutoBackupEnabled = isAutoBackup;
        _lastBackupDate = lastBackup;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading backup settings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _authenticate() async {
    final success = await _backupService.authenticate();
    
    if (mounted) {
      setState(() {
        _isAuthenticated = success;
      });
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected to Google Drive successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect to Google Drive'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _backup() async {
    if (!_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to Google Drive first')),
      );
      return;
    }

    final controller = context.read<AboController>();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success = await _backupService.backupToCloud(controller);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadBackupSettings(); // Refresh settings
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _restore() async {
    if (!_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to Google Drive first')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace your current subscriptions with the backup from Google Drive. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final controller = context.read<AboController>();
      final success = await _backupService.restoreFromCloud(controller);
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restore completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restore failed. No backup found.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleAutoBackup() async {
    if (!_isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to Google Drive first')),
      );
      return;
    }

    await _backupService.setAutoBackupEnabled(!_isAutoBackupEnabled);
    
    if (mounted) {
      setState(() {
        _isAutoBackupEnabled = !_isAutoBackupEnabled;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isAutoBackupEnabled
                ? 'Auto-backup enabled (weekly)'
                : 'Auto-backup disabled',
          ),
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disconnect Google Drive'),
        content: const Text('Are you sure you want to disconnect?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _backupService.logout();
    
    if (mounted) {
      setState(() {
        _isAuthenticated = false;
        _isAutoBackupEnabled = false;
        _lastBackupDate = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected from Google Drive')),
      );
    }
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
                Icons.cloud_outlined,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Cloud Backup',
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
                  'Backup your subscriptions to Google Drive',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Connection Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isAuthenticated
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isAuthenticated
                          ? Colors.green.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isAuthenticated
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        color: _isAuthenticated ? Colors.green : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isAuthenticated ? 'Connected' : 'Not Connected',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _isAuthenticated
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            if (_lastBackupDate != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Last backup: ${DateFormat('MMM d, y HH:mm').format(_lastBackupDate!)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _isAuthenticated
                                      ? Colors.green.withOpacity(0.8)
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (_isAuthenticated)
                        IconButton(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          tooltip: 'Disconnect',
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                if (!_isAuthenticated)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _authenticate,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Connect Google Drive'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _backup,
                              icon: const Icon(Icons.backup),
                              label: const Text('Backup Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _restore,
                              icon: const Icon(Icons.restore),
                              label: const Text('Restore'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: theme.primaryColor,
                                side: BorderSide(color: theme.primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Auto-backup Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.autorenew,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Auto-backup (weekly)',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          Switch(
                            value: _isAutoBackupEnabled,
                            onChanged: (_) => _toggleAutoBackup(),
                            activeColor: theme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                
                const SizedBox(height: 16),
                
                // Info Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Backups are encrypted and stored securely in your Google Drive',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
