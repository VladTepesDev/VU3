import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../providers/menu_provider.dart';
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
  void initState() {
    super.initState();
    // Refresh stats when screen loads to ensure we have latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().refreshDailyStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch both providers to rebuild when either changes
    context.watch<MealProvider>();
    context.watch<MenuProvider>();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/app_background.png'),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
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

        // Red bubble shadow, top-right positioned
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppTheme.bubbleShadowRed,
                blurRadius: 80,
                spreadRadius: 10,
                offset: const Offset(20, -10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Avg Calories',
                  avgCalories.toInt().toString(),
                  AppTheme.accentOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '$streak days',
                  AppTheme.accentPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Days Tracked',
                  totalDays.toString(),
                  AppTheme.accentBlue,
              ),
            ),
          ],
        ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textBlack,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.textGray.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderGray.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 48,
                color: AppTheme.textGray.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No data for this period',
                style: TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Start logging meals to see your trend',
                style: TextStyle(
                  color: AppTheme.textGray.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final maxCalories = stats.fold<double>(
      0,
      (max, s) => s.totalCalories > max ? s.totalCalories : max,
    );

    if (maxCalories == 0) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppTheme.textGray.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderGray.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fastfood_outlined,
                size: 48,
                color: AppTheme.textGray.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No calories logged yet',
                style: TextStyle(
                  color: AppTheme.textGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your calorie data will appear here',
                style: TextStyle(
                  color: AppTheme.textGray.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
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
                  Tooltip(
                    message: '${stat.totalCalories.toInt()} kcal',
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.textBlack.withValues(alpha: 0.5),
                            AppTheme.textBlack.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
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
        // Always show last 7 days for recent meals
        final now = DateTime.now();
        final startDate = now.subtract(const Duration(days: 7));
        final stats = mealProvider.getStatsForRange(startDate, now);

        // Collect all meals from all days
        final allMeals = <MealEntry>[];
        for (var stat in stats) {
          allMeals.addAll(stat.meals);
        }

        // Sort by timestamp descending (most recent first)
        allMeals.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (allMeals.isEmpty) {
          return GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Meals (Last 7 Days)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.textGray.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.borderGray.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 48,
                          color: AppTheme.textGray.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No recent meals',
                          style: TextStyle(
                            color: AppTheme.textGray,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start logging meals to see them here',
                          style: TextStyle(
                            color: AppTheme.textGray.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Meals',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.textBlack.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Last 7 days',
                      style: TextStyle(
                        color: AppTheme.textGray,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Fixed height container for 7 meal cards with scrolling
              SizedBox(
                height: 7 * (48 + 12), // 7 items × (item height + spacing)
                child: ListView.builder(
                  itemCount: allMeals.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMealItem(allMeals[index]),
                    );
                  },
                ),
              ),
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
