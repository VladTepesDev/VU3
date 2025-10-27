import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/meal.dart';
import '../models/menu.dart';
import '../models/meal_log.dart';
import '../models/notification_settings.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _mealsKey = 'meals';
  static const String _menusKey = 'menus';
  static const String _mealLogsKey = 'meal_logs';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _isFirstLaunchKey = 'is_first_launch';
  static const String _activeMenuIdKey = 'active_menu_id';
  static const String _menuStartDateKey = 'menu_start_date';

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
    if (jsonString == null) return _getDefaultMenus();
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

  List<Menu> _getDefaultMenus() {
    return [
      _getMaintenancePlan(),
      _getMuscleGainPlan(),
      _getWeightLossPlan(),
    ];
  }

  Menu _getMaintenancePlan() {
    // 2000 kcal/day - Maintenance plan
    final meals = <MenuMeal>[];
    
    for (int day = 1; day <= 7; day++) {
      meals.addAll([
        MenuMeal(
          id: 'maint_d${day}_breakfast',
          name: 'Breakfast',
          calories: 450,
          protein: 20,
          carbs: 55,
          fat: 15,
          mealType: 'breakfast',
          dayNumber: day,
          scheduledTime: '08:00',
          foods: [],
          instructions: 'Target: 450 kcal, 20g protein, 55g carbs, 15g fat',
        ),
        MenuMeal(
          id: 'maint_d${day}_lunch',
          name: 'Lunch',
          calories: 550,
          protein: 35,
          carbs: 60,
          fat: 18,
          mealType: 'lunch',
          dayNumber: day,
          scheduledTime: '13:00',
          foods: [],
          instructions: 'Target: 550 kcal, 35g protein, 60g carbs, 18g fat',
        ),
        MenuMeal(
          id: 'maint_d${day}_snack',
          name: 'Snack',
          calories: 250,
          protein: 12,
          carbs: 30,
          fat: 8,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '16:00',
          foods: [],
          instructions: 'Target: 250 kcal, 12g protein, 30g carbs, 8g fat',
        ),
        MenuMeal(
          id: 'maint_d${day}_dinner',
          name: 'Dinner',
          calories: 600,
          protein: 40,
          carbs: 65,
          fat: 20,
          mealType: 'dinner',
          dayNumber: day,
          scheduledTime: '19:00',
          foods: [],
          instructions: 'Target: 600 kcal, 40g protein, 65g carbs, 20g fat',
        ),
        MenuMeal(
          id: 'maint_d${day}_snack2',
          name: 'Evening Snack',
          calories: 150,
          protein: 8,
          carbs: 15,
          fat: 6,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '21:00',
          foods: [],
          instructions: 'Target: 150 kcal, 8g protein, 15g carbs, 6g fat',
        ),
      ]);
    }

    return Menu(
      id: 'maintenance_2000',
      name: 'Balanced Maintenance Plan',
      description: '~2000 kcal/day - Perfect for maintaining current weight with balanced nutrition',
      durationDays: 7,
      meals: meals,
    );
  }

  Menu _getMuscleGainPlan() {
    // 2500 kcal/day - Muscle building plan
    final meals = <MenuMeal>[];
    
    for (int day = 1; day <= 7; day++) {
      meals.addAll([
        MenuMeal(
          id: 'muscle_d${day}_breakfast',
          name: 'Breakfast',
          calories: 550,
          protein: 35,
          carbs: 65,
          fat: 16,
          mealType: 'breakfast',
          dayNumber: day,
          scheduledTime: '07:30',
          foods: [],
          instructions: 'Target: 550 kcal, 35g protein, 65g carbs, 16g fat',
        ),
        MenuMeal(
          id: 'muscle_d${day}_snack1',
          name: 'Mid-Morning Snack',
          calories: 350,
          protein: 30,
          carbs: 35,
          fat: 8,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '10:30',
          foods: [],
          instructions: 'Target: 350 kcal, 30g protein, 35g carbs, 8g fat',
        ),
        MenuMeal(
          id: 'muscle_d${day}_lunch',
          name: 'Lunch',
          calories: 700,
          protein: 50,
          carbs: 75,
          fat: 20,
          mealType: 'lunch',
          dayNumber: day,
          scheduledTime: '13:00',
          foods: [],
          instructions: 'Target: 700 kcal, 50g protein, 75g carbs, 20g fat',
        ),
        MenuMeal(
          id: 'muscle_d${day}_snack2',
          name: 'Pre-Workout Snack',
          calories: 300,
          protein: 25,
          carbs: 35,
          fat: 6,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '16:00',
          foods: [],
          instructions: 'Target: 300 kcal, 25g protein, 35g carbs, 6g fat',
        ),
        MenuMeal(
          id: 'muscle_d${day}_dinner',
          name: 'Dinner',
          calories: 650,
          protein: 45,
          carbs: 70,
          fat: 18,
          mealType: 'dinner',
          dayNumber: day,
          scheduledTime: '19:30',
          foods: [],
          instructions: 'Target: 650 kcal, 45g protein, 70g carbs, 18g fat',
        ),
        MenuMeal(
          id: 'muscle_d${day}_snack3',
          name: 'Evening Snack',
          calories: 250,
          protein: 20,
          carbs: 20,
          fat: 10,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '21:30',
          foods: [],
          instructions: 'Target: 250 kcal, 20g protein, 20g carbs, 10g fat',
        ),
      ]);
    }

    return Menu(
      id: 'muscle_gain_2500',
      name: 'Muscle Building Plan',
      description: '~2500 kcal/day - High protein for muscle growth and recovery',
      durationDays: 7,
      meals: meals,
    );
  }

  Menu _getWeightLossPlan() {
    // 1500 kcal/day - Weight loss plan
    final meals = <MenuMeal>[];
    
    for (int day = 1; day <= 7; day++) {
      meals.addAll([
        MenuMeal(
          id: 'loss_d${day}_breakfast',
          name: 'Breakfast',
          calories: 300,
          protein: 25,
          carbs: 30,
          fat: 10,
          mealType: 'breakfast',
          dayNumber: day,
          scheduledTime: '08:00',
          foods: [],
          instructions: 'Target: 300 kcal, 25g protein, 30g carbs, 10g fat',
        ),
        MenuMeal(
          id: 'loss_d${day}_snack1',
          name: 'Morning Snack',
          calories: 150,
          protein: 10,
          carbs: 15,
          fat: 5,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '10:30',
          foods: [],
          instructions: 'Target: 150 kcal, 10g protein, 15g carbs, 5g fat',
        ),
        MenuMeal(
          id: 'loss_d${day}_lunch',
          name: 'Lunch',
          calories: 400,
          protein: 35,
          carbs: 35,
          fat: 12,
          mealType: 'lunch',
          dayNumber: day,
          scheduledTime: '13:00',
          foods: [],
          instructions: 'Target: 400 kcal, 35g protein, 35g carbs, 12g fat',
        ),
        MenuMeal(
          id: 'loss_d${day}_snack2',
          name: 'Afternoon Snack',
          calories: 120,
          protein: 8,
          carbs: 12,
          fat: 4,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '16:00',
          foods: [],
          instructions: 'Target: 120 kcal, 8g protein, 12g carbs, 4g fat',
        ),
        MenuMeal(
          id: 'loss_d${day}_dinner',
          name: 'Dinner',
          calories: 450,
          protein: 40,
          carbs: 35,
          fat: 15,
          mealType: 'dinner',
          dayNumber: day,
          scheduledTime: '19:00',
          foods: [],
          instructions: 'Target: 450 kcal, 40g protein, 35g carbs, 15g fat',
        ),
        MenuMeal(
          id: 'loss_d${day}_snack3',
          name: 'Evening Snack',
          calories: 80,
          protein: 6,
          carbs: 8,
          fat: 2,
          mealType: 'snack',
          dayNumber: day,
          scheduledTime: '21:00',
          foods: [],
          instructions: 'Target: 80 kcal, 6g protein, 8g carbs, 2g fat',
        ),
      ]);
    }

    return Menu(
      id: 'weight_loss_1500',
      name: 'Weight Loss Plan',
      description: '~1500 kcal/day - Calorie deficit for healthy weight loss (~0.5kg per week)',
      durationDays: 7,
      meals: meals,
    );
  }

  // Notification Settings
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
