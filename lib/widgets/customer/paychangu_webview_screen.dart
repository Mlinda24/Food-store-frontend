import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaychanguWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String reference;
  final double amount;
  final String? orderId;

  const PaychanguWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.reference,
    required this.amount,
    this.orderId,
  });

  @override
  State<PaychanguWebViewScreen> createState() => _PaychanguWebViewScreenState();
}

class _PaychanguWebViewScreenState extends State<PaychanguWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isReturning = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _checkPaymentStatus(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('/api/payments/webhook/') ||
                request.url.contains('success') ||
                request.url.contains('complete')) {
              _returnToApp(success: true);
              return NavigationDecision.prevent;
            }
            if (request.url.contains('cancel') ||
                request.url.contains('failed')) {
              _returnToApp(success: false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _checkPaymentStatus(String url) {
    if (_isReturning) return;
    if (url.contains('success') ||
        url.contains('complete') ||
        url.contains('/api/payments/webhook/')) {
      _returnToApp(success: true);
    }
  }

  void _returnToApp({required bool success}) {
    if (_isReturning) return;
    _isReturning = true;
    Navigator.of(context).pop({
      'status': success ? 'submitted' : 'cancelled',
      'reference': widget.reference,
      'amount': widget.amount,
      'order_id': widget.orderId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _returnToApp(success: false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
