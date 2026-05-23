import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/restaurant_provider.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Pizza', 'Burgers', 'Sushi', 'Desserts', 'Drinks'];

  // Get available categories (excluding 'All')
  List<String> get _availableCategories => _categories.where((c) => c != 'All').toList();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RestaurantProvider>().loadMenuItems();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _deleteMenuItem(MenuItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
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
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.5)),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
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

    if (confirmed == true) {
      final success = await context.read<RestaurantProvider>().deleteMenuItem(item.id);
      if (success) {
        _showSnackBar('${item.name} deleted');
      } else {
        _showSnackBar('Failed to delete ${item.name}', isError: true);
      }
    }
  }

  Future<String?> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return pickedFile.path;
      }
      return null;
    } catch (e) {
      _showSnackBar('Error picking image: $e', isError: true);
      return null;
    }
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.getMutedTextColor(context));
    }
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Icon(Icons.broken_image, size: 40, color: AppTheme.getMutedTextColor(context)),
    );
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    
    // Initialize with first available category, not 'All'
    String selectedCategory = _availableCategories.isNotEmpty ? _availableCategories.first : 'Pizza';
    String? imagePath;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.getCardColor(context),
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
                      if (path != null) setDialogState(() => imagePath = path);
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                      ),
                      child: imagePath != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(imagePath!), fit: BoxFit.cover))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.getMutedTextColor(context)),
                                const SizedBox(height: 8),
                                Text('Tap to add image', style: TextStyle(color: AppTheme.getMutedTextColor(context))),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Item Name *',
                      labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Price (MK) *',
                      labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                      prefixText: 'MK ',
                      prefixStyle: const TextStyle(color: AppTheme.primaryRed),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // FIXED: Dropdown with proper null safety
                  DropdownButtonFormField<String>(
                    value: _availableCategories.contains(selectedCategory) ? selectedCategory : null,
                    hint: const Text('Select Category'),
                    dropdownColor: AppTheme.getCardColor(context),
                    style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: _availableCategories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category, style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
                    )).toList(),
                    onChanged: (value) => setDialogState(() => selectedCategory = value!),
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
                          side: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.5)),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameCtrl.text.isEmpty) {
                          _showSnackBar('Please enter item name', isError: true);
                          return;
                        }
                        if (priceCtrl.text.isEmpty) {
                          _showSnackBar('Please enter price', isError: true);
                          return;
                        }
                        
                        final itemData = {
                          'name': nameCtrl.text,
                          'description': descCtrl.text,
                          'price': double.parse(priceCtrl.text) ?? 0,
                          'category': selectedCategory,
                          'is_available': true,
                        };
                        
                        final success = await context.read<RestaurantProvider>().addMenuItem(itemData);
                        
                        if (success) {
                          Navigator.pop(context);
                          _showSnackBar('${nameCtrl.text} added to menu');
                        } else {
                          _showSnackBar('Failed to add item', isError: true);
                        }
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

  void _showEditItemDialog(MenuItem item) {
    final nameCtrl = TextEditingController(text: item.name);
    final descCtrl = TextEditingController(text: item.description);
    final priceCtrl = TextEditingController(text: item.price.toString());
    
    // Ensure selectedCategory is valid
    String selectedCategory = _availableCategories.contains(item.category) 
        ? item.category 
        : (_availableCategories.isNotEmpty ? _availableCategories.first : 'Pizza');
    String? imagePath;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.getCardColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
            ),
            title: const Text('Edit Menu Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final path = await _pickImage();
                      if (path != null) setDialogState(() => imagePath = path);
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                      ),
                      child: imagePath != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(imagePath!), fit: BoxFit.cover))
                          : (item.image.isNotEmpty
                              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildImageWidget(item.image))
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.getMutedTextColor(context)),
                                    const SizedBox(height: 8),
                                    Text('Tap to change image', style: TextStyle(color: AppTheme.getMutedTextColor(context))),
                                  ],
                                )),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Item Name *',
                      labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Price (MK) *',
                      labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                      prefixText: 'MK ',
                      prefixStyle: const TextStyle(color: AppTheme.primaryRed),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // FIXED: Dropdown with proper null safety
                  DropdownButtonFormField<String>(
                    value: _availableCategories.contains(selectedCategory) ? selectedCategory : null,
                    hint: const Text('Select Category'),
                    dropdownColor: AppTheme.getCardColor(context),
                    style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    items: _availableCategories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category, style: TextStyle(color: AppTheme.getPrimaryTextColor(context))),
                    )).toList(),
                    onChanged: (value) => setDialogState(() => selectedCategory = value!),
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
                          side: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.5)),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameCtrl.text.isEmpty) {
                          _showSnackBar('Please enter item name', isError: true);
                          return;
                        }
                        if (priceCtrl.text.isEmpty) {
                          _showSnackBar('Please enter price', isError: true);
                          return;
                        }
                        
                        final itemData = {
                          'id': item.id,
                          'name': nameCtrl.text,
                          'description': descCtrl.text,
                          'price': double.parse(priceCtrl.text),
                          'category': selectedCategory,
                          'is_available': item.isAvailable,
                        };
                        
                        final success = await context.read<RestaurantProvider>().updateMenuItem(item.id, itemData);
                        
                        if (success) {
                          Navigator.pop(context);
                          _showSnackBar('${nameCtrl.text} updated');
                        } else {
                          _showSnackBar('Failed to update item', isError: true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _toggleAvailability(MenuItem item) async {
    final itemData = {
      'id': item.id,
      'is_available': !item.isAvailable,
    };
    
    final success = await context.read<RestaurantProvider>().updateMenuItem(item.id, itemData);
    if (success) {
      _showSnackBar('${item.name} is now ${!item.isAvailable ? 'available' : 'out of stock'}');
    } else {
      _showSnackBar('Failed to update availability', isError: true);
    }
  }

  List<MenuItem> get _filteredItems {
    final items = context.watch<RestaurantProvider>().menuItems;
    return _selectedCategory == 'All' 
        ? items 
        : items.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<RestaurantProvider>().isLoading;
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Column(
        children: [
          // Categories
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
                      color: isSelected ? null : AppTheme.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(30),
                      border: isSelected ? null : Border.all(color: AppTheme.getMutedTextColor(context).withOpacity(0.3)),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.getSecondaryTextColor(context),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Menu Items List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_menu, size: 64, color: AppTheme.getMutedTextColor(context)),
                            const SizedBox(height: 16),
                            Text('No items in this category', style: TextStyle(color: AppTheme.getSecondaryTextColor(context))),
                            const SizedBox(height: 8),
                            Text('Tap + Add to add new items', style: TextStyle(color: AppTheme.getMutedTextColor(context))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return _buildMenuItemCard(item);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.primaryRed,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        tooltip: 'Add New Meal',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: item.image.isNotEmpty
                ? ClipRRect(borderRadius: BorderRadius.circular(10), child: _buildImageWidget(item.image))
                : Icon(Icons.fastfood, size: 30, color: AppTheme.getMutedTextColor(context)),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryTextColor(context),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.isAvailable ? AppTheme.success.withOpacity(0.2) : AppTheme.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.isAvailable ? 'Available' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: item.isAvailable ? AppTheme.success : AppTheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MK${item.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: AppTheme.primaryRed),
                          onPressed: () => _showEditItemDialog(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                          onPressed: () => _deleteMenuItem(item),
                        ),
                        IconButton(
                          icon: Icon(
                            item.isAvailable ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                            color: item.isAvailable ? AppTheme.getMutedTextColor(context) : AppTheme.success,
                          ),
                          onPressed: () => _toggleAvailability(item),
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
  }
}