import 'package:flutter/material.dart';
import '../../config/theme.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  final List<Map<String, dynamic>> _menuItems = [
    {
      'id': '1',
      'name': 'Pepperoni Pizza',
      'price': 'MK8,500',
      'category': 'Pizza',
      'available': true,
      'description': 'Classic pepperoni pizza with mozzarella cheese',
    },
    {
      'id': '2',
      'name': 'Cheeseburger',
      'price': 'MK5,500',
      'category': 'Burgers',
      'available': true,
      'description': 'Beef patty with cheese, lettuce, and tomato',
    },
    {
      'id': '3',
      'name': 'California Roll',
      'price': 'MK6,000',
      'category': 'Sushi',
      'available': false,
      'description': 'Sushi roll with crab, avocado, and cucumber',
    },
  ];

  final List<String> _categories = ['All', 'Pizza', 'Burgers', 'Sushi', 'Desserts'];
  String _selectedCategory = 'All';

  void _addMenuItem() {
    // TODO: Implement add menu item
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add menu item feature coming soon')),
    );
  }

  void _editMenuItem(Map<String, dynamic> item) {
    // TODO: Implement edit menu item
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${item['name']} feature coming soon')),
    );
  }

  void _deleteMenuItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _menuItems.removeWhere((i) => i['id'] == item['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item['name']} deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleAvailability(Map<String, dynamic> item) {
    setState(() {
      item['available'] = !item['available'];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} is now ${item['available'] ? 'available' : 'unavailable'}'),
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedCategory == 'All') {
      return _menuItems;
    }
    return _menuItems.where((item) => item['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: Column(
        children: [
          // Categories Filter
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryRed : AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryRed : AppTheme.deepCrimson.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.primaryText,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Menu Items List
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 64, color: AppTheme.mutedText),
                        const SizedBox(height: 16),
                        Text(
                          'No menu items',
                          style: TextStyle(color: AppTheme.secondaryText),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first menu item',
                          style: TextStyle(color: AppTheme.mutedText),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppTheme.cardGlowGradient,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            // Image Placeholder
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.fastfood,
                                size: 30,
                                color: AppTheme.mutedText,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Item Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['description'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.secondaryText,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryRed.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          item['category'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppTheme.primaryRed,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        item['price'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Actions
                            Column(
                              children: [
                                Switch(
                                  value: item['available'],
                                  onChanged: (_) => _toggleAvailability(item),
                                  activeColor: AppTheme.success,
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      color: AppTheme.warning,
                                      onPressed: () => _editMenuItem(item),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      color: AppTheme.error,
                                      onPressed: () => _deleteMenuItem(item),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMenuItem,
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}