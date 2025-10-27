import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../models/meal_log.dart';
import '../models/daily_stats.dart';
import '../services/storage_service.dart';

class MealProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<DailyMeals> _dailyMealsList = [];
  List<MealLog> _mealLogs = [];
  List<DailyStats> _dailyStats = [];

  MealProvider(this._storageService) {
    _loadMeals();
    _loadMealLogs();
    _loadDailyStats();
  }

  List<DailyMeals> get dailyMealsList => _dailyMealsList;
  List<DailyStats> get dailyStats => _dailyStats;

  Future<void> _loadMeals() async {
    _dailyMealsList = await _storageService.getMeals();
    notifyListeners();
  }

  Future<void> _loadMealLogs() async {
    _mealLogs = await _storageService.getMealLogs();
    notifyListeners();
  }

  Future<void> _loadDailyStats() async {
    _dailyStats = await _storageService.getDailyStats();
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
    await updateDailyStatistics();
  }

  Future<void> updateMeal(String mealId, Meal updatedMeal) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final todayIndex = _dailyMealsList.indexWhere((dm) =>
        dm.date.year == todayStart.year &&
        dm.date.month == todayStart.month &&
        dm.date.day == todayStart.day);

    if (todayIndex >= 0) {
      final updatedMeals = _dailyMealsList[todayIndex].meals.map((meal) {
        return meal.id == mealId ? updatedMeal : meal;
      }).toList();

      _dailyMealsList[todayIndex] = DailyMeals(
        date: todayStart,
        meals: updatedMeals,
      );

      await _storageService.saveMeals(_dailyMealsList);
      notifyListeners();
      await updateDailyStatistics();
    }
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
      await updateDailyStatistics();
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

    // Start with manually logged meals (from add meal screen)
    double calories = todayMeals?.totalCalories ?? 0;
    double protein = todayMeals?.totalProtein ?? 0;
    double carbs = todayMeals?.totalCarbs ?? 0;
    double fat = todayMeals?.totalFat ?? 0;

    // Add completed plan meals (from menu/plan quick log)
    final todayLogs = _mealLogs.where((log) =>
      log.scheduledDate.year == todayStart.year &&
      log.scheduledDate.month == todayStart.month &&
      log.scheduledDate.day == todayStart.day &&
      log.status == MealLogStatus.completed
    );

    for (var log in todayLogs) {
      // Use actual values if provided, otherwise use the plan's target values
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

  // Get average daily calories for a specific period
  double getAverageCalories({int days = 7}) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));
    
    final recentMeals = _dailyMealsList
        .where((dm) => dm.date.isAfter(cutoffDate))
        .toList();
    
    if (recentMeals.isEmpty) return 0;
    
    double totalCalories = 0;
    for (var dm in recentMeals) {
      totalCalories += dm.totalCalories;
    }
    
    // Include meal logs
    final cutoffStart = DateTime(cutoffDate.year, cutoffDate.month, cutoffDate.day);
    final recentLogs = _mealLogs.where((log) =>
      log.scheduledDate.isAfter(cutoffStart) &&
      log.status == MealLogStatus.completed
    );
    
    for (var log in recentLogs) {
      totalCalories += log.actualCalories ?? 0;
    }
    
    return totalCalories / days;
  }

  // Get macro distribution percentage
  Map<String, double> getMacroDistribution({int days = 7}) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));
    
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    
    final recentMeals = _dailyMealsList
        .where((dm) => dm.date.isAfter(cutoffDate))
        .toList();
    
    for (var dm in recentMeals) {
      totalProtein += dm.totalProtein;
      totalCarbs += dm.totalCarbs;
      totalFat += dm.totalFat;
    }
    
    // Include meal logs
    final cutoffStart = DateTime(cutoffDate.year, cutoffDate.month, cutoffDate.day);
    final recentLogs = _mealLogs.where((log) =>
      log.scheduledDate.isAfter(cutoffStart) &&
      log.status == MealLogStatus.completed
    );
    
    for (var log in recentLogs) {
      totalProtein += log.actualProtein ?? 0;
      totalCarbs += log.actualCarbs ?? 0;
      totalFat += log.actualFat ?? 0;
    }
    
    final totalMacros = totalProtein + totalCarbs + totalFat;
    if (totalMacros == 0) {
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }
    
    return {
      'protein': (totalProtein / totalMacros * 100),
      'carbs': (totalCarbs / totalMacros * 100),
      'fat': (totalFat / totalMacros * 100),
    };
  }

  // Get total days tracked
  int getTotalDaysTracked() {
    if (_dailyMealsList.isEmpty && _mealLogs.isEmpty) return 0;
    
    final uniqueDates = <DateTime>{};
    
    for (var dm in _dailyMealsList) {
      uniqueDates.add(DateTime(dm.date.year, dm.date.month, dm.date.day));
    }
    
    for (var log in _mealLogs.where((l) => l.status == MealLogStatus.completed)) {
      uniqueDates.add(DateTime(
        log.scheduledDate.year,
        log.scheduledDate.month,
        log.scheduledDate.day,
      ));
    }
    
    return uniqueDates.length;
  }

  // Get tracking streak (consecutive days)
  int getCurrentStreak() {
    final now = DateTime.now();
    final trackedDates = <DateTime>{};
    
    for (var dm in _dailyMealsList.where((dm) => dm.meals.isNotEmpty)) {
      trackedDates.add(DateTime(dm.date.year, dm.date.month, dm.date.day));
    }
    
    for (var log in _mealLogs.where((l) => l.status == MealLogStatus.completed)) {
      trackedDates.add(DateTime(
        log.scheduledDate.year,
        log.scheduledDate.month,
        log.scheduledDate.day,
      ));
    }
    
    if (trackedDates.isEmpty) return 0;
    
    int streak = 0;
    var checkDate = DateTime(now.year, now.month, now.day);
    
    while (trackedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  // Calculate and save daily statistics
  Future<void> updateDailyStatistics({DateTime? forDate}) async {
    final date = forDate ?? DateTime.now();
    final dateStart = DateTime(date.year, date.month, date.day);

    // Get manual meals for the day
    final manualMeals = _dailyMealsList
        .where((dm) =>
            dm.date.year == dateStart.year &&
            dm.date.month == dateStart.month &&
            dm.date.day == dateStart.day)
        .expand((dm) => dm.meals)
        .toList();

    // Get plan meals for the day
    final planLogs = _mealLogs.where((log) =>
        log.scheduledDate.year == dateStart.year &&
        log.scheduledDate.month == dateStart.month &&
        log.scheduledDate.day == dateStart.day &&
        log.status == MealLogStatus.completed).toList();

    // Convert to MealEntry objects
    final List<MealEntry> meals = [];

    for (var meal in manualMeals) {
      meals.add(MealEntry(
        id: meal.id,
        name: meal.name,
        type: meal.mealType,
        calories: meal.calories,
        protein: meal.protein,
        carbs: meal.carbs,
        fat: meal.fat,
        timestamp: meal.createdAt,
        source: 'manual',
        imagePath: meal.imagePath,
      ));
    }

    for (var log in planLogs) {
      meals.add(MealEntry(
        id: log.id,
        name: 'Plan Meal', // We'll need to get actual name from menu
        type: 'plan',
        calories: log.actualCalories ?? 0,
        protein: log.actualProtein ?? 0,
        carbs: log.actualCarbs ?? 0,
        fat: log.actualFat ?? 0,
        timestamp: log.loggedAt ?? dateStart,
        source: 'plan',
        imagePath: log.imagePath,
      ));
    }

    // Calculate totals
    final totalCalories = meals.fold<double>(0, (sum, m) => sum + m.calories);
    final totalProtein = meals.fold<double>(0, (sum, m) => sum + m.protein);
    final totalCarbs = meals.fold<double>(0, (sum, m) => sum + m.carbs);
    final totalFat = meals.fold<double>(0, (sum, m) => sum + m.fat);

    // Create stats
    final stats = DailyStats(
      id: 'stats_${dateStart.toIso8601String()}',
      date: dateStart,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      manualMealCount: manualMeals.length,
      planMealCount: planLogs.length,
      planAdherence: null, // Will be calculated by MenuProvider
      meals: meals,
    );

    await _storageService.addOrUpdateDailyStats(stats);
    await _loadDailyStats();
  }

  // Get stats for a specific date
  DailyStats? getStatsForDate(DateTime date) {
    final dateStart = DateTime(date.year, date.month, date.day);
    try {
      return _dailyStats.firstWhere((s) =>
          s.date.year == dateStart.year &&
          s.date.month == dateStart.month &&
          s.date.day == dateStart.day);
    } catch (e) {
      return null;
    }
  }

  // Get stats for a date range
  List<DailyStats> getStatsForRange(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    return _dailyStats
        .where((s) =>
            (s.date.isAfter(startDate) || s.date.isAtSameMomentAs(startDate)) &&
            (s.date.isBefore(endDate) || s.date.isAtSameMomentAs(endDate)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Get average calories for a period
  double getAverageCaloriesForPeriod(int days) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final stats = getStatsForRange(startDate, now);

    if (stats.isEmpty) return 0;

    final totalCalories = stats.fold<double>(0, (sum, s) => sum + s.totalCalories);
    return totalCalories / days; // Divide by actual days, not stats.length
  }
}

