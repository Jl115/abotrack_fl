import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:abotrack_fl/src/service/widget_service.dart';

/// Settings component for configuring home screen widgets.
class WidgetSettingsComponent extends StatefulWidget {
  const WidgetSettingsComponent({super.key});

  @override
  State<WidgetSettingsComponent> createState() => _WidgetSettingsComponentState();
}

class _WidgetSettingsComponentState extends State<WidgetSettingsComponent> {
  final WidgetService _widgetService = WidgetService();
  bool _isMainWidgetEnabled = false;
  bool _isBudgetWidgetEnabled = false;
  bool _isUpcomingWidgetEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWidgetSettings();
  }

  Future<void> _loadWidgetSettings() async {
    setState(() => _isLoading = true);
    // In a real app, load from SharedPreferences
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  Future<void> _updateWidgets() async {
    final controller = context.read<AboController>();
    final abos = controller.abos;
    
    if (abos.isEmpty) return;

    // Calculate data for main widget
    final monthlySpend = controller.getMonthlyCost();
    final totalSubscriptions = abos.length;
    final expiringCount = abos.where((a) => a.expiresSoon).length;
    
    // Find next renewal
    final activeAbos = abos.where((a) => a.isActive).toList();
    activeAbos.sort((a, b) => a.endDate.compareTo(b.endDate));
    final nextRenewal = activeAbos.isNotEmpty ? activeAbos.first : null;
    
    if (_isMainWidgetEnabled) {
      await _widgetService.updateMainWidget(
        monthlySpend: monthlySpend,
        totalSubscriptions: totalSubscriptions,
        expiringCount: expiringCount,
        nextRenewalName: nextRenewal?.name ?? 'None',
        daysUntilNextRenewal: nextRenewal?.daysUntilExpiration ?? 0,
      );
    }

    // Update budget widget
    if (_isBudgetWidgetEnabled) {
      // In real app, load budget from settings
      final budget = 100.0;
      final spent = monthlySpend;
      final remaining = budget - spent;
      final isOverBudget = remaining < 0;

      await _widgetService.updateBudgetWidget(
        budget: budget,
        spent: spent,
        remaining: remaining,
        isOverBudget: isOverBudget,
      );
    }

    // Update upcoming renewals widget
    if (_isUpcomingWidgetEnabled) {
      final now = DateTime.now();
      final thirtyDaysFromNow = now.add(const Duration(days: 30));
      final upcoming = activeAbos
          .where((a) => a.endDate.isAfter(now) && a.endDate.isBefore(thirtyDaysFromNow))
          .take(5)
          .map((a) => {
                'name': a.name,
                'price': a.price,
                'days': a.daysUntilExpiration,
                'date': a.endDate.toIso8601String(),
              })
          .toList();

      await _widgetService.updateUpcomingWidget(upcomingRenewals: upcoming);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Widgets updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
                Icons.widgets_outlined,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Home Screen Widgets',
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
                  'Add widgets to your home screen for quick access',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.disabledColor,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Main Widget Toggle
                _buildWidgetOption(
                  theme,
                  'Main Widget',
                  'Monthly spend, total subs, and next renewal',
                  Icons.dashboard_outlined,
                  _isMainWidgetEnabled,
                  (value) {
                    setState(() => _isMainWidgetEnabled = value);
                    _updateWidgets();
                  },
                ),
                const Divider(height: 24),
                
                // Budget Widget Toggle
                _buildWidgetOption(
                  theme,
                  'Budget Widget',
                  'Track spending vs budget limit',
                  Icons.account_balance_wallet_outlined,
                  _isBudgetWidgetEnabled,
                  (value) {
                    setState(() => _isBudgetWidgetEnabled = value);
                    _updateWidgets();
                  },
                ),
                const Divider(height: 24),
                
                // Upcoming Widget Toggle
                _buildWidgetOption(
                  theme,
                  'Upcoming Renewals',
                  'See subscriptions renewing soon',
                  Icons.upcoming_outlined,
                  _isUpcomingWidgetEnabled,
                  (value) {
                    setState(() => _isUpcomingWidgetEnabled = value);
                    _updateWidgets();
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How to add widgets:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Long press on your home screen\n'
                        '2. Tap "+" or "Add Widget"\n'
                        '3. Search for "AboTrack"\n'
                        '4. Choose your preferred widget size\n'
                        '5. Tap to add to home screen',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Manual Update Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _updateWidgets,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Update Widgets Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildWidgetOption(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    bool isEnabled,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isEnabled
                ? theme.primaryColor.withOpacity(0.2)
                : theme.disabledColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isEnabled ? theme.primaryColor : theme.disabledColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? theme.textTheme.bodyLarge?.color : theme.disabledColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: isEnabled,
          onChanged: onChanged,
          activeColor: theme.primaryColor,
        ),
      ],
    );
  }
}
