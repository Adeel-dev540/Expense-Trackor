import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../utils/currency_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().getUserProfile();
      context.read<AccountProvider>().startListening();
      context.read<TransactionProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);
    const darkText = Color(0xFF202624);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F7),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: darkText,
          ),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: darkText,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            onPressed: () => _showEditProfileDialog(context),
            icon: const Icon(
              Icons.edit_outlined,
              color: primaryGreen,
            ),
          ),
        ],
      ),
      body: Consumer3<UserProvider, AccountProvider, TransactionProvider>(
        builder: (context, userProvider, accProvider, txProvider, child) {
          final String name = userProvider.displayName;
          final String email = userProvider.email;
          final String phone = userProvider.phone;
          final String initials = userProvider.initials;

          // Calculate summary stats
          double totalBalance = 0;
          for (final acc in accProvider.accounts) {
            final bal = acc.data()['balance'];
            if (bal is num) totalBalance += bal.toDouble();
          }

          final int accountsCount = accProvider.accounts.length;
          final int txCount = txProvider.transactions.length;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              children: [
                // ------------------------------------------------------
                // USER PROFILE HEADER CARD
                // ------------------------------------------------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar Circle
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // User Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // User Email
                      Text(
                        email.isNotEmpty ? email : 'No email attached',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Edit Button
                      InkWell(
                        onTap: () => _showEditProfileDialog(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded,
                                  size: 14, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ------------------------------------------------------
                // FINANCIAL SUMMARY METRICS
                // ------------------------------------------------------
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // Total Balance
                      Expanded(
                        child: _buildStatItem(
                          title: 'Net Worth',
                          value: CurrencyHelper.format(totalBalance),
                          icon: Icons.account_balance_wallet_outlined,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),

                      Container(
                        height: 36,
                        width: 1,
                        color: Colors.grey.shade200,
                      ),

                      // Accounts
                      Expanded(
                        child: _buildStatItem(
                          title: 'Accounts',
                          value: '$accountsCount',
                          icon: Icons.credit_card_rounded,
                          color: const Color(0xFF1E88E5),
                        ),
                      ),

                      Container(
                        height: 36,
                        width: 1,
                        color: Colors.grey.shade200,
                      ),

                      // Transactions
                      Expanded(
                        child: _buildStatItem(
                          title: 'Transactions',
                          value: '$txCount',
                          icon: Icons.receipt_long_outlined,
                          color: const Color(0xFFE65100),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------------
                // PERSONAL INFO SECTION
                // ------------------------------------------------------
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        value: name,
                        onTap: () => _showEditProfileDialog(context),
                      ),
                      Divider(height: 1, color: Colors.grey.shade100),
                      _buildInfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email Address',
                        value: email.isNotEmpty ? email : 'Not provided',
                        isEditable: false,
                      ),
                      Divider(height: 1, color: Colors.grey.shade100),
                      _buildInfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number',
                        value: phone.isNotEmpty ? phone : 'Not set',
                        onTap: () => _showEditProfileDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ------------------------------------------------------
                // QUICK SHORTCUTS
                // ------------------------------------------------------
                _buildSectionHeader('Quick Shortcuts'),
                const SizedBox(height: 10),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildNavTile(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: const Color(0xFF2E7D32),
                        title: 'My Accounts',
                        subtitle: '$accountsCount accounts active',
                        onTap: () =>
                            Navigator.pushNamed(context, '/AccountsScreen'),
                      ),
                      Divider(height: 1, color: Colors.grey.shade100),
                      _buildNavTile(
                        icon: Icons.swap_horiz_rounded,
                        iconColor: const Color(0xFF1E88E5),
                        title: 'All Transactions',
                        subtitle: '$txCount total records',
                        onTap: () =>
                            Navigator.pushNamed(context, '/TransactionsScreen'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ------------------------------------------------------
                // LOGOUT BUTTON
                // ------------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.red.shade100),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF202624),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202624),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    bool isEditable = true,
  }) {
    return ListTile(
      onTap: isEditable ? onTap : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF202624),
        ),
      ),
      trailing: isEditable
          ? Icon(Icons.chevron_right_rounded,
              color: Colors.grey.shade400, size: 20)
          : null,
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF202624),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.grey.shade400,
        size: 16,
      ),
    );
  }

  // ------------------------------------------------------------------------
  // EDIT PROFILE MODAL DIALOG
  // ------------------------------------------------------------------------
  void _showEditProfileDialog(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final nameController =
        TextEditingController(text: userProvider.displayName);
    final phoneController = TextEditingController(text: userProvider.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Color(0xFF2E7D32)),
            SizedBox(width: 10),
            Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  hintText: '+92 300 1234567',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final newName = nameController.text.trim();
              final newPhone = phoneController.text.trim();

              Navigator.pop(ctx);

              final success = await userProvider.updateUserProfile(
                name: newName,
                phone: newPhone,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Profile updated successfully'
                          : (userProvider.errorMessage ??
                              'Failed to update profile'),
                    ),
                    backgroundColor: success
                        ? const Color(0xFF2E7D32)
                        : Colors.red.shade800,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // LOGOUT CONFIRMATION DIALOG
  // ------------------------------------------------------------------------
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Log Out',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/LoginScreen',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
