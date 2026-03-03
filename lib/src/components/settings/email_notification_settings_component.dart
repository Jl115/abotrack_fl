import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/settings_controller.dart';
import '../../service/email_notification_service.dart';

/// Email notification settings component.
class EmailNotificationSettingsComponent extends StatefulWidget {
  const EmailNotificationSettingsComponent({super.key});

  @override
  State<EmailNotificationSettingsComponent> createState() => _EmailNotificationSettingsComponentState();
}

class _EmailNotificationSettingsComponentState extends State<EmailNotificationSettingsComponent> {
  final EmailNotificationService _emailService = EmailNotificationService();
  bool _isEnabled = false;
  bool _isConfigured = false;
  bool _isLoading = true;
  
  final _smtpController = TextEditingController();
  final _portController = TextEditingController(text: '587');
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _recipientController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      await _emailService.loadConfiguration();
      final enabled = await _emailService.areEmailNotificationsEnabled();
      
      setState(() {
        _isEnabled = enabled;
        _isConfigured = _emailService.isConfigured;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading email settings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleEmailNotifications() async {
    if (!_isConfigured && !_isEnabled) {
      _showConfigurationDialog();
      return;
    }

    await _emailService.setEmailNotificationsEnabled(!_isEnabled);
    
    if (mounted) {
      setState(() {
        _isEnabled = !_isEnabled;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEnabled 
                ? 'Email notifications enabled' 
                : 'Email notifications disabled',
          ),
        ),
      );
    }
  }

  void _showConfigurationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configure Email Notifications'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _smtpController,
                  decoration: InputDecoration(
                    labelText: 'SMTP Server',
                    hintText: 'smtp.gmail.com',
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter SMTP server';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _portController,
                  decoration: const InputDecoration(
                    labelText: 'SMTP Port',
                    hintText: '587',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter port';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'your@email.com',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password/App Password',
                    hintText: '••••••••',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _recipientController,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Email',
                    hintText: 'recipient@email.com',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter recipient email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Note: For Gmail, use an App Password from your Google Account settings.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await _emailService.configureSmtp(
                    smtpServer: _smtpController.text,
                    smtpPort: int.parse(_portController.text),
                    username: _usernameController.text,
                    password: _passwordController.text,
                    recipientEmail: _recipientController.text,
                  );
                  
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    setState(() {
                      _isConfigured = true;
                      _isEnabled = true;
                    });
                    _emailService.setEmailNotificationsEnabled(true);
                    
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Email notifications configured successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Theme.of(ctx).colorScheme.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save'),
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
                Icons.email_outlined,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Email Notifications',
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
                  'Receive renewal reminders and summaries via email',
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
                          _isEnabled ? Icons.notifications_active : Icons.notifications_off,
                          color: _isEnabled ? theme.primaryColor : theme.disabledColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isEnabled ? 'Enabled' : 'Disabled',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _isEnabled ? theme.primaryColor : theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isEnabled,
                      onChanged: (_) => _toggleEmailNotifications(),
                      activeColor: theme.primaryColor,
                    ),
                  ],
                ),
                
                if (_isConfigured) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: theme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Email notifications are configured and active',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _showConfigurationDialog,
                          child: const Text('Edit'),
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

  @override
  void dispose() {
    _smtpController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _recipientController.dispose();
    super.dispose();
  }
}
