import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:abotrack_fl/src/controller/settings_controller.dart';
import 'package:abotrack_fl/src/service/settings_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart' as wm;
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:background_fetch/background_fetch.dart';
import 'package:path_provider/path_provider.dart';
import 'src/app.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Define the navigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Callback to be executed when a Workmanager task is scheduled.
///
/// Tasks are used to run code in the background. This callback is
/// responsible for scheduling a local notification when a task is
/// triggered (e.g. when a subscription is expiring soon).
void callbackDispatcher() {
  wm.Workmanager().executeTask((task, inputData) async {
    _showNotification(
        "Subscription Expiring Soon", "Check your subscriptions!");
    return Future.value(true);
  });
}

/// Shows a local notification with the given title and body.
///
/// This function is used in the Workmanager callback to notify the user
/// when a subscription is expiring soon.
///
/// [title] is the title of the notification.
///
/// [body] is the body of the notification.
Future<void> _showNotification(String title, String body) async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'abonnement_expiring_check',
    'Abonnements Expiring Check',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
  );
}

/// Called when a background fetch event is triggered.
///
/// This function is called by the BackgroundFetch plugin when a background
/// fetch event is triggered. It shows a local notification to indicate that
/// the event was triggered and then calls [BackgroundFetch.finish] to
/// complete the event.
void backgroundFetchHeadlessTask(String taskId) async {
  print("[BackgroundFetch] Headless event received.");
  _showNotification("Background Fetch", "Background fetch event triggered!");
  BackgroundFetch.finish(taskId);
}

/// The main entry point of the application.
///
/// This function is the main entry point of the application. It initializes the
/// application, loads the settings and the abonnement data, initializes the
/// local notification plugin, and then runs the application.
///
/// On Android, it also registers a periodic task using the WorkManager plugin
/// to check for expiring abonnements every 15 minutes.
///
/// On iOS, it configures the background fetch plugin to fetch the abonnement
/// data every 15 minutes, and registers a headless background task to handle
/// the background fetch event.
///
/// Finally, it runs the application using the [MaterialApp] widget.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  final aboController = AboController();
  await aboController.loadAbos();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    onDidReceiveLocalNotification: (id, title, body, payload) async {
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: Text(title ?? 'Notification'),
          content: Text(body ?? 'You have a new notification'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    },
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final payload = response.payload;
      if (payload != null) {
        Navigator.push(
          navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => const MyApp()),
        );
      }
    },
  );

  if (Platform.isAndroid) {
    // Android-specific notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'abonnement_expiring_check',
      'Abonnements Expiring Check',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    PermissionStatus status = await Permission.notification.request();
    if (!status.isGranted) {
      print("Notification permission not granted");
    }

    // Register periodic tasks only on Android
    wm.Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    wm.Workmanager().registerPeriodicTask(
      "1",
      "checkExpiringSubscriptions",
      frequency: const Duration(
          minutes: 15), // Minimum interval supported by WorkManager
      initialDelay: _calculateInitialDelay(),
      constraints: wm.Constraints(
        networkType: wm.NetworkType.not_required,
        requiresBatteryNotLow: true,
        requiresCharging: false,
        requiresDeviceIdle: false,
      ),
    );
  } else if (Platform.isIOS) {
    // Configure background fetch for iOS
    BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,
          stopOnTerminate: false,
          enableHeadless: true,
        ), (taskId) async {
      // This callback is executed when the app is in the background
      print("[BackgroundFetch] Event received: $taskId");
      _showNotification("Background Fetch Notification",
          "This is a background fetch notification.");
      BackgroundFetch.finish(taskId);
    });

    // Register headless background task
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => settingsController),
        ChangeNotifierProvider.value(value: aboController),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: MyApp(),
      ),
    ),
  );
}

/// Calculates the duration until the next scheduled notification.
///
/// The next scheduled notification will occur at the next 12:00 PM.
/// If the current time is after 12:00 PM, the next scheduled notification
/// will occur at 12:00 PM the next day.
///
/// Returns the duration until the next scheduled notification.
Duration _calculateInitialDelay() {
  DateTime now = DateTime.now();
  DateTime targetTime = DateTime(now.year, now.month, now.day, 12);
  if (now.isAfter(targetTime)) {
    targetTime = targetTime.add(const Duration(days: 1));
  }
  return targetTime.difference(now);
}
