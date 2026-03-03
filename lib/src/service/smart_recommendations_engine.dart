import 'dart:math';
import 'package:abotrack_fl/src/controller/abo_controller.dart';

/// AI-powered smart recommendations engine for subscription optimization.
class SmartRecommendationsEngine {
  static final SmartRecommendationsEngine _instance = SmartRecommendationsEngine._internal();
  factory SmartRecommendationsEngine() => _instance;
  SmartRecommendationsEngine._internal();

  /// Generate all recommendations for the user.
  Future<RecommendationsResult> generateRecommendations(AboController controller) async {
    final abos = controller.abos;
    
    if (abos.isEmpty) {
      return RecommendationsResult(
        recommendations: [],
        totalPotentialSavings: 0,
        insights: ['Add subscriptions to get personalized recommendations'],
      );
    }

    final recommendations = <Recommendation>[];
    final insights = <String>[];

    // Analyze for duplicate subscriptions
    recommendations.addAll(_findDuplicates(abos));

    // Find unused or rarely used subscriptions (based on age)
    recommendations.addAll(_findUnusedSubscriptions(abos));

    // Identify expensive subscriptions
    recommendations.addAll(_findExpensiveSubscriptions(abos));

    // Find subscriptions expiring soon (renewal optimization)
    recommendations.addAll(_findRenewalOptimizations(abos));

    // Category spending analysis
    recommendations.addAll(_analyzeCategorySpending(abos));

    // Find cheaper alternatives suggestion
    recommendations.addAll(_suggestAlternatives(abos));

    // Budget optimization
    recommendations.addAll(_optimizeBudget(abos, controller.getMonthlyCost()));

    // Calculate total potential savings
    final totalSavings = recommendations
        .where((r) => r.estimatedSavings > 0)
        .fold<double>(0, (sum, r) => sum + r.estimatedSavings);

    // Generate insights
    insights.addAll(_generateInsights(abos, controller.getMonthlyCost()));

    return RecommendationsResult(
      recommendations: recommendations,
      totalPotentialSavings: totalSavings,
      insights: insights,
    );
  }

  /// Find duplicate subscriptions (same name or category).
  List<Recommendation> _findDuplicates(List<Abo> abos) {
    final recommendations = <Recommendation>[];
    final nameMap = <String, List<Abo>>{};

    // Group by name (case-insensitive)
    for (final abo in abos) {
      final normalizedName = abo.name.toLowerCase().trim();
      if (!nameMap.containsKey(normalizedName)) {
        nameMap[normalizedName] = [];
      }
      nameMap[normalizedName]!.add(abo);
    }

    // Find duplicates
    for (final entry in nameMap.entries) {
      if (entry.value.length > 1) {
        final duplicates = entry.value;
        final totalCost = duplicates.fold<double>(0, (sum, a) => sum + a.price);
        final potentialSavings = totalCost - duplicates.map((a) => a.price).reduce(max);

        recommendations.add(Recommendation(
          id: 'duplicate_${entry.key}',
          type: RecommendationType.duplicate,
          priority: Priority.high,
          title: 'Duplicate Subscription: ${duplicates.first.name}',
          description: 'You have ${duplicates.length} subscriptions with the same name. Consider keeping only one.',
          affectedSubscriptions: duplicates.map((a) => a.id).toList(),
          estimatedSavings: potentialSavings,
          actionLabel: 'Review Duplicates',
        ));
      }
    }

    return recommendations;
  }

