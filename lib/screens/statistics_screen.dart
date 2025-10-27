import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../models/daily_stats.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = '7'; // 7, 30, 90 days

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodSelector(),
                      const SizedBox(height: 24),
                      _buildOverviewCards(context),
                      const SizedBox(height: 24),
                      _buildCalorieChart(context),
                      const SizedBox(height: 24),
                      _buildMacroDistribution(context),
                      const SizedBox(height: 24),
                      _buildRecentMeals(context),
                      const SizedBox(height: 24), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppTheme.textBlack),
          ),
          const SizedBox(width: 12),
          Text(
            'Statistics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return GlassContainer(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton('7 Days', '7'),
          ),
          Expanded(
            child: _buildPeriodButton('30 Days', '30'),
          ),
          Expanded(
            child: _buildPeriodButton('90 Days', '90'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.textBlack.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppTheme.textBlack : AppTheme.textGray,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    return Consumer2<MealProvider, UserProvider>(
      builder: (context, mealProvider, userProvider, _) {
        final days = int.parse(_selectedPeriod);
        final now = DateTime.now();
        final startDate = now.subtract(Duration(days: days));
        final stats = mealProvider.getStatsForRange(startDate, now);
        
        final avgCalories = stats.isEmpty
            ? 0.0
            : stats.fold<double>(0, (sum, s) => sum + s.totalCalories) / days;
        
        final streak = mealProvider.getCurrentStreak();
        final totalDays = stats.length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Avg Calories',
                avgCalories.toInt().toString(),
                Icons.local_fire_department,
                AppTheme.accentOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Streak',
                '$streak days',
                Icons.bolt,
                AppTheme.accentPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Days Tracked',
                totalDays.toString(),
                Icons.calendar_today,
                AppTheme.accentBlue,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textBlack,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textGray,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieChart(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, _) {
        final days = int.parse(_selectedPeriod);
        final now = DateTime.now();
        final startDate = now.subtract(Duration(days: days));
        final stats = mealProvider.getStatsForRange(startDate, now);

        return GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Calorie Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildSimpleChart(stats),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleChart(List<DailyStats> stats) {
    if (stats.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: AppTheme.textGray),
          ),
        ),
      );
    }

    final maxCalories = stats.fold<double>(
      0,
      (max, s) => s.totalCalories > max ? s.totalCalories : max,
    );

    if (maxCalories == 0) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            'No calories logged yet',
            style: TextStyle(color: AppTheme.textGray),
          ),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats.take(int.parse(_selectedPeriod)).map((stat) {
          final height = (stat.totalCalories / maxCalories * 120).clamp(5.0, 120.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: AppTheme.textBlack.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stat.date.day}',
                    style: const TextStyle(
                      color: AppTheme.textGray,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMacroDistribution(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, _) {
        final days = int.parse(_selectedPeriod);
        final now = DateTime.now();
        final startDate = now.subtract(Duration(days: days));
        final stats = mealProvider.getStatsForRange(startDate, now);

        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;

        for (var stat in stats) {
          totalProtein += stat.totalProtein;
          totalCarbs += stat.totalCarbs;
          totalFat += stat.totalFat;
        }

        final totalMacros = totalProtein + totalCarbs + totalFat;
        final proteinPct = totalMacros > 0 ? (totalProtein / totalMacros * 100).toDouble() : 0.0;
        final carbsPct = totalMacros > 0 ? (totalCarbs / totalMacros * 100).toDouble() : 0.0;
        final fatPct = totalMacros > 0 ? (totalFat / totalMacros * 100).toDouble() : 0.0;

        return GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Macro Distribution',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 20),
              _buildMacroBar('Protein', proteinPct, totalProtein.toInt(), AppTheme.accentBlue),
              const SizedBox(height: 12),
              _buildMacroBar('Carbs', carbsPct, totalCarbs.toInt(), AppTheme.accentOrange),
              const SizedBox(height: 12),
              _buildMacroBar('Fat', fatPct, totalFat.toInt(), AppTheme.accentPurple),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacroBar(String label, double percentage, int grams, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textBlack,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${percentage.toInt()}% (${grams}g)',
              style: const TextStyle(
                color: AppTheme.textGray,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: AppTheme.textLightGray.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMeals(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, _) {
        final days = int.parse(_selectedPeriod);
        final now = DateTime.now();
        final startDate = now.subtract(Duration(days: days));
        final stats = mealProvider.getStatsForRange(startDate, now);

        // Collect all meals from all days
        final allMeals = <MealEntry>[];
        for (var stat in stats) {
          allMeals.addAll(stat.meals);
        }

        // Sort by timestamp descending (most recent first)
        allMeals.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (allMeals.isEmpty) {
          return const SizedBox.shrink();
        }

        return GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Meals',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...allMeals.take(10).map((meal) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMealItem(meal),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealItem(MealEntry meal) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: meal.source == 'manual' ? AppTheme.textBlack : AppTheme.textGray,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.name,
                style: const TextStyle(
                  color: AppTheme.textBlack,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${meal.calories.toInt()} kcal • ${_formatDate(meal.timestamp)}',
                style: const TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.textLightGray.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            meal.type,
            style: const TextStyle(
              color: AppTheme.textGray,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mealDate = DateTime(date.year, date.month, date.day);

    if (mealDate == today) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (mealDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}
