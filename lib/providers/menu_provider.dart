import 'package:flutter/foundation.dart';
import '../models/menu.dart';
import '../models/meal_log.dart';
import '../services/storage_service.dart';

class MenuProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Menu> _menus = [];
  Menu? _activeMenu;
  DateTime? _menuStartDate;
  List<MealLog> _mealLogs = [];

  MenuProvider(this._storageService) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadMenus();
    await _loadMealLogs();
    await _loadActiveMenu();
  }

  List<Menu> get menus => _menus;
  List<Menu> get customMenus => _menus.where((m) => m.isCustom).toList();
  List<Menu> get predefinedMenus => _menus.where((m) => !m.isCustom).toList();
  Menu? get activeMenu => _activeMenu;
  DateTime? get menuStartDate => _menuStartDate;
  List<MealLog> get mealLogs => _mealLogs;

  Future<void> _loadMenus() async {
    _menus = await _storageService.getMenus();
    notifyListeners();
  }

  Future<void> _loadMealLogs() async {
    _mealLogs = await _storageService.getMealLogs();
    notifyListeners();
  }

  Future<void> checkAndResetForNewDay() async {
    // Reload meal logs and regenerate for today
    await _loadMealLogs();
    if (_activeMenu != null) {
      await _generateMealLogsForActiveMenu();
    }
    notifyListeners();
  }

  Future<void> _loadActiveMenu() async {
    final menuId = await _storageService.getActiveMenuId();
    final startDate = await _storageService.getMenuStartDate();
    
    if (menuId != null) {
      await _loadMenus(); // Ensure menus are loaded
      
      // Try to find the menu in loaded menus
      try {
        _activeMenu = _menus.firstWhere((m) => m.id == menuId);
        _menuStartDate = startDate;
        await _generateMealLogsForActiveMenu();
        notifyListeners();
      } catch (e) {
        // Menu not found - it might have been dynamically generated
        // Will be regenerated when user opens MenusScreen
        debugPrint('Active menu with ID $menuId not found in storage');
        // Clear the invalid menu ID
        await _storageService.saveActiveMenuId(null);
        await _storageService.saveMenuStartDate(null);
      }
    }
  }

  // Method to regenerate and restore active menu from user profile
  Future<void> regenerateActiveMenuFromProfile(double targetCalories, String goal) async {
    final menuId = await _storageService.getActiveMenuId();
    
    if (menuId != null && _activeMenu == null) {
      // We have a saved menu ID but the menu wasn't found
      // Regenerate the menus and try to restore
      final generatedMenus = _storageService.generateMenusForUser(targetCalories, goal);
      
      // Try to find a menu with matching ID
      final restoredMenu = generatedMenus.firstWhere(
        (m) => m.id == menuId,
        orElse: () => generatedMenus.first,
      );
      
      if (restoredMenu.id == menuId) {
        // Perfect match found
        _activeMenu = restoredMenu;
        _menuStartDate = await _storageService.getMenuStartDate();
        
        // Add to menus list
        if (!_menus.any((m) => m.id == restoredMenu.id)) {
          _menus.add(restoredMenu);
          await _storageService.saveMenus(_menus);
        }
        
        await _generateMealLogsForActiveMenu();
        notifyListeners();
      }
    }
  }

  Future<void> addMenu(Menu menu) async {
    _menus.add(menu);
    await _storageService.saveMenus(_menus);
    notifyListeners();
  }

  Future<void> updateMenu(Menu menu) async {
    final index = _menus.indexWhere((m) => m.id == menu.id);
    if (index >= 0) {
      _menus[index] = menu;
      await _storageService.saveMenus(_menus);
      notifyListeners();
    }
  }

  Future<void> deleteMenu(String menuId) async {
    _menus.removeWhere((m) => m.id == menuId);
    await _storageService.saveMenus(_menus);
    
    if (_activeMenu?.id == menuId) {
      _activeMenu = null;
      _menuStartDate = null;
    }
    
    notifyListeners();
  }

  Future<void> setActiveMenu(Menu? menu) async {
    final bool planChanged = _activeMenu?.id != menu?.id;
    
    _activeMenu = menu;
    _menuStartDate = menu != null ? DateTime.now() : null;
    
    // Persist to storage
    await _storageService.saveActiveMenuId(menu?.id);
    await _storageService.saveMenuStartDate(_menuStartDate);
    
    // Save the menu to the menus list so it persists across app restarts
    if (menu != null) {
      // Check if menu already exists in list
      final existingIndex = _menus.indexWhere((m) => m.id == menu.id);
      if (existingIndex == -1) {
        // Add new menu
        _menus.add(menu);
      } else {
        // Update existing menu
        _menus[existingIndex] = menu;
      }
      await _storageService.saveMenus(_menus);
    }
    
    // When switching plans, only clear TODAY'S meal logs, keep historical data
    if (planChanged && menu != null) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // Remove only today's logs
      _mealLogs.removeWhere((log) =>
        log.scheduledDate.year == todayStart.year &&
        log.scheduledDate.month == todayStart.month &&
        log.scheduledDate.day == todayStart.day
      );
      
      await _storageService.saveMealLogs(_mealLogs);
    }
    
    if (menu != null) {
      await _generateMealLogsForActiveMenu();
    }
    
    notifyListeners();
  }

  Future<void> _generateMealLogsForActiveMenu() async {
    if (_activeMenu == null || _menuStartDate == null) return;

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final startDate = DateTime(_menuStartDate!.year, _menuStartDate!.month, _menuStartDate!.day);
    final daysDifference = todayStart.difference(startDate).inDays;
    final currentDay = (daysDifference % _activeMenu!.durationDays) + 1;

    for (var meal in _activeMenu!.meals.where((m) => m.dayNumber == currentDay)) {
      final existingLog = _mealLogs.firstWhere(
        (log) => log.menuMealId == meal.id && 
                 log.scheduledDate.year == todayStart.year &&
                 log.scheduledDate.month == todayStart.month &&
                 log.scheduledDate.day == todayStart.day,
        orElse: () => MealLog(
          id: '${meal.id}_${todayStart.toIso8601String()}',
          menuMealId: meal.id,
          scheduledDate: todayStart,
          status: MealLogStatus.upcoming,
        ),
      );

      if (!_mealLogs.any((log) => log.id == existingLog.id)) {
        await _storageService.addMealLog(existingLog);
        _mealLogs.add(existingLog);
      }
    }
  }

  List<MenuMeal> getTodayMenuMeals() {
    if (_activeMenu == null || _menuStartDate == null) return [];
    
    // Calculate current day of the plan (1-7, cycling)
    final today = DateTime.now();
    final startDate = DateTime(_menuStartDate!.year, _menuStartDate!.month, _menuStartDate!.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysDifference = todayDate.difference(startDate).inDays;
    final currentDay = (daysDifference % _activeMenu!.durationDays) + 1;
    
    return _activeMenu!.meals
        .where((meal) => meal.dayNumber == currentDay)
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  int? getCurrentPlanDay() {
    if (_activeMenu == null || _menuStartDate == null) return null;
    
    final today = DateTime.now();
    final startDate = DateTime(_menuStartDate!.year, _menuStartDate!.month, _menuStartDate!.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysDifference = todayDate.difference(startDate).inDays;
    return (daysDifference % _activeMenu!.durationDays) + 1;
  }

  int? getTotalDaysOnPlan() {
    if (_activeMenu == null || _menuStartDate == null) return null;
    
    final today = DateTime.now();
    final startDate = DateTime(_menuStartDate!.year, _menuStartDate!.month, _menuStartDate!.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    return todayDate.difference(startDate).inDays + 1;
  }

  double getTodayTargetCalories() {
    final todayMeals = getTodayMenuMeals();
    return todayMeals.fold(0.0, (sum, meal) => sum + meal.calories);
  }

  Map<String, double> getTodayTargetMacros() {
    final todayMeals = getTodayMenuMeals();
    return {
      'calories': todayMeals.fold(0.0, (sum, meal) => sum + meal.calories),
      'protein': todayMeals.fold(0.0, (sum, meal) => sum + meal.protein),
      'carbs': todayMeals.fold(0.0, (sum, meal) => sum + meal.carbs),
      'fat': todayMeals.fold(0.0, (sum, meal) => sum + meal.fat),
    };
  }

  double getPlanAdherence() {
    if (_activeMenu == null || _menuStartDate == null) return 0.0;
    
    final today = DateTime.now();
    final startDate = DateTime(_menuStartDate!.year, _menuStartDate!.month, _menuStartDate!.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysSinceStart = todayDate.difference(startDate).inDays + 1;
    
    // Count completed meals
    int completedCount = 0;
    int totalExpectedMeals = 0;
    
    for (int i = 0; i < daysSinceStart; i++) {
      final checkDate = startDate.add(Duration(days: i));
      final planDay = (i % _activeMenu!.durationDays) + 1;
      final dayMeals = _activeMenu!.meals.where((m) => m.dayNumber == planDay).toList();
      
      totalExpectedMeals += dayMeals.length;
      
      for (var meal in dayMeals) {
        final log = getMealLog(meal.id, checkDate);
        if (log?.status == MealLogStatus.completed) {
          completedCount++;
        }
      }
    }
    
    if (totalExpectedMeals == 0) return 0.0;
    return (completedCount / totalExpectedMeals * 100).clamp(0.0, 100.0);
  }

  MealLog? getMealLog(String menuMealId, DateTime date) {
    final dateStart = DateTime(date.year, date.month, date.day);
    try {
      return _mealLogs.firstWhere(
        (log) => log.menuMealId == menuMealId &&
                 log.scheduledDate.year == dateStart.year &&
                 log.scheduledDate.month == dateStart.month &&
                 log.scheduledDate.day == dateStart.day,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> logMeal({
    required String menuMealId,
    String? imagePath,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? notes,
  }) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final existingLog = getMealLog(menuMealId, todayStart);
    
    final log = (existingLog ?? MealLog(
      id: '${menuMealId}_${todayStart.toIso8601String()}',
      menuMealId: menuMealId,
      scheduledDate: todayStart,
      status: MealLogStatus.upcoming,
    )).copyWith(
      status: MealLogStatus.completed,
      loggedAt: DateTime.now(),
      imagePath: imagePath,
      actualCalories: calories,
      actualProtein: protein,
      actualCarbs: carbs,
      actualFat: fat,
      notes: notes,
    );

    if (existingLog != null) {
      await _storageService.updateMealLog(log);
      final index = _mealLogs.indexWhere((l) => l.id == log.id);
      if (index >= 0) {
        _mealLogs[index] = log;
      }
    } else {
      await _storageService.addMealLog(log);
      _mealLogs.add(log);
    }

    await _storageService.saveMealLogs(_mealLogs);
    await _updateDailyStatistics();
    notifyListeners();
  }
  
  List<MealLog> get todayCompletedLogs {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    return _mealLogs.where((log) =>
      log.scheduledDate.year == todayStart.year &&
      log.scheduledDate.month == todayStart.month &&
      log.scheduledDate.day == todayStart.day &&
      log.status == MealLogStatus.completed
    ).toList();
  }
  
  /// Check if a meal can be logged based on sequential ordering
  /// A meal can only be logged if all previous meals (by scheduled time) are completed, missed, or replaced by manual meals
  bool canLogMeal(String menuMealId) {
    if (_activeMenu == null) return true; // No restrictions if no active menu
    
    final todayMeals = getTodayMenuMeals();
    if (todayMeals.isEmpty) return true;
    
    // Find the meal in today's schedule
    final mealIndex = todayMeals.indexWhere((m) => m.id == menuMealId);
    if (mealIndex == -1) return true; // Not in today's schedule, allow
    
    // First meal can always be logged
    if (mealIndex == 0) return true;
    
    // Debug: print current state
    debugPrint('=== canLogMeal Debug ===');
    debugPrint('Checking meal: ${todayMeals[mealIndex].name} (${todayMeals[mealIndex].mealType})');
    
    // Check if all previous PLAN meals are completed or missed
    // Manual meals do NOT unlock plan meals - only completing plan meals does
    final today = DateTime.now();
    for (int i = 0; i < mealIndex; i++) {
      final previousMeal = todayMeals[i];
      final log = getMealLog(previousMeal.id, today);
      
      debugPrint('Checking previous meal ${i + 1}: ${previousMeal.name} (${previousMeal.mealType})');
      debugPrint('  - Log status: ${log?.status}');
      
      // The meal must be completed or missed to unlock the next meal
      final isLoggedOrMissed = log != null && 
          (log.status == MealLogStatus.completed || log.status == MealLogStatus.missed);
      
      debugPrint('  - Is satisfied: $isLoggedOrMissed');
      
      // If this previous plan meal is not completed or missed, block the current meal
      if (!isLoggedOrMissed) {
        debugPrint('  - BLOCKED! Previous plan meal not completed or missed');
        return false;
      }
    }
    
    debugPrint('=== Meal CAN be logged ===');
    return true;
  }
  
  /// Get the next meal that needs to be logged
  MenuMeal? getNextMealToLog() {
    final todayMeals = getTodayMenuMeals();
    if (todayMeals.isEmpty) return null;
    
    final today = DateTime.now();
    for (var meal in todayMeals) {
      final log = getMealLog(meal.id, today);
      if (log == null || 
          (log.status != MealLogStatus.completed && log.status != MealLogStatus.missed)) {
        return meal;
      }
    }
    
    return null; // All meals completed or missed
  }

  Map<String, double> getTodayConsumedFromPlan() {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    
    for (var log in todayCompletedLogs) {
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

  Future<void> markMealAsMissed(String menuMealId) async {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final existingLog = getMealLog(menuMealId, todayStart);
    
    if (existingLog != null) {
      final log = existingLog.copyWith(status: MealLogStatus.missed);
      await _storageService.updateMealLog(log);
      final index = _mealLogs.indexWhere((l) => l.id == log.id);
      if (index >= 0) {
        _mealLogs[index] = log;
      }
      await _updateDailyStatistics(); // Update statistics when meal is marked as missed
      notifyListeners();
    }
  }

  // Update daily statistics after logging meals
  // This now triggers MealProvider to fully recalculate stats
  Future<void> _updateDailyStatistics() async {
    // Statistics are now handled by MealProvider's updateDailyStatistics()
    // This method is kept for backwards compatibility but does nothing
    // The actual update happens in logMeal() which calls MealProvider.updateDailyStatistics()
    notifyListeners();
  }
}

