import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/restaurant_provider.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String selectedProvider = 'mpamba';
  bool loading = false;

  @override
  void dispose() {
    amountController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _updateMaxAmount() {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    final balance = restaurantProvider.stats?.walletBalance ?? 0;

    final currentAmount = amountController.text.trim();
    if (currentAmount.isNotEmpty) {
      final amountValue = double.tryParse(currentAmount);
      if (amountValue != null && amountValue > balance) {
        amountController.text = balance.toStringAsFixed(0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Maximum withdrawal amount is MK${balance.toStringAsFixed(0)}'),
            backgroundColor: AppTheme.warning,
          ),
        );
      }
    }
  }

  Future<void> submitWithdraw() async {
    final amount = amountController.text.trim();
    final phone = phoneController.text.trim();
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    final balance = restaurantProvider.stats?.walletBalance ?? 0;

    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an amount")),
      );
      return;
    }

    final amountValue = double.tryParse(amount);
    if (amountValue == null || amountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    if (amountValue > balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Amount exceeds available balance of MK${balance.toStringAsFixed(0)}"),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (amountValue < 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Minimum withdrawal amount is MK1,000")),
      );
      return;
    }

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your phone number")),
      );
      return;
    }

    if (phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid phone number")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await restaurantProvider.requestWithdraw(
        amount: amountValue,
        phone: phone,
        provider: selectedProvider,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Withdrawal request submitted successfully"),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }

    setState(() => loading = false);
  }

  void _setMaxWithdrawal() {
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);
    final balance = restaurantProvider.stats?.walletBalance ?? 0;

    if (balance >= 1000) {
      amountController.text = balance.toStringAsFixed(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Maximum amount set to MK${balance.toStringAsFixed(0)}"),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Insufficient balance for withdrawal. Minimum required is MK1,000"),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final balance = restaurantProvider.stats?.walletBalance ?? 0;
    final canWithdraw = balance >= 1000;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text("Withdraw Funds"),
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryButtonGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'MK${balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: canWithdraw
                          ? Colors.green.withOpacity(0.3)
                          : Colors.red.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      canWithdraw
                          ? '✓ Ready to Withdraw'
                          : '✗ Minimum MK1,000 required',
                      style: TextStyle(
                        fontSize: 12,
                        color: canWithdraw ? Colors.white : Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Withdrawal Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGlowGradient(context),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Withdrawal Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount Field with Max Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.getPrimaryTextColor(context),
                        ),
                        onChanged: (value) {
                          final amountValue = double.tryParse(value);
                          if (amountValue != null && amountValue > balance) {
                            amountController.text = balance.toStringAsFixed(0);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Amount cannot exceed available balance of MK${balance.toStringAsFixed(0)}'),
                                backgroundColor: AppTheme.warning,
                              ),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Amount (MWK)',
                          labelStyle: TextStyle(
                              color: AppTheme.getSecondaryTextColor(context)),
                          hintText: 'Enter amount to withdraw',
                          hintStyle: TextStyle(
                              color: AppTheme.getMutedTextColor(context)),
                          prefixText: 'MK ',
                          prefixStyle: TextStyle(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                          suffixIcon: balance >= 1000
                              ? TextButton(
                                  onPressed: _setMaxWithdrawal,
                                  child: Text(
                                    'MAX',
                                    style: TextStyle(
                                      color: AppTheme.primaryRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor: AppTheme.getSurfaceColor(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppTheme.primaryRed, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Minimum: MK1,000',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getMutedTextColor(context),
                            ),
                          ),
                          Text(
                            'Maximum: MK${balance.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getMutedTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.getPrimaryTextColor(context),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(
                          color: AppTheme.getSecondaryTextColor(context)),
                      hintText: 'e.g., 0999123456',
                      hintStyle:
                          TextStyle(color: AppTheme.getMutedTextColor(context)),
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        width: 24,
                        height: 24,
                        child: Image.asset(
                          selectedProvider == 'mpamba'
                              ? 'assets/images/tnm.jpeg'
                              : 'assets/images/airtel.jpeg',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              selectedProvider == 'mpamba'
                                  ? Icons.phone_android
                                  : Icons.phone_iphone,
                              color: AppTheme.primaryRed,
                              size: 20,
                            );
                          },
                        ),
                      ),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryRed, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Selection with Images
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMethodOptionWithImage(
                          context,
                          'Mpamba',
                          'assets/images/tnm.jpeg',
                          selectedProvider == 'mpamba',
                          () => setState(() => selectedProvider = 'mpamba'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMethodOptionWithImage(
                          context,
                          'Airtel Money',
                          'assets/images/airtel.jpeg',
                          selectedProvider == 'airtel',
                          () => setState(() => selectedProvider = 'airtel'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppTheme.warning.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 20, color: AppTheme.warning),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Important Information',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.warning,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Minimum withdrawal amount is MK1,000\n'
                          '• Maximum withdrawal is your available balance\n'
                          '• Funds will be sent to your mobile money wallet',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Withdraw Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          loading || !canWithdraw ? null : submitWithdraw,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canWithdraw ? AppTheme.primaryRed : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              canWithdraw
                                  ? 'Request Withdrawal'
                                  : 'Insufficient Balance',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOptionWithImage(
    BuildContext context,
    String label,
    String imagePath,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryRed.withOpacity(0.1)
              : AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryRed
                : AppTheme.getMutedTextColor(context).withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.primaryRed : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      label == 'Mpamba'
                          ? Icons.phone_android
                          : Icons.phone_iphone,
                      size: 20,
                      color: isSelected
                          ? AppTheme.primaryRed
                          : AppTheme.getSecondaryTextColor(context),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppTheme.primaryRed
                    : AppTheme.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
