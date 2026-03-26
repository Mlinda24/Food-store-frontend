import 'package:flutter/material.dart';
import '../../models/models.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;
  
  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final List<OrderStatus> _statusFlow = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.pickedUp,
    OrderStatus.onTheWay,
    OrderStatus.delivered,
  ];

  int _getCurrentStep() {
    return _statusFlow.indexOf(widget.order.status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Text(
                  'Order #${widget.order.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${widget.order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stepper(
              currentStep: _getCurrentStep(),
              controlsBuilder: (context, details) {
                return const SizedBox.shrink();
              },
              steps: _statusFlow.map((status) {
                return Step(
                  title: Text(_getStatusText(status)),
                  content: const SizedBox.shrink(),
                  isActive: _statusFlow.indexOf(status) <= _getCurrentStep(),
                  state: _statusFlow.indexOf(status) < _getCurrentStep()
                      ? StepState.complete
                      : _statusFlow.indexOf(status) == _getCurrentStep()
                          ? StepState.editing
                          : StepState.indexed,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Order Placed';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.onTheWay:
        return 'On The Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}