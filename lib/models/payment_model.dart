import 'package:flutter/material.dart';

class Payment {
  final String id;
  final String transactionId;
  final String orderId;
  final double amount;
  final String phoneNumber;
  final String paymentMethod;
  final String status; // pending, completed, failed, refunded
  final String? reference;
  final DateTime createdAt;
  final DateTime? completedAt;

  Payment({
    required this.id,
    required this.transactionId,
    required this.orderId,
    required this.amount,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.status,
    this.reference,
    required this.createdAt,
    this.completedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'].toString(),
      transactionId: json['transaction_id'] ?? json['id'].toString(),
      orderId: json['order_id'].toString(),
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] as double?) ?? 0.0,
      phoneNumber: json['phone_number'] ?? '',
      paymentMethod: json['payment_method'] ?? 'mpamba',
      status: json['status'] ?? 'pending',
      reference: json['reference'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'order_id': orderId,
      'amount': amount,
      'phone_number': phoneNumber,
      'payment_method': paymentMethod,
      'status': status,
      'reference': reference,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

enum PaymentMethod {
  mpamba,
  airtel_money,
  cash_on_delivery,
  paychangu, // Add this
}

extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.mpamba:
        return 'mpamba';
      case PaymentMethod.airtel_money:
        return 'airtel_money';
      case PaymentMethod.cash_on_delivery:
        return 'cash_on_delivery';
      case PaymentMethod.paychangu:
        return 'paychangu';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.mpamba:
        return 'Mpamba';
      case PaymentMethod.airtel_money:
        return 'Airtel Money';
      case PaymentMethod.cash_on_delivery:
        return 'Cash on Delivery';
      case PaymentMethod.paychangu:
        return 'PayChangu';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.mpamba:
        return Icons.phone_android;
      case PaymentMethod.airtel_money:
        return Icons.phone_iphone;
      case PaymentMethod.cash_on_delivery:
        return Icons.money;
      case PaymentMethod.paychangu:
        return Icons.payment;
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'mpamba':
        return PaymentMethod.mpamba;
      case 'airtel_money':
        return PaymentMethod.airtel_money;
      case 'cash_on_delivery':
        return PaymentMethod.cash_on_delivery;
      case 'paychangu':
        return PaymentMethod.paychangu;
      default:
        return PaymentMethod.cash_on_delivery;
    }
  }
}
