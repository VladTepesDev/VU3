import 'dart:ui';
import 'dart:io';
import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/custom_toast.dart';
import '../providers/user_provider.dart';
import '../providers/meal_provider.dart';
import '../providers/water_provider.dart';
import '../providers/menu_provider.dart';
import '../models/meal_log.dart';
import 'edit_meal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _lastCheckDate;

  @override
  void initState() {
    super.initState();
    // Refresh meal logs when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      // Check for day change
      await _checkForDayChange();
      
      if (!mounted) return;
      
      // Attempt to restore active menu if it's missing
      final userProfile = context.read<UserProvider>().userProfile;
      final menuProvider = context.read<MenuProvider>();
      
      if (userProfile != null && menuProvider.activeMenu == null) {
        await menuProvider.regenerateActiveMenuFromProfile(
          userProfile.recommendedCalories,
          userProfile.goal,
        );
      }
    });
  }

  Future<void> _checkForDayChange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastCheckDate == null || _lastCheckDate!.isBefore(today)) {
      _lastCheckDate = today;
      
      // Day has changed, refresh all providers
      if (!mounted) return;
      
      await context.read<WaterProvider>().checkAndResetForNewDay();
      await context.read<MealProvider>().checkAndResetForNewDay();
      await context.read<MenuProvider>().checkAndResetForNewDay();
    }
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
                      'Hello there!',
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
    return Consumer3<UserProvider, MealProvider, MenuProvider>(
      builder: (context, userProvider, mealProvider, menuProvider, child) {
        final user = userProvider.userProfile;
        final macros = mealProvider.getTodayMacros();
        final consumedCalories = macros['calories'] ?? 0;
        
        final targetCalories = user?.recommendedCalories ?? 
                               menuProvider.getTodayTargetCalories();
        
        String zone = 'none';
        Color zoneColor = AppTheme.textGray;
        
        if (consumedCalories > 0 && user != null) {
          zone = user.getCalorieZone(consumedCalories);
          zoneColor = user.getZoneColor(zone);
        }

        return GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            children: [
              if (menuProvider.activeMenu != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book, size: 16, color: AppTheme.textGray),
                    const SizedBox(width: 8),
                    Text(
                      '${menuProvider.activeMenu!.name} - Day ${menuProvider.getCurrentPlanDay()}/${menuProvider.activeMenu!.durationDays}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              Text(
                'Today\'s Calories',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),

              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Zone markers background
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CustomPaint(
                        painter: _CalorieZonePainter(
                          targetCalories: targetCalories,
                        ),
                      ),
                    ),
                    // Actual progress
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CustomPaint(
                        painter: _CalorieProgressPainter(
                          targetCalories: targetCalories,
                          consumedCalories: consumedCalories,
                          zoneColor: zoneColor,
                        ),
                      ),
                    ),
                    // Center content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${consumedCalories.toInt()}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 56,
                            color: consumedCalories > 0 ? zoneColor : AppTheme.textGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'kcal',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textGray,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (consumedCalories > 0 && user != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: zoneColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: zoneColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              user.getZoneDescription(zone),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: zoneColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              // Target and remaining info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCalorieInfoChip(
                    context,
                    'Target',
                    '${targetCalories.toInt()}',
                    Icons.flag_outlined,
                    AppTheme.textGray,
                  ),
                  const SizedBox(width: 12),
                  _buildCalorieInfoChip(
                    context,
                    'Remaining',
                    '${(targetCalories - consumedCalories).toInt()}',
                    Icons.trending_down,
                    consumedCalories > targetCalories 
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF66BB6A),
                  ),
                ],
              ),
              
              // Show adherence if on a plan
              if (menuProvider.activeMenu != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.textBlack.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.track_changes, size: 18, color: AppTheme.textBlack),
                      const SizedBox(width: 8),
                      Text(
                        '${menuProvider.getPlanAdherence().toInt()}% Plan Adherence',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalorieInfoChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.glassWhite.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderGray.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textGray,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '$value kcal',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
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
    return Consumer2<MenuProvider, MealProvider>(
      builder: (context, menuProvider, mealProvider, _) {
        if (menuProvider.activeMenu == null) {
          return const SizedBox.shrink();
        }

        final todayMeals = menuProvider.getTodayMenuMeals();
        if (todayMeals.isEmpty) {
          return const SizedBox.shrink();
        }
        
        // Get today's manual meals to check for meal slot coverage
        final todayManualMeals = mealProvider.getTodayMeals()?.meals ?? [];

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
              final canLog = menuProvider.canLogMeal(meal.id, todayManualMeals: todayManualMeals);
              final isInteractive = canLog || status == MealLogStatus.completed || status == MealLogStatus.missed;
              final hasPhoto = mealLog?.imagePath != null;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: isInteractive
                      ? () => _showLogMealDialog(context, meal, menuProvider)
                      : null,
                  child: Opacity(
                    opacity: isInteractive ? 1.0 : 0.5,
                    child: GlassContainer(
                      padding: const EdgeInsets.all(18),
                      color: status == MealLogStatus.completed 
                          ? const Color(0xFFE8F5E9) // Soft green when completed
                          : !canLog
                              ? AppTheme.textGray.withValues(alpha: 0.1) // Locked appearance
                              : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Meal icon or photo
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: hasPhoto ? null : LinearGradient(
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
                                child: hasPhoto
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.file(
                                          File(mealLog!.imagePath!),
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              _getMealTypeIcon(meal.mealType),
                                              color: AppTheme.textBlack,
                                              size: 28,
                                            );
                                          },
                                        ),
                                      )
                                    : Icon(
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
                              if (!canLog && status != MealLogStatus.completed)
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
                                    Icons.lock_outline,
                                    color: AppTheme.textGray,
                                    size: 22,
                                  ),
                                )
                              else if (status == MealLogStatus.upcoming)
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
                                )
                              else if (status == MealLogStatus.completed)
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
                                )
                              else if (status == MealLogStatus.missed)
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
    final mealProvider = context.read<MealProvider>();
    final todayManualMeals = mealProvider.getTodayMeals()?.meals ?? [];
    final canLog = menuProvider.canLogMeal(meal.id, todayManualMeals: todayManualMeals);
    final nextMeal = menuProvider.getNextMealToLog();
    
    // If meal is locked, show info message instead
    if (!canLog) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
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
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    
                    // Lock icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.textGray.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: AppTheme.textGray,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      'Meal Locked',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    Text(
                      'Please log your meals in order.\n${nextMeal != null ? 'Next meal: ${nextMeal.name}' : ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textGray,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    GlassButton(
                      isPrimary: true,
                      onPressed: () => Navigator.pop(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, color: AppTheme.textWhite, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Got it',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: 24 + MediaQuery.of(context).padding.bottom,
                ),
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
                          if (!context.mounted) return;
                          
                          final mealProvider = context.read<MealProvider>();
                          await mealProvider.refreshMealLogs();
                          await mealProvider.updateDailyStatistics();
                          if (!context.mounted) return;
                          
                          Navigator.pop(context);
                          CustomToast.success(context, '${meal.name} logged!');
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
                        onPressed: () async {
                          Navigator.pop(context);
                          
                          final result = await Navigator.pushNamed(
                            context, 
                            '/add-meal', 
                            arguments: meal,
                          );
                          
                          if (!context.mounted) return;
                          
                          if (result is String) {
                            CustomToast.success(context, result);
                          }
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
                          if (!context.mounted) return;
                          
                          final mealProvider = context.read<MealProvider>();
                          await mealProvider.refreshMealLogs();
                          await mealProvider.updateDailyStatistics();
                          if (!context.mounted) return;
                          
                          Navigator.pop(context);
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
        final isComplete = waterProvider.glassesConsumed >= waterProvider.dailyGoal;
        
        return GlassContainer(
          padding: const EdgeInsets.all(20),
          color: isComplete ? const Color(0xFFE8F5E9) : null, // Soft green when complete
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
              if (!isComplete)
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        onPressed: () => waterProvider.addGlass(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                )
              else
                GlassButton(
                  onPressed: () => waterProvider.removeGlass(),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove, size: 20),
                      SizedBox(width: 8),
                      Text('Remove Glass'),
                    ],
                  ),
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
              child: Dismissible(
                key: Key(meal.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text('Delete Meal'),
                        content: Text('Are you sure you want to delete "${meal.name}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFEF5350),
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) async {
                  await mealProvider.deleteMeal(meal.id);
                  if (context.mounted) {
                    CustomToast.success(context, 'Meal deleted');
                  }
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMealScreen(meal: meal),
                      ),
                    );
                  },
                  child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (meal.imagePath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(meal.imagePath!),
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
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit,
                        size: 18,
                        color: AppTheme.textGray.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
          ],
        );
      },
    );
  }
}

