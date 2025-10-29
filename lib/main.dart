import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/day_change_service.dart';
import 'services/sound_service.dart';
import 'providers/user_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/water_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/add_meal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Initialize sound service
  final soundService = SoundService();
  await soundService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final notificationService = NotificationService();
    final dayChangeService = DayChangeService();
    
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<NotificationService>.value(value: notificationService),
        Provider<DayChangeService>.value(value: dayChangeService),
        ChangeNotifierProvider(
          create: (_) => UserProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => MealProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => WaterProvider(notificationService),
        ),
      ],
      child: MaterialApp(
        title: 'Olympus Balance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppInitializer(),
        routes: {
          '/edit-profile': (context) => const EditProfileScreen(),
          '/add-meal': (context) => const AddMealScreen(),
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> with WidgetsBindingObserver {
  DateTime? _lastCheckDate;
  bool _isInitialized = false;
  Widget? _targetScreen;
  bool _showTarget = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
    
    // Listen to day change service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final dayChangeService = context.read<DayChangeService>();
      dayChangeService.addListener(_handleDayChange);
    });
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();
    
    // Run all initialization tasks in parallel
    await Future.wait([
      _checkAndHandleDayChange(),
      _determineTargetScreen(),
      Future.delayed(const Duration(seconds: 3)), // Minimum 3 seconds
    ]);
    
    // Ensure we've waited at least 3 seconds total
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inSeconds < 3) {
      await Future.delayed(Duration(seconds: 3 - elapsed.inSeconds));
    }
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
      
      // Wait for zoom animation to complete before fading
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        setState(() {
          _showTarget = true;
        });
      }
    }
  }

  Future<void> _determineTargetScreen() async {
    final storageService = context.read<StorageService>();
    final userProvider = context.read<UserProvider>();
    
    // Wait for user profile to load
    while (userProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    final isFirstLaunch = await storageService.isFirstLaunch();
    final hasProfile = userProvider.hasProfile;
    
    if (isFirstLaunch || !hasProfile) {
      _targetScreen = const WelcomeScreen();
    } else {
      _targetScreen = MainNavigation();
    }
  }

  @override
  void dispose() {
    final dayChangeService = context.read<DayChangeService>();
    dayChangeService.removeListener(_handleDayChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground, check if day changed
      _checkAndHandleDayChange();
    }
  }

  void _handleDayChange() {
    // Called when day changes automatically
    _checkAndHandleDayChange();
  }

  Future<void> _checkAndHandleDayChange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastCheckDate == null || _lastCheckDate!.isBefore(today)) {
      _lastCheckDate = today;
      
      // Trigger day change in all providers
      if (!mounted) return;
      
      // Reload water data (it has built-in day check)
      final waterProvider = context.read<WaterProvider>();
      final mealProvider = context.read<MealProvider>();
      final menuProvider = context.read<MenuProvider>();
      
      await waterProvider.checkAndResetForNewDay();
      if (!mounted) return;
      
      await mealProvider.checkAndResetForNewDay();
      if (!mounted) return;
      
      await menuProvider.checkAndResetForNewDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _isInitialized && _showTarget && _targetScreen != null
          ? _targetScreen!
          : LoadingScreen(shouldZoomOut: _isInitialized),
    );
  }
}
