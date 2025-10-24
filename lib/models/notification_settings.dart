class NotificationSettings {
  final bool waterReminders;
  final List<NotificationTime> waterReminderTimes;
  final bool mealReminders;
  final List<NotificationTime> mealReminderTimes;
  final bool dailySummary;
  final String dailySummaryTime;

  NotificationSettings({
    this.waterReminders = true,
    this.waterReminderTimes = const [],
    this.mealReminders = true,
    this.mealReminderTimes = const [],
    this.dailySummary = true,
    this.dailySummaryTime = '20:00',
  });

  Map<String, dynamic> toJson() {
    return {
      'waterReminders': waterReminders,
      'waterReminderTimes': waterReminderTimes.map((e) => e.toJson()).toList(),
      'mealReminders': mealReminders,
      'mealReminderTimes': mealReminderTimes.map((e) => e.toJson()).toList(),
      'dailySummary': dailySummary,
      'dailySummaryTime': dailySummaryTime,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      waterReminders: json['waterReminders'] ?? true,
      waterReminderTimes: (json['waterReminderTimes'] as List?)
          ?.map((e) => NotificationTime.fromJson(e))
          .toList() ?? [],
      mealReminders: json['mealReminders'] ?? true,
      mealReminderTimes: (json['mealReminderTimes'] as List?)
          ?.map((e) => NotificationTime.fromJson(e))
          .toList() ?? [],
      dailySummary: json['dailySummary'] ?? true,
      dailySummaryTime: json['dailySummaryTime'] ?? '20:00',
    );
  }

  NotificationSettings copyWith({
    bool? waterReminders,
    List<NotificationTime>? waterReminderTimes,
    bool? mealReminders,
    List<NotificationTime>? mealReminderTimes,
    bool? dailySummary,
    String? dailySummaryTime,
  }) {
    return NotificationSettings(
      waterReminders: waterReminders ?? this.waterReminders,
      waterReminderTimes: waterReminderTimes ?? this.waterReminderTimes,
      mealReminders: mealReminders ?? this.mealReminders,
      mealReminderTimes: mealReminderTimes ?? this.mealReminderTimes,
      dailySummary: dailySummary ?? this.dailySummary,
      dailySummaryTime: dailySummaryTime ?? this.dailySummaryTime,
    );
  }
}

class NotificationTime {
  final int hour;
  final int minute;
  final String message;
  final String type; // 'water', 'meal'

  NotificationTime({
    required this.hour,
    required this.minute,
    required this.message,
    required this.type,
  });

  String get timeString {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
      'message': message,
      'type': type,
    };
  }

  factory NotificationTime.fromJson(Map<String, dynamic> json) {
    return NotificationTime(
      hour: json['hour'],
      minute: json['minute'],
      message: json['message'],
      type: json['type'],
    );
  }
}
