import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../models/daily_stats.dart';
import '../providers/meal_provider.dart';
import 'package:intl/intl.dart';
import 'edit_meal_screen.dart';

class MealEntryDetailsScreen extends StatelessWidget {
  final MealEntry mealEntry;

  const MealEntryDetailsScreen({super.key, required this.mealEntry});

  @override
  Widget build(BuildContext context) {
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
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppTheme.textBlack),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Meal Details',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Edit Button (only for manual meals)
                    if (mealEntry.source == 'manual')
                      Consumer<MealProvider>(
                        builder: (context, mealProvider, _) {
                          // Find the actual meal object by ID
                          final meal = mealProvider.getMealById(mealEntry.id);
                          
                          if (meal == null) {
                            return const SizedBox.shrink();
                          }
                          
                          return Column(
                            children: [
                              GlassButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditMealScreen(meal: meal),
                                    ),
                                  );
                                  // If meal was updated, pop back to refresh
                                  if (result != null && context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Edit Meal',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),

                    // Image
                    if (mealEntry.imagePath != null)
                      GlassContainer(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            File(mealEntry.imagePath!),
                            height: 250,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 250,
                                color: AppTheme.glassGray,
                                child: const Icon(
                                  Icons.restaurant,
                                  size: 80,
                                  color: AppTheme.textGray,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    if (mealEntry.imagePath != null) const SizedBox(height: 16),

                    // Meal Name and Type
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  mealEntry.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.glassGray,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.borderGray,
                                  ),
                                ),
                                child: Text(
                                  mealEntry.type.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textGray,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: AppTheme.textGray,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy • h:mm a').format(mealEntry.timestamp),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textGray,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                mealEntry.source == 'manual' 
                                    ? Icons.edit 
                                    : Icons.menu_book,
                                size: 16,
                                color: AppTheme.textGray,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                mealEntry.source == 'manual' 
                                    ? 'Manually logged' 
                                    : 'From meal plan',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textGray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Macronutrients
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nutrition Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMacroCard(
                                  context,
                                  'Calories',
                                  '${mealEntry.calories.toInt()}',
                                  'kcal',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMacroCard(
                                  context,
                                  'Protein',
                                  '${mealEntry.protein.toInt()}',
                                  'g',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMacroCard(
                                  context,
                                  'Carbs',
                                  '${mealEntry.carbs.toInt()}',
                                  'g',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMacroCard(
                                  context,
                                  'Fat',
                                  '${mealEntry.fat.toInt()}',
                                  'g',
                                ),
                              ),
                            ],
                          ),
                          if (mealEntry.weight != null && mealEntry.weight! > 0) ...[
                            const SizedBox(height: 12),
                            _buildMacroCard(
                              context,
                              'Weight',
                              '${mealEntry.weight!.toInt()}',
                              'g',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    if (mealEntry.notes != null && mealEntry.notes!.isNotEmpty)
                      GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notes',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              mealEntry.notes!,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroCard(BuildContext context, String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderGray,
        ),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textGray,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
