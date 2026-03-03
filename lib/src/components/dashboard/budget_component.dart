import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:intl/intl.dart';

/// Budget tracking component for monitoring subscription spending against limits.
class BudgetComponent extends StatefulWidget {
  const BudgetComponent({super.key});

  @override
  State<BudgetComponent> createState() => _BudgetComponentState();
}

class _BudgetComponentState extends State<BudgetComponent> {
  double _monthlyBudget = 0;
  bool _isEditing = false;
  final TextEditingController _budgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load saved budget (in a real app, this would come from SharedPreferences)
    _monthlyBudget = 100.0; // Default budget
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aboController = Provider.of<AboController>(context);
    final monthlyCost = aboController.getMonthlyCost();
    final percentageUsed = _monthlyBudget > 0 ? ((monthlyCost / _monthlyBudget * 100).clamp(0, 100)).toDouble() : 0.0;
    final remaining = _monthlyBudget - monthlyCost;
    final isOverBudget = remaining < 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          gradient: LinearGradient(
            colors: isOverBudget
                ? [theme.colorScheme.error.withOpacity(0.2), theme.colorScheme.error.withOpacity(0.1)]
                : remaining < 20
                    ? [Colors.orange.withOpacity(0.2), Colors.orange.withOpacity(0.1)]
                    : [theme.primaryColor.withOpacity(0.2), theme.primaryColor.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: isOverBudget ? theme.colorScheme.error : theme.primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Monthly Budget',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                        if (_isEditing) {
                          _budgetController.text = _monthlyBudget.toStringAsFixed(2);
                        }
                      });
                    },
                    icon: Icon(_isEditing ? Icons.close : Icons.edit),
                    tooltip: _isEditing ? 'Cancel' : 'Edit Budget',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Budget Display
              if (!_isEditing) ...[
                _buildBudgetDisplay(theme, monthlyCost, remaining, percentageUsed, isOverBudget),
              ] else ...[
                _buildBudgetEditor(theme),
              ],

              const SizedBox(height: 20),

              // Progress Bar
              _buildProgressBar(theme, percentageUsed, isOverBudget),
              const SizedBox(height: 12),

              // Breakdown
              _buildBreakdown(theme, monthlyCost, _monthlyBudget, remaining, isOverBudget),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetDisplay(
    ThemeData theme,
    double monthlyCost,
    double remaining,
    double percentageUsed,
    bool isOverBudget,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spent this month',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${monthlyCost.toStringAsFixed(2)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOverBudget ? theme.colorScheme.error : theme.primaryColor,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isOverBudget ? 'Over budget' : 'Remaining',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isOverBudget
                  ? '\$${(-remaining).toStringAsFixed(2)} over'
                  : '\$${remaining.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOverBudget ? theme.colorScheme.error : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetEditor(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set your monthly budget:',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.primaryColor.withOpacity(0.05),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                final newBudget = double.tryParse(_budgetController.text);
                if (newBudget != null && newBudget > 0) {
                  setState(() {
                    _monthlyBudget = newBudget;
                    _isEditing = false;
                  });
                  // In a real app, save to SharedPreferences here
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(ThemeData theme, double percentageUsed, bool isOverBudget) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: (percentageUsed / 100).clamp(0, 1),
            backgroundColor: theme.primaryColor.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? theme.colorScheme.error : percentageUsed > 80 ? Colors.orange : theme.primaryColor,
            ),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
            Text(
              '${percentageUsed.toStringAsFixed(1)}% used',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isOverBudget ? theme.colorScheme.error : theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '100%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdown(
    ThemeData theme,
    double monthlyCost,
    double budget,
    double remaining,
    bool isOverBudget,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildBreakdownRow(
            theme,
            'Monthly Budget',
            '\$${budget.toStringAsFixed(2)}',
            Icons.account_balance_wallet,
          ),
          const SizedBox(height: 8),
          _buildBreakdownRow(
            theme,
            'Total Spent',
            '\$${monthlyCost.toStringAsFixed(2)}',
            Icons.trending_up,
          ),
          const SizedBox(height: 8),
          _buildBreakdownRow(
            theme,
            isOverBudget ? 'Over Budget' : 'Remaining',
            isOverBudget ? '\$${(-remaining).toStringAsFixed(2)}' : '\$${remaining.toStringAsFixed(2)}',
            isOverBudget ? Icons.warning : Icons.savings,
            valueColor: isOverBudget ? theme.colorScheme.error : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: theme.disabledColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.primaryColor,
          ),
        ),
      ],
    );
  }
}
