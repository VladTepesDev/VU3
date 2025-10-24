import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../providers/user_provider.dart';
import '../providers/meal_provider.dart';
import '../providers/water_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello there! 👋',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMMM d').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            // Today's Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildTodaysSummary(context),
                    const SizedBox(height: 24),
                    _buildMacrosBreakdown(context),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 24),
                    _buildTodaysMeals(context),
                    const SizedBox(height: 100), // Bottom padding for nav bar
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysSummary(BuildContext context) {
    return Consumer2<UserProvider, MealProvider>(
      builder: (context, userProvider, mealProvider, child) {
        final user = userProvider.userProfile;
        final macros = mealProvider.getTodayMacros();
        final targetCalories = user?.tdee ?? 2000;
        final consumedCalories = macros['calories'] ?? 0;
        final percentage = (consumedCalories / targetCalories * 100).clamp(0, 100);

        return GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Today\'s Calories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textGray,
                ),
              ),
              const SizedBox(height: 16),
              
              // Circular Progress
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 12,
                      backgroundColor: AppTheme.textGray.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage > 100
                            ? Colors.red.withOpacity(0.7)
                            : AppTheme.textBlack.withOpacity(0.8),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        '${consumedCalories.toInt()}',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'of ${targetCalories.toInt()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'kcal',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              Text(
                '${(targetCalories - consumedCalories).toInt()} kcal remaining',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacrosBreakdown(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, child) {
        final macros = mealProvider.getTodayMacros();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutrients',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMacroCard(
                    context,
                    'Protein',
                    '${macros['protein']?.toInt() ?? 0}g',
                    Icons.egg,
                    const Color(0xFFE8F4F8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroCard(
                    context,
                    'Carbs',
                    '${macros['carbs']?.toInt() ?? 0}g',
                    Icons.rice_bowl,
                    const Color(0xFFF5E6F8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroCard(
                    context,
                    'Fat',
                    '${macros['fat']?.toInt() ?? 0}g',
                    Icons.water_drop,
                    const Color(0xFFFFF4E6),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMacroCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textBlack, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Water Intake',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildWaterTracker(context),
        const SizedBox(height: 24),
        Text(
          'Daily Tips',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildDailyTip(context),
      ],
    );
  }

  Widget _buildWaterTracker(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, waterProvider, _) {
        return GlassContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.water_drop,
                    color: Colors.blue.shade400,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${waterProvider.glassesConsumed} / ${waterProvider.dailyGoal} glasses',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${waterProvider.remaining} glasses remaining',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: waterProvider.progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      onPressed: () => waterProvider.addGlass(),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      isPrimary: true,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text('Add Glass'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GlassButton(
                    onPressed: () => waterProvider.removeGlass(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: const Icon(Icons.remove, size: 20),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyTip(BuildContext context) {
    final tips = [
      'Stay hydrated! Drink water throughout the day.',
      'Eat a balanced breakfast to kickstart your metabolism.',
      'Include protein in every meal for better satiety.',
      'Plan your meals in advance for better nutrition.',
      'Don\'t skip meals - eat regularly to maintain energy.',
      'Add colorful vegetables to increase nutrient intake.',
      'Get enough sleep - it affects your eating habits.',
    ];
    
    final today = DateTime.now();
    final tipIndex = today.day % tips.length;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lightbulb,
              color: Colors.amber.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tips[tipIndex],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysMeals(BuildContext context) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, _) {
        final todayMeals = mealProvider.getTodayMeals();
        
        if (todayMeals == null || todayMeals.meals.isEmpty) {
          return GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.restaurant,
                  size: 48,
                  color: AppTheme.textGray.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No meals logged yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the camera icon to add your first meal',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Meals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...todayMeals.meals.map((meal) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (meal.imagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          meal.imagePath!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.textGray.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.restaurant),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.textGray.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.restaurant),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${meal.calories.toInt()} kcal',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.textGray.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        meal.mealType,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        );
      },
    );
  }
}
