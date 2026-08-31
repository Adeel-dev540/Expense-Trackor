import 'package:flutter/material.dart';

import '../widgets/custom_buttons.dart';
import '../widgets/custom_text_field.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _balanceController =
  TextEditingController();

  String _selectedType = 'Bank';

  final List<String> _accountTypes = [
    'Bank',
    'Cash',
    'Wallet',
    'Savings',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _addAccount() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String name = _nameController.text.trim();

    final double? balance =
    double.tryParse(_balanceController.text.trim());

    if (balance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid balance'),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // TODO:
    // Connect this data with AccountProvider.
    //
    // Example data:
    //
    // name
    // _selectedType
    // balance
    //
    // We will use your actual AccountProvider method here.
    // ----------------------------------------------------------

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account data is ready to save'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F7),
        elevation: 0,
        title: const Text(
          'Add Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Color(0xFF2E7D32),
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create an account',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add a place where you keep your money.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Account Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Account Name
                CustomTextField(
                  controller: _nameController,
                  label: 'Account Name',
                  hint: 'Enter account name',
                  prefixIcon: Icons.account_balance_wallet_outlined,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter account name';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Account Type
                const Text(
                  'Account Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      items: _accountTypes.map(
                            (String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Initial Balance
                CustomTextField(
                  controller: _balanceController,
                  label: 'Initial Balance',
                  hint: '0.00',
                  prefixIcon: Icons.payments_outlined,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter initial balance';
                    }

                    final balance =
                    double.tryParse(value.trim());

                    if (balance == null) {
                      return 'Enter a valid amount';
                    }

                    if (balance < 0) {
                      return 'Balance cannot be negative';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 32),

                CustomButtons(
                  text: 'Add Account',
                  icon: Icons.add,
                  onPressed: _addAccount,
                ),

                const SizedBox(height: 12),

                CustomButtons(
                  text: 'Cancel',
                  outlined: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
