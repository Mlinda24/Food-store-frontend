import '../models/models.dart';

class MockDataService {
  Future<List<Restaurant>> getRestaurants() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Restaurant(
        id: '1',
        name: 'Pizza Paradise',
        description: 'Best pizza in town!',
        image: '',
        address: '123 Main St, Downtown',
        rating: 4.5,
        deliveryTime: 30,
        deliveryFee: 2.99,
        minOrderAmount: 10.0,
        categories: ['Pizza', 'Italian'],
        isOpen: true,
      ),
      Restaurant(
        id: '2',
        name: 'Burger King',
        description: 'Flame-grilled burgers',
        image: '',
        address: '456 Oak Ave, Midtown',
        rating: 4.2,
        deliveryTime: 25,
        deliveryFee: 1.99,
        minOrderAmount: 8.0,
        categories: ['Burger', 'Fast Food'],
        isOpen: true,
      ),
      Restaurant(
        id: '3',
        name: 'Sushi Master',
        description: 'Fresh sushi daily',
        image: '',
        address: '789 Pine St, Uptown',
        rating: 4.8,
        deliveryTime: 35,
        deliveryFee: 3.99,
        minOrderAmount: 15.0,
        categories: ['Sushi', 'Japanese'],
        isOpen: false,
      ),
    ];
  }

  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      MenuItem(
        id: '1',
        restaurantId: restaurantId,
        name: 'Margherita Pizza',
        description: 'Fresh mozzarella, tomato sauce, basil',
        price: 12.99,
        image: '',
        category: 'Pizza',
        isAvailable: true,
        options: ['Extra Cheese', 'Thin Crust'],
      ),
      MenuItem(
        id: '2',
        restaurantId: restaurantId,
        name: 'Pepperoni Pizza',
        description: 'Classic pepperoni with mozzarella',
        price: 14.99,
        image: '',
        category: 'Pizza',
        isAvailable: true,
        options: ['Extra Pepperoni', 'Extra Cheese'],
      ),
    ];
  }

  Future<List<Order>> getOrders(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      Order(
        id: '1',
        userId: userId,
        restaurantId: '1',
        driverId: 'driver1',
        items: [
          OrderItem(
            menuItemId: '1',
            name: 'Margherita Pizza',
            quantity: 2,
            price: 12.99,
          ),
        ],
        status: OrderStatus.delivered,
        subtotal: 25.98,
        deliveryFee: 2.99,
        tax: 2.60,
        total: 31.57,
        deliveryAddress: '123 Main St',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}