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

  List<Payment> get pendingPayments =>
      _payments.where((p) => p.status == 'pending').toList();

  List<Payment> get completedPayments =>
      _payments.where((p) => p.status == 'completed').toList();

  List<Payment> get failedPayments =>
      _payments.where((p) => p.status == 'failed').toList();

  // ============================================
  // GROUP 2: PAYMENT INITIATION
  // ============================================

  /// Calls POST /api/payments/initiate/
  /// Returns the full response map including checkout_url and reference.
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
      final result = await _apiService.initiatePayment(
        amount: amount,
        phoneNumber: phoneNumber,
        orderId: orderId,
        method: method,
      );

      print('✅ Payment initiated: $result');

      // Store current payment if the response has enough data
      try {
        _currentPayment = Payment.fromJson(result);
      } catch (_) {
        // fromJson may fail if checkout_url fields differ — non-fatal
      }

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

  /// Simplified payment initiation - PayChangu handles everything
  /// User selects payment method and enters phone number on PayChangu checkout page
  Future<Map<String, dynamic>> initiateSimplePayment({
    required double amount,
    required String orderId,
  }) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    print('💳 Initiating simple payment (PayChangu handles everything):');
    print('   Amount: MK$amount');
    print('   Order ID: $orderId');

    try {
      final result = await _apiService.initiateSimplePayment(
        amount: amount,
        orderId: orderId,
      );

      print('✅ Simple payment initiated: $result');

      // Store current payment if the response has enough data
      try {
        _currentPayment = Payment.fromJson(result);
      } catch (_) {
        // fromJson may fail if checkout_url fields differ — non-fatal
      }

      _isLoading = false;
      _safeNotify();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotify();
      print('❌ Simple payment initiation failed: $e');
      rethrow;
    }
  }

  /// Alternative method using paychangu method
  Future<Map<String, dynamic>> initiatePayChanguPayment({
    required double amount,
    required String orderId,
  }) async {
    _isLoading = true;
    _error = null;
    _safeNotify();

    print('💳 Initiating PayChangu payment via dedicated method:');
    print('   Amount: MK$amount');
    print('   Order ID: $orderId');

    try {
      final result = await _apiService.initiatePayChanguPayment(
        amount: amount,
        orderId: orderId,
      );

      print('✅ PayChangu payment initiated: $result');

      try {
        _currentPayment = Payment.fromJson(result);
      } catch (_) {}

      _isLoading = false;
      _safeNotify();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      _safeNotify();
      print('❌ PayChangu payment initiation failed: $e');
      rethrow;
    }
  }

  // ============================================
  // GROUP 3: PAYMENT VERIFICATION
  // ============================================

  /// Verifies by transaction ID. Returns true if completed.
  Future<bool> verifyPayment(String transactionId) async {
    _isProcessing = true;
    _safeNotify();

    try {
      final result = await _apiService.verifyPayment(transactionId);
      final isSuccessful =
          result['status'] == 'completed' || result['status'] == 'success';

      if (isSuccessful) {
        final index =
            _payments.indexWhere((p) => p.transactionId == transactionId);
        if (index != -1) {
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

  /// Polls GET /api/payments/status_by_reference/?reference=xxx
  /// Returns the full status map or null on error.
  Future<Map<String, dynamic>?> getPaymentStatusByReference(
      String reference) async {
    try {
      return await _apiService.getPaymentStatusByReference(reference);
    } catch (e) {
      print('❌ Error getting payment by reference: $e');
      return null;
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
      final index =
          _payments.indexWhere((p) => p.transactionId == transactionId);
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

  String getPaymentStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
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
      case 'processing':
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
      case 'paychangu':
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  String formatAmount(double amount) {
    return 'MK${amount.toStringAsFixed(0)}';
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
