import 'dart:io';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for sending email notifications about subscription renewals.
class EmailNotificationService {
  static final EmailNotificationService _instance = EmailNotificationService._internal();
  factory EmailNotificationService() => _instance;
  EmailNotificationService._internal();

  String? _smtpServer;
  String? _smtpUsername;
  String? _smtpPassword;
  String? _recipientEmail;
  bool _isConfigured = false;

  /// Check if email notifications are enabled.
  Future<bool> areEmailNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('email_notifications_enabled') ?? false;
  }

  /// Enable or disable email notifications.
  Future<void> setEmailNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('email_notifications_enabled', enabled);
  }

  /// Configure SMTP server settings.
  Future<void> configureSmtp({
    required String smtpServer,
    required int smtpPort,
    required String username,
    required String password,
    required String recipientEmail,
    bool useSsl = true,
  }) async {
    try {
      final smtp = SmtpServer(
        smtpServer,
        port: smtpPort,
        username: username,
        password: password,
        ssl: useSsl,
        ignoreBadCertificate: false,
      );

      _smtpServer = smtpServer;
      _smtpUsername = username;
      _smtpPassword = password;
      _recipientEmail = recipientEmail;
      _isConfigured = true;

      // Save configuration (in production, encrypt these!)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('smtp_server', smtpServer);
      await prefs.setInt('smtp_port', smtpPort);
      await prefs.setString('smtp_username', username);
      await prefs.setString('smtp_password', password);
      await prefs.setString('recipient_email', recipientEmail);
      await prefs.setBool('use_ssl', useSsl);

      print('SMTP configured successfully');
    } catch (e) {
      print('Error configuring SMTP: $e');
      rethrow;
    }
  }

  /// Load SMTP configuration from storage.
  Future<void> loadConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final server = prefs.getString('smtp_server');
      final port = prefs.getInt('smtp_port') ?? 587;
      final username = prefs.getString('smtp_username');
      final password = prefs.getString('smtp_password');
      final recipient = prefs.getString('recipient_email');
      final useSsl = prefs.getBool('use_ssl') ?? true;

      if (server != null && username != null && password != null && recipient != null) {
        _smtpServer = server;
        _smtpUsername = username;
        _smtpPassword = password;
        _recipientEmail = recipient;
        _isConfigured = true;
        print('SMTP configuration loaded');
      } else {
        _isConfigured = false;
        print('No SMTP configuration found');
      }
    } catch (e) {
      print('Error loading SMTP configuration: $e');
      _isConfigured = false;
    }
  }

  /// Send a renewal reminder email.
  Future<bool> sendRenewalReminder({
    required String subscriptionName,
    required double price,
    required bool isMonthly,
    required int daysUntilRenewal,
    required String renewalDate,
  }) async {
    if (!_isConfigured) {
      print('SMTP not configured');
      return false;
    }

    try {
      final smtp = SmtpServer(
        _smtpServer!,
        port: 587,
        username: _smtpUsername,
        password: _smtpPassword,
        ssl: true,
        ignoreBadCertificate: false,
      );

      final message = Message()
        ..from = Address(_smtpUsername!, 'AboTrack')
        ..recipients.add(_recipientEmail!)
        ..subject = '🔔 Subscription Renewal Reminder: $subscriptionName'
        ..html = _buildRenewalEmailHtml(
          subscriptionName,
          price,
          isMonthly,
          daysUntilRenewal,
          renewalDate,
        );

      await send(message, smtp);
      print('Renewal reminder email sent for $subscriptionName');
      return true;
    } catch (e) {
      print('Error sending renewal reminder email: $e');
      return false;
    }
  }

  /// Send expiration warning email.
  Future<bool> sendExpirationWarning({
    required String subscriptionName,
    required double price,
    required int daysUntilExpiration,
  }) async {
    if (!_isConfigured) {
      print('SMTP not configured');
      return false;
    }

    try {
      final smtp = SmtpServer(
        _smtpServer!,
        port: 587,
        username: _smtpUsername,
        password: _smtpPassword,
        ssl: true,
        ignoreBadCertificate: false,
      );

      final message = Message()
        ..from = Address(_smtpUsername!, 'AboTrack')
        ..recipients.add(_recipientEmail!)
        ..subject = '⚠️ Subscription Expiring Soon: $subscriptionName'
        ..html = _buildExpirationEmailHtml(
          subscriptionName,
          price,
          daysUntilExpiration,
        );

      await send(message, smtp);
      print('Expiration warning email sent for $subscriptionName');
      return true;
    } catch (e) {
      print('Error sending expiration warning email: $e');
      return false;
    }
  }

  /// Send monthly spending summary email.
  Future<bool> sendMonthlySummary({
    required double totalSpent,
    required int subscriptionCount,
    required List<Map<String, dynamic>> topSubscriptions,
  }) async {
    if (!_isConfigured) {
      print('SMTP not configured');
      return false;
    }

    try {
      final smtp = SmtpServer(
        _smtpServer!,
        port: 587,
        username: _smtpUsername,
        password: _smtpPassword,
        ssl: true,
        ignoreBadCertificate: false,
      );

      final message = Message()
        ..from = Address(_smtpUsername!, 'AboTrack')
        ..recipients.add(_recipientEmail!)
        ..subject = '📊 Your Monthly Subscription Summary'
        ..html = _buildMonthlySummaryEmailHtml(
          totalSpent,
          subscriptionCount,
          topSubscriptions,
        );

      await send(message, smtp);
      print('Monthly summary email sent');
      return true;
    } catch (e) {
      print('Error sending monthly summary email: $e');
      return false;
    }
  }

  String _buildRenewalEmailHtml(
    String name,
    double price,
    bool isMonthly,
    int days,
    String date,
  ) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .highlight { background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0; }
          .button { display: inline-block; background: #667eea; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; margin-top: 20px; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🔔 Renewal Reminder</h1>
          </div>
          <div class="content">
            <h2>$name</h2>
            <p>Your subscription is renewing soon!</p>
            <div class="highlight">
              <strong>⏰ Renewing in $days days</strong><br>
              <strong>📅 Date:</strong> $date<br>
              <strong>💰 Price:</strong> \$${price.toStringAsFixed(2)} ${isMonthly ? '/month' : '/year'}
            </div>
            <p>Make sure you have sufficient funds available for the upcoming renewal.</p>
            <p style="text-align: center;">
              <a href="#" class="button">View in AboTrack</a>
            </p>
          </div>
          <div class="footer">
            <p>Sent by AboTrack - Your Subscription Manager</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _buildExpirationEmailHtml(
    String name,
    double price,
    int days,
  ) {
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          .warning { background: #f8d7da; border-left: 4px solid #dc3545; padding: 15px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>⚠️ Expiring Soon</h1>
          </div>
          <div class="content">
            <h2>$name</h2>
            <div class="warning">
              <strong>⏰ Expires in $days days!</strong><br>
              <strong>💰 Cost:</strong> \$${price.toStringAsFixed(2)}
            </div>
            <p>This subscription will expire soon. Decide if you want to renew or cancel.</p>
          </div>
          <div class="footer">
            <p>Sent by AboTrack - Your Subscription Manager</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  String _buildMonthlySummaryEmailHtml(
    double total,
    int count,
    List<Map<String, dynamic>> topSubs,
  ) {
    final topSubsHtml = topSubs.map((sub) => '''
      <tr>
        <td style="padding: 10px; border-bottom: 1px solid #eee;">${sub['name']}</td>
        <td style="padding: 10px; border-bottom: 1px solid #eee; text-align: right;">\$${(sub['price'] as double).toStringAsFixed(2)}</td>
      </tr>
    ''').join('');

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
          table { width: 100%; border-collapse: collapse; margin: 20px 0; background: white; }
          .stat-box { display: inline-block; background: white; padding: 20px; margin: 10px; border-radius: 10px; text-align: center; min-width: 150px; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📊 Monthly Summary</h1>
          </div>
          <div class="content">
            <h2>Your Subscription Overview</h2>
            <div style="text-align: center;">
              <div class="stat-box">
                <div style="font-size: 24px; font-weight: bold; color: #4facfe;">\$${total.toStringAsFixed(2)}</div>
                <div style="color: #666;">Total Spent</div>
              </div>
              <div class="stat-box">
                <div style="font-size: 24px; font-weight: bold; color: #4facfe;">$count</div>
                <div style="color: #666;">Active Subscriptions</div>
              </div>
            </div>
            <h3>Top Subscriptions:</h3>
            <table>
              $topSubsHtml
            </table>
          </div>
          <div class="footer">
            <p>Sent by AboTrack - Your Subscription Manager</p>
          </div>
        </div>
      </body>
      </html>
    ''';
  }

  /// Clear SMTP configuration.
  Future<void> clearConfiguration() async {
    _smtpServer = null;
    _smtpUsername = null;
    _smtpPassword = null;
    _recipientEmail = null;
    _isConfigured = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('smtp_server');
    await prefs.remove('smtp_port');
    await prefs.remove('smtp_username');
    await prefs.remove('smtp_password');
    await prefs.remove('recipient_email');
    await prefs.remove('use_ssl');

    print('SMTP configuration cleared');
  }

  /// Check if SMTP is configured.
  bool get isConfigured => _isConfigured;
}
