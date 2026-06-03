import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  // Only used on mobile — NOT initialized on web (avoids LateInitializationError)
  WebViewController? _controller;
  bool _isLoading = true;
  bool _isReturning = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Only set up WebView on Android/iOS
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initWebView();
      });
    }
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
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

  /// Web fallback: opens the payment URL in a new browser tab
  Future<void> _launchInBrowser() async {
    final uri = Uri.parse(widget.checkoutUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open payment page.')),
        );
      }
    }
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
      body: kIsWeb ? _buildWebFallback() : _buildMobileWebView(),
    );
  }

  /// Mobile: show the full inline WebView
  Widget _buildMobileWebView() {
    return Stack(
      children: [
        if (_controller != null) WebViewWidget(controller: _controller!),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  /// Web: prompt user to open payment in a browser tab
  Widget _buildWebFallback() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.payment, size: 72, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'You will be redirected to Paychangu to complete your payment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: MWK ${widget.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open Payment Page'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _launchInBrowser,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _returnToApp(success: true),
                child: const Text('I have completed payment'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _returnToApp(success: false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
