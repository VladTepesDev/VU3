import 'package:flutter/foundation.dart';
import '../models/menu.dart';
import '../services/storage_service.dart';

class MenuProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Menu> _menus = [];
  Menu? _activeMenu;

  MenuProvider(this._storageService) {
    _loadMenus();
  }

  List<Menu> get menus => _menus;
  List<Menu> get customMenus => _menus.where((m) => m.isCustom).toList();
  List<Menu> get predefinedMenus => _menus.where((m) => !m.isCustom).toList();
  Menu? get activeMenu => _activeMenu;

  Future<void> _loadMenus() async {
    _menus = await _storageService.getMenus();
    notifyListeners();
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
    }
    
    notifyListeners();
  }

  void setActiveMenu(Menu? menu) {
    _activeMenu = menu;
    notifyListeners();
  }

  List<MenuMeal> getTodayMenuMeals() {
    if (_activeMenu == null) return [];
    
    final daysSinceStart = DateTime.now().difference(_activeMenu!.meals.first.dayNumber as DateTime).inDays;
    final currentDay = (daysSinceStart % _activeMenu!.durationDays) + 1;
    
    return _activeMenu!.meals
        .where((meal) => meal.dayNumber == currentDay)
        .toList();
  }
}
