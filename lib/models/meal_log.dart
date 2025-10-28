class MealLog {
  final String id;
  final String menuMealId;
  final String mealName; // Name of the meal from the menu
  final DateTime scheduledDate;
  final DateTime? loggedAt;
  final String? imagePath;
  final double? actualCalories;
  final double? actualProtein;
  final double? actualCarbs;
  final double? actualFat;
  final String? notes;
  final MealLogStatus status;

  MealLog({
    required this.id,
    required this.menuMealId,
    required this.mealName,
    required this.scheduledDate,
    this.loggedAt,
    this.imagePath,
    this.actualCalories,
    this.actualProtein,
    this.actualCarbs,
    this.actualFat,
    this.notes,
    required this.status,
  });

  bool get isCompleted => status == MealLogStatus.completed;
  bool get isMissed => status == MealLogStatus.missed;
  bool get isUpcoming => status == MealLogStatus.upcoming;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuMealId': menuMealId,
      'mealName': mealName,
      'scheduledDate': scheduledDate.toIso8601String(),
      'loggedAt': loggedAt?.toIso8601String(),
      'imagePath': imagePath,
      'actualCalories': actualCalories,
      'actualProtein': actualProtein,
      'actualCarbs': actualCarbs,
      'actualFat': actualFat,
      'notes': notes,
      'status': status.toString(),
    };
  }

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'],
      menuMealId: json['menuMealId'],
      mealName: json['mealName'] ?? 'Plan Meal', // Default for old data
      scheduledDate: DateTime.parse(json['scheduledDate']),
      loggedAt: json['loggedAt'] != null ? DateTime.parse(json['loggedAt']) : null,
      imagePath: json['imagePath'],
      actualCalories: json['actualCalories'],
      actualProtein: json['actualProtein'],
      actualCarbs: json['actualCarbs'],
      actualFat: json['actualFat'],
      notes: json['notes'],
      status: _statusFromString(json['status']),
    );
  }

  static MealLogStatus _statusFromString(String status) {
    if (status.contains('completed')) return MealLogStatus.completed;
    if (status.contains('missed')) return MealLogStatus.missed;
    return MealLogStatus.upcoming;
  }

  MealLog copyWith({
    String? id,
    String? menuMealId,
    String? mealName,
    DateTime? scheduledDate,
    DateTime? loggedAt,
    String? imagePath,
    double? actualCalories,
    double? actualProtein,
    double? actualCarbs,
    double? actualFat,
    String? notes,
    MealLogStatus? status,
  }) {
    return MealLog(
      id: id ?? this.id,
      menuMealId: menuMealId ?? this.menuMealId,
      mealName: mealName ?? this.mealName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      loggedAt: loggedAt ?? this.loggedAt,
      imagePath: imagePath ?? this.imagePath,
      actualCalories: actualCalories ?? this.actualCalories,
      actualProtein: actualProtein ?? this.actualProtein,
      actualCarbs: actualCarbs ?? this.actualCarbs,
      actualFat: actualFat ?? this.actualFat,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}

enum MealLogStatus {
  upcoming,
  completed,
  missed,
}
