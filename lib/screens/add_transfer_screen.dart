import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/currency_helper.dart';

class AddTransferScreen extends StatefulWidget {
  const AddTransferScreen({super.key});

  @override
  State<AddTransferScreen> createState() => _AddTransferScreenState();
}

class _AddTransferScreenState extends State<AddTransferScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedFromAccount;
  String? _selectedToAccount;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E88E5),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1B1B1B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _saveTransfer() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFromAccount == null) {
      _showError('Please select a source account');
      return;
    }

    if (_selectedToAccount == null) {
      _showError('Please select a destination account');
      return;
    }

    if (_selectedFromAccount == _selectedToAccount) {
      _showError('Source and destination accounts must be different');
      return;
    }

    final accountProvider = context.read<AccountProvider>();
    final fromDoc = accountProvider.accounts
        .where((doc) => doc.id == _selectedFromAccount)
        .firstOrNull;
    final double fromBalance = fromDoc != null
        ? ((fromDoc.data()['balance'] as num?)?.toDouble() ?? 0.0)
        : 0.0;

    final double transferAmount =
        double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (fromBalance <= 0) {
      _showError(
        'Source account has zero balance. Cannot transfer money.',
      );
      return;
    }

    if (transferAmount > fromBalance) {
      _showError(
        'Insufficient balance in source account! Available: ${CurrencyHelper.format(fromBalance)}',
      );
      return;
    }

    final transactionProvider = context.read<TransactionProvider>();
    final success = await transactionProvider.addTransfer(
      fromAccountId: _selectedFromAccount!,
      toAccountId: _selectedToAccount!,
      amount: transferAmount,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
    );

    if (!mounted) return;

    if (success) {
      _showSuccess();
    } else {
      _showError(
        transactionProvider.errorMessage ?? 'Failed to complete transfer',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Transfer completed successfully',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E88E5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1E88E5);
    const lightBlue = Color(0xFFE3F2FD);
    const darkText = Color(0xFF202624);
    const mutedText = Color(0xFF7A8580);

    final accountProvider = Provider.of<AccountProvider>(context);
    final accounts = accountProvider.accounts;
    final List<MapEntry<String, String>> accountItems = accounts.map((doc) {
      final data = doc.data();
      final name = data['name']?.toString() ?? 'Unnamed Account';
      final double balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      return MapEntry(doc.id, '$name (${CurrencyHelper.format(balance)})');
    }).toList();

    final selectedFromDoc = _selectedFromAccount != null
        ? accounts.where((doc) => doc.id == _selectedFromAccount).firstOrNull
        : null;
    final double selectedFromBalance = selectedFromDoc != null
        ? ((selectedFromDoc.data()['balance'] as num?)?.toDouble() ?? 0.0)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        title: const Text(
          'Transfer',
          style: TextStyle(
            color: darkText,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------------------------------------------------
                // TRANSFER HEADER
                // ---------------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(.18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          const SizedBox(width: 13),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Internal Transfer',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Transfer Between Accounts',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Transfer Amount',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Rs.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.w800,
                              ),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 35,
                                  fontWeight: FontWeight.w800,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter amount';
                                }

                                final amount = double.tryParse(value);

                                if (amount == null || amount <= 0) {
                                  return 'Enter a valid amount';
                                }

                                if (_selectedFromAccount != null &&
                                    amount > selectedFromBalance) {
                                  return 'Exceeds source balance (${CurrencyHelper.format(selectedFromBalance)})';
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ---------------------------------------------------------
                // BASIC INFORMATION
                // ---------------------------------------------------------
                const Text(
                  'Transfer Details',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 14),

                // FROM ACCOUNT
                _sectionLabel(
                  icon: Icons.upload_rounded,
                  title: 'From Account (Source)',
                  color: primaryBlue,
                ),

                const SizedBox(height: 8),

                _dropdownCard(
                  value: _selectedFromAccount,
                  hint: 'Select source account',
                  icon: Icons.account_balance_wallet_rounded,
                  items: accountItems,
                  onChanged: (value) {
                    setState(() {
                      _selectedFromAccount = value;
                    });
                  },
                ),

                if (_selectedFromAccount != null) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Balance:',
                          style: TextStyle(
                            color: mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          CurrencyHelper.format(selectedFromBalance),
                          style: TextStyle(
                            color: selectedFromBalance > 0
                                ? const Color(0xFF2E7D32)
                                : Colors.red.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // TO ACCOUNT
                _sectionLabel(
                  icon: Icons.download_rounded,
                  title: 'To Account (Destination)',
                  color: primaryBlue,
                ),

                const SizedBox(height: 8),

                _dropdownCard(
                  value: _selectedToAccount,
                  hint: 'Select destination account',
                  icon: Icons.account_balance_wallet_rounded,
                  items: accountItems,
                  onChanged: (value) {
                    setState(() {
                      _selectedToAccount = value;
                    });
                  },
                ),

                const SizedBox(height: 22),

                // DATE
                _sectionLabel(
                  icon: Icons.calendar_today_outlined,
                  title: 'Date',
                  color: primaryBlue,
                ),

                const SizedBox(height: 8),

                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE1E7E4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: lightBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: primaryBlue,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Transaction Date',
                                style: TextStyle(
                                  color: mutedText,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _formatDate(_selectedDate),
                                style: const TextStyle(
                                  color: darkText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 15,
                          color: mutedText,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // DESCRIPTION
                _sectionLabel(
                  icon: Icons.notes_rounded,
                  title: 'Description',
                  color: primaryBlue,
                ),

                const SizedBox(height: 8),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE1E7E4)),
                  ),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(color: darkText, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Add a note about this transfer...',
                      hintStyle: TextStyle(
                        color: Color(0xFFA1AAA6),
                        fontSize: 14,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 15, right: 8, top: 13),
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: primaryBlue,
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 45,
                        minHeight: 45,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ---------------------------------------------------------
                // SUMMARY
                // ---------------------------------------------------------
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: lightBlue,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFBBDEFB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.swap_horiz_rounded,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transfer transaction',
                              style: TextStyle(
                                color: darkText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'This amount will move from the source account to the destination account.',
                              style: TextStyle(
                                color: mutedText,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ---------------------------------------------------------
                // SAVE BUTTON
                // ---------------------------------------------------------
                Consumer<TransactionProvider>(
                  builder: (context, provider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _saveTransfer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swap_horizontal_circle_outlined,
                                    size: 22,
                                  ),
                                  SizedBox(width: 9),
                                  Text(
                                    'Save Transfer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF202624),
          ),
        ),
      ],
    );
  }

  Widget _dropdownCard({
    required String? value,
    required String hint,
    required IconData icon,
    required List<MapEntry<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E7E4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Row(
            children: [
              Icon(icon, color: const Color(0xFF7A8580), size: 20),
              const SizedBox(width: 11),
              Text(
                hint,
                style: const TextStyle(color: Color(0xFF8C9692), fontSize: 14),
              ),
            ],
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF7A8580),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item.key,
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF1E88E5), size: 20),
                  const SizedBox(width: 11),
                  Text(
                    item.value,
                    style: const TextStyle(
                      color: Color(0xFF202624),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
