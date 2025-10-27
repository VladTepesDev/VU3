import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../providers/user_provider.dart';
import '../providers/meal_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                child: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
            
            // User Info Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.userProfile;
                    
                    if (user == null) {
                      return const SizedBox();
                    }
                    
                    return GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.glassWhite.withValues(alpha: 0.5),
                                  AppTheme.glassGray.withValues(alpha: 0.5),
                                ],
                              ),
                              border: Border.all(
                                color: AppTheme.borderGray,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              user.gender == 'male' ? Icons.male : Icons.female,
                              size: 40,
                              color: AppTheme.textBlack,
                            ),
                          ),
                          
                          const SizedBox(height: 16),

                          // Basic Info
                          Text(
                            '${user.age} years old',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                  Text(
                    user.gender == 'male' ? 'Male' : 'Female',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),                          const SizedBox(height: 24),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn(
                                context,
                                '${user.weight.toStringAsFixed(1)} kg',
                                'Weight',
                              ),
                              _buildStatColumn(
                                context,
                                '${user.height.toInt()} cm',
                                'Height',
                              ),
                              _buildStatColumn(
                                context,
                                user.bmi.toStringAsFixed(1),
                                'BMI',
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),

                          // BMI Category
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getBMIColor(user.bmiCategory).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.bmiCategory,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _getBMIColor(user.bmiCategory),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Daily Targets
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.userProfile;
                    if (user == null) return const SizedBox();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Targets',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        GlassContainer(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildTargetRow(
                                context,
                                'Calories',
                                '${user.tdee.toInt()} kcal',
                                Icons.local_fire_department,
                              ),
                              const Divider(height: 24),
                              _buildTargetRow(
                                context,
                                'BMR',
                                '${user.bmr.toInt()} kcal',
                                Icons.speed,
                              ),
                              const Divider(height: 24),
                              _buildTargetRow(
                                context,
                                'Activity Level',
                                _getActivityLabel(user.activityLevel),
                                Icons.directions_run,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            
            // Weight Progress
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final progress = userProvider.getWeightProgress();                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weight Progress',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        GlassContainer(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              if (progress != null) ...[
                                Text(
                                  '${progress > 0 ? '-' : '+'}${progress.abs().toStringAsFixed(1)} kg',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: AppTheme.textBlack,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Since you started',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                              ],
                              GlassButton(
                                onPressed: () => _showWeightDialog(context, userProvider),
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: const Text('Update Weight'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            
            // Statistics
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
              child: Consumer<MealProvider>(
                builder: (context, mealProvider, _) {
                  final avgCalories = mealProvider.getWeeklyAverageCalories();
                  final weekMeals = mealProvider.getWeekMeals();                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Stats',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GlassContainer(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Text(
                                      '${avgCalories.toInt()}',
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Avg Calories',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GlassContainer(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Text(
                                      '${weekMeals.length}',
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Days Tracked',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            
            // Settings
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      context,
                      Icons.notifications,
                      'Notifications',
                      () => _showNotificationSettings(context),
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      context,
                      Icons.info_outline,
                      'About',
                      () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // Bottom padding for nav bar
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
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
    );
  }

  Widget _buildTargetRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textGray),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textBlack),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textGray,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case 'Normal':
        return AppTheme.textBlack;
      case 'Underweight':
        return AppTheme.textGray;
      case 'Overweight':
        return AppTheme.textDarkGray;
      case 'Obese':
        return AppTheme.textDarkGray;
      default:
        return AppTheme.textGray;
    }
  }

  String _getActivityLabel(String level) {
    switch (level) {
      case 'sedentary':
        return 'Sedentary';
      case 'light':
        return 'Lightly Active';
      case 'moderate':
        return 'Moderately Active';
      case 'active':
        return 'Very Active';
      case 'very_active':
        return 'Extremely Active';
      default:
        return 'Moderate';
    }
  }

  void _showWeightDialog(BuildContext context, UserProvider userProvider) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Weight'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            hintText: 'Enter your current weight',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final weight = double.tryParse(controller.text);
              if (weight != null && weight > 0) {
                await userProvider.addWeightEntry(weight);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Weight updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.borderWhite.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.glassWhite.withValues(alpha: 0.95),
                  AppTheme.glassWhite.withValues(alpha: 0.9),
                ],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notification Settings',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Configure your reminders for water intake and meals',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: Text(
                      'Notification settings will be available here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGray,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Olympus Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version 1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'Track your nutrition journey with elegance and ease.',
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 Olympus Balance',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
