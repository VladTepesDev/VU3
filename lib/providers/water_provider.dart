import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../models/notification_settings.dart';

class WaterProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  int _glassesConsumed = 0;
  final int dailyGoal = 8;
  bool _waterNotificationsEnabled = false;

  WaterProvider(this._notificationService) {
    _loadWaterData();
    _loadNotificationSettings();
  }

  int get glassesConsumed => _glassesConsumed;
  double get progress => (_glassesConsumed / dailyGoal).clamp(0.0, 1.0);
  int get remaining => (dailyGoal - _glassesConsumed).clamp(0, dailyGoal);
  bool get waterNotificationsEnabled => _waterNotificationsEnabled;

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

  Future<void> checkAndResetForNewDay() async {
    await _loadWaterData();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _waterNotificationsEnabled = prefs.getBool('water_notifications_enabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleWaterNotifications(bool enabled) async {
    _waterNotificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('water_notifications_enabled', enabled);
    
    if (enabled) {
      // Schedule water notifications (8 times a day, 9 AM to 9 PM)
      final settings = NotificationSettings(
        waterReminders: true,
        waterReminderTimes: List.generate(8, (index) {
          final hour = 9 + (index * 1.5).floor(); // 9 AM, 10:30 AM, 12 PM, etc.
          final minute = (index % 2 == 0) ? 0 : 30;
          return NotificationTime(
            hour: hour,
            minute: minute,
            message: '💧 Time to drink water! Glass ${index + 1} of 8',
            type: 'water',
          );
        }),
        mealReminders: false,
        mealReminderTimes: [],
        dailySummary: false,
        dailySummaryTime: '20:00',
      );
      
      await _notificationService.scheduleNotifications(settings);
    } else {
      // Cancel all water notifications (IDs 0-7)
      for (int i = 0; i < 8; i++) {
        await _notificationService.cancelNotification(i);
      }
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
