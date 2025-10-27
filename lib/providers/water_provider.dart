import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterProvider extends ChangeNotifier {
  int _glassesConsumed = 0;
  final int dailyGoal = 8;

  WaterProvider() {
    _loadWaterData();
  }

  int get glassesConsumed => _glassesConsumed;
  double get progress => (_glassesConsumed / dailyGoal).clamp(0.0, 1.0);
  int get remaining => (dailyGoal - _glassesConsumed).clamp(0, dailyGoal);

  Future<void> _loadWaterData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('water_last_date');
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';

    if (lastDate == todayStr) {
      _glassesConsumed = prefs.getInt('water_glasses') ?? 0;
    } else {
      _glassesConsumed = 0;
      await prefs.setString('water_last_date', todayStr);
      await prefs.setInt('water_glasses', 0);
    }
    notifyListeners();
  }

  Future<void> addGlass() async {
    if (_glassesConsumed < dailyGoal) {
      _glassesConsumed++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_glasses', _glassesConsumed);
      notifyListeners();
    }
  }

  Future<void> removeGlass() async {
    if (_glassesConsumed > 0) {
      _glassesConsumed--;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('water_glasses', _glassesConsumed);
      notifyListeners();
    }
  }

  Future<void> reset() async {
    _glassesConsumed = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('water_glasses', 0);
    notifyListeners();
  }
}
