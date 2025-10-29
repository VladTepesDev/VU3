import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/sound_service.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
import 'add_meal_screen.dart';
import 'menus_screen.dart';
import 'profile_screen.dart';

// Global key to access MainNavigation state
final mainNavigationKey = GlobalKey<MainNavigationState>();

class MainNavigation extends StatefulWidget {
  MainNavigation({Key? key}) : super(key: key ?? mainNavigationKey);

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    AddMealScreen(),
    MenusScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: Column(
        children: [
          // Fixed header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.glassWhite.withValues(alpha: 0.3),
                  AppTheme.glassGray.withValues(alpha: 0.2),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderWhite.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top / 2,
              left: 20,
              right: 20,
              bottom: 16,
            ),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final user = userProvider.userProfile;
                final userName = user?.name ?? 'User';
                
                return Column(
                  children: [
                    // Profile Image and Name
                    Row(
                      children: [
                        // Profile Image
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.textBlack.withValues(alpha: 0.1),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: user?.profileImage != null && File(user!.profileImage!).existsSync()
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
                                          size: 24,
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
                                      user?.gender == 'male' ? Icons.male : Icons.female,
                                      size: 24,
                                      color: AppTheme.textBlack,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Name and greeting
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Welcome back!',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textBlack,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Date
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('EEEE, MMMM d').format(DateTime.now()),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textBlack.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Body content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.glassWhite.withValues(alpha: 0.3),
              AppTheme.glassGray.withValues(alpha: 0.2),
            ],
          ),
          border: Border(
            top: BorderSide(
              color: AppTheme.borderWhite.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom / 2,
        ),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.add_a_photo_outlined,
                activeIcon: Icons.add_a_photo,
                label: 'Add Meal',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book,
                label: 'Plans',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          SoundService().playTapSound();
          setState(() {
            _currentIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: AppTheme.textBlack,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textBlack,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
