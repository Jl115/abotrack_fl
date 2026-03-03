import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';

/// Widget service for home screen widgets (iOS & Android).
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  /// Initialize widget service.
  Future<void> initialize() async {
    // Widgets are initialized automatically by the platform
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
      // Save data for widget to read
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('widget_monthly_spend', monthlySpend);
      await prefs.setInt('widget_total_subscriptions', totalSubscriptions);
      await prefs.setInt('widget_expiring_count', expiringCount);
      await prefs.setString('widget_next_renewal_name', nextRenewalName);
      await prefs.setInt('widget_days_until_renewal', daysUntilNextRenewal);
      await prefs.setInt('widget_last_updated', DateTime.now().millisecondsSinceEpoch);

      // Update Android widget
      await HomeWidget.updateWidget(
        name: 'AboTrackWidgetProvider',
        androidName: 'AboTrackWidgetProvider',
        iOSName: 'HomeWidget',
        data: {
          'monthly_spend': monthlySpend.toStringAsFixed(2),
          'total_subscriptions': totalSubscriptions,
          'expiring_count': expiringCount,
          'next_renewal_name': nextRenewalName,
          'days_until_renewal': daysUntilNextRenewal,
          'last_updated': DateTime.now().toIso8601String(),
        },
      );

      print('Widget updated successfully');
    } catch (e) {
      print('Error updating widget: $e');
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

      await HomeWidget.updateWidget(
        name: 'AboTrackBudgetWidgetProvider',
        androidName: 'AboTrackBudgetWidgetProvider',
        iOSName: 'BudgetHomeWidget',
        data: {
          'budget': budget.toStringAsFixed(2),
          'spent': spent.toStringAsFixed(2),
          'remaining': remaining.toStringAsFixed(2),
          'over_budget': isOverBudget,
          'percentage_used': budget > 0 ? ((spent / budget) * 100).toStringAsFixed(1) : '0',
        },
      );

      print('Budget widget updated successfully');
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

      await HomeWidget.updateWidget(
        name: 'AboTrackUpcomingWidgetProvider',
        androidName: 'AboTrackUpcomingWidgetProvider',
        iOSName: 'UpcomingHomeWidget',
        data: {
          'renewals': renewalsJson,
          'count': upcomingRenewals.length,
        },
      );

      print('Upcoming renewals widget updated successfully');
    } catch (e) {
      print('Error updating upcoming widget: $e');
    }
  }

  /// Set widget click callback (opens app to specific screen).
  Future<void> setClickCallback({String? screen}) async {
    try {
      await HomeWidget.setAppGroupId('group.com.abotrack.widgets'); // iOS group ID
      print('Widget click callback set for screen: $screen');
    } catch (e) {
      print('Error setting click callback: $e');
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
      'budget': prefs.getDouble('widget_budget') ?? 0.0,
      'spent': prefs.getDouble('widget_spent') ?? 0.0,
      'remaining': prefs.getDouble('widget_remaining') ?? 0.0,
      'over_budget': prefs.getBool('widget_over_budget') ?? false,
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
    await prefs.remove('widget_budget');
    await prefs.remove('widget_spent');
    await prefs.remove('widget_remaining');
    await prefs.remove('widget_over_budget');
    await prefs.remove('widget_upcoming_renewals');
    await prefs.remove('widget_last_updated');
    
    print('Widget data cleared');
  }
}
