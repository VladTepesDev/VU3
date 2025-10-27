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

class EditMealScreen extends StatefulWidget {
  final Meal meal;

  const EditMealScreen({
    super.key,
    required this.meal,
  });

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  
  late String _selectedMealType;
  File? _imageFile;
  String? _existingImagePath;
  final ImagePicker _picker = ImagePicker();
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.meal.name);
    _caloriesController = TextEditingController(
      text: widget.meal.calories > 0 ? widget.meal.calories.toStringAsFixed(0) : '',
    );
    _proteinController = TextEditingController(
      text: widget.meal.protein > 0 ? widget.meal.protein.toStringAsFixed(1) : '',
    );
    _carbsController = TextEditingController(
      text: widget.meal.carbs > 0 ? widget.meal.carbs.toStringAsFixed(1) : '',
    );
    _fatController = TextEditingController(
      text: widget.meal.fat > 0 ? widget.meal.fat.toStringAsFixed(1) : '',
    );
    _weightController = TextEditingController(
      text: widget.meal.weight > 0 
        ? widget.meal.weight.toStringAsFixed(0) 
        : '',
    );
    _notesController = TextEditingController(text: widget.meal.notes ?? '');
    _selectedMealType = widget.meal.mealType;
    _existingImagePath = widget.meal.imagePath;
  }

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
          _imageChanged = true;
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
      return null;
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
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
                if (_imageFile != null || _existingImagePath != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _imageFile = null;
                        _existingImagePath = null;
                        _imageChanged = true;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? finalImagePath = _existingImagePath;
    
    if (_imageChanged) {
      if (_imageFile != null) {
        finalImagePath = await _saveImage(_imageFile!);
      } else {
        finalImagePath = null;
      }
    }

    final updatedMeal = Meal(
      id: widget.meal.id,
      name: _nameController.text.trim(),
      calories: double.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      weight: double.tryParse(_weightController.text) ?? 0,
      mealType: _selectedMealType,
      imagePath: finalImagePath,
      createdAt: widget.meal.createdAt,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (mounted) {
      await context.read<MealProvider>().updateMeal(widget.meal.id, updatedMeal);
      
      if (mounted) {
        Navigator.pop(context);
        CustomToast.success(context, 'Meal updated successfully!');
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
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Edit Meal',
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
                            : _existingImagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      File(_existingImagePath!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildPlaceholder();
                                      },
                                    ),
                                  )
                                : _buildPlaceholder(),
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
                    
                    // Update Button
                    GlassButton(
                      onPressed: _updateMeal,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Update Meal',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo,
          size: 40,
          color: AppTheme.textGray.withValues(alpha: 0.7),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to change photo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textGray,
          ),
        ),
      ],
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppTheme.textGray.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : AppTheme.textGray,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
