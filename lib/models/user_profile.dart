class UserProfile {
  final String id;
  final String gender; // 'male' or 'female'
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final DateTime createdAt;
  final List<WeightEntry> weightHistory;
  final double? targetWeight;
  final String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'

  UserProfile({
    required this.id,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.createdAt,
    this.weightHistory = const [],
    this.targetWeight,
    this.activityLevel = 'moderate',
  });

  // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  double get bmr {
    if (gender == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  double get tdee {
    double multiplier;
    switch (activityLevel) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'light':
        multiplier = 1.375;
        break;
      case 'moderate':
        multiplier = 1.55;
        break;
      case 'active':
        multiplier = 1.725;
        break;
      case 'very_active':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.55;
    }
    return bmr * multiplier;
  }

  // Calculate BMI
  double get bmi {
    return weight / ((height / 100) * (height / 100));
  }

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'createdAt': createdAt.toIso8601String(),
      'weightHistory': weightHistory.map((e) => e.toJson()).toList(),
      'targetWeight': targetWeight,
      'activityLevel': activityLevel,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      gender: json['gender'],
      age: json['age'],
      height: json['height'],
      weight: json['weight'],
      createdAt: DateTime.parse(json['createdAt']),
      weightHistory: (json['weightHistory'] as List?)
          ?.map((e) => WeightEntry.fromJson(e))
          .toList() ?? [],
      targetWeight: json['targetWeight'],
      activityLevel: json['activityLevel'] ?? 'moderate',
    );
  }

  UserProfile copyWith({
    String? id,
    String? gender,
    int? age,
    double? height,
    double? weight,
    DateTime? createdAt,
    List<WeightEntry>? weightHistory,
    double? targetWeight,
    String? activityLevel,
  }) {
    return UserProfile(
      id: id ?? this.id,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      weightHistory: weightHistory ?? this.weightHistory,
      targetWeight: targetWeight ?? this.targetWeight,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }
}

class WeightEntry {
  final DateTime date;
  final double weight;
  final String? note;

  WeightEntry({
    required this.date,
    required this.weight,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'note': note,
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      date: DateTime.parse(json['date']),
      weight: json['weight'],
      note: json['note'],
    );
  }
}
