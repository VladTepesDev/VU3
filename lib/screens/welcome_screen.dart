import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import 'profile_setup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isSmallScreen ? 20 : 40),
                    
                    GlassContainer(
                      padding: EdgeInsets.all(isSmallScreen ? 30 : 40),
                      child: Icon(
                        Icons.restaurant_menu,
                        size: isSmallScreen ? 60 : 80,
                        color: AppTheme.textBlack.withValues(alpha: 0.8),
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 24 : 40),
                    
                    Text(
                      'Olympus Balance',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: isSmallScreen ? 28 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    GlassContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Text(
                        'Track your nutrition journey\nwith elegance and ease',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textGray,
                          fontSize: isSmallScreen ? 14 : null,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 32 : 48),
                    
                    _buildFeature(
                      context,
                      Icons.track_changes,
                      'Track your daily meals and calories',
                      isSmallScreen,
                    ),
                    const SizedBox(height: 16),
                    _buildFeature(
                      context,
                      Icons.menu_book,
                      'Follow personalized meal plans',
                      isSmallScreen,
                    ),
                    const SizedBox(height: 16),
                    _buildFeature(
                      context,
                      Icons.notifications_active,
                      'Get timely reminders for meals & water',
                      isSmallScreen,
                    ),
                    
                    SizedBox(height: isSmallScreen ? 32 : 48),
                    
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
                      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 20),
                      child: Text(
                        'Get Started',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textWhite,
                          fontSize: isSmallScreen ? 16 : null,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 20 : 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String text, bool isSmallScreen) {
    return GlassContainer(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
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
              size: isSmallScreen ? 24 : 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 14 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
