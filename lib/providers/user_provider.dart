import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final StorageService _storageService;
  UserProfile? _userProfile;
  bool _isLoading = true;

  UserProvider(this._storageService) {
    _loadUserProfile();
  }

  UserProfile? get userProfile => _userProfile;
  bool get hasProfile => _userProfile != null;
  bool get isLoading => _isLoading;

  Future<void> _loadUserProfile() async {
    _isLoading = true;
    _userProfile = await _storageService.getUserProfile();
    
    // Check if profile image path is valid, if not clear it
    if (_userProfile?.profileImage != null) {
      final imageFile = File(_userProfile!.profileImage!);
      if (!await imageFile.exists()) {
        debugPrint('Profile image not found at: ${_userProfile!.profileImage}');
        debugPrint('Clearing invalid profile image path');
        // Clear the invalid image path by creating new profile without it
        _userProfile = UserProfile(
          id: _userProfile!.id,
          name: _userProfile!.name,
          profileImage: null, // Clear the invalid path
          gender: _userProfile!.gender,
          age: _userProfile!.age,
          height: _userProfile!.height,
          weight: _userProfile!.weight,
          createdAt: _userProfile!.createdAt,
          weightHistory: _userProfile!.weightHistory,
          targetWeight: _userProfile!.targetWeight,
          activityLevel: _userProfile!.activityLevel,
          goal: _userProfile!.goal,
        );
        await _storageService.saveUserProfile(_userProfile!);
      } else {
        debugPrint('Profile image found at: ${_userProfile!.profileImage}');
      }
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> createProfile({
    String? name,
    String? profileImage,
    required String gender,
    required int age,
    required double height,
    required double weight,
    String activityLevel = 'moderate',
    double? targetWeight,
    String goal = 'maintain_weight',
  }) async {
    _userProfile = UserProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      profileImage: profileImage,
      gender: gender,
      age: age,
      height: height,
      weight: weight,
      createdAt: DateTime.now(),
      activityLevel: activityLevel,
      targetWeight: targetWeight,
      goal: goal,
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
