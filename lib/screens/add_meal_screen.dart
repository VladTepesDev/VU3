import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../widgets/glass_text_field.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
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
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Add Meal',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            ),
            
            // Form
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Picker
                      GestureDetector(
                        onTap: () => _showImageSourceDialog(),
                        child: GlassContainer(
                          height: 200,
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
                                      size: 48,
                                      color: AppTheme.textGray.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Tap to add photo',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: AppTheme.textGray,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Meal Type
                      Text(
                        'Meal Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
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
                      
                      const SizedBox(height: 24),
                      
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
                      
                      const SizedBox(height: 16),
                      
                      // Calories and Weight
                      Row(
                        children: [
                          Expanded(
                            child: GlassTextField(
                              controller: _caloriesController,
                              labelText: 'Calories (optional)',
                              hintText: '0',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassTextField(
                              controller: _weightController,
                              labelText: 'Weight (g) (optional)',
                              hintText: '0',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Macros
                      Text(
                        'Macronutrients (grams)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: GlassTextField(
                              controller: _proteinController,
                              labelText: 'Protein (optional)',
                              hintText: '0',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GlassTextField(
                              controller: _carbsController,
                              labelText: 'Carbs (optional)',
                              hintText: '0',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GlassTextField(
                              controller: _fatController,
                              labelText: 'Fat (optional)',
                              hintText: '0',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Notes
                      GlassTextField(
                        controller: _notesController,
                        labelText: 'Notes (optional)',
                        hintText: 'Add any additional notes...',
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Save Button
                      GlassButton(
                        onPressed: _saveMeal,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Save Meal',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 100), // Bottom padding for nav bar
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeChip(String type, String label) {
    final isSelected = _selectedMealType == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMealType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
          child: Center(
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
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(24),
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

    await context.read<MealProvider>().addMeal(meal);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal added successfully!'),
          backgroundColor: AppTheme.textBlack,
          behavior: SnackBarBehavior.floating,
        ),
      );

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
}
