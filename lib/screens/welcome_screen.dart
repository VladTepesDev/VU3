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
    
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/welcome_screen_bg.png'),
          fit: BoxFit.cover,
        ),
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
                  
                  Image.asset(
                    'assets/images/app_logo.png',
                    width: isSmallScreen ? 200 : 250,
                    height: isSmallScreen ? 200 : 250,
                    fit: BoxFit.contain,
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
                        color: AppTheme.textBlack,
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
