import 'package:flutter/material.dart';

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
  final String goal; // 'lose_weight', 'maintain_weight', 'gain_muscle'

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
    this.goal = 'maintain_weight',
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

  double get recommendedCalories {
    switch (goal) {
      case 'lose_weight':
        return tdee - 500;
      case 'gain_muscle':
        return tdee + 300;
      case 'maintain_weight':
      default:
        return tdee;
    }
  }

  Map<String, double> get optimalRange {
    final target = recommendedCalories;
    return {
      'min': target - 100,
      'max': target + 100,
    };
  }

  Map<String, double> get acceptableRange {
    final target = recommendedCalories;
    return {
      'min': target - 250,
      'max': target + 250,
    };
  }

  String getCalorieZone(double calories) {
    final target = recommendedCalories;
    final diff = calories - target;
    
    // Check if within optimal range (±100 kcal)
    if (diff.abs() <= 100) {
      return 'optimal';
    } 
    // Check if within acceptable range (±250 kcal)
    else if (diff.abs() <= 250) {
      return 'acceptable';
    }
    // Overeating (more than 250 kcal over target)
    else if (diff > 250) {
      return 'overeating';
    }
    // Under goal (more than 250 kcal under target)
    else {
      return 'under_goal';
    }
  }

  String getZoneDescription(String zone) {
    switch (zone) {
      case 'optimal':
        return 'Perfect Range';
      case 'acceptable':
        return 'Acceptable Range';
      case 'overeating':
        return 'Overeating';
      case 'under_goal':
        return 'Under Goal';
      default:
        return 'Unknown';
    }
  }
  
  Color getZoneColor(String zone) {
    switch (zone) {
      case 'optimal':
        return const Color(0xFF66BB6A); // Green
      case 'acceptable':
        return const Color(0xFFFFA726); // Orange
      case 'overeating':
      case 'under_goal':
        return const Color(0xFFEF5350); // Red
      default:
        return const Color(0xFF9E9E9E); // Gray
    }
  }

  // Get goal description
  String get goalDescription {
    switch (goal) {
      case 'lose_weight':
        return 'Lose Weight';
      case 'gain_muscle':
        return 'Build Muscle';
      case 'maintain_weight':
      default:
        return 'Maintain Weight';
    }
  }

  // Calculate weight progress towards target
  double? get weightProgressPercent {
    if (targetWeight == null || weightHistory.isEmpty) return null;
    
    final startWeight = weightHistory.first.weight;
    final currentWeight = weight;
    final goalWeight = targetWeight!;
    
    final totalToLose = startWeight - goalWeight;
    if (totalToLose == 0) return 100.0;
    
    final lostSoFar = startWeight - currentWeight;
    return (lostSoFar / totalToLose * 100).clamp(0.0, 100.0);
  }

  // Days until target weight (estimated)
  int? get estimatedDaysToGoal {
    if (targetWeight == null || weightHistory.length < 2) return null;
    
    final currentWeight = weight;
    final goalWeight = targetWeight!;
    final remainingWeight = (currentWeight - goalWeight).abs();
    
    if (remainingWeight <= 0) return 0;
    
    // Calculate average weight change per day from history
    final recentEntries = weightHistory.length > 7 
        ? weightHistory.sublist(weightHistory.length - 7) 
        : weightHistory;
    
    if (recentEntries.length < 2) return null;
    
    final firstEntry = recentEntries.first;
    final lastEntry = recentEntries.last;
    final daysDiff = lastEntry.date.difference(firstEntry.date).inDays;
    
    if (daysDiff == 0) return null;
    
    final weightChange = (lastEntry.weight - firstEntry.weight).abs();
    final avgChangePerDay = weightChange / daysDiff;
    
    if (avgChangePerDay == 0) return null;
    
    return (remainingWeight / avgChangePerDay).round();
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
      'goal': goal,
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
      goal: json['goal'] ?? 'maintain_weight',
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
    String? goal,
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
      goal: goal ?? this.goal,
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
