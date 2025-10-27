class DailyStats {
  final String id;
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int manualMealCount;
  final int planMealCount;
  final double? planAdherence; // Percentage of plan meals completed
  final List<MealEntry> meals; // All meals logged that day

  DailyStats({
    required this.id,
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.manualMealCount,
    required this.planMealCount,
    this.planAdherence,
    required this.meals,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'manualMealCount': manualMealCount,
      'planMealCount': planMealCount,
      'planAdherence': planAdherence,
      'meals': meals.map((m) => m.toJson()).toList(),
    };
  }

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      id: json['id'],
      date: DateTime.parse(json['date']),
      totalCalories: json['totalCalories'],
      totalProtein: json['totalProtein'],
      totalCarbs: json['totalCarbs'],
      totalFat: json['totalFat'],
      manualMealCount: json['manualMealCount'],
      planMealCount: json['planMealCount'],
      planAdherence: json['planAdherence'],
      meals: (json['meals'] as List)
          .map((m) => MealEntry.fromJson(m))
          .toList(),
    );
  }
}

class MealEntry {
  final String id;
  final String name;
  final String type; // breakfast, lunch, dinner, snack
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime timestamp;
  final String source; // 'manual' or 'plan'
  final String? imagePath;

  MealEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
    required this.source,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'timestamp': timestamp.toIso8601String(),
      'source': source,
      'imagePath': imagePath,
    };
  }

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    return MealEntry(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
      timestamp: DateTime.parse(json['timestamp']),
      source: json['source'],
      imagePath: json['imagePath'],
    );
  }
}
