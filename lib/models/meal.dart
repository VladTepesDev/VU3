class Meal {
  final String id;
  final String name;
  final double calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final double weight; // in grams
  final String? imagePath;
  final DateTime createdAt;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final String? notes;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.weight,
    this.imagePath,
    required this.createdAt,
    this.mealType = 'snack',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'weight': weight,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'mealType': mealType,
      'notes': notes,
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
      weight: json['weight'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      mealType: json['mealType'] ?? 'snack',
      notes: json['notes'],
    );
  }

  Meal copyWith({
    String? id,
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? weight,
    String? imagePath,
    DateTime? createdAt,
    String? mealType,
    String? notes,
  }) {
    return Meal(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      weight: weight ?? this.weight,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      mealType: mealType ?? this.mealType,
      notes: notes ?? this.notes,
    );
  }
}

class DailyMeals {
  final DateTime date;
  final List<Meal> meals;

  DailyMeals({
    required this.date,
    required this.meals,
  });

  double get totalCalories => meals.fold(0, (sum, meal) => sum + meal.calories);
  double get totalProtein => meals.fold(0, (sum, meal) => sum + meal.protein);
  double get totalCarbs => meals.fold(0, (sum, meal) => sum + meal.carbs);
  double get totalFat => meals.fold(0, (sum, meal) => sum + meal.fat);

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'meals': meals.map((e) => e.toJson()).toList(),
    };
  }

  factory DailyMeals.fromJson(Map<String, dynamic> json) {
    return DailyMeals(
      date: DateTime.parse(json['date']),
      meals: (json['meals'] as List).map((e) => Meal.fromJson(e)).toList(),
    );
  }
}
