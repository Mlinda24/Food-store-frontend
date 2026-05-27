import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaychanguWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String reference;
  final double amount;

  const PaychanguWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.reference,
    required this.amount,
  });

  @override
  State<PaychanguWebViewScreen> createState() => _PaychanguWebViewScreenState();
}

class _PaychanguWebViewScreenState extends State<PaychanguWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isReturning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
            print('🌐 WebView page started: $url');
            _checkForPaymentCompletion(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            print('🌐 WebView page finished: $url');
            _checkForPaymentCompletion(url);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _error = error.description;
              _isLoading = false;
            });
            print('❌ WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔗 Navigation request: ${request.url}');

            // Check if this is a return/callback URL
            if (_shouldCloseWebView(request.url)) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  bool _shouldCloseWebView(String url) {
    final lowerUrl = url.toLowerCase();

    // Check for success indicators
    if (lowerUrl.contains('success') ||
        lowerUrl.contains('complete') ||
        (lowerUrl.contains('/payment/status/') &&
            !lowerUrl.contains('cancelled')) ||
        lowerUrl.contains('reference=${widget.reference}') &&
            !lowerUrl.contains('cancelled')) {
      _returnToApp(success: true, cancelled: false);
      return true;
    }

    // Check for cancel indicators
    if (lowerUrl.contains('cancel') ||
        lowerUrl.contains('cancelled') ||
        lowerUrl.contains('error') ||
        lowerUrl.contains('failed')) {
      _returnToApp(success: false, cancelled: true);
      return true;
    }

    return false;
  }

  void _checkForPaymentCompletion(String url) {
    if (_isReturning) return;
    _shouldCloseWebView(url);
  }

  void _returnToApp({required bool success, required bool cancelled}) {
    if (_isReturning) return;
    _isReturning = true;

    print('✅ Returning to app: success=$success, cancelled=$cancelled');

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).pop({
          'status':
              cancelled ? 'cancelled' : (success ? 'submitted' : 'failed'),
          'reference': widget.reference,
          'amount': widget.amount,
        });
      }
    });
  }

  void _onCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to cancel? Your order will not be confirmed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue Paying'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _returnToApp(success: false, cancelled: true);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: _onCancel,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secure Payment',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'MK${widget.amount.toStringAsFixed(0)} via PayChangu',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 12, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  'Secure',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading payment page...',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ref: ${widget.reference}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isLoading = true;
                      });
                      _controller.reload();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
