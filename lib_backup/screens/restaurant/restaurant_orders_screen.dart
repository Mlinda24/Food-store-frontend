import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/models.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  String _selectedTab = 'Active';
  final List<String> _tabs = ['Active', 'Ready', 'Past'];

  List<RestaurantOrder> _activeOrders = [];
  List<RestaurantOrder> _readyOrders = [];
  List<RestaurantOrder> _pastOrders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    _activeOrders = [
      RestaurantOrder(
        id: 'ORD-001',
        customerName: 'John Doe',
        customerPhone: '+265 888 123 456',
        customerAddress: '123 Main St, Area 3',
        items: [
          OrderItemModel(
              menuItemId: '1',
              name: 'Margherita Pizza',
              quantity: 2,
              price: 4500),
          OrderItemModel(
              menuItemId: '2', name: 'Coke', quantity: 2, price: 800),
        ],
        status: OrderStatus.confirmed,
        total: 10600,
        orderTime: DateTime.now().subtract(const Duration(minutes: 5)),
        estimatedPrepTime: 20,
      ),
      RestaurantOrder(
        id: 'ORD-002',
        customerName: 'Jane Smith',
        customerPhone: '+265 999 789 012',
        customerAddress: '456 Oak Ave, Area 47',
        items: [
          OrderItemModel(
              menuItemId: '3', name: 'Cheeseburger', quantity: 1, price: 3800),
          OrderItemModel(
              menuItemId: '4', name: 'French Fries', quantity: 1, price: 1200),
        ],
        status: OrderStatus.pending,
        total: 5000,
        orderTime: DateTime.now().subtract(const Duration(minutes: 12)),
        estimatedPrepTime: 15,
      ),
      RestaurantOrder(
        id: 'ORD-005',
        customerName: 'Alice Brown',
        customerPhone: '+265 888 555 777',
        customerAddress: '789 Pine St, Area 9',
        items: [
          OrderItemModel(
              menuItemId: '1',
              name: 'Pepperoni Pizza',
              quantity: 1,
              price: 5500),
          OrderItemModel(
              menuItemId: '5', name: 'Chicken Wings', quantity: 2, price: 3900),
        ],
        status: OrderStatus.preparing,
        total: 13300,
        orderTime: DateTime.now().subtract(const Duration(minutes: 8)),
        estimatedPrepTime: 10,
      ),
    ];

    _readyOrders = [
      RestaurantOrder(
        id: 'ORD-003',
        customerName: 'Mike Johnson',
        customerPhone: '+265 777 456 789',
        customerAddress: '789 Pine St, Area 9',
        items: [
          OrderItemModel(
              menuItemId: '1',
              name: 'Pepperoni Pizza',
              quantity: 1,
              price: 5500),
        ],
        status: OrderStatus.ready,
        total: 5500,
        orderTime: DateTime.now().subtract(const Duration(minutes: 25)),
        estimatedPrepTime: 0,
      ),
    ];

    _pastOrders = [
      RestaurantOrder(
        id: 'ORD-004',
        customerName: 'Sarah Wilson',
        customerPhone: '+265 666 321 654',
        customerAddress: '321 Elm St, Area 12',
        items: [
          OrderItemModel(
              menuItemId: '5', name: 'Chicken Wings', quantity: 1, price: 3900),
        ],
        status: OrderStatus.delivered,
        total: 3900,
        orderTime: DateTime.now().subtract(const Duration(hours: 2)),
        estimatedPrepTime: 0,
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

  void _acceptOrder(RestaurantOrder order) {
    setState(() {
      final index = _activeOrders.indexOf(order);
      if (index != -1) {
        _activeOrders[index] = RestaurantOrder(
          id: order.id,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
          customerAddress: order.customerAddress,
          items: order.items,
          status: OrderStatus.confirmed,
          total: order.total,
          orderTime: order.orderTime,
          specialInstructions: order.specialInstructions,
          estimatedPrepTime: order.estimatedPrepTime,
        );
      }
    });
    _showSnackBar('Order ${order.id} accepted!');
  }

  void _declineOrder(RestaurantOrder order) {
    setState(() {
      _activeOrders.removeWhere((o) => o.id == order.id);
    });
    _showSnackBar('Order ${order.id} declined', isError: true);
  }

  void _markAsPreparing(RestaurantOrder order) {
    setState(() {
      final index = _activeOrders.indexOf(order);
      if (index != -1) {
        _activeOrders[index] = RestaurantOrder(
          id: order.id,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
          customerAddress: order.customerAddress,
          items: order.items,
          status: OrderStatus.preparing,
          total: order.total,
          orderTime: order.orderTime,
          specialInstructions: order.specialInstructions,
          estimatedPrepTime: 15,
        );
      }
    });
    _showSnackBar('Order ${order.id} is now being prepared');
  }

  void _markAsReady(RestaurantOrder order) {
    setState(() {
      _activeOrders.removeWhere((o) => o.id == order.id);
      _readyOrders.add(RestaurantOrder(
        id: order.id,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        customerAddress: order.customerAddress,
        items: order.items,
        status: OrderStatus.ready,
        total: order.total,
        orderTime: order.orderTime,
        specialInstructions: order.specialInstructions,
        estimatedPrepTime: 0,
      ));
    });
    _showSnackBar('Order ${order.id} is ready for pickup!');
  }

  void _markAsPickedUp(RestaurantOrder order) {
    setState(() {
      _readyOrders.removeWhere((o) => o.id == order.id);
      _pastOrders.add(RestaurantOrder(
        id: order.id,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        customerAddress: order.customerAddress,
        items: order.items,
        status: OrderStatus.pickedUp,
        total: order.total,
        orderTime: order.orderTime,
        specialInstructions: order.specialInstructions,
        estimatedPrepTime: 0,
      ));
    });
    _showSnackBar('Order ${order.id} has been picked up');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackground,
      body: Column(
        children: [
          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _tabs.map((tab) {
                final isSelected = _selectedTab == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = tab),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient:
                            isSelected ? AppTheme.primaryButtonGradient : null,
                        color: isSelected ? null : AppTheme.secondaryBackground,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        tab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Orders List
          Expanded(
            child: _getOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _getOrdersList() {
    List<RestaurantOrder> orders;
    if (_selectedTab == 'Active') {
      orders = _activeOrders;
    } else if (_selectedTab == 'Ready') {
      orders = _readyOrders;
    } else {
      orders = _pastOrders;
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: AppTheme.mutedText,
            ),
            const SizedBox(height: 16),
            Text(
              'No $_selectedTab orders',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index]);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, RestaurantOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    order.id,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
              Text(
                order.formattedTime,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Customer Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person,
                    size: 16, color: AppTheme.mutedText),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryText,
                      ),
                    ),
                    Text(
                      order.customerPhone,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Address
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 14, color: AppTheme.mutedText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.customerAddress,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            height: 24,
            color: AppTheme.deepCrimson,
          ),
          // Items
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity}x ${item.name}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    Text(
                      'MK${(item.price * item.quantity).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(height: 16),
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryText,
                ),
              ),
              Text(
                'MK${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryRed,
                ),
              ),
            ],
          ),

          // ========== ACTION BUTTONS - CENTERED WITH REDUCED SIZE ==========

          // For Pending Orders - Accept/Decline buttons (centered, reduced size)
          if (_selectedTab == 'Active' && order.status == OrderStatus.pending)
            const SizedBox(height: 16),
          if (_selectedTab == 'Active' && order.status == OrderStatus.pending)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 100,
                    child: OutlinedButton(
                      onPressed: () => _declineOrder(order),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(
                              color: AppTheme.error.withOpacity(0.5)),
                        ),
                      ),
                      child: const Text(
                        'Decline',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () => _acceptOrder(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Accept',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // For Confirmed Orders - Start Preparing button (centered, reduced size)
          if (_selectedTab == 'Active' && order.status == OrderStatus.confirmed)
            const SizedBox(height: 16),
          if (_selectedTab == 'Active' && order.status == OrderStatus.confirmed)
            Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: () => _markAsPreparing(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warning,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.kitchen, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Start Preparing',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // For Preparing Orders - Ready button (centered, reduced size, GREEN)
          if (_selectedTab == 'Active' && order.status == OrderStatus.preparing)
            const SizedBox(height: 16),
          if (_selectedTab == 'Active' && order.status == OrderStatus.preparing)
            Center(
              child: SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () => _markAsReady(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success, // GREEN
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.done_all, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Ready',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // For Ready Orders - Picked Up button (centered, reduced size)
          if (_selectedTab == 'Ready') const SizedBox(height: 16),
          if (_selectedTab == 'Ready')
            Center(
              child: SizedBox(
                width: 120,
                child: OutlinedButton(
                  onPressed: () => _markAsPickedUp(order),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.teal, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping,
                          size: 14, color: AppTheme.teal),
                      SizedBox(width: 6),
                      Text(
                        'Picked Up',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppTheme.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.warning;
      case OrderStatus.confirmed:
        return AppTheme.primaryRed;
      case OrderStatus.preparing:
        return AppTheme.warning;
      case OrderStatus.ready:
        return AppTheme.success; // GREEN
      case OrderStatus.pickedUp:
        return AppTheme.teal;
      case OrderStatus.delivered:
        return AppTheme.success;
      default:
        return AppTheme.mutedText;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.delivered:
        return 'Delivered';
      default:
        return 'Unknown';
    }
  }
}
