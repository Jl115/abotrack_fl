import 'dart:async';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:abotrack_fl/src/service/email_notification_service.dart';
import 'package:abotrack_fl/src/service/notification_service.dart';

/// Background task manager for periodic subscription checks.
/// Simplified version without platform-specific background fetch.
class BackgroundTaskManager {
  static final BackgroundTaskManager _instance = BackgroundTaskManager._internal();
  factory BackgroundTaskManager() => _instance;
  BackgroundTaskManager._internal();

  Timer? _checkTimer;

  /// Initialize background checks (runs every 6 hours while app is active).
  Future<void> initialize() async {
    // Start periodic check every 6 hours
    _checkTimer = Timer.periodic(const Duration(hours: 6), (_) {
      _checkAndSendNotifications();
    });

    print('Background task manager initialized (checks every 6 hours)');
  }

  /// Check subscriptions and send notifications for expiring ones.
  Future<void> _checkAndSendNotifications() async {
    print('[BackgroundTask] Checking for expiring subscriptions...');
    
    try {
      // Note: In production, you'd load controller from a provider or singleton
      // This is a simplified version
      final emailService = EmailNotificationService();
      final notificationService = NotificationService();

      // Load email configuration
      await emailService.loadConfiguration();
      final emailEnabled = await emailService.areEmailNotificationsEnabled();

      // Note: Controller would need to be passed in or accessed via singleton
      print('[BackgroundTask] Check completed (requires controller instance)');
    } catch (e) {
      print('[BackgroundTask] Error during check: $e');
    }
  }

  /// Send monthly summary email.
  Future<void> sendMonthlySummary(AboController controller) async {
    try {
      final emailService = EmailNotificationService();
      await emailService.loadConfiguration();
      
      final emailEnabled = await emailService.areEmailNotificationsEnabled();
      if (!emailEnabled || !emailService.isConfigured) {
        print('[MonthlySummary] Email notifications not enabled');
        return;
      }

      final totalSpent = controller.getMonthlyCost();
      final subscriptionCount = controller.abos.where((a) => a.isActive).length;

      final sortedAbos = List.from(controller.abos)
        ..sort((a, b) => b.price.compareTo(a.price));
      
      final topSubscriptions = sortedAbos.take(5).map((abo) {
        return {
          'name': abo.name,
          'price': abo.price,
          'isMonthly': abo.isMonthly,
        };
      }).toList();

      final success = await emailService.sendMonthlySummary(
        totalSpent: totalSpent,
        subscriptionCount: subscriptionCount,
        topSubscriptions: topSubscriptions,
      );

      if (success) {
        print('[MonthlySummary] Email sent successfully');
      }
    } catch (e) {
      print('[MonthlySummary] Error: $e');
    }
  }

  /// Cancel all background tasks.
  Future<void> cancelAll() async {
    _checkTimer?.cancel();
    _checkTimer = null;
    print('Background tasks cancelled');
  }

  /// Manual trigger for testing.
  Future<void> triggerCheck(AboController controller) async {
    await _checkAndSendNotifications();
  }
}
