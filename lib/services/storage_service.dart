import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/meal.dart';
import '../models/menu.dart';
import '../models/notification_settings.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _mealsKey = 'meals';
  static const String _menusKey = 'menus';
  static const String _notificationSettingsKey = 'notification_settings';
  static const String _isFirstLaunchKey = 'is_first_launch';

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
            name: 'Oatmeal with Berries',
            calories: 350,
            protein: 12,
            carbs: 55,
            fat: 8,
            mealType: 'breakfast',
            dayNumber: 1,
            foods: [
              FoodItem(name: 'Rolled oats', amount: 60, unit: 'g'),
              FoodItem(name: 'Mixed berries', amount: 100, unit: 'g'),
              FoodItem(name: 'Honey', amount: 15, unit: 'ml'),
              FoodItem(name: 'Almonds', amount: 20, unit: 'g'),
            ],
            instructions: 'Cook oats with water or milk. Top with berries, honey, and almonds.',
          ),
          MenuMeal(
            id: 'm1_2',
            name: 'Grilled Chicken Salad',
            calories: 450,
            protein: 40,
            carbs: 25,
            fat: 20,
            mealType: 'lunch',
            dayNumber: 1,
            foods: [
              FoodItem(name: 'Chicken breast', amount: 150, unit: 'g'),
              FoodItem(name: 'Mixed greens', amount: 100, unit: 'g'),
              FoodItem(name: 'Cherry tomatoes', amount: 50, unit: 'g'),
              FoodItem(name: 'Cucumber', amount: 50, unit: 'g'),
              FoodItem(name: 'Olive oil dressing', amount: 15, unit: 'ml'),
            ],
            instructions: 'Grill chicken, slice and place on mixed greens with vegetables. Drizzle with dressing.',
          ),
          MenuMeal(
            id: 'm1_3',
            name: 'Salmon with Vegetables',
            calories: 550,
            protein: 45,
            carbs: 30,
            fat: 25,
            mealType: 'dinner',
            dayNumber: 1,
            foods: [
              FoodItem(name: 'Salmon fillet', amount: 180, unit: 'g'),
              FoodItem(name: 'Broccoli', amount: 150, unit: 'g'),
              FoodItem(name: 'Sweet potato', amount: 150, unit: 'g'),
              FoodItem(name: 'Lemon', amount: 1, unit: 'piece'),
            ],
            instructions: 'Bake salmon at 180°C for 15-20 min. Steam broccoli and roast sweet potato.',
          ),
          MenuMeal(
            id: 'm2_1',
            name: 'Greek Yogurt Bowl',
            calories: 380,
            protein: 20,
            carbs: 45,
            fat: 12,
            mealType: 'breakfast',
            dayNumber: 2,
            foods: [
              FoodItem(name: 'Greek yogurt', amount: 200, unit: 'g'),
              FoodItem(name: 'Granola', amount: 40, unit: 'g'),
              FoodItem(name: 'Banana', amount: 1, unit: 'piece'),
              FoodItem(name: 'Chia seeds', amount: 10, unit: 'g'),
            ],
            instructions: 'Layer yogurt with granola, sliced banana, and chia seeds.',
          ),
          MenuMeal(
            id: 'm2_2',
            name: 'Turkey Wrap',
            calories: 480,
            protein: 35,
            carbs: 40,
            fat: 18,
            mealType: 'lunch',
            dayNumber: 2,
            foods: [
              FoodItem(name: 'Whole wheat tortilla', amount: 1, unit: 'piece'),
              FoodItem(name: 'Turkey breast', amount: 100, unit: 'g'),
              FoodItem(name: 'Avocado', amount: 50, unit: 'g'),
              FoodItem(name: 'Lettuce', amount: 30, unit: 'g'),
              FoodItem(name: 'Tomato', amount: 50, unit: 'g'),
            ],
            instructions: 'Layer ingredients on tortilla and wrap tightly. Cut in half.',
          ),
          MenuMeal(
            id: 'm2_3',
            name: 'Beef Stir Fry',
            calories: 520,
            protein: 38,
            carbs: 45,
            fat: 20,
            mealType: 'dinner',
            dayNumber: 2,
            foods: [
              FoodItem(name: 'Beef sirloin', amount: 150, unit: 'g'),
              FoodItem(name: 'Mixed vegetables', amount: 200, unit: 'g'),
              FoodItem(name: 'Brown rice', amount: 150, unit: 'g'),
              FoodItem(name: 'Soy sauce', amount: 15, unit: 'ml'),
              FoodItem(name: 'Garlic', amount: 2, unit: 'cloves'),
            ],
            instructions: 'Stir fry beef with garlic, add vegetables. Serve over brown rice.',
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
            name: 'Protein Pancakes',
            calories: 400,
            protein: 35,
            carbs: 40,
            fat: 12,
            mealType: 'breakfast',
            dayNumber: 1,
            foods: [
              FoodItem(name: 'Eggs', amount: 3, unit: 'pieces'),
              FoodItem(name: 'Protein powder', amount: 30, unit: 'g'),
              FoodItem(name: 'Oats', amount: 40, unit: 'g'),
              FoodItem(name: 'Banana', amount: 1, unit: 'piece'),
            ],
            instructions: 'Blend all ingredients. Cook pancakes in non-stick pan.',
          ),
          MenuMeal(
            id: 'hp1_2',
            name: 'Beef and Quinoa Bowl',
            calories: 600,
            protein: 50,
            carbs: 45,
            fat: 22,
            mealType: 'lunch',
            dayNumber: 1,
            foods: [
              FoodItem(name: 'Ground beef', amount: 150, unit: 'g'),
              FoodItem(name: 'Quinoa', amount: 100, unit: 'g'),
              FoodItem(name: 'Black beans', amount: 80, unit: 'g'),
              FoodItem(name: 'Corn', amount: 50, unit: 'g'),
              FoodItem(name: 'Avocado', amount: 40, unit: 'g'),
            ],
            instructions: 'Cook beef and quinoa. Mix with beans and corn. Top with avocado.',
          ),
          MenuMeal(
            id: 'hp1_3',
            name: 'Chicken and Sweet Potato',
            calories: 580,
            protein: 52,
            carbs: 48,
            fat: 16,
            mealType: 'dinner',
            dayNumber: 1,
            foods: [
              FoodItem(name: 'Chicken breast', amount: 200, unit: 'g'),
              FoodItem(name: 'Sweet potato', amount: 200, unit: 'g'),
              FoodItem(name: 'Green beans', amount: 150, unit: 'g'),
              FoodItem(name: 'Olive oil', amount: 10, unit: 'ml'),
            ],
            instructions: 'Grill chicken, bake sweet potato, steam green beans.',
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
            name: 'Egg White Omelette',
            calories: 280,
            protein: 25,
            carbs: 20,
            fat: 10,
            mealType: 'breakfast',
            dayNumber: 1,
            foods: [
              FoodItem(name: 'Egg whites', amount: 150, unit: 'ml'),
              FoodItem(name: 'Spinach', amount: 50, unit: 'g'),
              FoodItem(name: 'Mushrooms', amount: 40, unit: 'g'),
              FoodItem(name: 'Whole wheat toast', amount: 1, unit: 'slice'),
            ],
            instructions: 'Cook egg whites with vegetables. Serve with toast.',
          ),
          MenuMeal(
            id: 'wl1_2',
            name: 'Tuna Salad',
            calories: 320,
            protein: 35,
            carbs: 15,
            fat: 12,
            mealType: 'lunch',
            dayNumber: 1,
            foods: [
              FoodItem(name: 'Canned tuna', amount: 120, unit: 'g'),
              FoodItem(name: 'Mixed greens', amount: 100, unit: 'g'),
              FoodItem(name: 'Cucumber', amount: 60, unit: 'g'),
              FoodItem(name: 'Tomatoes', amount: 60, unit: 'g'),
              FoodItem(name: 'Lemon juice', amount: 15, unit: 'ml'),
            ],
            instructions: 'Mix tuna with vegetables. Dress with lemon juice.',
          ),
          MenuMeal(
            id: 'wl1_3',
            name: 'Grilled Fish with Vegetables',
            calories: 380,
            protein: 40,
            carbs: 20,
            fat: 14,
            mealType: 'dinner',
            dayNumber: 1,
            foods: [
              FoodItem(name: 'White fish', amount: 180, unit: 'g'),
              FoodItem(name: 'Zucchini', amount: 150, unit: 'g'),
              FoodItem(name: 'Bell peppers', amount: 100, unit: 'g'),
              FoodItem(name: 'Herbs', amount: 5, unit: 'g'),
            ],
            instructions: 'Grill fish with herbs. Roast vegetables.',
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
