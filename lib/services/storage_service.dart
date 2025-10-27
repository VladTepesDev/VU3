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
      Menu(
        id: 'balanced_1',
        name: 'Balanced Weekly Plan',
        description: 'A well-balanced meal plan with variety',
        durationDays: 7,
        meals: [
          MenuMeal(
            id: 'm1_1',
            name: 'Breakfast',
            calories: 520,
            protein: 25,
            carbs: 60,
            fat: 18,
            mealType: 'breakfast',
            dayNumber: 1,
            scheduledTime: '08:00',
            foods: [],
            instructions: 'Target: 520 kcal, 25g protein, 60g carbs, 18g fat',
          ),
          MenuMeal(
            id: 'm1_2',
            name: 'Lunch',
            calories: 680,
            protein: 52,
            carbs: 55,
            fat: 24,
            mealType: 'lunch',
            dayNumber: 1,
            scheduledTime: '13:00',
            foods: [],
            instructions: 'Target: 680 kcal, 52g protein, 55g carbs, 24g fat',
          ),
          MenuMeal(
            id: 'm1_3',
            name: 'Dinner',
            calories: 750,
            protein: 55,
            carbs: 65,
            fat: 28,
            mealType: 'dinner',
            dayNumber: 1,
            scheduledTime: '19:00',
            foods: [],
            instructions: 'Target: 750 kcal, 55g protein, 65g carbs, 28g fat',
          ),
          MenuMeal(
            id: 'm1_snack1',
            name: 'Morning Snack',
            calories: 250,
            protein: 25,
            carbs: 20,
            fat: 8,
            mealType: 'snack',
            dayNumber: 1,
            scheduledTime: '10:30',
            foods: [],
            instructions: 'Target: 250 kcal, 25g protein, 20g carbs, 8g fat',
          ),
          MenuMeal(
            id: 'm1_snack2',
            name: 'Afternoon Snack',
            calories: 220,
            protein: 8,
            carbs: 18,
            fat: 14,
            mealType: 'snack',
            dayNumber: 1,
            scheduledTime: '16:00',
            foods: [],
            instructions: 'Target: 220 kcal, 8g protein, 18g carbs, 14g fat',
          ),
          MenuMeal(
            id: 'm2_1',
            name: 'Breakfast',
            calories: 380,
            protein: 20,
            carbs: 45,
            fat: 12,
            mealType: 'breakfast',
            dayNumber: 2,
            scheduledTime: '08:00',
            foods: [],
            instructions: 'Target: 380 kcal, 20g protein, 45g carbs, 12g fat',
          ),
          MenuMeal(
            id: 'm2_2',
            name: 'Lunch',
            calories: 480,
            protein: 35,
            carbs: 40,
            fat: 18,
            mealType: 'lunch',
            dayNumber: 2,
            scheduledTime: '13:00',
            foods: [],
            instructions: 'Target: 480 kcal, 35g protein, 40g carbs, 18g fat',
          ),
          MenuMeal(
            id: 'm2_3',
            name: 'Dinner',
            calories: 520,
            protein: 38,
            carbs: 45,
            fat: 20,
            mealType: 'dinner',
            dayNumber: 2,
            scheduledTime: '19:00',
            foods: [],
            instructions: 'Target: 520 kcal, 38g protein, 45g carbs, 20g fat',
          ),
        ],
      ),
      Menu(
        id: 'high_protein',
        name: 'High Protein Plan',
        description: 'For muscle building and recovery',
        durationDays: 7,
        meals: [
          MenuMeal(
            id: 'hp1_1',
            name: 'Breakfast',
            calories: 400,
            protein: 35,
            carbs: 40,
            fat: 12,
            mealType: 'breakfast',
            dayNumber: 1,
            scheduledTime: '08:00',
            foods: [],
            instructions: 'Target: 400 kcal, 35g protein, 40g carbs, 12g fat',
          ),
          MenuMeal(
            id: 'hp1_2',
            name: 'Lunch',
            calories: 600,
            protein: 50,
            carbs: 45,
            fat: 22,
            mealType: 'lunch',
            dayNumber: 1,
            scheduledTime: '13:00',
            foods: [],
            instructions: 'Target: 600 kcal, 50g protein, 45g carbs, 22g fat',
          ),
          MenuMeal(
            id: 'hp1_3',
            name: 'Dinner',
            calories: 580,
            protein: 52,
            carbs: 48,
            fat: 16,
            mealType: 'dinner',
            dayNumber: 1,
            scheduledTime: '19:00',
            foods: [],
            instructions: 'Target: 580 kcal, 52g protein, 48g carbs, 16g fat',
          ),
        ],
      ),
      Menu(
        id: 'weight_loss',
        name: 'Weight Loss Plan',
        description: 'Calorie-controlled meals for weight loss',
        durationDays: 7,
        meals: [
          MenuMeal(
            id: 'wl1_1',
            name: 'Breakfast',
            calories: 280,
            protein: 25,
            carbs: 20,
            fat: 10,
            mealType: 'breakfast',
            dayNumber: 1,
            scheduledTime: '08:00',
            foods: [],
            instructions: 'Target: 280 kcal, 25g protein, 20g carbs, 10g fat',
          ),
          MenuMeal(
            id: 'wl1_2',
            name: 'Lunch',
            calories: 320,
            protein: 35,
            carbs: 15,
            fat: 12,
            mealType: 'lunch',
            dayNumber: 1,
            scheduledTime: '13:00',
            foods: [],
            instructions: 'Target: 320 kcal, 35g protein, 15g carbs, 12g fat',
          ),
          MenuMeal(
            id: 'wl1_3',
            name: 'Dinner',
            calories: 380,
            protein: 40,
            carbs: 20,
            fat: 14,
            mealType: 'dinner',
            dayNumber: 1,
            scheduledTime: '19:00',
            foods: [],
            instructions: 'Target: 380 kcal, 40g protein, 20g carbs, 14g fat',
          ),
        ],
      ),
    ];
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
