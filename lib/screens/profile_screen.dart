import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/custom_toast.dart';
import '../providers/user_provider.dart';
import '../providers/meal_provider.dart';
import '../services/sound_service.dart';
import 'statistics_screen.dart';
import 'webview_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSoundPreference();
  }

  Future<void> _loadSoundPreference() async {
    final soundEnabled = SoundService().soundEnabled;
    setState(() {
      _soundEnabled = soundEnabled;
    });
  }

  Future<void> _toggleSound(bool value) async {
    await SoundService().toggleSound(value);
    setState(() {
      _soundEnabled = value;
    });
    if (mounted) {
      CustomToast.success(
        context,
        value ? 'Sound enabled' : 'Sound disabled',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/app_background.png'),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: SafeArea(
        top: false, // Header handles top safe area
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
            
            // User Info Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.userProfile;
                    
                    if (user == null) {
                      return const SizedBox();
                    }
                    
                    // Purple bubble shadow, center positioned
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.bubbleShadowPurple,
                            blurRadius: 80,
                            spreadRadius: 10,
                            offset: const Offset(0, 25),
                          ),
                        ],
                      ),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                        children: [
                          // Profile Image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.borderGray,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: user.profileImage != null && File(user.profileImage!).existsSync()
                                  ? Image.file(
                                      File(user.profileImage!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppTheme.glassWhite.withValues(alpha: 0.5),
                                                AppTheme.glassGray.withValues(alpha: 0.5),
                                              ],
                                            ),
                                          ),
                                          child: Icon(
                                            user.gender == 'male' ? Icons.male : Icons.female,
                                            size: 40,
                                            color: AppTheme.textBlack,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.glassWhite.withValues(alpha: 0.5),
                                            AppTheme.glassGray.withValues(alpha: 0.5),
                                          ],
                                        ),
                                      ),
                                      child: Icon(
                                        user.gender == 'male' ? Icons.male : Icons.female,
                                        size: 40,
                                        color: AppTheme.textBlack,
                                      ),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),

                          // Name
                          if (user.name != null)
                            Text(
                              user.name!,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          
                          if (user.name != null) const SizedBox(height: 4),

                          // Basic Info
                          Text(
                            '${user.age} years old',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                  Text(
                    user.gender == 'male' ? 'Male' : 'Female',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Goal badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.textBlack.withValues(alpha: 0.1),
                          AppTheme.textGray.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.textBlack.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.goal == 'lose_weight' ? Icons.trending_down :
                          user.goal == 'gain_muscle' ? Icons.trending_up :
                          Icons.remove,
                          size: 16,
                          color: AppTheme.textBlack,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.goalDescription,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

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
                          
                          const SizedBox(height: 20),
                          
                          // Edit Profile Button
                          GlassButton(
                            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit Profile'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    );
                  },
                ),
              ),
            ),
            
            // Daily Targets
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  final progress = userProvider.getWeightProgress();
                  final user = userProvider.userProfile;
                  
                    return Column(
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildWeightStat(
                                      context,
                                      'Start',
                                      '${user!.weightHistory.first.weight.toStringAsFixed(1)} kg',
                                      Icons.flag,
                                    ),
                                    _buildWeightStat(
                                      context,
                                      'Current',
                                      '${user.weight.toStringAsFixed(1)} kg',
                                      Icons.monitor_weight,
                                    ),
                                    if (user.targetWeight != null)
                                      _buildWeightStat(
                                        context,
                                        'Target',
                                        '${user.targetWeight!.toStringAsFixed(1)} kg',
                                        Icons.emoji_events,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  '${progress > 0 ? '-' : '+'}${progress.abs().toStringAsFixed(1)} kg',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: progress > 0 ? Colors.green : Colors.orange,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Since you started',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                
                                // Progress towards goal
                                if (user.targetWeight != null && user.weightProgressPercent != null) ...[
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: (user.weightProgressPercent! / 100).clamp(0.0, 1.0),
                                      minHeight: 10,
                                      backgroundColor: AppTheme.textLightGray.withValues(alpha: 0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.green.shade600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${user.weightProgressPercent!.toInt()}% to goal',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textGray,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (user.estimatedDaysToGoal != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Est. ${user.estimatedDaysToGoal} days to reach goal',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textGray,
                                      ),
                                    ),
                                  ],
                                ],
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
                padding: const EdgeInsets.all(20.0),
              child: Consumer<MealProvider>(
                builder: (context, mealProvider, _) {
                  final avgCalories = mealProvider.getAverageCalories(days: 7);
                  final totalDays = mealProvider.getTotalDaysTracked();
                  final streak = mealProvider.getCurrentStreak();
                  final macros = mealProvider.getMacroDistribution(days: 7);
                  
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Stats',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        GlassContainer(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      '${avgCalories.toInt()}',
                                      'Avg Daily\nCalories',
                                      Icons.local_fire_department,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      '$totalDays',
                                      'Days\nTracked',
                                      Icons.calendar_today,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatCard(
                                      context,
                                      '$streak',
                                      'Day\nStreak',
                                      Icons.local_fire_department_outlined,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              GlassButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const StatisticsScreen(),
                                    ),
                                  );
                                },
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.bar_chart, size: 20),
                                    SizedBox(width: 8),
                                    Text('View Detailed Statistics'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Macro Distribution (7 days)',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildMacroBar(
                                          context,
                                          'Protein',
                                          macros['protein'] ?? 0,
                                          Colors.blue,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildMacroBar(
                                          context,
                                          'Carbs',
                                          macros['carbs'] ?? 0,
                                          Colors.orange,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildMacroBar(
                                          context,
                                          'Fat',
                                          macros['fat'] ?? 0,
                                          Colors.purple,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
            
            // Settings
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      Icons.analytics_outlined,
                      'Statistics',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatisticsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSoundToggle(context),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      context,
                      Icons.privacy_tip_outlined,
                      'Privacy Policy',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WebViewScreen(
                              url: 'https://www.example.com/privacy-policy',
                              title: 'Privacy Policy',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsItem(
                      context,
                      Icons.description_outlined,
                      'Terms of Service',
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WebViewScreen(
                              url: 'https://www.example.com/terms-of-service',
                              title: 'Terms of Service',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 24), // Bottom padding for nav bar
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

  Widget _buildWeightStat(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.textGray),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textGray,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderGray,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: AppTheme.textBlack),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar(BuildContext context, String label, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${percentage.toInt()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
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

  Widget _buildSoundToggle(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(
            _soundEnabled ? Icons.volume_up : Icons.volume_off,
            color: AppTheme.textBlack,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Sound Effects',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          SizedBox(
            height: 24,
            child: Switch(
              value: _soundEnabled,
              onChanged: _toggleSound,
              activeColor: AppTheme.textBlack,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textBlack, size: 24),
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
              size: 24,
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
                  CustomToast.success(context, 'Weight updated successfully!');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
