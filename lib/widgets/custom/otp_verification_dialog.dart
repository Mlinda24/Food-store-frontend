import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'otp_input_field.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String destination; // email or phone number
  final Function(String otp) onVerify;
  final VoidCallback onResend;

  const OtpVerificationDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.destination,
    required this.onVerify,
    required this.onResend,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (index) => TextEditingController());
    _focusNodes = List.generate(6, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleVerification() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length == 6) {
      widget.onVerify(otp);
      Navigator.pop(context);
    } else {
      setState(() {
        _error = 'Please enter all 6 digits';
      });
    }
  }

  void _clearError() {
    if (_error.isNotEmpty) {
      setState(() {
        _error = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: isDark ? AppTheme.darkCardBackground : AppTheme.lightCardBackground,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.title == 'Verify Email' ? Icons.email_outlined : Icons.phone_android,
                size: 32,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            
            // Destination
            Text(
              widget.destination,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            const SizedBox(height: 24),
            
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) => OtpInputField(
                index: index,
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                onChanged: (value) => _clearError(),
                onCompleted: _handleVerification,
              )),
            ),
            
            // Error Message
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _error,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.error,
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Resend Button
            TextButton(
              onPressed: () {
                widget.onResend();
                _controllers.forEach((c) => c.clear());
                _focusNodes[0].requestFocus();
                _clearError();
              },
              child: const Text(
                'Resend Code',
                style: TextStyle(color: AppTheme.primaryRed),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Verify'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
