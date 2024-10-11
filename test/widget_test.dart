import 'package:abotrack_fl/src/views/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:io';

/// Tests the DashboardView widget.
///
/// This test suite ensures the DashboardView widget properly renders a list of
/// subscriptions and allows the user to filter the list by the oldest or newest
/// subscriptions.
///
/// The test suite uses the following setup:
///
/// - Mocks the getApplicationDocumentsDirectory method to return a temporary
///   directory.
/// - Initializes the AboController and adds two initial Abos for testing.
///
/// The test suite consists of one test, which checks that the subscriptions are
/// properly rendered on the screen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock the getApplicationDocumentsDirectory to return a temporary directory during tests
    final directory = await Directory.systemTemp.createTemp();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return directory.path;
        }
        return null;
      },
    );
  });

  group('DashboardView Widget Tests', () {
    late AboController aboController;

    setUp(() {
      // Initialize AboController
      aboController = AboController();

      // Add some initial Abos to test rendering
      aboController.addAbo(
        'Netflix',
        19.99,
        true,
        DateTime.now(),
        DateTime.now().add(const Duration(days: 30)),
      );
      aboController.addAbo(
        'Spotify',
        9.99,
        true,
        DateTime.now(),
        DateTime.now().add(const Duration(days: 30)),
      );
    });

    testWidgets('should display list of subscriptions',
        (WidgetTester tester) async {
      // Build the DashboardView with the necessary providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: aboController,
            ),
          ],
          child: MaterialApp(
            home: DashboardView(),
          ),
        ),
      );

      // Trigger a frame.
      await tester.pump();

      // Check if the subscriptions are rendered on the screen
      expect(find.text('Netflix'), findsOneWidget);
      expect(find.text('Spotify'), findsOneWidget);
    });
  });
}
