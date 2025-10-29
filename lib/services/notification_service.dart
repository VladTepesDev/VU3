import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/notification_settings.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Initialize timezone
    tz.initializeTimeZones();

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Future enhancement: Navigate to specific screen based on payload
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleNotifications(NotificationSettings settings) async {
    await cancelAllNotifications();

    // Schedule water reminders
    if (settings.waterReminders) {
      for (var i = 0; i < settings.waterReminderTimes.length; i++) {
        final time = settings.waterReminderTimes[i];
        await _scheduleDailyNotification(
          id: i,
          title: 'Olympus Balance',
          body: time.message,
          hour: time.hour,
          minute: time.minute,
        );
      }
    }

    // Schedule meal reminders
    if (settings.mealReminders) {
      for (var i = 0; i < settings.mealReminderTimes.length; i++) {
        final time = settings.mealReminderTimes[i];
        await _scheduleDailyNotification(
          id: 100 + i,
          title: 'Olympus Balance',
          body: time.message,
          hour: time.hour,
          minute: time.minute,
        );
      }
    }

    // Schedule daily summary
    if (settings.dailySummary) {
      final parts = settings.dailySummaryTime.split(':');
      await _scheduleDailyNotification(
        id: 200,
        title: 'Olympus Balance',
        body: 'Check your daily progress! 📊',
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_notifications',
          'Daily Notifications',
          channelDescription: 'Daily reminders for water and meals',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notifications',
          'Instant Notifications',
          channelDescription: 'Instant notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
