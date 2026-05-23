import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/theme.dart';
import '../../models/models.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<MenuItem> _menuItems = [];
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Pizza', 'Burgers', 'Sushi', 'Desserts', 'Drinks'];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  void _loadMenuItems() {
    _menuItems = [
      MenuItem(id: '1', restaurantId: '1', name: 'Margherita Pizza', description: 'Fresh mozzarella, tomato sauce, basil', price: 4500, image: '', category: 'Pizza', isAvailable: true),
      MenuItem(id: '2', restaurantId: '1', name: 'Pepperoni Pizza', description: 'Classic pepperoni with mozzarella', price: 5500, image: '', category: 'Pizza', isAvailable: true),
      MenuItem(id: '3', restaurantId: '1', name: 'Cheeseburger', description: 'Beef patty with cheese, lettuce, tomato', price: 3800, image: '', category: 'Burgers', isAvailable: true),
      MenuItem(id: '4', restaurantId: '1', name: 'Veggie Burger', description: 'Plant-based patty with fresh veggies', price: 4200, image: '', category: 'Burgers', isAvailable: false),
    ];
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? AppTheme.error : AppTheme.success, duration: const Duration(seconds: 2)),
    );
  }

  void _deleteMenuItem(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 28),
            const SizedBox(width: 12),
            const Text('Delete Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Are you sure you want to delete "${item.name}"?\n\nThis action cannot be undone.'),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: AppTheme.mutedText.withOpacity(0.5)),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _menuItems.removeWhere((i) => i.id == item.id));
                    Navigator.pop(context);
                    _showSnackBar('${item.name} deleted');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }

  Widget _buildImageWidget(String? imagePath, bool isDark) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.add_photo_alternate, size: 40, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText);
    }
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 40, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
    );
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCategory = 'Pizza';
    String? imagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
            ),
            title: const Text('Add Menu Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final path = await _pickImage();
                      if (path != null) setStateDialog(() => imagePath = path);
                    },
                    child: Container(
                      height: 120, width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                      ),
                      child: imagePath != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildImageWidget(imagePath, isDark))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                                const SizedBox(height: 8),
                                Text('Tap to add image', style: TextStyle(color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                    decoration: InputDecoration(
                      labelText: 'Item Name *',
                      labelStyle: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: TextStyle(color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                    decoration: InputDecoration(
                      labelText: 'Price (MK) *',
                      labelStyle: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText),
                      prefixText: 'MK ',
                      prefixStyle: const TextStyle(color: AppTheme.primaryRed),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: Theme.of(context).cardColor,
                    style: TextStyle(color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText),
                      filled: true,
                      fillColor: isDark ? AppTheme.darkSurface : AppTheme.lightBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: _categories.where((c) => c != 'All').map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category, style: TextStyle(color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText)),
                    )).toList(),
                    onChanged: (value) => setStateDialog(() => selectedCategory = value!),
                  ),
                ],
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: AppTheme.mutedText.withOpacity(0.5)),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameCtrl.text.isEmpty) return _showSnackBar('Please enter item name', isError: true);
                        if (priceCtrl.text.isEmpty) return _showSnackBar('Please enter price', isError: true);
                        setState(() {
                          _menuItems.add(MenuItem(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            restaurantId: '1',
                            name: nameCtrl.text,
                            description: descCtrl.text,
                            price: double.parse(priceCtrl.text),
                            image: imagePath ?? '',
                            category: selectedCategory,
                            isAvailable: true,
                          ));
                        });
                        Navigator.pop(context);
                        _showSnackBar('${nameCtrl.text} added to menu');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<MenuItem> get _filteredItems => _selectedCategory == 'All' ? _menuItems : _menuItems.where((item) => item.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        elevation: 0,
        title: Text('Menu Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _showAddItemDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('+ Add', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryButtonGradient : null,
                      color: isSelected ? null : (isDark ? AppTheme.darkSurface : AppTheme.lightBackground),
                      borderRadius: BorderRadius.circular(30),
                      border: isSelected ? null : Border.all(color: (isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText).withOpacity(0.3)),
                    ),
                    child: Text(category, style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    )),
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
                        Icon(Icons.restaurant_menu, size: 64, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                        const SizedBox(height: 16),
                        Text('No items in this category', style: TextStyle(color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText)),
                        const SizedBox(height: 8),
                        Text('Tap + Add to add new items', style: TextStyle(color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText)),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70, height: 70,
                              decoration: BoxDecoration(color: isDark ? AppTheme.darkSurface : AppTheme.lightBackground, borderRadius: BorderRadius.circular(10)),
                              child: item.image.isNotEmpty
                                  ? ClipRRect(borderRadius: BorderRadius.circular(10), child: _buildImageWidget(item.image, isDark))
                                  : Icon(Icons.fastfood, size: 30, color: isDark ? AppTheme.darkMutedText : AppTheme.lightMutedText),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppTheme.darkPrimaryText : AppTheme.lightPrimaryText))),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: item.isAvailable ? AppTheme.success.withOpacity(0.2) : AppTheme.error.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(item.isAvailable ? 'Available' : 'Out of Stock', style: TextStyle(fontSize: 10, color: item.isAvailable ? AppTheme.success : AppTheme.error)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.description, style: TextStyle(fontSize: 11, color: isDark ? AppTheme.darkSecondaryText : AppTheme.lightSecondaryText), maxLines: 2),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('MK${item.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryRed)),
                                      Row(
                                        children: [
                                          IconButton(icon: const Icon(Icons.edit, size: 18, color: AppTheme.primaryRed), onPressed: () {}),
                                          IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error), onPressed: () => _deleteMenuItem(item)),
                                          IconButton(
                                            icon: Icon(item.isAvailable ? Icons.visibility_off : Icons.visibility, size: 18, color: item.isAvailable ? AppTheme.mutedText : AppTheme.success),
                                            onPressed: () {
                                              setState(() {
                                                final index = _menuItems.indexOf(item);
                                                _menuItems[index] = MenuItem(
                                                  id: item.id, restaurantId: item.restaurantId, name: item.name, description: item.description,
                                                  price: item.price, image: item.image, category: item.category, isAvailable: !item.isAvailable,
                                                );
                                              });
                                              _showSnackBar('${item.name} is now ${!item.isAvailable ? 'available' : 'out of stock'}');
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}