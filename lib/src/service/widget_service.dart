import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget service for home screen widgets (simplified version).
/// Full widget implementation requires native platform code.
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  /// Initialize widget service.
  Future<void> initialize() async {
    print('Widget service initialized');
  }

  /// Update the main widget with subscription data.
  Future<void> updateMainWidget({
    required double monthlySpend,
    required int totalSubscriptions,
    required int expiringCount,
    required String nextRenewalName,
    required int daysUntilNextRenewal,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('widget_monthly_spend', monthlySpend);
      await prefs.setInt('widget_total_subscriptions', totalSubscriptions);
      await prefs.setInt('widget_expiring_count', expiringCount);
      await prefs.setString('widget_next_renewal_name', nextRenewalName);
      await prefs.setInt('widget_days_until_renewal', daysUntilNextRenewal);
      await prefs.setInt('widget_last_updated', DateTime.now().millisecondsSinceEpoch);

      print('Main widget data updated');
    } catch (e) {
      print('Error updating main widget: $e');
    }
  }

  /// Update the budget widget.
  Future<void> updateBudgetWidget({
    required double budget,
    required double spent,
    required double remaining,
    required bool isOverBudget,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('widget_budget', budget);
      await prefs.setDouble('widget_spent', spent);
      await prefs.setDouble('widget_remaining', remaining);
      await prefs.setBool('widget_over_budget', isOverBudget);

      print('Budget widget data updated');
    } catch (e) {
      print('Error updating budget widget: $e');
    }
  }

  /// Update the upcoming renewals widget.
  Future<void> updateUpcomingWidget({
    required List<Map<String, dynamic>> upcomingRenewals,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final renewalsJson = jsonEncode(upcomingRenewals);
      await prefs.setString('widget_upcoming_renewals', renewalsJson);

      print('Upcoming renewals widget data updated');
    } catch (e) {
      print('Error updating upcoming widget: $e');
    }
  }

  /// Get widget data (for debugging).
  Future<Map<String, dynamic>> getWidgetData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'monthly_spend': prefs.getDouble('widget_monthly_spend') ?? 0.0,
      'total_subscriptions': prefs.getInt('widget_total_subscriptions') ?? 0,
      'expiring_count': prefs.getInt('widget_expiring_count') ?? 0,
      'next_renewal_name': prefs.getString('widget_next_renewal_name') ?? '',
      'days_until_renewal': prefs.getInt('widget_days_until_renewal') ?? 0,
      'last_updated': prefs.getInt('widget_last_updated') ?? 0,
    };
  }

  /// Clear all widget data.
  Future<void> clearWidgetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('widget_monthly_spend');
    await prefs.remove('widget_total_subscriptions');
    await prefs.remove('widget_expiring_count');
    await prefs.remove('widget_next_renewal_name');
    await prefs.remove('widget_days_until_renewal');
    await prefs.remove('widget_upcoming_renewals');
    await prefs.remove('widget_last_updated');
    
    print('Widget data cleared');
  }
}
