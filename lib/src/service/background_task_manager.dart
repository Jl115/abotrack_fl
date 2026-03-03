import 'dart:async';
import 'dart:io';

import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:abotrack_fl/src/service/email_notification_service.dart';
import 'package:abotrack_fl/src/service/notification_service.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

/// Background task manager for periodic subscription checks and notifications.
class BackgroundTaskManager {
  static final BackgroundTaskManager _instance = BackgroundTaskManager._internal();
  factory BackgroundTaskManager() => _instance;
  BackgroundTaskManager._internal();

  /// Initialize background tasks.
  Future<void> initialize() async {
    // Initialize WorkManager for periodic tasks
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // Set to false in production
    );

    // Register periodic check for expiring subscriptions
    await Workmanager().registerPeriodicTask(
      'subscription-check',
      'checkExpiringSubscriptions',
      frequency: const Duration(hours: 6), // Check every 6 hours
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
      ),
    );

    // Initialize BackgroundFetch for iOS
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // Minimum 15 minutes on iOS
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotCharging: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      _onBackgroundFetch,
      _onBackgroundFetchTimeout,
    );

    print('Background tasks initialized');
  }

  /// Background fetch callback for iOS.
  Future<void> _onBackgroundFetch(String taskId) async {
    print('[BackgroundFetch] Event received: $taskId');
    
    try {
      await _checkAndSendNotifications();
      BackgroundFetch.finish(taskId);
    } catch (e) {
      print('[BackgroundFetch] Error: $e');
      BackgroundFetch.finish(taskId);
    }
  }

  /// Background fetch timeout callback.
  void _onBackgroundFetchTimeout(String taskId) {
    print('[BackgroundFetch] TIMEOUT: $taskId');
    BackgroundFetch.finish(taskId);
  }

  /// Check subscriptions and send notifications for expiring ones.
  Future<void> _checkAndSendNotifications() async {
    print('[BackgroundTask] Checking for expiring subscriptions...');
    
    try {
      // Load subscriptions
      final controller = AboController();
      await controller.loadAbos();

      final now = DateTime.now();
      final emailService = EmailNotificationService();
      final notificationService = NotificationService();

      // Load email configuration
      await emailService.loadConfiguration();
      final emailEnabled = await emailService.areEmailNotificationsEnabled();

      for (final abo in controller.abos) {
        final daysUntil = abo.endDate.difference(now).inDays;

        // Send notifications for subscriptions expiring within 7 days
        if (abo.expiresSoon && abo.isActive) {
          // Local push notification
          await notificationService.scheduleExpiringReminder(
            subscriptionName: abo.name,
            daysUntilExpiration: daysUntil,
            subscriptionId: abo.id,
          );

          // Email notification (if enabled)
          if (emailEnabled && emailService.isConfigured) {
            await emailService.sendExpirationWarning(
              subscriptionName: abo.name,
              price: abo.price,
              daysUntilExpiration: daysUntil,
            );
          }

          print('[BackgroundTask] Notification sent for: ${abo.name} (expires in $daysUntil days)');
        }

        // Send renewal reminder 3 days before renewal (for monthly subs)
        if (abo.isMonthly && daysUntil == 3 && abo.isActive) {
          if (emailEnabled && emailService.isConfigured) {
            await emailService.sendRenewalReminder(
              subscriptionName: abo.name,
              price: abo.price,
              isMonthly: true,
              daysUntilRenewal: daysUntil,
              renewalDate: abo.endDate.toLocal().toString().split(' ')[0],
            );
          }
        }
      }

      print('[BackgroundTask] Check completed successfully');
    } catch (e) {
      print('[BackgroundTask] Error during check: $e');
    }
  }

  /// Send monthly summary email (to be called on the 1st of each month).
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

      // Get top subscriptions by price
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
      } else {
        print('[MonthlySummary] Failed to send email');
      }
    } catch (e) {
      print('[MonthlySummary] Error: $e');
    }
  }

  /// Cancel all registered background tasks.
  Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    await BackgroundFetch.stop();
    print('All background tasks cancelled');
  }
}

/// WorkManager callback dispatcher (must be top-level function).
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('[WorkManager] Task received: $task');
    
    switch (task) {
      case 'checkExpiringSubscriptions':
        final manager = BackgroundTaskManager();
        // Note: Can't use AboController directly here due to isolate limitations
        // In production, you'd need to load data from SharedPreferences or a database
        print('[WorkManager] Checking expiring subscriptions...');
        break;
      
      default:
        print('[WorkManager] Unknown task: $task');
    }
    
    return Future.value(true);
  });
}
