import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_text_field.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';
import 'main_navigation.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String? _profileImagePath;
  String _selectedGender = 'male';
  String _activityLevel = 'moderate';
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    
    if (image != null) {
      try {
        // Save the image to permanent storage
        final storageService = StorageService();
        final permanentPath = await storageService.saveProfileImage(image.path);
        
        setState(() {
          _profileImagePath = permanentPath;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Let\'s set up\nyour profile',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'We need some information to personalize your experience',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
                const SizedBox(height: 32),
                
                // Progress Indicator
                _buildProgressIndicator(),
                
                const SizedBox(height: 32),
                
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: _buildCurrentStep(),
                    ),
                  ),
                ),
                
                // Navigation Buttons
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: GlassButton(
                          onPressed: () {
                            setState(() {
                              _currentStep--;
                            });
                          },
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      child: GlassButton(
                        onPressed: _handleNext,
                        child: Text(_currentStep == 3 ? 'Complete' : 'Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.textBlack
                  : AppTheme.textLightGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildGenderStep();
      case 2:
        return _buildMeasurementsStep();
      case 3:
        return _buildActivityStep();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Let\'s start with your profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 32),
        
        // Profile Image
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.textBlack.withValues(alpha: 0.2),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: _profileImagePath != null && File(_profileImagePath!).existsSync()
                        ? Image.file(
                            File(_profileImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppTheme.textLightGray.withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.textGray.withValues(alpha: 0.5),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppTheme.textLightGray.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: AppTheme.textGray.withValues(alpha: 0.5),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: AppTheme.textBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Name Field
        GlassTextField(
          controller: _nameController,
          labelText: 'Your Name',
          hintText: 'Enter your name',
          prefixIcon: const Icon(Icons.person_outline),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Your name and photo will be displayed in the app',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textGray,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGenderStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What\'s your gender?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        
        GestureDetector(
          onTap: () => setState(() => _selectedGender = 'male'),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            border: Border.all(
              color: _selectedGender == 'male'
                  ? AppTheme.textBlack
                  : AppTheme.borderGray,
              width: _selectedGender == 'male' ? 2 : 1.5,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.male,
                  size: 32,
                  color: AppTheme.textBlack,
                ),
                const SizedBox(width: 16),
                Text(
                  'Male',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        GestureDetector(
          onTap: () => setState(() => _selectedGender = 'female'),
          child: GlassContainer(
            padding: const EdgeInsets.all(20),
            border: Border.all(
              color: _selectedGender == 'female'
                  ? AppTheme.textBlack
                  : AppTheme.borderGray,
              width: _selectedGender == 'female' ? 2 : 1.5,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.female,
                  size: 32,
                  color: AppTheme.textBlack,
                ),
                const SizedBox(width: 16),
                Text(
                  'Female',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeasurementsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your measurements',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        
        GlassTextField(
          controller: _ageController,
          labelText: 'Age',
          hintText: 'Enter your age',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.cake),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your age';
            }
            final age = int.tryParse(value);
            if (age == null || age < 13 || age > 120) {
              return 'Please enter a valid age';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        GlassTextField(
          controller: _heightController,
          labelText: 'Height (cm)',
          hintText: 'Enter your height',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.height),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your height';
            }
            final height = double.tryParse(value);
            if (height == null || height < 100 || height > 250) {
              return 'Please enter a valid height';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        GlassTextField(
          controller: _weightController,
          labelText: 'Weight (kg)',
          hintText: 'Enter your weight',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.monitor_weight),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your weight';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight < 30 || weight > 300) {
              return 'Please enter a valid weight';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActivityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity level',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'This helps us calculate your daily calorie needs',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        
        _buildActivityOption(
          'sedentary',
          'Sedentary',
          'Little or no exercise',
        ),
        const SizedBox(height: 12),
        _buildActivityOption(
          'light',
          'Lightly Active',
          'Exercise 1-3 times/week',
        ),
        const SizedBox(height: 12),
        _buildActivityOption(
          'moderate',
          'Moderately Active',
          'Exercise 3-5 times/week',
        ),
        const SizedBox(height: 12),
        _buildActivityOption(
          'active',
          'Very Active',
          'Exercise 6-7 times/week',
        ),
        const SizedBox(height: 12),
        _buildActivityOption(
          'very_active',
          'Extremely Active',
          'Physical job or 2x training',
        ),
      ],
    );
  }

  Widget _buildActivityOption(String value, String title, String subtitle) {
    final isSelected = _activityLevel == value;
    
    return GestureDetector(
      onTap: () => setState(() => _activityLevel = value),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        border: Border.all(
          color: isSelected
              ? AppTheme.textBlack
              : AppTheme.borderGray,
          width: isSelected ? 2 : 1.5,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.textBlack
                    : AppTheme.glassGray,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.textBlack
                      : AppTheme.borderGray,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                color: isSelected ? AppTheme.textWhite : Colors.transparent,
                size: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() async {
    if (_currentStep < 3) {
      // Validate current step before moving forward
      if ((_currentStep == 0 || _currentStep == 2) && !_formKey.currentState!.validate()) {
        return;
      }
      setState(() {
        _currentStep++;
      });
    } else {
      // Final step - create profile
      if (!_formKey.currentState!.validate()) {
        return;
      }
      
      final userProvider = context.read<UserProvider>();
      final storageService = context.read<StorageService>();
      final navigator = Navigator.of(context);
      
      await userProvider.createProfile(
        name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
        profileImage: _profileImagePath,
        gender: _selectedGender,
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        activityLevel: _activityLevel,
      );
      
      await storageService.setFirstLaunchComplete();
      
      if (!mounted) return;
      
      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigation(),
        ),
      );
    }
  }
}
