import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service to detect day changes and notify listeners
class DayChangeService {
  DateTime _currentDay = DateTime.now();
  Timer? _timer;
  final List<VoidCallback> _listeners = [];

  DayChangeService() {
    _startTimer();
  }

  void _startTimer() {
    // Check every minute for day change
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkDayChange();
    });
  }

  void _checkDayChange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDay = DateTime(_currentDay.year, _currentDay.month, _currentDay.day);

    if (today.isAfter(currentDay)) {
      // Day has changed!
      _currentDay = now;
      _notifyListeners();
    }
  }

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void dispose() {
    _timer?.cancel();
    _listeners.clear();
  }
}
