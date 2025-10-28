import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/user_profile.dart';
import '../models/meal.dart';
import '../models/menu.dart';
import '../models/meal_log.dart';
import '../models/notification_settings.dart';
import '../models/daily_stats.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _mealsKey = 'meals';
  static const String _menusKey = 'menus';
  static const String _mealLogsKey = 'meal_logs';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _activeMenuIdKey = 'active_menu_id';
  static const String _menuStartDateKey = 'menu_start_date';
  static const String _dailyStatsKey = 'daily_stats';

  // Profile Image Management
  Future<String> saveProfileImage(String imagePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory('${appDir.path}/profile_images');
      
      // Create directory if it doesn't exist
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imagePath);
      final newFileName = 'profile_$timestamp$extension';
      final newPath = '${profileImagesDir.path}/$newFileName';

      // Copy the image to permanent storage
      final sourceFile = File(imagePath);
      await sourceFile.copy(newPath);

      return newPath;
    } catch (e) {
      throw Exception('Failed to save profile image: $e');
    }
  }

  Future<void> deleteProfileImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore deletion errors - file might not exist
    }
  }

  // User Profile
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userProfileKey);
    if (jsonString == null) return null;
    return UserProfile.fromJson(jsonDecode(jsonString));
  }

  // Meals
  Future<void> saveMeals(List<DailyMeals> dailyMealsList) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = dailyMealsList.map((e) => e.toJson()).toList();
    await prefs.setString(_mealsKey, jsonEncode(jsonList));
  }

  Future<List<DailyMeals>> getMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_mealsKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((e) => DailyMeals.fromJson(e)).toList();
  }

  Future<void> addMeal(Meal meal) async {
    final dailyMealsList = await getMeals();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    final todayIndex = dailyMealsList.indexWhere((dm) => 
      dm.date.year == todayStart.year &&
      dm.date.month == todayStart.month &&
      dm.date.day == todayStart.day
    );

    if (todayIndex >= 0) {
      dailyMealsList[todayIndex] = DailyMeals(
        date: todayStart,
        meals: [...dailyMealsList[todayIndex].meals, meal],
      );
    } else {
      dailyMealsList.add(DailyMeals(
        date: todayStart,
        meals: [meal],
      ));
    }

    await saveMeals(dailyMealsList);
  }

  // Menus
  Future<void> saveMenus(List<Menu> menus) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = menus.map((e) => e.toJson()).toList();
    await prefs.setString(_menusKey, jsonEncode(jsonList));
  }

  Future<List<Menu>> getMenus() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_menusKey);
    if (jsonString == null) return [];
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((e) => Menu.fromJson(e)).toList();
  }

  // Active Menu Persistence
  Future<void> saveActiveMenuId(String? menuId) async {
    final prefs = await SharedPreferences.getInstance();
    if (menuId == null) {
      await prefs.remove(_activeMenuIdKey);
    } else {
      await prefs.setString(_activeMenuIdKey, menuId);
    }
  }

  Future<String?> getActiveMenuId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeMenuIdKey);
  }

  Future<void> saveMenuStartDate(DateTime? date) async {
    final prefs = await SharedPreferences.getInstance();
    if (date == null) {
      await prefs.remove(_menuStartDateKey);
    } else {
      await prefs.setString(_menuStartDateKey, date.toIso8601String());
    }
  }

  Future<DateTime?> getMenuStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_menuStartDateKey);
    if (dateString == null) return null;
    return DateTime.parse(dateString);
  }

  List<Menu> generateMenusForUser(double targetCalories, String goal) {
    return [
      _generateBalancedPlan(targetCalories, goal),
      _generateHighProteinPlan(targetCalories, goal),
      _generateLowCarbPlan(targetCalories, goal),
    ];
  }

  Menu _generateBalancedPlan(double dailyCalories, String goal) {
    final meals = <MenuMeal>[];
    
    final breakfastCal = dailyCalories * 0.25;
    final snack1Cal = dailyCalories * 0.10;
    final lunchCal = dailyCalories * 0.30;
    final snack2Cal = dailyCalories * 0.10;
    final dinnerCal = dailyCalories * 0.25;
    
    for (int day = 1; day <= 7; day++) {
      meals.addAll([
        MenuMeal(
          id: 'balanced_d${day}_breakfast',
          name: 'Breakfast',
          calories: breakfastCal,
          protein: breakfastCal * 0.20 / 4,
          carbs: breakfastCal * 0.50 / 4,
          fat: breakfastCal * 0.30 / 9,
          mealType: 'breakfast',
          dayNumber: day,
          scheduledTime: '08:00',
          foods: [],
          instructions: 'Target: ${breakfastCal.toInt()} kcal, balanced macros',
        ),
        MenuMeal(
          id: 'balanced_d${day}_snack1',
          name: 'Morning Snack',
          calories: snack1Cal,
          protein: snack1Cal * 0.25 / 4,
          carbs: snack1Cal * 0.50 / 4,
          fat: snack1Cal * 0.25 / 9,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '10:30',
          foods: [],
          instructions: 'Target: ${snack1Cal.toInt()} kcal',
        ),
        MenuMeal(
          id: 'balanced_d${day}_lunch',
          name: 'Lunch',
          calories: lunchCal,
          protein: lunchCal * 0.30 / 4,
          carbs: lunchCal * 0.40 / 4,
          fat: lunchCal * 0.30 / 9,
          mealType: 'lunch',
          dayNumber: day,
          scheduledTime: '13:00',
          foods: [],
          instructions: 'Target: ${lunchCal.toInt()} kcal',
        ),
        MenuMeal(
          id: 'balanced_d${day}_snack2',
          name: 'Afternoon Snack',
          calories: snack2Cal,
          protein: snack2Cal * 0.20 / 4,
          carbs: snack2Cal * 0.50 / 4,
          fat: snack2Cal * 0.30 / 9,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '16:00',
          foods: [],
          instructions: 'Target: ${snack2Cal.toInt()} kcal',
        ),
        MenuMeal(
          id: 'balanced_d${day}_dinner',
          name: 'Dinner',
          calories: dinnerCal,
          protein: dinnerCal * 0.30 / 4,
          carbs: dinnerCal * 0.40 / 4,
          fat: dinnerCal * 0.30 / 9,
          mealType: 'dinner',
          dayNumber: day,
          scheduledTime: '19:00',
          foods: [],
          instructions: 'Target: ${dinnerCal.toInt()} kcal',
        ),
      ]);
    }

    return Menu(
      id: 'balanced_plan',
      name: 'Balanced Plan',
      description: '~${dailyCalories.toInt()} kcal/day - Balanced nutrition for ${goal.replaceAll('_', ' ')}',
      durationDays: 7,
      meals: meals,
    );
  }

  Menu _generateHighProteinPlan(double dailyCalories, String goal) {
    final meals = <MenuMeal>[];
    
    final breakfastCal = dailyCalories * 0.25;
    final snack1Cal = dailyCalories * 0.12;
    final lunchCal = dailyCalories * 0.30;
    final snack2Cal = dailyCalories * 0.10;
    final dinnerCal = dailyCalories * 0.23;
    
    for (int day = 1; day <= 7; day++) {
      meals.addAll([
        MenuMeal(
          id: 'protein_d${day}_breakfast',
          name: 'Breakfast',
          calories: breakfastCal,
          protein: breakfastCal * 0.35 / 4,
          carbs: breakfastCal * 0.40 / 4,
          fat: breakfastCal * 0.25 / 9,
          mealType: 'breakfast',
          dayNumber: day,
          scheduledTime: '07:30',
          foods: [],
          instructions: 'Target: ${breakfastCal.toInt()} kcal, high protein',
        ),
        MenuMeal(
          id: 'protein_d${day}_snack1',
          name: 'Mid-Morning Snack',
          calories: snack1Cal,
          protein: snack1Cal * 0.50 / 4,
          carbs: snack1Cal * 0.35 / 4,
          fat: snack1Cal * 0.15 / 9,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '10:30',
          foods: [],
          instructions: 'Target: ${snack1Cal.toInt()} kcal, protein-rich',
        ),
        MenuMeal(
          id: 'protein_d${day}_lunch',
          name: 'Lunch',
          calories: lunchCal,
          protein: lunchCal * 0.35 / 4,
          carbs: lunchCal * 0.40 / 4,
          fat: lunchCal * 0.25 / 9,
          mealType: 'lunch',
          dayNumber: day,
          scheduledTime: '13:00',
          foods: [],
          instructions: 'Target: ${lunchCal.toInt()} kcal',
        ),
        MenuMeal(
          id: 'protein_d${day}_snack2',
          name: 'Pre-Workout Snack',
          calories: snack2Cal,
          protein: snack2Cal * 0.40 / 4,
          carbs: snack2Cal * 0.45 / 4,
          fat: snack2Cal * 0.15 / 9,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '16:00',
          foods: [],
          instructions: 'Target: ${snack2Cal.toInt()} kcal',
        ),
        MenuMeal(
          id: 'protein_d${day}_dinner',
          name: 'Dinner',
          calories: dinnerCal,
          protein: dinnerCal * 0.40 / 4,
          carbs: dinnerCal * 0.35 / 4,
          fat: dinnerCal * 0.25 / 9,
          mealType: 'dinner',
          dayNumber: day,
          scheduledTime: '19:30',
          foods: [],
          instructions: 'Target: ${dinnerCal.toInt()} kcal',
        ),
      ]);
    }

    return Menu(
      id: 'high_protein_plan',
      name: 'High Protein Plan',
      description: '~${dailyCalories.toInt()} kcal/day - 35-40% protein for muscle building',
      durationDays: 7,
      meals: meals,
    );
  }

  Menu _generateLowCarbPlan(double dailyCalories, String goal) {
    final meals = <MenuMeal>[];
    
    final breakfastCal = dailyCalories * 0.20;
    final snack1Cal = dailyCalories * 0.10;
    final lunchCal = dailyCalories * 0.35;
    final snack2Cal = dailyCalories * 0.10;
    final dinnerCal = dailyCalories * 0.25;
    
    for (int day = 1; day <= 7; day++) {
      meals.addAll([
        MenuMeal(
          id: 'lowcarb_d${day}_breakfast',
          name: 'Breakfast',
          calories: breakfastCal,
          protein: breakfastCal * 0.35 / 4,
          carbs: breakfastCal * 0.20 / 4,
          fat: breakfastCal * 0.45 / 9,
          mealType: 'breakfast',
          dayNumber: day,
          scheduledTime: '08:00',
          foods: [],
          instructions: 'Target: ${breakfastCal.toInt()} kcal, low carb',
        ),
        MenuMeal(
          id: 'lowcarb_d${day}_snack1',
          name: 'Morning Snack',
          calories: snack1Cal,
          protein: snack1Cal * 0.30 / 4,
          carbs: snack1Cal * 0.15 / 4,
          fat: snack1Cal * 0.55 / 9,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '10:30',
          foods: [],
          instructions: 'Target: ${snack1Cal.toInt()} kcal',
        ),
        MenuMeal(
          id: 'lowcarb_d${day}_lunch',
          name: 'Lunch',
          calories: lunchCal,
          protein: lunchCal * 0.40 / 4,
          carbs: lunchCal * 0.20 / 4,
          fat: lunchCal * 0.40 / 9,
          mealType: 'lunch',
          dayNumber: day,
          scheduledTime: '13:00',
          foods: [],
          instructions: 'Target: ${lunchCal.toInt()} kcal',
        ),
        MenuMeal(
          id: 'lowcarb_d${day}_snack2',
          name: 'Afternoon Snack',
          calories: snack2Cal,
          protein: snack2Cal * 0.30 / 4,
          carbs: snack2Cal * 0.15 / 4,
          fat: snack2Cal * 0.55 / 9,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '16:00',
          foods: [],
          instructions: 'Target: ${snack2Cal.toInt()} kcal',
        ),
        MenuMeal(
          id: 'lowcarb_d${day}_dinner',
          name: 'Dinner',
          calories: dinnerCal,
          protein: dinnerCal * 0.40 / 4,
          carbs: dinnerCal * 0.15 / 4,
          fat: dinnerCal * 0.45 / 9,
          mealType: 'dinner',
          dayNumber: day,
          scheduledTime: '19:00',
          foods: [],
          instructions: 'Target: ${dinnerCal.toInt()} kcal',
        ),
      ]);
    }

    return Menu(
      id: 'low_carb_plan',
      name: 'Low Carb Plan',
      description: '~${dailyCalories.toInt()} kcal/day - 15-20% carbs for fat loss',
      durationDays: 7,
      meals: meals,
    );
  }

  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationSettingsKey, jsonEncode(settings.toJson()));
  }

  Future<NotificationSettings> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_notificationSettingsKey);
    if (jsonString == null) {
      return NotificationSettings(
        waterReminderTimes: [
          NotificationTime(hour: 9, minute: 0, message: 'Time to drink water! 💧', type: 'water'),
          NotificationTime(hour: 12, minute: 0, message: 'Stay hydrated! 💧', type: 'water'),
          NotificationTime(hour: 15, minute: 0, message: 'Drink some water! 💧', type: 'water'),
          NotificationTime(hour: 18, minute: 0, message: 'Hydration time! 💧', type: 'water'),
        ],
        mealReminderTimes: [
          NotificationTime(hour: 8, minute: 0, message: 'Time for breakfast! 🍳', type: 'meal'),
          NotificationTime(hour: 13, minute: 0, message: 'Lunch time! 🥗', type: 'meal'),
          NotificationTime(hour: 19, minute: 0, message: 'Dinner time! 🍽️', type: 'meal'),
        ],
      );
    }
    return NotificationSettings.fromJson(jsonDecode(jsonString));
  }

  // Meal Logs
  Future<void> saveMealLogs(List<MealLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = logs.map((log) => log.toJson()).toList();
    await prefs.setString(_mealLogsKey, jsonEncode(logsJson));
  }

  Future<List<MealLog>> getMealLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_mealLogsKey);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => MealLog.fromJson(json)).toList();
  }

  Future<void> addMealLog(MealLog log) async {
    final logs = await getMealLogs();
    logs.add(log);
    await saveMealLogs(logs);
  }

  Future<void> updateMealLog(MealLog log) async {
    final logs = await getMealLogs();
    final index = logs.indexWhere((l) => l.id == log.id);
    if (index >= 0) {
      logs[index] = log;
      await saveMealLogs(logs);
    }
  }

  // Daily Stats
  Future<void> saveDailyStats(List<DailyStats> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = stats.map((stat) => stat.toJson()).toList();
    await prefs.setString(_dailyStatsKey, jsonEncode(statsJson));
  }

  Future<List<DailyStats>> getDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_dailyStatsKey);
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => DailyStats.fromJson(json)).toList();
  }

  Future<void> addOrUpdateDailyStats(DailyStats stats) async {
    final allStats = await getDailyStats();
    final dateStart = DateTime(stats.date.year, stats.date.month, stats.date.day);
    
    final index = allStats.indexWhere((s) =>
      s.date.year == dateStart.year &&
      s.date.month == dateStart.month &&
      s.date.day == dateStart.day
    );

    if (index >= 0) {
      allStats[index] = stats;
    } else {
      allStats.add(stats);
    }

    await saveDailyStats(allStats);
  }

  Future<DailyStats?> getStatsForDate(DateTime date) async {
    final allStats = await getDailyStats();
    final dateStart = DateTime(date.year, date.month, date.day);
    
    try {
      return allStats.firstWhere((s) =>
        s.date.year == dateStart.year &&
        s.date.month == dateStart.month &&
        s.date.day == dateStart.day
      );
    } catch (e) {
      return null;
    }
  }

  // First Launch
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, false);
  }

  // Clear all data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