  /// Find old subscriptions that might not be used.
  List<Recommendation> _findUnusedSubscriptions(List<Abo> abos) {
    final recommendations = <Recommendation>[];
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 180));

    for (final abo in abos) {
      // If subscription started more than 6 months ago and is still active
      if (abo.startDate.isBefore(sixMonthsAgo) && abo.isActive) {
        final totalSpent = abo.isMonthly
            ? abo.price * abo.startDate.difference(now).inDays ~/ 30
            : abo.price * abo.startDate.difference(now).inDays ~/ 365;

        if (totalSpent > 100) {
          recommendations.add(Recommendation(
            id: 'unused_${abo.id}',
            type: RecommendationType.underutilized,
            priority: Priority.medium,
            title: 'Review ${abo.name}',
            description: 'You\'ve had this subscription for over 6 months and spent \$${totalSpent.toStringAsFixed(2)}. Are you still using it?',
            affectedSubscriptions: [abo.id],
            estimatedSavings: abo.isMonthly ? abo.price : abo.price / 12,
            actionLabel: 'Review Usage',
            metadata: {'totalSpent': totalSpent, 'months': abo.startDate.difference(now).inDays ~/ 30},
          ));
        }
      }
    }

    return recommendations;
  }

  /// Find the most expensive subscriptions.
  List<Recommendation> _findExpensiveSubscriptions(List<Abo> abos) {
    final recommendations = <Recommendation>[];
    final monthlyCosts = abos.map((a) => a.isMonthly ? a.price : a.price / 12).toList();
    
    if (monthlyCosts.isEmpty) return [];

    final avgCost = monthlyCosts.reduce((a, b) => a + b) / monthlyCosts.length;
    final threshold = avgCost * 2; // More than 2x average

    for (final abo in abos) {
      final monthlyEquivalent = abo.isMonthly ? abo.price : abo.price / 12;
      
      if (monthlyEquivalent > threshold) {
        recommendations.add(Recommendation(
          id: 'expensive_${abo.id}',
          type: RecommendationType.expensive,
          priority: Priority.medium,
          title: 'High-Cost Subscription: ${abo.name}',
          description: 'At \$${monthlyEquivalent.toStringAsFixed(2)}/month, this costs ${(monthlyEquivalent / avgCost * 100).toStringAsFixed(0)}% more than your average subscription.',
          affectedSubscriptions: [abo.id],
          estimatedSavings: monthlyEquivalent * 0.2, // Assume 20% savings possible
          actionLabel: 'Find Alternatives',
          metadata: {'monthlyEquivalent': monthlyEquivalent, 'averageCost': avgCost},
        ));
      }
    }

    return recommendations;
  }

  /// Find subscriptions expiring soon for renewal optimization.
  List<Recommendation> _findRenewalOptimizations(List<Abo> abos) {
    final recommendations = <Recommendation>[];
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    for (final abo in abos) {
      if (abo.endDate.isAfter(now) && abo.endDate.isBefore(thirtyDaysFromNow)) {
        final daysUntil = abo.endDate.difference(now).inDays;
        
        if (daysUntil <= 7) {
          recommendations.add(Recommendation(
            id: 'renewal_${abo.id}',
            type: RecommendationType.renewal,
            priority: Priority.high,
            title: 'Renewal Alert: ${abo.name}',
            description: 'Renews in $daysUntil days. Consider if you still need it or negotiate a better rate.',
            affectedSubscriptions: [abo.id],
            estimatedSavings: 0,
            actionLabel: 'Decide Now',
            metadata: {'daysUntilRenewal': daysUntil},
          ));
        } else if (daysUntil <= 14) {
          recommendations.add(Recommendation(
            id: 'renewal_${abo.id}',
            type: RecommendationType.renewal,
            priority: Priority.medium,
            title: 'Upcoming Renewal: ${abo.name}',
            description: 'Renews in $daysUntil days. Time to evaluate if it\'s still worth it.',
            affectedSubscriptions: [abo.id],
            estimatedSavings: 0,
            actionLabel: 'Review',
            metadata: {'daysUntilRenewal': daysUntil},
          ));
        }
      }
    }

    return recommendations;
  }

  /// Analyze spending by category.
  List<Recommendation> _analyzeCategorySpending(List<Abo> abos) {
    final recommendations = <Recommendation>[];
    final categoryMap = <String, List<Abo>>{};

    // Group by category
    for (final abo in abos) {
      final category = abo.category ?? 'Uncategorized';
      if (!categoryMap.containsKey(category)) {
        categoryMap[category] = [];
      }
      categoryMap[category]!.add(abo);
    }

    // Find categories with high spending
    for (final entry in categoryMap.entries) {
      final totalMonthly = entry.value.fold<double>(
        0,
        (sum, a) => sum + (a.isMonthly ? a.price : a.price / 12),
      );

      if (totalMonthly > 50 && entry.value.length > 2) {
        recommendations.add(Recommendation(
          id: 'category_${entry.key}',
          type: RecommendationType.category,
          priority: Priority.low,
          title: 'High Spending: ${entry.key}',
          description: 'You spend \$${totalMonthly.toStringAsFixed(2)}/month on ${entry.value.length} ${entry.key} subscriptions. Consider consolidating.',
          affectedSubscriptions: entry.value.map((a) => a.id).toList(),
          estimatedSavings: totalMonthly * 0.15,
          actionLabel: 'Review Category',
          metadata: {'category': entry.key, 'totalMonthly': totalMonthly, 'count': entry.value.length},
        ));
      }
    }

    return recommendations;
  }

  /// Suggest finding cheaper alternatives.
  List<Recommendation> _suggestAlternatives(List<Abo> abos) {
    final recommendations = <Recommendation>[];
    
    // Common services with known alternatives
    final alternativeSuggestions = {
      'netflix': ['Hulu', 'Disney+', 'Amazon Prime'],
      'spotify': ['Apple Music', 'YouTube Music', 'Amazon Music'],
      'gym': ['Home workouts', 'Outdoor activities', 'YouTube fitness'],
      'magazine': ['Digital subscriptions', 'Library access', 'Free newsletters'],
      'cloud': ['Google One', 'iCloud', 'OneDrive'],
    };

    for (final abo in abos) {
      final normalizedName = abo.name.toLowerCase();
      
      for (final key in alternativeSuggestions.keys) {
        if (normalizedName.contains(key)) {
          final alternatives = alternativeSuggestions[key]!;
          recommendations.add(Recommendation(
            id: 'alternative_${abo.id}',
            type: RecommendationType.alternative,
            priority: Priority.low,
            title: 'Consider Alternatives for ${abo.name}',
            description: 'You might save with: ${alternatives.take(2).join(", ")}',
            affectedSubscriptions: [abo.id],
            estimatedSavings: abo.price * 0.1,
            actionLabel: 'Explore Options',
            metadata: {'alternatives': alternatives},
          ));
          break;
        }
      }
    }

    return recommendations;
  }

  /// Budget optimization recommendations.
  List<Recommendation> _optimizeBudget(List<Abo> abos, double totalMonthly) {
    final recommendations = <Recommendation>[];

    // If spending more than $200/month, suggest review
    if (totalMonthly > 200) {
      final sortedAbos = List<Abo>.from(abos)
        ..sort((a, b) {
          final aMonthly = a.isMonthly ? a.price : a.price / 12;
          final bMonthly = b.isMonthly ? b.price : b.price / 12;
          return bMonthly.compareTo(aMonthly);
        });

      final topThree = sortedAbos.take(3).toList();
      final topThreeCost = topThree.fold<double>(
        0,
        (sum, a) => sum + (a.isMonthly ? a.price : a.price / 12),
      );

      recommendations.add(Recommendation(
        id: 'budget_optimization',
        type: RecommendationType.budget,
        priority: Priority.high,
        title: 'High Monthly Spending',
        description: 'At \$${totalMonthly.toStringAsFixed(2)}/month, your top 3 subscriptions cost \$${topThreeCost.toStringAsFixed(2)}. Review these for potential savings.',
        affectedSubscriptions: topThree.map((a) => a.id).toList(),
        estimatedSavings: topThreeCost * 0.2,
        actionLabel: 'Review Top Subscriptions',
        metadata: {'totalMonthly': totalMonthly, 'topThreeCost': topThreeCost},
      ));
    }

    return recommendations;
  }

  /// Generate general insights.
  List<String> _generateInsights(List<Abo> abos, double totalMonthly) {
    final insights = <String>[];
    
    if (abos.isEmpty) return insights;

    // Count by type
    final monthlyCount = abos.where((a) => a.isMonthly).length;
    final yearlyCount = abos.where((a) => !a.isMonthly).length;

    if (yearlyCount > monthlyCount) {
      insights.add('Most of your subscriptions are yearly - great for savings!');
    }

    if (totalMonthly > 100) {
      insights.add('Your monthly spending is above average. Consider reviewing unused subscriptions.');
    }

    final expiringCount = abos.where((a) => a.expiresSoon).length;
    if (expiringCount > 0) {
      insights.add('$expiringCount subscription(s) expiring soon - review before auto-renewal.');
    }

    final categoryCount = abos.map((a) => a.category).where((c) => c != null).toSet().length;
    if (categoryCount > 5) {
      insights.add('You have subscriptions across $categoryCount categories - consider consolidating.');
    }

    return insights;
  }
}

