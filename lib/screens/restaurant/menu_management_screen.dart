import '../../services/restaurant_service.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/restaurant_service.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<dynamic> _menuItems = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final items = await RestaurantService.getMenuItems();
      setState(() {
        _menuItems = items;
        // Build category list from items
        final cats = items.map((i) => i['category_name']).whereType<String>().toSet().toList();
        _categories = ['All', ...cats];
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  List<dynamic> get _filteredItems {
    if (_selectedCategory == 'All') return _menuItems;
    return _menuItems.where((i) => i['category_name'] == _selectedCategory).toList();
  }

  void _addMenuItem() {
    _showMenuItemDialog();
  }

  void _editMenuItem(Map<String, dynamic> item) {
    _showMenuItemDialog(item: item);
  }

  void _showMenuItemDialog({Map<String, dynamic>? item}) {
    final isEditing = item != null;
    final nameController = TextEditingController(text: item?['name'] ?? '');
    final priceController = TextEditingController(text: item?['price']?.toString() ?? '');
    final descController = TextEditingController(text: item?['description'] ?? '');
    bool isAvailable = item?['is_available'] ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(isEditing ? 'Edit ${item!['name']}' : 'Add Menu Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.fastfood)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price (MK)', prefixIcon: Icon(Icons.attach_money)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Available'),
                  value: isAvailable,
                  onChanged: (v) => setStateDialog(() => isAvailable = v),
                  activeColor: AppTheme.success,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final data = {
                    'name': nameController.text,
                    'price': priceController.text,
                    'description': descController.text,
                    'is_available': isAvailable,
                  };
                  if (isEditing) {
                    await RestaurantService.updateMenuItem(item!['id'], data);
                  } else {
                    await RestaurantService.createMenuItem(data);
                  }
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? 'Item updated!' : 'Item added!'), backgroundColor: AppTheme.success),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMenuItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${item['name']}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await RestaurantService.deleteMenuItem(item['id']);
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item['name']} deleted'), backgroundColor: AppTheme.error),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAvailability(Map<String, dynamic> item) async {
    try {
      await RestaurantService.updateMenuItem(item['id'], {'is_available': !item['is_available']});
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                      const SizedBox(height: 12),
                      Text('Failed to load menu', style: TextStyle(color: AppTheme.secondaryText)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                    ],
                  ),
                )
              : Column(
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
                          final category = _categories[index].toString();
                          final isSelected = _selectedCategory == category;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = category),
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

                    Expanded(
                      child: _filteredItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.restaurant_menu, size: 64, color: AppTheme.mutedText),
                                  const SizedBox(height: 16),
                                  Text('No menu items', style: TextStyle(color: AppTheme.secondaryText)),
                                  const SizedBox(height: 8),
                                  Text('Tap + to add your first item', style: TextStyle(color: AppTheme.mutedText)),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadData,
                              color: AppTheme.primaryRed,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = _filteredItems[index] as Map<String, dynamic>;
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
                                        // Image or placeholder
                                        Container(
                                          width: 60, height: 60,
                                          decoration: BoxDecoration(
                                            color: AppTheme.secondaryBackground,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: item['image'] != null
                                              ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image.network(item['image'], fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => Icon(Icons.fastfood, size: 30, color: AppTheme.mutedText),
                                                  ),
                                                )
                                              : Icon(Icons.fastfood, size: 30, color: AppTheme.mutedText),
                                        ),
                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryText)),
                                              const SizedBox(height: 4),
                                              Text(item['description'] ?? '', style: TextStyle(fontSize: 12, color: AppTheme.secondaryText), maxLines: 2, overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  if (item['category_name'] != null)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(color: AppTheme.primaryRed.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                                      child: Text(item['category_name'], style: TextStyle(fontSize: 10, color: AppTheme.primaryRed)),
                                                    ),
                                                  const SizedBox(width: 8),
                                                  Text('MK${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        Column(
                                          children: [
                                            Switch(
                                              value: item['is_available'] ?? false,
                                              onChanged: (_) => _toggleAvailability(item),
                                              activeColor: AppTheme.success,
                                            ),
                                            Row(
                                              children: [
                                                IconButton(icon: const Icon(Icons.edit, size: 20), color: AppTheme.warning, onPressed: () => _editMenuItem(item)),
                                                IconButton(icon: const Icon(Icons.delete, size: 20), color: AppTheme.error, onPressed: () => _deleteMenuItem(item)),
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