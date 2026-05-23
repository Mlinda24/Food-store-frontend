import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../providers/restaurant_provider.dart';
import '../../services/api_service.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All'];
  final ApiService _apiService = ApiService();
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadData();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted && mounted) {
        context.read<RestaurantProvider>().loadMenuItems();
      }
    });
  }

  void _updateCategories(List<MenuItem> items) {
    final Set<String> cats = {'All'};
    for (var item in items) {
      if (item.category.isNotEmpty) {
        cats.add(item.category);
      }
    }
    if (_isMounted && mounted) {
      setState(() {
        _categories.clear();
        _categories.addAll(cats);
        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = 'All';
        }
      });
    }
  }

  // REMOVED: _showSnackBar method - no more popup messages

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

    if (confirmed == true && _isMounted && mounted) {
      // Silent delete - no success message
      await context.read<RestaurantProvider>().deleteMenuItem(item.id);
      _loadData();
      // NO SNACKBAR
    }
  }

  Future<XFile?> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      return pickedFile;
    } catch (e) {
      // Silent error - no snackbar
      return null;
    }
  }

  Widget _buildImagePreview(XFile? imageFile) {
    if (imageFile == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 40, color: AppTheme.getMutedTextColor(context)),
          const SizedBox(height: 8),
          Text('Tap to add image', style: TextStyle(color: AppTheme.getMutedTextColor(context))),
        ],
      );
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageFile.path,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
      ),
    );
  }

  Widget _buildImageWidget(MenuItem item) {
    final imageToUse = item.imageUrl.isNotEmpty ? item.imageUrl : item.image;
    
    if (imageToUse.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        color: AppTheme.getSurfaceColor(context),
        child: Icon(Icons.fastfood, size: 30, color: AppTheme.getMutedTextColor(context)),
      );
    }
    
    String fullUrl;
    if (imageToUse.startsWith('http')) {
      fullUrl = imageToUse;
    } else if (imageToUse.startsWith('/media/')) {
      fullUrl = 'http://192.168.137.1:8000$imageToUse';
    } else {
      fullUrl = 'http://192.168.137.1:8000/media/$imageToUse';
    }
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        fullUrl,
        fit: BoxFit.cover,
        width: 60,
        height: 60,
        errorBuilder: (_, __, ___) => Container(
          width: 60,
          height: 60,
          color: AppTheme.getSurfaceColor(context),
          child: Icon(Icons.broken_image, size: 30, color: AppTheme.getMutedTextColor(context)),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 60,
            height: 60,
            color: AppTheme.getSurfaceColor(context),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    
    String selectedCategory = 'General';
    XFile? selectedImage;
    bool isUploading = false;
    bool dialogMounted = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.getCardColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
            ),
            title: const Text('Add Menu Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final image = await _pickImage();
                        if (image != null && dialogMounted) {
                          setDialogState(() => selectedImage = image);
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                        ),
                        child: _buildImagePreview(selectedImage),
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
                    TextField(
                      controller: TextEditingController(text: selectedCategory),
                      style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                        hintText: 'e.g., Pizza, Burgers, Desserts',
                        filled: true,
                        fillColor: AppTheme.getSurfaceColor(context),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) {
                        if (dialogMounted) {
                          setDialogState(() => selectedCategory = value.trim().isEmpty ? 'General' : value.trim());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  dialogMounted = false;
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.5)),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) {
                    // Silent validation - no snackbar
                    return;
                  }
                  if (priceCtrl.text.trim().isEmpty) {
                    // Silent validation - no snackbar
                    return;
                  }
                  
                  final priceValue = double.tryParse(priceCtrl.text.trim());
                  if (priceValue == null) {
                    // Silent validation - no snackbar
                    return;
                  }
                  
                  if (dialogMounted) {
                    setDialogState(() => isUploading = true);
                  }
                  
                  try {
                    bool success;
                    
                    final XFile? image = selectedImage;
                    if (image != null) {
                      success = await context.read<RestaurantProvider>().addMenuItemWithImage(
                        name: nameCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        price: priceValue,
                        category: selectedCategory,
                        imageFile: image,
                      );
                    } else {
                      final itemData = {
                        'name': nameCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                        'price': priceValue,
                        'category': selectedCategory,
                        'is_available': true,
                      };
                      success = await context.read<RestaurantProvider>().addMenuItem(itemData);
                    }
                    
                    if (success && dialogMounted) {
                      dialogMounted = false;
                      Navigator.pop(context);
                      _loadData();
                      // NO SNACKBAR
                    } else if (dialogMounted) {
                      // Silent failure - no snackbar
                      setDialogState(() => isUploading = false);
                    }
                  } catch (e) {
                    // Silent error - no snackbar
                    if (dialogMounted) {
                      setDialogState(() => isUploading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Add Item', style: TextStyle(fontWeight: FontWeight.bold)),
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
    
    String selectedCategory = item.category.isEmpty ? 'General' : item.category;
    XFile? selectedImage;
    bool isUploading = false;
    bool dialogMounted = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTheme.getCardColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppTheme.deepCrimson.withOpacity(0.3)),
            ),
            title: const Text('Edit Menu Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final image = await _pickImage();
                        if (image != null && dialogMounted) {
                          setDialogState(() => selectedImage = image);
                        }
                      },
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
                        ),
                        child: selectedImage != null
                            ? _buildImagePreview(selectedImage)
                            : (item.imageUrl.isNotEmpty || item.image.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _buildImageWidget(item),
                                  )
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
                    TextField(
                      controller: TextEditingController(text: selectedCategory),
                      style: TextStyle(color: AppTheme.getPrimaryTextColor(context)),
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
                        hintText: 'e.g., Pizza, Burgers, Desserts',
                        filled: true,
                        fillColor: AppTheme.getSurfaceColor(context),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (value) {
                        if (dialogMounted) {
                          setDialogState(() => selectedCategory = value.trim().isEmpty ? 'General' : value.trim());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  dialogMounted = false;
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: AppTheme.getMutedTextColor(context).withOpacity(0.5)),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) {
                    // Silent validation - no snackbar
                    return;
                  }
                  if (priceCtrl.text.trim().isEmpty) {
                    // Silent validation - no snackbar
                    return;
                  }
                  
                  final priceValue = double.tryParse(priceCtrl.text.trim());
                  if (priceValue == null) {
                    // Silent validation - no snackbar
                    return;
                  }
                  
                  if (dialogMounted) {
                    setDialogState(() => isUploading = true);
                  }
                  
                  final itemData = {
                    'name': nameCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'price': priceValue,
                    'category': selectedCategory,
                    'is_available': item.isAvailable,
                  };
                  
                  final success = await context.read<RestaurantProvider>().updateMenuItem(item.id, itemData);
                  
                  if (success && dialogMounted) {
                    dialogMounted = false;
                    Navigator.pop(context);
                    _loadData();
                    // NO SNACKBAR
                  } else if (dialogMounted) {
                    // Silent failure - no snackbar
                    setDialogState(() => isUploading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleAvailability(MenuItem item) async {
    // Use the dedicated toggle method from provider
    await context.read<RestaurantProvider>().toggleMenuItemAvailability(item.id, !item.isAvailable);
    _loadData();
    // NO SNACKBAR - completely silent
  }

  List<MenuItem> get _filteredItems {
    final items = context.watch<RestaurantProvider>().menuItems;
    _updateCategories(items);
    return _selectedCategory == 'All' 
        ? items 
        : items.where((item) => item.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<RestaurantProvider>().isLoadingMenu;
    final filteredItems = _filteredItems;
    
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Column(
        children: [
          if (_categories.length > 1)
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
                    onTap: () {
                      if (_isMounted && mounted) {
                        setState(() => _selectedCategory = category);
                      }
                    },
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
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
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
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: _buildImageWidget(item),
          ),
          const SizedBox(width: 12),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getPrimaryTextColor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.isAvailable ? AppTheme.success.withOpacity(0.2) : AppTheme.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.isAvailable ? 'Available' : 'Out',
                        style: TextStyle(
                          fontSize: 9,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          icon: Icons.edit,
                          color: AppTheme.primaryRed,
                          onPressed: () => _showEditItemDialog(item),
                        ),
                        _buildActionButton(
                          icon: Icons.delete_outline,
                          color: AppTheme.error,
                          onPressed: () => _deleteMenuItem(item),
                        ),
                        _buildActionButton(
                          icon: item.isAvailable ? Icons.visibility_off : Icons.visibility,
                          color: item.isAvailable ? AppTheme.getMutedTextColor(context) : AppTheme.success,
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

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