// Custom painter for calorie zone markers
class _CalorieZonePainter extends CustomPainter {
  final double targetCalories;

  _CalorieZonePainter({
    required this.targetCalories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 12.0;

    // Calculate zone boundaries as percentages of target
    final zones = [
      // Under goal severe: 0% to 50%
      {'start': 0.0, 'end': 0.5, 'color': const Color(0xFFEF5350)},
      // Under goal moderate: 50% to 87.5% (target - 250)
      {'start': 0.5, 'end': 0.875, 'color': const Color(0xFFFFA726)},
      // Optimal zone: 87.5% to 112.5% (target ± 100, but we'll make it ±12.5% for visibility)
      {'start': 0.875, 'end': 1.125, 'color': const Color(0xFF66BB6A)},
      // Acceptable high: 112.5% to 125% (target + 250)
      {'start': 1.125, 'end': 1.25, 'color': const Color(0xFFFFA726)},
      // Overeating: 125% to 150%
      {'start': 1.25, 'end': 1.5, 'color': const Color(0xFFEF5350)},
    ];

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw background track
    paint.color = AppTheme.textLightGray.withValues(alpha: 0.15);
    canvas.drawCircle(center, radius, paint);

    // Draw zone markers
    for (var zone in zones) {
      final startAngle = -90 + ((zone['start'] as double) * 300); // Map to 300° arc
      final sweepAngle = ((zone['end'] as double) - (zone['start'] as double)) * 300;
      
      paint.color = (zone['color'] as Color).withValues(alpha: 0.25);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle * (3.14159 / 180),
        sweepAngle * (3.14159 / 180),
        false,
        paint,
      );
    }

    // Draw zone dividers (subtle lines)
    paint.strokeWidth = 2;
    paint.color = AppTheme.glassWhite.withValues(alpha: 0.5);
    
    for (var zone in zones) {
      if (zone['start'] != 0.0) {
        final angle = -90 + ((zone['start'] as double) * 300);
        final angleRad = angle * (3.14159 / 180);
        
        final innerRadius = radius - strokeWidth / 2;
        final outerRadius = radius + strokeWidth / 2;
        
        final innerPoint = Offset(
          center.dx + innerRadius * cos(angleRad),
          center.dy + innerRadius * sin(angleRad),
        );
        final outerPoint = Offset(
          center.dx + outerRadius * cos(angleRad),
          center.dy + outerRadius * sin(angleRad),
        );
        
        canvas.drawLine(innerPoint, outerPoint, paint);
      }
    }

    // Draw target marker (small dot at 100%)
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.fill;
    paint.color = AppTheme.textBlack.withValues(alpha: 0.6);
    
    final targetAngle = -90 + (1.0 * 300); // 100% position
    final targetAngleRad = targetAngle * (3.14159 / 180);
    final targetPoint = Offset(
      center.dx + radius * cos(targetAngleRad),
      center.dy + radius * sin(targetAngleRad),
    );
    
    canvas.drawCircle(targetPoint, 5, paint);
    
    // Inner circle for target marker
    paint.color = AppTheme.glassWhite;
    canvas.drawCircle(targetPoint, 3, paint);
  }

