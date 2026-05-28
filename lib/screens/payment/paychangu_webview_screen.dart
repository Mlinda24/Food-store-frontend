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
  String? _error;
  int _loadAttempts = 0;
  Timer? _timeoutTimer;

  // Detect payment completion patterns
  final List<String> _successPatterns = [
    'success',
    'complete',
    'confirmed',
    'paid',
    'thank-you',
  ];

  final List<String> _cancelPatterns = [
    'cancel',
    'cancelled',
    'error',
    'failed',
    'declined',
  ];

  @override
  void initState() {
    super.initState();
    _initWebView();
    _startTimeoutTimer();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startTimeoutTimer() {
    _timeoutTimer = Timer(const Duration(minutes: 5), () {
      if (mounted && !_isReturning) {
        print('⏰ Payment timeout after 5 minutes');
        _returnToApp(success: false, cancelled: true, reason: 'timeout');
      }
    });
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
            print('🌐 WebView page started: $url');
            _checkUrlAndHandle(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            print('🌐 WebView page finished: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView error: ${error.description}');
            // Don't show error for webhook redirects - handle silently
            if (!error.description.contains('CLEARTEXT')) {
              setState(() {
                _error = error.description;
                _isLoading = false;
              });
            } else {
              // For cleartext errors, this is likely our webhook - consider it success
              print('⚠️ Cleartext error (webhook) - treating as success');
              _returnToApp(success: true, cancelled: false);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🔗 Navigation request: ${request.url}');

            // CRITICAL: Check if this is our webhook URL
            if (request.url.contains('/api/payments/webhook/') ||
                request.url.contains('webhook') ||
                request.url.contains(widget.reference)) {
              print('✅ Intercepted webhook call - payment successful!');
              _returnToApp(success: true, cancelled: false);
              return NavigationDecision.prevent;
            }

            // Check for success patterns
            for (final pattern in _successPatterns) {
              if (request.url.toLowerCase().contains(pattern)) {
                if (request.url.contains(widget.reference.toLowerCase())) {
                  print('✅ Success pattern detected: $pattern');
                  _returnToApp(success: true, cancelled: false);
                  return NavigationDecision.prevent;
                }
              }
            }

            // Check for cancel patterns
            for (final pattern in _cancelPatterns) {
              if (request.url.toLowerCase().contains(pattern)) {
                print('❌ Cancel pattern detected: $pattern');
                _returnToApp(success: false, cancelled: true);
                return NavigationDecision.prevent;
              }
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _checkUrlAndHandle(String url) {
    if (_isReturning) return;

    // Check if this is our webhook URL
    if (url.contains('/api/payments/webhook/')) {
      print('✅ Webhook URL detected - payment completed!');
      _returnToApp(success: true, cancelled: false);
      return;
    }

    // Check for success patterns
    for (final pattern in _successPatterns) {
      if (url.toLowerCase().contains(pattern)) {
        print('✅ Success detected: $pattern');
        _returnToApp(success: true, cancelled: false);
        return;
      }
    }

    // Check for cancel patterns
    for (final pattern in _cancelPatterns) {
      if (url.toLowerCase().contains(pattern)) {
        print('❌ Cancel detected: $pattern');
        _returnToApp(success: false, cancelled: true);
        return;
      }
    }
  }

  void _returnToApp({
    required bool success,
    required bool cancelled,
    String? reason,
  }) {
    if (_isReturning) return;
    _isReturning = true;
    _timeoutTimer?.cancel();

    final status = cancelled
        ? 'cancelled'
        : success
            ? 'submitted'
            : 'failed';

    print('✅ Returning to app: status=$status, reference=${widget.reference}');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pop({
          'status': status,
          'reference': widget.reference,
          'amount': widget.amount,
          'order_id': widget.orderId,
          'reason': reason,
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

  void _reloadWebView() {
    setState(() {
      _error = null;
      _isLoading = true;
      _loadAttempts++;
    });
    _controller.reload();
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'MK${widget.amount.toStringAsFixed(2)} via PayChangu',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
              children: [
                Icon(Icons.lock, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  'Secure',
                  style: TextStyle(
                    fontSize: 12,
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFE31837)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading secure payment page...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ref: ${widget.reference}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_error != null && _error!.contains('CLEARTEXT') == false)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          child: ElevatedButton(
                            onPressed: _reloadWebView,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE31837),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: OutlinedButton(
                            onPressed: _onCancel,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