/// Result of recommendations generation.
class RecommendationsResult {
  final List<Recommendation> recommendations;
  final double totalPotentialSavings;
  final List<String> insights;

  RecommendationsResult({
    required this.recommendations,
    required this.totalPotentialSavings,
    required this.insights,
  });
}

/// Types of recommendations.
enum RecommendationType {
  duplicate,
  underutilized,
  expensive,
  renewal,
  category,
  alternative,
  budget,
}

/// Priority levels.
enum Priority {
  low,
  medium,
  high,
}

/// Individual recommendation.
class Recommendation {
  final String id;
  final RecommendationType type;
  final Priority priority;
  final String title;
  final String description;
  final List<String> affectedSubscriptions;
  final double estimatedSavings;
  final String actionLabel;
  final Map<String, dynamic>? metadata;

  Recommendation({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.affectedSubscriptions,
    required this.estimatedSavings,
    required this.actionLabel,
    this.metadata,
  });

  /// Get color for priority.
  String get priorityColor {
    switch (priority) {
      case Priority.high:
        return 'error';
      case Priority.medium:
        return 'warning';
      case Priority.low:
        return 'info';
    }
  }

  /// Get icon for type.
  String get typeIcon {
    switch (type) {
      case RecommendationType.duplicate:
        return 'content_copy';
      case RecommendationType.underutilized:
        return 'trending_down';
      case RecommendationType.expensive:
        return 'attach_money';
      case RecommendationType.renewal:
        return 'autorenew';
      case RecommendationType.category:
        return 'category';
      case RecommendationType.alternative:
        return 'swap_horiz';
      case RecommendationType.budget:
        return 'account_balance_wallet';
    }
  }
}
