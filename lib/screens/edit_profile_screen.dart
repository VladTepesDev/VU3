import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/custom_toast.dart';
import '../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;
  
  String? _gender;
  String? _activityLevel;
  String? _goal;
  
  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().userProfile!;
    
    _ageController = TextEditingController(text: user.age.toString());
    _heightController = TextEditingController(text: user.height.toString());
    _weightController = TextEditingController(text: user.weight.toString());
    _targetWeightController = TextEditingController(
      text: user.targetWeight?.toString() ?? '',
    );
    
    _gender = user.gender;
    _activityLevel = user.activityLevel;
    _goal = user.goal;
  }
  
  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.glassWhite.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.borderGray,
                          ),
                        ),
                        child: const Icon(Icons.arrow_back, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Edit Profile',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  physics: const ClampingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Basic Information',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              
                              // Gender
                              Text('Gender', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildGenderButton('male', Icons.male, 'Male'),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildGenderButton('female', Icons.female, 'Female'),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Age
                              TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  labelText: 'Age',
                                  suffixText: 'years',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your age';
                                  }
                                  final age = int.tryParse(value);
                                  if (age == null || age < 15 || age > 100) {
                                    return 'Please enter a valid age (15-100)';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Height
                              TextFormField(
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  labelText: 'Height',
                                  suffixText: 'cm',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your height';
                                  }
                                  final height = double.tryParse(value);
                                  if (height == null || height < 100 || height > 250) {
                                    return 'Please enter a valid height (100-250 cm)';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Weight
                              TextFormField(
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  labelText: 'Current Weight',
                                  suffixText: 'kg',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your weight';
                                  }
                                  final weight = double.tryParse(value);
                                  if (weight == null || weight < 30 || weight > 300) {
                                    return 'Please enter a valid weight (30-300 kg)';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Target Weight
                              TextFormField(
                                controller: _targetWeightController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 14),
                                decoration: const InputDecoration(
                                  labelText: 'Target Weight',
                                  suffixText: 'kg',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    final weight = double.tryParse(value);
                                    if (weight == null || weight < 30 || weight > 300) {
                                      return 'Please enter a valid weight (30-300 kg)';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        const SizedBox(height: 12),
                        
                        GlassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Activity & Goals',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              
                              // Activity Level
                              Text('Activity Level', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 6),
                              _buildActivityDropdown(),
                              
                              const SizedBox(height: 12),
                              
                              // Goal
                              Text('Your Goal', style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 6),
                              _buildGoalDropdown(),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        GlassButton(
                          isPrimary: true,
                          onPressed: _saveProfile,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: AppTheme.textWhite),
                              SizedBox(width: 12),
                              Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildGenderButton(String value, IconData icon, String label) {
    final isSelected = _gender == value;
    
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.textBlack 
              : AppTheme.glassWhite.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.textBlack : AppTheme.borderGray,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppTheme.textWhite : AppTheme.textBlack,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.textWhite : AppTheme.textBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _activityLevel,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      isExpanded: true,
      style: const TextStyle(fontSize: 13, color: AppTheme.textBlack),
      items: const [
        DropdownMenuItem(value: 'sedentary', child: Text('Sedentary')),
        DropdownMenuItem(value: 'light', child: Text('Lightly Active')),
        DropdownMenuItem(value: 'moderate', child: Text('Moderately Active')),
        DropdownMenuItem(value: 'active', child: Text('Very Active')),
        DropdownMenuItem(value: 'very_active', child: Text('Extremely Active')),
      ],
      onChanged: (value) => setState(() => _activityLevel = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your activity level';
        }
        return null;
      },
    );
  }
  
  Widget _buildGoalDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _goal,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
      isExpanded: true,
      style: const TextStyle(fontSize: 13, color: AppTheme.textBlack),
      items: const [
        DropdownMenuItem(value: 'lose_weight', child: Text('Lose Weight')),
        DropdownMenuItem(value: 'maintain_weight', child: Text('Maintain Weight')),
        DropdownMenuItem(value: 'gain_muscle', child: Text('Build Muscle')),
      ],
      onChanged: (value) => setState(() => _goal = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your goal';
        }
        return null;
      },
    );
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.userProfile!;
    
    final updatedProfile = currentUser.copyWith(
      gender: _gender,
      age: int.parse(_ageController.text),
      height: double.parse(_heightController.text),
      weight: double.parse(_weightController.text),
      targetWeight: _targetWeightController.text.isNotEmpty 
          ? double.parse(_targetWeightController.text) 
          : null,
      activityLevel: _activityLevel,
      goal: _goal,
    );
    
    await userProvider.updateProfile(updatedProfile);
    
    if (mounted) {
      Navigator.pop(context);
      CustomToast.success(context, 'Profile updated successfully!');
    }
  }
}
