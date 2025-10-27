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
    _loadMenus();
    _loadMealLogs();
    _loadActiveMenu();
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

  Future<void> _loadActiveMenu() async {
    final menuId = await _storageService.getActiveMenuId();
    final startDate = await _storageService.getMenuStartDate();
    
    if (menuId != null) {
      await _loadMenus(); // Ensure menus are loaded
      _activeMenu = _menus.firstWhere(
        (m) => m.id == menuId,
        orElse: () => _menus.first,
      );
      _menuStartDate = startDate;
      await _generateMealLogsForActiveMenu();
      notifyListeners();
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
    _activeMenu = menu;
    _menuStartDate = menu != null ? DateTime.now() : null;
    
    // Persist to storage
    await _storageService.saveActiveMenuId(menu?.id);
    await _storageService.saveMenuStartDate(_menuStartDate);
    
    if (menu != null) {
      await _generateMealLogsForActiveMenu();
    }
    
    notifyListeners();
  }

  Future<void> _generateMealLogsForActiveMenu() async {
    if (_activeMenu == null || _menuStartDate == null) return;

    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    for (var meal in _activeMenu!.meals.where((m) => m.dayNumber == 1)) {
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
    if (_activeMenu == null) return [];
    
    return _activeMenu!.meals
        .where((meal) => meal.dayNumber == 1)
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
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
      notifyListeners();
    }
  }
}
