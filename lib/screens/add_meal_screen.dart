import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_text_field.dart';
import '../widgets/custom_toast.dart';
import '../models/meal.dart';
import '../providers/meal_provider.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedMealType = 'breakfast';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        CustomToast.error(context, 'Error picking image: $e');
      }
    }
  }

  Future<String?> _saveImage(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'meal_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = '${directory.path}/$fileName';
      
      await image.copy(path);
      return path;
    } catch (e) {
      // Error saving image - return null
      return null;
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
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add Meal',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                      // Image Picker
                      GestureDetector(
                        onTap: () => _showImageSourceDialog(),
                        child: GlassContainer(
                          width: double.infinity,
                          height: 160,
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 40,
                                      color: AppTheme.textGray.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to add photo',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textGray,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Meal Type
                      Text(
                        'Meal Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildMealTypeChip('breakfast', '🍳 Breakfast'),
                            const SizedBox(width: 8),
                            _buildMealTypeChip('lunch', '🥗 Lunch'),
                            const SizedBox(width: 8),
                            _buildMealTypeChip('dinner', '🍽️ Dinner'),
                            const SizedBox(width: 8),
                            _buildMealTypeChip('snack', '🍎 Snack'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Meal Name
                      GlassTextField(
                        controller: _nameController,
                        labelText: 'Meal Name',
                        hintText: 'e.g., Grilled Chicken Salad',
                        prefixIcon: const Icon(Icons.restaurant),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter meal name';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Calories
                      GlassTextField(
                        controller: _caloriesController,
                        labelText: 'Calories',
                        hintText: '0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter calories';
                          }
                          final calories = double.tryParse(value);
                          if (calories == null || calories < 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Weight
                      GlassTextField(
                        controller: _weightController,
                        labelText: 'Weight (g) (optional)',
                        hintText: '0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Protein
                      GlassTextField(
                        controller: _proteinController,
                        labelText: 'Protein (g) (optional)',
                        hintText: '0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Carbs
                      GlassTextField(
                        controller: _carbsController,
                        labelText: 'Carbs (g) (optional)',
                        hintText: '0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Fat
                      GlassTextField(
                        controller: _fatController,
                        labelText: 'Fat (g) (optional)',
                        hintText: '0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Notes
                      GlassTextField(
                        controller: _notesController,
                        labelText: 'Notes (optional)',
                        hintText: 'Add any additional notes...',
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Save Button
                      GlassButton(
                        onPressed: _saveMeal,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Save Meal',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16), // Bottom padding for keyboard
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildMealTypeChip(String type, String label) {
    final isSelected = _selectedMealType == type;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMealType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.textBlack,
                    AppTheme.textDarkGray,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppTheme.textBlack
                : AppTheme.borderGray,
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.textWhite : AppTheme.textGray,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.borderWhite.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.glassWhite.withValues(alpha: 0.9),
                  AppTheme.glassWhite.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final mealProvider = context.read<MealProvider>();

    String? imagePath;
    if (_imageFile != null) {
      imagePath = await _saveImage(_imageFile!);
    }

    final calories = _caloriesController.text.isNotEmpty 
        ? (double.tryParse(_caloriesController.text) ?? 0.0)
        : 0.0;
    final protein = _proteinController.text.isNotEmpty 
        ? (double.tryParse(_proteinController.text) ?? 0.0)
        : 0.0;
    final carbs = _carbsController.text.isNotEmpty 
        ? (double.tryParse(_carbsController.text) ?? 0.0)
        : 0.0;
    final fat = _fatController.text.isNotEmpty 
        ? (double.tryParse(_fatController.text) ?? 0.0)
        : 0.0;
    final weight = _weightController.text.isNotEmpty 
        ? (double.tryParse(_weightController.text) ?? 0.0)
        : 0.0;

    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      weight: weight,
      imagePath: imagePath,
      createdAt: DateTime.now(),
      mealType: _selectedMealType,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await mealProvider.addMeal(meal);

    if (!mounted) return;
    
    CustomToast.success(context, 'Meal added successfully!');

    // Clear form
    _nameController.clear();
    _caloriesController.clear();
    _proteinController.clear();
    _carbsController.clear();
    _fatController.clear();
    _weightController.clear();
    _notesController.clear();
    setState(() {
      _imageFile = null;
      _selectedMealType = 'breakfast';
    });
  }
}
