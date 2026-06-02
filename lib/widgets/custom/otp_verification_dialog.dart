import 'package:flutter/material.dart';
import '../../config/theme.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String destination;
  final Function(String) onVerify;
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
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${widget.subtitle}\n${widget.destination}'),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: TextStyle(
                color: isDark
                    ? AppTheme.darkPrimaryText
                    : AppTheme.lightPrimaryText),
            decoration: const InputDecoration(
              labelText: 'Enter 6-digit code',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: widget.onResend, child: const Text('Resend Code')),
        ElevatedButton(
          onPressed: () => widget.onVerify(_otpController.text),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
          child: const Text('Verify'),
        ),
      ],
    );
  }
}
