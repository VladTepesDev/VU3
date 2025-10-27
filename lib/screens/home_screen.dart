import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../providers/user_provider.dart';
import '../providers/meal_provider.dart';
import '../providers/water_provider.dart';
import '../providers/menu_provider.dart';
import '../models/meal_log.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh meal logs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().refreshMealLogs();
    });
  }

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
                padding: const EdgeInsets.all(20.0),
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
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildTodaysSummary(context),
                  const SizedBox(height: 24),
                  _buildMacrosBreakdown(context),
                  const SizedBox(height: 24),
                  _buildMealSchedule(context),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildTodaysMeals(context),
                  const SizedBox(height: 24), // Bottom padding for nav bar
                ]),
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
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            children: [
              Text(
                'Today\'s Calories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              // Circular Progress - centered
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: CircularProgressIndicator(
                        value: percentage / 100,
                        strokeWidth: 14,
                        backgroundColor: AppTheme.textLightGray.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage > 100
                              ? AppTheme.textGray
                              : AppTheme.textBlack,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${consumedCalories.toInt()}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'of ${targetCalories.toInt()}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textGray,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'kcal',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Text(
                '${(targetCalories - consumedCalories).toInt()} kcal remaining',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textDarkGray,
                  fontWeight: FontWeight.w500,
                ),
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroCard(
                    context,
                    'Carbs',
                    '${macros['carbs']?.toInt() ?? 0}g',
                    Icons.rice_bowl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroCard(
                    context,
                    'Fat',
                    '${macros['fat']?.toInt() ?? 0}g',
                    Icons.water_drop,
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

  Widget _buildMealSchedule(BuildContext context) {
    return Consumer<MenuProvider>(
      builder: (context, menuProvider, _) {
        if (menuProvider.activeMenu == null) {
          return const SizedBox.shrink();
        }

        final todayMeals = menuProvider.getTodayMenuMeals();
        if (todayMeals.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Meal Plan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...todayMeals.map((meal) {
              final mealLog = menuProvider.getMealLog(meal.id, DateTime.now());
              final status = mealLog?.status ?? MealLogStatus.upcoming;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () => _showLogMealDialog(context, meal, menuProvider),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Meal icon
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.glassWhite.withValues(alpha: 0.4),
                                    AppTheme.glassGray.withValues(alpha: 0.3),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.borderGray,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _getMealTypeIcon(meal.mealType),
                                color: AppTheme.textBlack,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            
                            // Meal info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: AppTheme.glassGray,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: AppTheme.borderGray,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.schedule,
                                              size: 12,
                                              color: AppTheme.textGray,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              meal.scheduledTime,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: AppTheme.textBlack,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        meal.mealType.toUpperCase(),
                                        style: const TextStyle(
                                          color: AppTheme.textGray,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    meal.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textBlack,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            
                            // Status indicator
                            if (status == MealLogStatus.upcoming)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.glassGray,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.borderGray,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.touch_app,
                                  color: AppTheme.textGray,
                                  size: 22,
                                ),
                              ),
                            if (status == MealLogStatus.completed)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.textBlack,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.textBlack,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.glassWhite,
                                  size: 22,
                                ),
                              ),
                            if (status == MealLogStatus.missed)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.textGray.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.textGray,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.cancel,
                                  color: AppTheme.textGray,
                                  size: 22,
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Macros row
                        Row(
                          children: [
                            _buildMacroTag(
                              Icons.local_fire_department,
                              '${meal.calories.toInt()}',
                              'kcal',
                            ),
                            const SizedBox(width: 8),
                            _buildMacroTag(
                              Icons.fitness_center,
                              '${meal.protein.toInt()}g',
                              'protein',
                            ),
                            const SizedBox(width: 8),
                            _buildMacroTag(
                              Icons.grain,
                              '${meal.carbs.toInt()}g',
                              'carbs',
                            ),
                            const SizedBox(width: 8),
                            _buildMacroTag(
                              Icons.opacity,
                              '${meal.fat.toInt()}g',
                              'fat',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
              }),
          ],
        );
      },
    );
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.restaurant;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.local_cafe;
      default:
        return Icons.restaurant_menu;
    }
  }

  Widget _buildMacroTag(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.glassGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderGray,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppTheme.textGray),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogMealDialog(BuildContext context, meal, MenuProvider menuProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.glassWhite.withValues(alpha: 0.9),
              AppTheme.glassGray.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: AppTheme.borderWhite.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.textLightGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Meal name
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Macros
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _buildMacroChip('${meal.calories.toInt()}', Icons.local_fire_department)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMacroChip('${meal.protein.toInt()}g', Icons.fitness_center)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMacroChip('${meal.carbs.toInt()}g', Icons.grain)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildMacroChip('${meal.fat.toInt()}g', Icons.opacity)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  GlassButton(
                    isPrimary: true,
                    onPressed: () async {
                      await menuProvider.logMeal(
                        menuMealId: meal.id,
                        calories: meal.calories,
                        protein: meal.protein,
                        carbs: meal.carbs,
                        fat: meal.fat,
                      );
                      if (context.mounted) {
                        await context.read<MealProvider>().refreshMealLogs();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✓ ${meal.name} logged!'),
                            backgroundColor: AppTheme.textBlack,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.textWhite, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Quick Log',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  GlassButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/add-meal', arguments: meal);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, color: AppTheme.textBlack, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Log with Photo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  GlassButton(
                    onPressed: () async {
                      await menuProvider.markMealAsMissed(meal.id);
                      if (context.mounted) {
                        await context.read<MealProvider>().refreshMealLogs();
                        Navigator.pop(context);
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, color: AppTheme.textGray, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Mark as Missed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroChip(String value, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      showShadow: false,
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.textGray),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBlack,
            ),
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
                    color: AppTheme.textGray,
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
                  backgroundColor: AppTheme.textLightGray.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.textBlack,
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
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.glassWhite.withValues(alpha: 0.5),
                  AppTheme.glassGray.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.borderGray,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppTheme.textBlack,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Tip',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tips[tipIndex],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
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
                  color: AppTheme.textGray.withValues(alpha: 0.5),
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
                                color: AppTheme.textGray.withValues(alpha: 0.2),
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
                          color: AppTheme.textGray.withValues(alpha: 0.2),
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
                        color: AppTheme.textGray.withValues(alpha: 0.2),
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
