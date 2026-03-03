import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:abotrack_fl/src/controller/abo_controller.dart';
import 'package:abotrack_fl/src/service/smart_recommendations_engine.dart';

/// Smart recommendations component showing AI-powered insights.
class SmartRecommendationsComponent extends StatefulWidget {
  const SmartRecommendationsComponent({super.key});

  @override
  State<SmartRecommendationsComponent> createState() => _SmartRecommendationsComponentState();
}

class _SmartRecommendationsComponentState extends State<SmartRecommendationsComponent> {
  final SmartRecommendationsEngine _engine = SmartRecommendationsEngine();
  RecommendationsResult? _result;
  bool _isLoading = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);
    
    try {
      final controller = context.read<AboController>();
      final result = await _engine.generateRecommendations(controller);
      
      setState(() {
        _result = result;
        _isLoading = false;
        _hasLoaded = true;
      });
    } catch (e) {
      print('Error loading recommendations: $e');
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          gradient: LinearGradient(
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.primaryColor.withOpacity(0.05),
            ],
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
                        Icons.psychology_outlined,
                        color: theme.primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Smart Recommendations',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_hasLoaded)
                    IconButton(
                      onPressed: _loadRecommendations,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'AI-powered insights to optimize your subscriptions',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
              const SizedBox(height: 20),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_result == null || _result!.recommendations.isEmpty)
                _buildEmptyState(theme)
              else
                Column(
                  children: [
                    // Total Savings Banner
                    _buildSavingsBanner(theme),
                    const SizedBox(height: 20),

                    // Insights
                    if (_result!.insights.isNotEmpty) ...[
                      _buildInsightsSection(theme),
                      const SizedBox(height: 20),
                    ],

                    // Recommendations List
                    _buildRecommendationsList(theme),
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
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: theme.disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No recommendations yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add more subscriptions to get personalized insights',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsBanner(ThemeData theme) {
    final savings = _result!.totalPotentialSavings;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: savings > 0
              ? [Colors.green.shade400, Colors.green.shade600]
              : [theme.primaryColor, theme.primaryColorDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (savings > 0 ? Colors.green : theme.primaryColor).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.savings,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Potential Savings',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${savings.toStringAsFixed(2)}/month',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.white.withOpacity(0.8),
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.insights,
              color: theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Insights',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._result!.insights.map((insight) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRecommendationsList(ThemeData theme) {
    // Sort by priority
    final sorted = List<Recommendation>.from(_result!.recommendations)
      ..sort((a, b) {
        final priorityOrder = {Priority.high: 0, Priority.medium: 1, Priority.low: 2};
        return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb,
              color: theme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Recommendations',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${sorted.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...sorted.map((rec) => _buildRecommendationCard(theme, rec)),
      ],
    );
  }

  Widget _buildRecommendationCard(ThemeData theme, Recommendation rec) {
    final color = rec.priority == Priority.high
        ? theme.colorScheme.error
        : rec.priority == Priority.medium
            ? Colors.orange
            : theme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconForType(rec.type),
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rec.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rec.priority.name.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            rec.description,
            style: theme.textTheme.bodyMedium,
          ),
          if (rec.estimatedSavings > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'Save \$${rec.estimatedSavings.toStringAsFixed(2)}/month',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to affected subscriptions or take action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action: ${rec.actionLabel}')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(rec.actionLabel),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(RecommendationType type) {
    switch (type) {
      case RecommendationType.duplicate:
        return Icons.content_copy;
      case RecommendationType.underutilized:
        return Icons.trending_down;
      case RecommendationType.expensive:
        return Icons.attach_money;
      case RecommendationType.renewal:
        return Icons.autorenew;
      case RecommendationType.category:
        return Icons.category;
      case RecommendationType.alternative:
        return Icons.swap_horiz;
      case RecommendationType.budget:
        return Icons.account_balance_wallet;
    }
  }
}
