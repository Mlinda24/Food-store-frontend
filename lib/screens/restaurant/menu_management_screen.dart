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
  bool _isLoading = false;

  final List<String> _categories = ['All', 'Pizza', 'Burgers', 'Sushi', 'Desserts', 'Drinks'];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  void _loadMenuItems() {
    _menuItems = [
      MenuItem(
        id: '1',
        restaurantId: '1',
        name: 'Margherita Pizza',
        description: 'Fresh mozzarella, tomato sauce, basil',
        price: 4500,
        image: '',
        category: 'Pizza',
        isAvailable: true,
      ),
      MenuItem(
        id: '2',
        restaurantId: '1',
        name: 'Pepperoni Pizza',
        description: 'Classic pepperoni with mozzarella',
        price: 5500,
        image: '',
        category: 'Pizza',
        isAvailable: true,
      ),
      MenuItem(
        id: '3',
        restaurantId: '1',
        name: 'Cheeseburger',
        description: 'Beef patty with cheese, lettuce, tomato',
        price: 3800,
        image: '',
        category: 'Burgers',
        isAvailable: true,
      ),
      MenuItem(
        id: '4',
        restaurantId: '1',
        name: 'Veggie Burger',
        description: 'Plant-based patty with fresh veggies',
        price: 4200,
        image: '',
        category: 'Burgers',
        isAvailable: false,
      ),
    ];
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

  void _deleteMenuItem(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.warning,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Item',
              style: TextStyle(
                color: AppTheme.primaryText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${item.name}"?\n\nThis action cannot be undone.',
          style: const TextStyle(
            color: AppTheme.secondaryText,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: AppTheme.mutedText.withOpacity(0.5)),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _menuItems.removeWhere((i) => i.id == item.id);
                    });
                    Navigator.pop(context);
                    _showSnackBar('${item.name} deleted');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      ),
    );
  }

  Future<String?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return pickedFile.path;
    }
    return null;
  }

  Widget _buildImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.mutedText);
    }
    
    // For web, we need to handle differently
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 40, color: AppTheme.mutedText);
        },
      );
    } else {
      // For desktop/mobile, we can use FileImage
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: 40, color: AppTheme.mutedText);
        },
      );
    }
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategory = 'Pizza';
    String? imagePath;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
              ),
              title: const Text(
                'Add Menu Item',
                style: TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: () async {
                        final path = await _pickImage();
                        if (path != null) {
                          setDialogState(() {
                            imagePath = path;
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                        ),
                        child: imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildImageWidget(imagePath),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                    color: AppTheme.mutedText,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to add image',
                                    style: TextStyle(
                                      color: AppTheme.mutedText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppTheme.primaryText),
                      decoration: InputDecoration(
                        labelText: 'Item Name *',
                        labelStyle: const TextStyle(color: AppTheme.secondaryText),
                        filled: true,
                        fillColor: AppTheme.secondaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(color: AppTheme.primaryText),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: const TextStyle(color: AppTheme.secondaryText),
                        filled: true,
                        fillColor: AppTheme.secondaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      style: const TextStyle(color: AppTheme.primaryText),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price (MK) *',
                        labelStyle: const TextStyle(color: AppTheme.secondaryText),
                        prefixText: 'MK ',
                        prefixStyle: const TextStyle(color: AppTheme.primaryRed),
                        filled: true,
                        fillColor: AppTheme.secondaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: AppTheme.cardBackground,
                      style: const TextStyle(color: AppTheme.primaryText),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: const TextStyle(color: AppTheme.secondaryText),
                        filled: true,
                        fillColor: AppTheme.secondaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _categories.where((c) => c != 'All').map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category, style: const TextStyle(color: AppTheme.primaryText)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: AppTheme.mutedText.withOpacity(0.5)),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isEmpty) {
                            _showSnackBar('Please enter item name', isError: true);
                            return;
                          }
                          if (priceController.text.isEmpty) {
                            _showSnackBar('Please enter price', isError: true);
                            return;
                          }
                          
                          setState(() {
                            _menuItems.add(MenuItem(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              restaurantId: '1',
                              name: nameController.text,
                              description: descriptionController.text,
                              price: double.parse(priceController.text),
                              image: imagePath ?? '',
                              category: selectedCategory,
                              isAvailable: true,
                            ));
                          });
                          Navigator.pop(context);
                          _showSnackBar('${nameController.text} added to menu');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Add Item',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            );
          },
        );
      },
    );
  }

  void _showEditItemDialog(MenuItem item) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());
    String selectedCategory = item.category;
    String? imagePath = item.image;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
              ),
              title: const Text(
                'Edit Menu Item',
                style: TextStyle(
                  color: AppTheme.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image Picker
                    GestureDetector(
                      onTap: () async {
                        final path = await _pickImage();
                        if (path != null) {
                          setDialogState(() {
                            imagePath = path;
                          });
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                        ),
                        child: imagePath != null && imagePath!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildImageWidget(imagePath),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                    color: AppTheme.mutedText,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to change image',
                                    style: TextStyle(
                                      color: AppTheme.mutedText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppTheme.primaryText),
                      decoration: InputDecoration(
                        labelText: 'Item Name *',
                        labelStyle: const TextStyle(color: AppTheme.secondaryText),
                        filled: true,
                        fillColor: AppTheme.secondaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(color: AppTheme.primaryText),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: const TextStyle(color: AppTheme.secondaryText),
                        filled: true,
                        fillColor: AppTheme.secondaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      style: const TextStyle(color: AppTheme.primaryText),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price (MK) *',
                        labelStyle: const TextStyle(color: AppTheme.secondaryText),
                        prefixText: 'MK ',
                        prefixStyle: const TextStyle(color: AppTheme.primaryRed),
                        filled: true,
                        fillColor: AppTheme.secondaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: AppTheme.cardBackground,
                      style: const TextStyle(color: AppTheme.primaryText),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: const TextStyle(color: AppTheme.secondaryText),
                        filled: true,
                        fillColor: AppTheme.secondaryBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: _categories.where((c) => c != 'All').map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category, style: const TextStyle(color: AppTheme.primaryText)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: AppTheme.mutedText.withOpacity(0.5)),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isEmpty) {
                            _showSnackBar('Please enter item name', isError: true);
                            return;
                          }
                          if (priceController.text.isEmpty) {
                            _showSnackBar('Please enter price', isError: true);
                            return;
                          }
                          
                          setState(() {
                            final index = _menuItems.indexOf(item);
                            _menuItems[index] = MenuItem(
                              id: item.id,
                              restaurantId: item.restaurantId,
                              name: nameController.text,
                              description: descriptionController.text,
                              price: double.parse(priceController.text),
                              image: imagePath ?? '',
                              category: selectedCategory,
                              isAvailable: item.isAvailable,
                              options: item.options,
                            );
                          });
                          Navigator.pop(context);
                          _showSnackBar('${nameController.text} updated');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRed,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            );
          },
        );
      },
    );
  }

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == 'All') {
      return _menuItems;
    }
    return _menuItems.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.mainBackground,
        elevation: 0,
        title: const Text(
          'Menu Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryRed),
            onPressed: _showAddItemDialog,
          ),
        ],
      ),
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
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: _selectedCategory == category
                          ? AppTheme.primaryButtonGradient
                          : null,
                      color: _selectedCategory == category ? null : AppTheme.secondaryBackground,
                      borderRadius: BorderRadius.circular(30),
                      border: _selectedCategory == category
                          ? null
                          : Border.all(color: AppTheme.mutedText.withOpacity(0.3)),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: _selectedCategory == category ? Colors.white : AppTheme.secondaryText,
                        fontWeight: _selectedCategory == category ? FontWeight.w600 : FontWeight.w500,
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
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: AppTheme.mutedText,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items in this category',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add new items',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedText,
                          ),
                        ),
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
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGlowGradient,
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
              color: AppTheme.elevatedPanel,
              borderRadius: BorderRadius.circular(10),
            ),
            child: item.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildImageWidget(item.image),
                  )
                : const Icon(Icons.fastfood, size: 30, color: AppTheme.mutedText),
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryText,
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
                    color: AppTheme.secondaryText,
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryRed,
                      ),
                    ),
                    Row(
                      children: [
                        // Edit Button
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18, color: AppTheme.primaryRed),
                          onPressed: () => _showEditItemDialog(item),
                        ),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                          onPressed: () => _deleteMenuItem(item),
                        ),
                        // Toggle Availability Button
                        IconButton(
                          icon: Icon(
                            item.isAvailable ? Icons.visibility_off : Icons.visibility,
                            size: 18,
                            color: item.isAvailable ? AppTheme.mutedText : AppTheme.success,
                          ),
                          onPressed: () {
                            setState(() {
                              final index = _menuItems.indexOf(item);
                              _menuItems[index] = MenuItem(
                                id: item.id,
                                restaurantId: item.restaurantId,
                                name: item.name,
                                description: item.description,
                                price: item.price,
                                image: item.image,
                                category: item.category,
                                isAvailable: !item.isAvailable,
                                options: item.options,
                              );
                            });
                            _showSnackBar(
                              '${item.name} is now ${!item.isAvailable ? 'available' : 'out of stock'}',
                            );
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
  }
}