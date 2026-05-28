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

  Future<void> submitWithdraw() async {
    final amount = amountController.text.trim();
    final phone = phoneController.text.trim();

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
      final provider = Provider.of<RestaurantProvider>(context, listen: false);

      await provider.requestWithdraw(
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

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);
    final balance = restaurantProvider.stats?.walletBalance ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text("Withdraw Funds"),
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // reduced from 16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // reduced from 20
              decoration: BoxDecoration(
                gradient: AppTheme.primaryButtonGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12, // reduced from 14
                    ),
                  ),
                  const SizedBox(height: 4), // reduced from 8
                  Text(
                    'MK${balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26, // reduced from 32
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14), // reduced from 24

            // Withdrawal Form
            Container(
              padding: const EdgeInsets.all(14), // reduced from 16
              decoration: BoxDecoration(
                gradient: AppTheme.cardGlowGradient(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.deepCrimson.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Withdrawal Details',
                    style: TextStyle(
                      fontSize: 15, // reduced from 18
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12), // reduced from 16

                  // Amount Field
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 13, // reduced from 14
                      color: AppTheme.getPrimaryTextColor(context),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount (MWK)',
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getSecondaryTextColor(context)),
                      hintText: 'Enter amount to withdraw',
                      hintStyle: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getMutedTextColor(context)),
                      prefixText: 'MK ',
                      prefixStyle: TextStyle(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryRed, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11, // reduced from 14
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // reduced from 16

                  // Phone Number Field
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.getPrimaryTextColor(context),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getSecondaryTextColor(context)),
                      hintText: 'e.g., 0999123456',
                      hintStyle: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getMutedTextColor(context)),
                      prefixIcon: Icon(
                        selectedProvider == 'mpamba'
                            ? Icons.phone_android
                            : Icons.phone_iphone,
                        size: 18, // added explicit size
                        color: AppTheme.primaryRed,
                      ),
                      filled: true,
                      fillColor: AppTheme.getSurfaceColor(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppTheme.primaryRed, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // reduced from 16

                  // Payment Method Selection
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 12, // reduced from 14
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMethodOption(
                          context,
                          'Mpamba',
                          Icons.phone_android,
                          selectedProvider == 'mpamba',
                          () => setState(() => selectedProvider = 'mpamba'),
                        ),
                      ),
                      const SizedBox(width: 10), // reduced from 12
                      Expanded(
                        child: _buildMethodOption(
                          context,
                          'Airtel Money',
                          Icons.phone_iphone,
                          selectedProvider == 'airtel',
                          () => setState(() => selectedProvider = 'airtel'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14), // reduced from 24

                  // Info Note
                  Container(
                    padding: const EdgeInsets.all(10), // reduced from 12
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppTheme.warning), // reduced from 20
                        const SizedBox(width: 8), // reduced from 12
                        Expanded(
                          child: Text(
                            'Min. withdrawal: MK1,000\nFunds sent within 24 hours.',
                            style: TextStyle(
                              fontSize: 11, // reduced from 12
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14), // reduced from 24

                  // Withdraw Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : submitWithdraw,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 12), // reduced from 14
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 18, // reduced from 20
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Request Withdrawal',
                              style: TextStyle(
                                fontSize: 14, // reduced from 16
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

  Widget _buildMethodOption(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9), // reduced from 12
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryRed.withOpacity(0.1)
              : AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(10),
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
            Icon(
              icon,
              size: 16, // reduced from 20
              color: isSelected
                  ? AppTheme.primaryRed
                  : AppTheme.getSecondaryTextColor(context),
            ),
            const SizedBox(width: 6), // reduced from 8
            Text(
              label,
              style: TextStyle(
                fontSize: 12, // reduced from 14
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
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