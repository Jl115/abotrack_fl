import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:intl/intl.dart';

/// Upcoming renewals component showing subscriptions that will renew soon.
class UpcomingRenewalsComponent extends StatelessWidget {
  const UpcomingRenewalsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aboController = Provider.of<AboController>(context);
    final abos = aboController.abos;

    if (abos.isEmpty) {
      return _buildEmptyState(theme);
    }

    // Filter active subscriptions and sort by end date
    final activeAbos = abos.where((a) => a.isActive).toList();
    activeAbos.sort((a, b) => a.endDate.compareTo(b.endDate));

    // Get upcoming renewals (next 30 days)
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));
    final upcomingRenewals = activeAbos
        .where((a) => a.endDate.isBefore(thirtyDaysFromNow) && a.endDate.isAfter(now))
        .toList();

    // Get already expired but showing for awareness
    final expiredAbos = activeAbos.where((a) => !a.isActive).toList();

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
                    Icons.upcoming_outlined,
                    color: theme.primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Upcoming Renewals',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Next 30 days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
              const SizedBox(height: 20),

              // Content
              if (upcomingRenewals.isEmpty && expiredAbos.isEmpty)
                _buildNoUpcomingState(theme)
              else
                Column(
                  children: [
                    // Expired section
                    if (expiredAbos.isNotEmpty) ...[
                      _buildSectionHeader(theme, 'Expired', theme.colorScheme.error),
                      ...expiredAbos.map((abo) => _buildRenewalCard(theme, abo, isExpired: true)),
                      const SizedBox(height: 16),
                    ],
                    
                    // Upcoming section
                    if (upcomingRenewals.isNotEmpty) ...[
                      _buildSectionHeader(theme, 'Renewing Soon', theme.primaryColor),
                      ...upcomingRenewals.map((abo) => _buildRenewalCard(theme, abo)),
                    ],
                  ],
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
                Icons.event_busy,
                size: 64,
                color: theme.disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No subscriptions yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add subscriptions to see upcoming renewals',
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

  Widget _buildNoUpcomingState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            Text(
              'All clear!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No renewals in the next 30 days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRenewalCard(ThemeData theme, dynamic abo, {bool isExpired = false}) {
    final daysUntil = abo.endDate.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil <= 7 && !isExpired;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExpired
            ? theme.colorScheme.error.withOpacity(0.1)
            : isUrgent
                ? theme.colorScheme.error.withOpacity(0.1)
                : theme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpired
              ? theme.colorScheme.error
              : isUrgent
                  ? theme.colorScheme.error
                  : theme.primaryColor.withOpacity(0.2),
          width: isUrgent || isExpired ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon with background
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isExpired
                  ? theme.colorScheme.error.withOpacity(0.2)
                  : isUrgent
                      ? theme.colorScheme.error.withOpacity(0.2)
                      : theme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isExpired ? Icons.cancel_outlined : Icons.calendar_today,
              color: isExpired || isUrgent
                  ? theme.colorScheme.error
                  : theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  abo.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (abo.category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          abo.category!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      '\$${abo.price.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' ${abo.isMonthly ? '/mo' : '/yr'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Days indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isExpired)
                Text(
                  'Expired',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  '$daysUntil days',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isUrgent
                        ? theme.colorScheme.error
                        : theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMM d').format(abo.endDate),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
