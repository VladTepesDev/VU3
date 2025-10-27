import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import 'profile_setup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // App Logo/Icon
                GlassContainer(
                  padding: const EdgeInsets.all(40),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: AppTheme.textBlack.withValues(alpha: 0.8),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // App Name
                Text(
                  'Olympus Balance',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                GlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Text(
                    'Track your nutrition journey\nwith elegance and ease',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const Spacer(),
                
                // Features
                _buildFeature(
                  context,
                  Icons.track_changes,
                  'Track your daily meals and calories',
                ),
                const SizedBox(height: 16),
                _buildFeature(
                  context,
                  Icons.menu_book,
                  'Follow personalized meal plans',
                ),
                const SizedBox(height: 16),
                _buildFeature(
                  context,
                  Icons.notifications_active,
                  'Get timely reminders for meals & water',
                ),
                
                const Spacer(),
                
                // Get Started Button
                GlassButton(
                  isPrimary: true,
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const ProfileSetupScreen(),
                      ),
                    );
                  },
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Get Started',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textWhite,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String text) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.glassWhite.withValues(alpha: 0.5),
                  AppTheme.glassGray.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.borderGray,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: AppTheme.textBlack,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
