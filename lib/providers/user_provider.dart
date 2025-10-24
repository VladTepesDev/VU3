import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final StorageService _storageService;
  UserProfile? _userProfile;

  UserProvider(this._storageService) {
    _loadUserProfile();
  }

  UserProfile? get userProfile => _userProfile;
  bool get hasProfile => _userProfile != null;

  Future<void> _loadUserProfile() async {
    _userProfile = await _storageService.getUserProfile();
    notifyListeners();
  }

  Future<void> createProfile({
    required String gender,
    required int age,
    required double height,
    required double weight,
    String activityLevel = 'moderate',
    double? targetWeight,
  }) async {
    _userProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      gender: gender,
      age: age,
      height: height,
      weight: weight,
      createdAt: DateTime.now(),
      activityLevel: activityLevel,
      targetWeight: targetWeight,
      weightHistory: [
        WeightEntry(
          date: DateTime.now(),
          weight: weight,
          note: 'Initial weight',
        ),
      ],
    );

    await _storageService.saveUserProfile(_userProfile!);
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _userProfile = profile;
    await _storageService.saveUserProfile(profile);
    notifyListeners();
  }

  Future<void> addWeightEntry(double weight, {String? note}) async {
    if (_userProfile == null) return;

    final entry = WeightEntry(
      date: DateTime.now(),
      weight: weight,
      note: note,
    );

    final updatedProfile = _userProfile!.copyWith(
      weight: weight,
      weightHistory: [..._userProfile!.weightHistory, entry],
    );

    await updateProfile(updatedProfile);
  }

  double? getWeightProgress() {
    if (_userProfile == null || _userProfile!.weightHistory.length < 2) {
      return null;
    }

    final firstWeight = _userProfile!.weightHistory.first.weight;
    final currentWeight = _userProfile!.weight;
    return firstWeight - currentWeight;
  }

  List<WeightEntry> getRecentWeightHistory({int days = 30}) {
    if (_userProfile == null) return [];

    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _userProfile!.weightHistory
        .where((entry) => entry.date.isAfter(cutoffDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
