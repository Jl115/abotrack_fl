import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';

class AboListComponent extends StatelessWidget {
  const AboListComponent({super.key});

  @override

  /// Build method for the AboListComponent widget.
  ///
  /// This method creates the layout for the AboListComponent widget. It contains a
  /// ListView with a Slidable widget for each abo. The user can swipe the
  /// Slidable widget to the left to edit the abo, and swipe it to the right to
  /// delete the abo.
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aboController = Provider.of<AboController>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        height: 780,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: theme.cardColor,
        ),
        child: Column(
          children: [
            // Header with stats
            Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subscriptions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      _buildStatBadge(
                        theme,
                        Icons.check_circle_outline,
                        '${aboController.abos.where((a) => a.isActive).length}',
                        'Active',
                      ),
                      const SizedBox(width: 12),
                      _buildStatBadge(
                        theme,
                        Icons.warning_amber_outlined,
                        '${aboController.abos.where((a) => a.expiresSoon).length}',
                        'Expiring',
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: aboController.abos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.subscriptions_outlined,
                              size: 64,
                              color: theme.disabledColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No subscriptions yet',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                            Text(
                              'Tap + to add your first subscription',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        shrinkWrap: true,
                        itemCount: aboController.abos.length,
                        itemBuilder: (context, index) {
                          final abo = aboController.abos[index];
                          final isExpiringSoon = abo.expiresSoon;
                          final isActive = abo.isActive;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Slidable(
                              key: ValueKey(abo.id),
                              startActionPane: ActionPane(
                                motion: const BehindMotion(),
                                extentRatio: 0.25,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      aboController.showEditAboDialog(context, abo);
                                    },
                                    backgroundColor: theme.primaryColor,
                                    foregroundColor: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    icon: Icons.edit,
                                  ),
                                ],
                              ),
                              endActionPane: ActionPane(
                                motion: const BehindMotion(),
                                extentRatio: 0.25,
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      aboController.deleteAbo(abo.id);
                                    },
                                    backgroundColor: theme.splashColor,
                                    foregroundColor: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    icon: Icons.delete,
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: theme.primaryColorDark,
                                  borderRadius: BorderRadius.circular(20),
                                  border: isExpiringSoon
                                      ? Border.all(
                                          color: theme.colorScheme.error,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  abo.name,
                                                  style: theme.textTheme.bodyLarge?.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (abo.category != null)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: theme.primaryColor.withOpacity(0.3),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    abo.category!,
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                abo.isMonthly ? 'Monthly' : 'Yearly',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              if (abo.category != null) ...[
                                                const SizedBox(width: 8),
                                                Text(
                                                  '•',
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              Text(
                                                isActive ? 'Active' : 'Expired',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: isActive ? Colors.green : Colors.red,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(
                                                isExpiringSoon ? Icons.warning : Icons.calendar_today,
                                                size: 12,
                                                color: isExpiringSoon ? theme.colorScheme.error : Colors.white70,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isExpiringSoon
                                                    ? 'Expires in ${abo.daysUntilExpiration} days!'
                                                    : 'Ends: ${abo.endDate.toLocal().toString().split(' ')[0]}',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: isExpiringSoon ? theme.colorScheme.error : Colors.white70,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${abo.price.toStringAsFixed(2)}',
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          abo.isMonthly ? '/month' : '/year',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatBadge(ThemeData theme, IconData icon, String value, String label, {Color? color}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color ?? theme.primaryColor,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color ?? theme.primaryColor,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color ?? theme.primaryColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
