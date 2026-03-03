import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';

/// Analytics component showing subscription insights and statistics.
class AnalyticsComponent extends StatelessWidget {
  const AnalyticsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aboController = Provider.of<AboController>(context);
    final abos = aboController.abos;

    if (abos.isEmpty) {
      return _buildEmptyState(theme);
    }

    // Calculate statistics
    final totalMonthly = aboController.getMonthlyCost();
    final totalYearly = totalMonthly * 12;
    final activeCount = abos.where((a) => a.isActive).length;
    final expiringCount = abos.where((a) => a.expiresSoon).length;
    
    // Category breakdown
    final categoryMap = <String, double>{};
    for (final abo in abos) {
      final category = abo.category ?? 'Uncategorized';
      final monthlyCost = abo.isMonthly ? abo.price : abo.price / 12;
      categoryMap[category] = (categoryMap[category] ?? 0) + monthlyCost;
    }

    // Sort categories by cost
    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.cardColor,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Analytics',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Key Metrics Grid
              _buildMetricsGrid(theme, totalMonthly, totalYearly, activeCount, expiringCount),
              const SizedBox(height: 24),
              
              // Category Breakdown
              Text(
                'Spending by Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...sortedCategories.map((entry) => _buildCategoryRow(theme, entry.key, entry.value, totalMonthly)),
              
              const SizedBox(height: 16),
              
              // Subscription Types
              Text(
                'Subscription Types',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSubscriptionTypeRow(
                theme,
                'Monthly',
                abos.where((a) => a.isMonthly).length,
                abos.where((a) => a.isMonthly).fold<double>(0, (sum, a) => sum + a.price),
              ),
              _buildSubscriptionTypeRow(
                theme,
                'Yearly',
                abos.where((a) => !a.isMonthly).length,
                abos.where((a) => !a.isMonthly).fold<double>(0, (sum, a) => sum + a.price),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.cardColor,
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: theme.disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No data yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add subscriptions to see analytics',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(
    ThemeData theme,
    double totalMonthly,
    double totalYearly,
    int activeCount,
    int expiringCount,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          theme,
          'Monthly Spend',
          '\$${totalMonthly.toStringAsFixed(2)}',
          Icons.account_balance_wallet_outlined,
          theme.primaryColor,
        ),
        _buildMetricCard(
          theme,
          'Yearly Spend',
          '\$${totalYearly.toStringAsFixed(2)}',
          Icons.calendar_today_outlined,
          theme.colorScheme.secondary,
        ),
        _buildMetricCard(
          theme,
          'Active',
          '$activeCount',
          Icons.check_circle_outline,
          Colors.green,
        ),
        _buildMetricCard(
          theme,
          'Expiring Soon',
          '$expiringCount',
          Icons.warning_amber_outlined,
          theme.colorScheme.error,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(ThemeData theme, String category, double amount, double total) {
    final percentage = total > 0 ? (amount / total * 100) : 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '\$${amount.toStringAsFixed(2)}/mo',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTypeRow(ThemeData theme, String type, int count, double total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                type == 'Monthly' ? Icons.calendar_month : Icons.calendar_view_month,
                size: 20,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                type,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          Text(
            '$count subscriptions - \$${total.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
