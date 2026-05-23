import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/api_service.dart';

class PaymentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _error;
  Payment? _currentPayment;
  bool _isProcessing = false;

  // ============================================
  // GROUP 1: GETTERS
  // ============================================
  
  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get error => _error;
  Payment? get currentPayment => _currentPayment;
  
  // Get pending payments
  List<Payment> get pendingPayments => 
      _payments.where((p) => p.status == 'pending').toList();
  
  // Get completed payments
  List<Payment> get completedPayments => 
      _payments.where((p) => p.status == 'completed').toList();
  
  // Get failed payments
  List<Payment> get failedPayments => 
      _payments.where((p) => p.status == 'failed').toList();

  // ============================================
  // GROUP 2: PAYMENT INITIATION
  // ============================================
  
  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String phoneNumber,
    required String orderId,
    required PaymentMethod method,
  }) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    print('💳 Initiating payment:');
    print('   Amount: MK$amount');
    print('   Phone: $phoneNumber');
    print('   Order ID: $orderId');
    print('   Method: ${method.displayName}');

    try {
      // ✅ FIXED: Use 'method' parameter (not 'paymentMethod')
      final result = await _apiService.initiatePayment(
        amount: amount,
        phoneNumber: phoneNumber,
        orderId: orderId,
        method: method,  // Pass the enum directly
      );
      
      print('✅ Payment initiated: $result');
      
      _currentPayment = Payment.fromJson(result);
      _isLoading = false;
      _safeNotify();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotify();
      print('❌ Payment initiation failed: $e');
      rethrow;
    }
  }

  // ============================================
  // GROUP 3: PAYMENT VERIFICATION
  // ============================================
  
  Future<bool> verifyPayment(String transactionId) async {
    _isProcessing = true;
    _safeNotify();

    try {
      final result = await _apiService.verifyPayment(transactionId);
      final isSuccessful = result['status'] == 'completed' || result['status'] == 'success';
      
      // Update local payment status if found
      final index = _payments.indexWhere((p) => p.transactionId == transactionId);
      if (index != -1 && isSuccessful) {
        _payments[index] = Payment(
          id: _payments[index].id,
          transactionId: _payments[index].transactionId,
          orderId: _payments[index].orderId,
          amount: _payments[index].amount,
          phoneNumber: _payments[index].phoneNumber,
          paymentMethod: _payments[index].paymentMethod,
          status: 'completed',
          reference: _payments[index].reference,
          createdAt: _payments[index].createdAt,
          completedAt: DateTime.now(),
        );
      }
      
      _isProcessing = false;
      _safeNotify();
      return isSuccessful;
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      _safeNotify();
      print('❌ Payment verification failed: $e');
      return false;
    }
  }
  
  Future<bool> checkPaymentStatus(String transactionId) async {
    try {
      final result = await _apiService.verifyPayment(transactionId);
      return result['status'] == 'completed' || result['status'] == 'success';
    } catch (e) {
      print('Error checking payment status: $e');
      return false;
    }
  }
  
  Future<Map<String, dynamic>?> getPaymentStatusByReference(String reference) async {
    try {
      return await _apiService.getPaymentStatusByReference(reference);
    } catch (e) {
      print('Error getting payment by reference: $e');
      return null;
    }
  }

  // ============================================
  // GROUP 4: PAYMENT HISTORY
  // ============================================
  
  Future<void> loadMyPayments() async {
    _isLoading = true;
    _safeNotify();

    try {
      final data = await _apiService.getMyPayments();
      _payments = data.map((item) => Payment.fromJson(item)).toList();
      _isLoading = false;
      _safeNotify();
      print('✅ Loaded ${_payments.length} payments');
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotify();
      print('❌ Failed to load payments: $e');
    }
  }
  
  Future<void> refreshPayments() async {
    await loadMyPayments();
  }
  
  Payment? getPaymentForOrder(String orderId) {
    try {
      return _payments.firstWhere((p) => p.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // GROUP 5: PAYMENT CANCELLATION
  // ============================================
  
  Future<bool> cancelPayment(String transactionId) async {
    _isProcessing = true;
    _safeNotify();
    
    try {
      // Call API to cancel payment (if your backend supports it)
      // For now, just update local status
      final index = _payments.indexWhere((p) => p.transactionId == transactionId);
      if (index != -1) {
        _payments[index] = Payment(
          id: _payments[index].id,
          transactionId: _payments[index].transactionId,
          orderId: _payments[index].orderId,
          amount: _payments[index].amount,
          phoneNumber: _payments[index].phoneNumber,
          paymentMethod: _payments[index].paymentMethod,
          status: 'cancelled',
          reference: _payments[index].reference,
          createdAt: _payments[index].createdAt,
          completedAt: DateTime.now(),
        );
      }
      
      _isProcessing = false;
      _safeNotify();
      return true;
    } catch (e) {
      _error = e.toString();
      _isProcessing = false;
      _safeNotify();
      return false;
    }
  }

  // ============================================
  // GROUP 6: UTILITY METHODS
  // ============================================
  
  void clearError() {
    _error = null;
    _safeNotify();
  }
  
  void clearCurrentPayment() {
    _currentPayment = null;
    _safeNotify();
  }
  
  void reset() {
    _payments = [];
    _error = null;
    _currentPayment = null;
    _isLoading = false;
    _isProcessing = false;
    _safeNotify();
  }
  
  void _safeNotify() {
    if (hasListeners) {
      notifyListeners();
    }
  }
  
  // Get payment status text for display
  String getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
  
  Color getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  IconData getPaymentMethodIcon(String method) {
    switch (method.toLowerCase()) {
      case 'mpamba':
        return Icons.phone_android;
      case 'airtel_money':
        return Icons.phone_iphone;
      case 'cash_on_delivery':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }
  
  // Format amount for display
  String formatAmount(double amount) {
    return 'MK${amount.toStringAsFixed(0)}';
  }
  
  // Format date for display
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}