import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/day_change_service.dart';
import 'providers/user_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/water_provider.dart';
import 'screens/welcome_screen.dart';
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
  await notificationService.requestPermissions();
  
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndHandleDayChange();
    
    // Listen to day change service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final dayChangeService = context.read<DayChangeService>();
      dayChangeService.addListener(_handleDayChange);
    });
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
      await context.read<WaterProvider>().checkAndResetForNewDay();
      
      // Refresh all data
      await context.read<MealProvider>().checkAndResetForNewDay();
      await context.read<MenuProvider>().checkAndResetForNewDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: context.read<StorageService>().isFirstLaunch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textBlack),
              ),
            ),
          );
        }
        
        final isFirstLaunch = snapshot.data ?? true;
        
        // Check if user has profile
        final hasProfile = context.watch<UserProvider>().hasProfile;
        
        if (isFirstLaunch || !hasProfile) {
          return const WelcomeScreen();
        }
        
        return const MainNavigation();
      },
    );
  }
}
