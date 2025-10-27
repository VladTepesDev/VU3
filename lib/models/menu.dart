class Menu {
  final String id;
  final String name;
  final String description;
  final List<MenuMeal> meals;
  final bool isCustom;
  final String? createdBy;
  final int durationDays;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.meals,
    this.isCustom = false,
    this.createdBy,
    this.durationDays = 7,
  });

  double get totalCalories => meals.fold(0, (sum, meal) => sum + meal.calories);
  double get avgDailyCalories => totalCalories / durationDays;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'meals': meals.map((e) => e.toJson()).toList(),
      'isCustom': isCustom,
      'createdBy': createdBy,
      'durationDays': durationDays,
    };
  }

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      meals: (json['meals'] as List).map((e) => MenuMeal.fromJson(e)).toList(),
      isCustom: json['isCustom'] ?? false,
      createdBy: json['createdBy'],
      durationDays: json['durationDays'] ?? 7,
    );
  }
}

class MenuMeal {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType;
  final int dayNumber;
  final List<FoodItem> foods;
  final String? instructions;
  final String scheduledTime;

  MenuMeal({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    required this.dayNumber,
    this.foods = const [],
    this.instructions,
    required this.scheduledTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'mealType': mealType,
      'dayNumber': dayNumber,
      'foods': foods.map((e) => e.toJson()).toList(),
      'instructions': instructions,
      'scheduledTime': scheduledTime,
    };
  }

  factory MenuMeal.fromJson(Map<String, dynamic> json) {
    return MenuMeal(
      id: json['id'],
      name: json['name'],
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
      mealType: json['mealType'],
      dayNumber: json['dayNumber'],
      foods: (json['foods'] as List?)?.map((e) => FoodItem.fromJson(e)).toList() ?? [],
      instructions: json['instructions'],
      scheduledTime: json['scheduledTime'] ?? '12:00',
    );
  }
}

class FoodItem {
  final String name;
  final double amount;
  final String unit;

  FoodItem({
    required this.name,
    required this.amount,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      amount: json['amount'],
      unit: json['unit'],
    );
  }
}
