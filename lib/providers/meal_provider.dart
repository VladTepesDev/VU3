import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../models/meal_log.dart';
import '../services/storage_service.dart';

class MealProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<DailyMeals> _dailyMealsList = [];
  List<MealLog> _mealLogs = [];

  MealProvider(this._storageService) {
    _loadMeals();
    _loadMealLogs();
  }

  List<DailyMeals> get dailyMealsList => _dailyMealsList;

  Future<void> _loadMeals() async {
    _dailyMealsList = await _storageService.getMeals();
    notifyListeners();
  }

  Future<void> _loadMealLogs() async {
    _mealLogs = await _storageService.getMealLogs();
    notifyListeners();
  }

  Future<void> refreshMealLogs() async {
    _mealLogs = await _storageService.getMealLogs();
    notifyListeners();
  }

  DailyMeals? getTodayMeals() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    try {
      return _dailyMealsList.firstWhere((dm) =>
          dm.date.year == todayStart.year &&
          dm.date.month == todayStart.month &&
          dm.date.day == todayStart.day);
    } catch (e) {
      return null;
    }
  }

  Future<void> addMeal(Meal meal) async {
    await _storageService.addMeal(meal);
    await _loadMeals();
  }

  Future<void> deleteMeal(String mealId) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final todayIndex = _dailyMealsList.indexWhere((dm) =>
        dm.date.year == todayStart.year &&
        dm.date.month == todayStart.month &&
        dm.date.day == todayStart.day);

    if (todayIndex >= 0) {
      final updatedMeals = _dailyMealsList[todayIndex]
          .meals
          .where((meal) => meal.id != mealId)
          .toList();

      _dailyMealsList[todayIndex] = DailyMeals(
        date: todayStart,
        meals: updatedMeals,
      );

      await _storageService.saveMeals(_dailyMealsList);
      notifyListeners();
    }
  }

  List<DailyMeals> getWeekMeals() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return _dailyMealsList
        .where((dm) => dm.date.isAfter(weekAgo))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  double getWeeklyAverageCalories() {
    final weekMeals = getWeekMeals();
    if (weekMeals.isEmpty) return 0;

    final totalCalories = weekMeals.fold<double>(
      0,
      (sum, dm) => sum + dm.totalCalories,
    );

    return totalCalories / weekMeals.length;
  }

  Map<String, double> getTodayMacros() {
    final todayMeals = getTodayMeals();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    double calories = todayMeals?.totalCalories ?? 0;
    double protein = todayMeals?.totalProtein ?? 0;
    double carbs = todayMeals?.totalCarbs ?? 0;
    double fat = todayMeals?.totalFat ?? 0;

    final todayLogs = _mealLogs.where((log) =>
      log.scheduledDate.year == todayStart.year &&
      log.scheduledDate.month == todayStart.month &&
      log.scheduledDate.day == todayStart.day &&
      log.status == MealLogStatus.completed
    );

    for (var log in todayLogs) {
      calories += log.actualCalories ?? 0;
      protein += log.actualProtein ?? 0;
      carbs += log.actualCarbs ?? 0;
      fat += log.actualFat ?? 0;
    }

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  List<Meal> getMealsByType(String type) {
    final todayMeals = getTodayMeals();
    if (todayMeals == null) return [];

    return todayMeals.meals.where((meal) => meal.mealType == type).toList();
  }
}
