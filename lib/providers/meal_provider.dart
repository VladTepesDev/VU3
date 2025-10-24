import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../services/storage_service.dart';

class MealProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<DailyMeals> _dailyMealsList = [];

  MealProvider(this._storageService) {
    _loadMeals();
  }

  List<DailyMeals> get dailyMealsList => _dailyMealsList;

  Future<void> _loadMeals() async {
    _dailyMealsList = await _storageService.getMeals();
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
    if (todayMeals == null) {
      return {'calories': 0, 'protein': 0, 'carbs': 0, 'fat': 0};
    }

    return {
      'calories': todayMeals.totalCalories,
      'protein': todayMeals.totalProtein,
      'carbs': todayMeals.totalCarbs,
      'fat': todayMeals.totalFat,
    };
  }

  List<Meal> getMealsByType(String type) {
    final todayMeals = getTodayMeals();
    if (todayMeals == null) return [];

    return todayMeals.meals.where((meal) => meal.mealType == type).toList();
  }
}
