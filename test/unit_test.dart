import 'package:flutter_test/flutter_test.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

/// This is the main function for unit testing the AboController class.
///
/// This function is called by the test runner to run all the unit tests in this
/// file. It initializes the AboController and runs all the unit tests in the
/// group 'AboController Unit Tests'.
void main() {
  // Ensure that the binding is initialized before any test runs
  TestWidgetsFlutterBinding.ensureInitialized();

  late AboController aboController;

  // Setup before each test
  setUp(() {
    aboController = AboController();
  });

  group('AboController Unit Tests', () {
    test('Add a new Abo', () {
      final name = 'Netflix';
      final price = 19.99;
      final isMonthly = true;
      final startDate = DateTime.now();
      final endDate = startDate.add(const Duration(days: 30));

      aboController.addAbo(name, price, isMonthly, startDate, endDate);

      expect(aboController.abos.length, 1);
      expect(aboController.abos.first.name, name);
      expect(aboController.abos.first.price, price);
      expect(aboController.abos.first.isMonthly, isMonthly);
    });

    test('Edit an existing Abo', () {
      // Adding a new Abo first
      var uuid = Uuid();
      final id = uuid.v4();
      final initialAbo = Abo(
        id: id,
        name: 'Netflix',
        price: 19.99,
        isMonthly: true,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      aboController.addAbo(
        initialAbo.name,
        initialAbo.price,
        initialAbo.isMonthly,
        initialAbo.startDate,
        initialAbo.endDate,
      );

      // Edit the abo
      final newName = 'Spotify';
      final newPrice = 9.99;
      final newIsMonthly = false;
      final newStartDate = DateTime.now().subtract(const Duration(days: 30));
      final newEndDate = newStartDate.add(const Duration(days: 365));

      aboController.editAbo(
        aboController.abos.first.id,
        newName,
        newPrice,
        newIsMonthly,
        newStartDate,
        newEndDate,
      );

      final updatedAbo = aboController.abos.first;

      expect(updatedAbo.name, newName);
      expect(updatedAbo.price, newPrice);
      expect(updatedAbo.isMonthly, newIsMonthly);
      expect(updatedAbo.startDate, newStartDate);
      expect(updatedAbo.endDate, newEndDate);
    });

    test('Delete an Abo', () {
      final name = 'Netflix';
      final price = 19.99;
      final isMonthly = true;
      final startDate = DateTime.now();
      final endDate = startDate.add(const Duration(days: 30));

      aboController.addAbo(name, price, isMonthly, startDate, endDate);

      expect(aboController.abos.length, 1);

      aboController.deleteAbo(aboController.abos.first.id);

      expect(aboController.abos.length, 0);
    });

    test('Get total monthly cost', () {
      // Adding multiple subscriptions
      aboController.addAbo(
        'Netflix',
        19.99,
        true,
        DateTime.now(),
        DateTime.now().add(const Duration(days: 30)),
      );
      aboController.addAbo(
        'Amazon Prime',
        100.00,
        false,
        DateTime.now(),
        DateTime.now().add(const Duration(days: 365)),
      );

      // Netflix: 19.99 monthly, Amazon Prime: 100.00 per year (estimated monthly 8.33)
      final totalMonthlyCost = aboController.getMonthlyCost();
      expect(totalMonthlyCost, 19.99 + (100.00 / 12));
    });
  });
}