  @override
  bool shouldRepaint(_CalorieZonePainter oldDelegate) {
    return oldDelegate.targetCalories != targetCalories;
  }
}

// Custom painter for calorie progress
class _CalorieProgressPainter extends CustomPainter {
  final double targetCalories;
  final double consumedCalories;
  final Color zoneColor;

  _CalorieProgressPainter({
    required this.targetCalories,
    required this.consumedCalories,
    required this.zoneColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (consumedCalories <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 12.0;

    // Calculate progress as percentage of target (clamped to 150%)
    final progressPercent = (consumedCalories / targetCalories).clamp(0.0, 1.5);
    final sweepAngle = progressPercent * 300; // Map to 300° arc

    // Draw progress arc with gradient
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Create gradient shader
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -90 * (3.14159 / 180),
      endAngle: (-90 + sweepAngle) * (3.14159 / 180),
      colors: [
        zoneColor.withValues(alpha: 0.8),
        zoneColor,
      ],
    );

    paint.shader = gradient.createShader(rect);

    canvas.drawArc(
      rect,
      -90 * (3.14159 / 180),
      sweepAngle * (3.14159 / 180),
      false,
      paint,
    );

    // Draw progress indicator (dot at end)
    paint.shader = null;
    paint.style = PaintingStyle.fill;
    paint.color = zoneColor;
    
    final endAngle = -90 + sweepAngle;
    final endAngleRad = endAngle * (3.14159 / 180);
    final endPoint = Offset(
      center.dx + radius * cos(endAngleRad),
      center.dy + radius * sin(endAngleRad),
    );
    
    // Outer glow
    paint.color = zoneColor.withValues(alpha: 0.3);
    canvas.drawCircle(endPoint, 10, paint);
    
    // Middle layer
    paint.color = zoneColor.withValues(alpha: 0.6);
    canvas.drawCircle(endPoint, 7, paint);
    
    // Inner dot
    paint.color = zoneColor;
    canvas.drawCircle(endPoint, 5, paint);
    
    // Center white dot
    paint.color = AppTheme.glassWhite;
    canvas.drawCircle(endPoint, 2.5, paint);
  }

  @override
  bool shouldRepaint(_CalorieProgressPainter oldDelegate) {
    return oldDelegate.consumedCalories != consumedCalories ||
           oldDelegate.targetCalories != targetCalories ||
           oldDelegate.zoneColor != zoneColor;
  }
}

double cos(double radians) => dart_math.cos(radians);
double sin(double radians) => dart_math.sin(radians);
