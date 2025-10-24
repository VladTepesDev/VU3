import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';
import '../providers/menu_provider.dart';
import '../models/menu.dart';

class MenusScreen extends StatelessWidget {
  const MenusScreen({super.key});

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meal Plans',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a plan or create your own',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            // Active Menu
            SliverToBoxAdapter(
              child: Consumer<MenuProvider>(
                builder: (context, menuProvider, _) {
                  final activeMenu = menuProvider.activeMenu;
                  
                  if (activeMenu != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Plan',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          _buildActiveMenuCard(context, activeMenu, menuProvider),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  }
                  
                  return const SizedBox(height: 0);
                },
              ),
            ),
            
            // Predefined Menus
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Plans',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            
            Consumer<MenuProvider>(
              builder: (context, menuProvider, _) {
                final predefinedMenus = menuProvider.predefinedMenus;
                
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final menu = predefinedMenus[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMenuCard(context, menu, menuProvider),
                        );
                      },
                      childCount: predefinedMenus.length,
                    ),
                  ),
                );
              },
            ),
            
            // Custom Menus
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Custom Plans',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        GlassButton(
                          onPressed: () {
                            // TODO: Add custom menu creation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Custom menu creation coming soon!'),
                              ),
                            );
                          },
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Create',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            
            Consumer<MenuProvider>(
              builder: (context, menuProvider, _) {
                final customMenus = menuProvider.customMenus;
                
                if (customMenus.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.menu_book,
                              size: 48,
                              color: AppTheme.textGray.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No custom plans yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first custom meal plan',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final menu = customMenus[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMenuCard(context, menu, menuProvider),
                        );
                      },
                      childCount: customMenus.length,
                    ),
                  ),
                );
              },
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // Bottom padding for nav bar
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMenuCard(BuildContext context, Menu menu, MenuProvider menuProvider) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${menu.durationDays} days plan',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ACTIVE',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  Icons.local_fire_department,
                  '${menu.avgDailyCalories.toInt()}',
                  'kcal/day',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  Icons.restaurant_menu,
                  '${menu.meals.length}',
                  'meals',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassButton(
            onPressed: () {
              menuProvider.setActiveMenu(null);
            },
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text('Stop Following'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, Menu menu, MenuProvider menuProvider) {
    final isActive = menuProvider.activeMenu?.id == menu.id;
    
    return _MenuCardExpanded(
      menu: menu,
      isActive: isActive,
      onFollow: () {
        menuProvider.setActiveMenu(menu);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Now following ${menu.name}'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onDelete: menu.isCustom
          ? () => _showDeleteDialog(context, menu, menuProvider)
          : null,
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppTheme.textGray),
        const SizedBox(width: 8),
        Text(
          '$value ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, Menu menu, MenuProvider menuProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu'),
        content: Text('Are you sure you want to delete ${menu.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              menuProvider.deleteMenu(menu.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _MenuCardExpanded extends StatefulWidget {
  final Menu menu;
  final bool isActive;
  final VoidCallback onFollow;
  final VoidCallback? onDelete;

  const _MenuCardExpanded({
    required this.menu,
    required this.isActive,
    required this.onFollow,
    this.onDelete,
  });

  @override
  State<_MenuCardExpanded> createState() => _MenuCardExpandedState();
}

class _MenuCardExpandedState extends State<_MenuCardExpanded> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.menu.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.menu.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (widget.onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onDelete,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                context,
                Icons.calendar_today,
                '${widget.menu.durationDays}',
                'days',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                context,
                Icons.local_fire_department,
                '${widget.menu.avgDailyCalories.toInt()}',
                'kcal/day',
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlassButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_isExpanded ? 'Hide Details' : 'View Meal Details'),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 20,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            _buildMealsList(context),
          ],
          if (!widget.isActive && !_isExpanded) ...[
            const SizedBox(height: 8),
            GlassButton(
              onPressed: widget.onFollow,
              width: double.infinity,
              isPrimary: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text('Follow This Plan'),
            ),
          ],
          if (!widget.isActive && _isExpanded) ...[
            const SizedBox(height: 12),
            GlassButton(
              onPressed: widget.onFollow,
              width: double.infinity,
              isPrimary: true,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const Text('Follow This Plan'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealsList(BuildContext context) {
    final mealsByDay = <int, List<MenuMeal>>{};
    
    for (var meal in widget.menu.meals) {
      mealsByDay[meal.dayNumber] ??= [];
      mealsByDay[meal.dayNumber]!.add(meal);
    }

    final sortedDays = mealsByDay.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var day in sortedDays.take(2)) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Day $day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...mealsByDay[day]!.map((meal) => _buildMealItem(context, meal)),
          const SizedBox(height: 12),
        ],
        if (sortedDays.length > 2)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+${sortedDays.length - 2} more days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMealItem(BuildContext context, MenuMeal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getMealTypeColor(meal.mealType).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  meal.mealType.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getMealTypeColor(meal.mealType),
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.local_fire_department, size: 16, color: AppTheme.textGray),
              const SizedBox(width: 4),
              Text(
                '${meal.calories} kcal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            meal.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMacroChip(context, 'P', meal.protein, Colors.blue),
              const SizedBox(width: 8),
              _buildMacroChip(context, 'C', meal.carbs, Colors.orange),
              const SizedBox(width: 8),
              _buildMacroChip(context, 'F', meal.fat, Colors.purple),
            ],
          ),
          if (meal.foods.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Ingredients:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ...meal.foods.map((food) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textGray.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${food.name}: ${food.amount}${food.unit}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
          ],
          if (meal.instructions != null && meal.instructions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Instructions:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              meal.instructions!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textGray,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroChip(BuildContext context, String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${value.toInt()}g',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return AppTheme.textGray;
    }
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppTheme.textGray),
        const SizedBox(width: 8),
        Text(
          '$value ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
