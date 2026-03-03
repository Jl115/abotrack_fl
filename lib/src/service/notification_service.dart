import 'dart:io';
import 'dart:io' show Platform;

import 'package:abotrack_fl/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'abo_controller.dart';

/// Service for managing local notifications for subscription reminders.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialize the notification service.
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize for Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Initialize for iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap.
  void _onNotificationTapped(NotificationResponse response) {
    // Navigate to dashboard when notification is tapped
    final navigatorKey = GlobalKey<NavigatorState>();
    navigatorKey.currentState?.pushNamed('/dashboard');
  }

  /// Request notification permissions.
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(alert: true, badge: true, sound: true);
        return granted ?? false;
      }
    }
    
    return false;
  }

  /// Schedule a reminder for a subscription expiring soon.
  Future<void> scheduleExpiringReminder({
    required String subscriptionName,
    required int daysUntilExpiration,
    required String subscriptionId,
  }) async {
    if (!_isInitialized) await init();
    await requestPermissions();

    const androidDetails = AndroidNotificationDetails(
      'expiring_subscriptions',
      'Expiring Subscriptions',
      channelDescription: 'Reminders for subscriptions expiring soon',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(
      subscriptionId.hashCode,
      'Subscription Expiring Soon!',
      '$subscriptionName expires in $daysUntilExpiration days',
      details,
      payload: subscriptionId,
    );
  }

  /// Schedule a daily reminder for all expiring subscriptions.
  Future<void> scheduleDailyReminders(AboController controller) async {
    if (!_isInitialized) await init();
    
    final now = DateTime.now();
    
    for (final abo in controller.abos) {
      if (abo.expiresSoon && abo.isActive) {
        await scheduleExpiringReminder(
          subscriptionName: abo.name,
          daysUntilExpiration: abo.daysUntilExpiration,
          subscriptionId: abo.id,
        );
      }
    }
  }

  /// Cancel a specific notification.
  Future<void> cancelNotification(String subscriptionId) async {
    await _notifications.cancel(subscriptionId.hashCode);
  }

  /// Cancel all notifications.
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Check if notifications are enabled.
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Set notification preference.
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }
}
