import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlatformWebView extends StatefulWidget {
  final String url;
  final String title;
  final VoidCallback? onPaymentSuccess;
  final VoidCallback? onPaymentCancel;

  const PlatformWebView({
    super.key,
    required this.url,
    required this.title,
    this.onPaymentSuccess,
    this.onPaymentCancel,
  });

  @override
  State<PlatformWebView> createState() => _PlatformWebViewState();
}

class _PlatformWebViewState extends State<PlatformWebView> {
  // Only initialize controller on non-web platforms
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) => setState(() => _isLoading = true),
            onPageFinished: (_) => setState(() => _isLoading = false),
            onNavigationRequest: (request) {
              // Handle success/cancel callbacks based on URL
              if (request.url.contains('success')) {
                widget.onPaymentSuccess?.call();
              } else if (request.url.contains('cancel')) {
                widget.onPaymentCancel?.call();
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    // On web: open in browser tab instead
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'You will be redirected to complete payment.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open Payment Page'),
                onPressed: () async {
                  final uri = Uri.parse(widget.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onPaymentCancel,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );
    }

    // On mobile: use WebView normally
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller!),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
