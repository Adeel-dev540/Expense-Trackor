import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../utils/currency_helper.dart';
import '../widgets/balance_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/transaction_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Start listening to accounts, transactions, and user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().getUserProfile();
      context.read<AccountProvider>().startListening();
      context.read<TransactionProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9F7),
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/ProfileScreen');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        userProvider.initials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: Consumer3<AccountProvider, TransactionProvider, UserProvider>(
          builder: (context, accountProvider, transactionProvider, userProvider, child) {
            // Calculate total balance
            double totalBalance = 0;

            for (final account in accountProvider.accounts) {
              final data = account.data();
              final balance = data['balance'];

              if (balance is num) {
                totalBalance += balance.toDouble();
              }
            }

            // Calculate total credit and debit
            double totalCredit = 0;
            double totalDebit = 0;

            for (final txDoc in transactionProvider.transactions) {
              final txData = txDoc.data();
              final type = txData['type'];
              final amount = (txData['amount'] as num?)?.toDouble() ?? 0.0;
              if (type == 'credit') {
                totalCredit += amount;
              } else if (type == 'debit') {
                totalDebit += amount;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------------------------------------------------------
                  // Welcome
                  // ------------------------------------------------------

                  Text(
                    'Welcome back, ${userProvider.displayName}!',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Manage your money',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ------------------------------------------------------
                  // Total Balance
                  // ------------------------------------------------------

                  BalanceCard(
                    title: 'Total Balance',
                    amount: totalBalance,
                    icon: Icons.account_balance_wallet_outlined,
                    isPositive: true,
                  ),

                  const SizedBox(height: 12),

                  // ------------------------------------------------------
                  // Credit / Debit
                  // ------------------------------------------------------

                  Row(
                    children: [
                      Expanded(
                        child: BalanceCard(
                          title: 'Credit',
                          amount: totalCredit,
                          icon: Icons.arrow_downward_rounded,
                          isPositive: true,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: BalanceCard(
                          title: 'Debit',
                          amount: totalDebit,
                          icon: Icons.arrow_upward_rounded,
                          isPositive: false,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ------------------------------------------------------
                  // Quick Actions
                  // ------------------------------------------------------

                  const SectionHeader(
                    title: 'Quick Actions',
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.add_circle_outline,
                          title: 'Add Credit',
                          iconColor: Colors.green,
                          onTap: () {
                            Navigator.pushNamed(context, "/AddCreditScreen");
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _QuickAction(
                          icon: Icons.remove_circle_outline,
                          title: 'Add Debit',
                          iconColor: Colors.red,
                          onTap: () {
                            Navigator.pushNamed(context, "/AddDebitScreen");
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.swap_horiz_rounded,
                          title: 'Transfer',
                          iconColor: Colors.blue,
                          onTap: () {
                            Navigator.pushNamed(context, "/AddTransferScreen");
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _QuickAction(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Accounts',
                          iconColor: Colors.orange,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/AccountsScreen',
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ------------------------------------------------------
                  // Accounts
                  // ------------------------------------------------------

                  SectionHeader(
                    title: 'My Accounts',
                    actionText: 'View All',
                    onAction: () {
                      Navigator.pushNamed(
                        context,
                        '/AccountsScreen',
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  if (accountProvider.accounts.isEmpty)
                    const EmptyState(
                      icon: Icons
                          .account_balance_wallet_outlined,
                      title: 'No accounts yet',
                      message:
                      'Add an account to start tracking your money.',
                    )
                  else
                    _AccountsPreview(
                      provider: accountProvider,
                    ),

                  const SizedBox(height: 28),

                  // ------------------------------------------------------
                  // Recent Transactions
                  // ------------------------------------------------------

                  SectionHeader(
                    title: 'Recent Transactions',
                    actionText: 'View All',
                    onAction: () {
                      Navigator.pushNamed(
                        context,
                        '/TransactionsScreen',
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  if (transactionProvider.transactions.isEmpty)
                    const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions yet',
                      message:
                      'Your credit, debit, and transfer transactions will appear here.',
                    )
                  else
                    _TransactionsPreview(
                      provider: transactionProvider,
                      accountProvider: accountProvider,
                    ),

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ========================================================================
// TRANSACTIONS PREVIEW
// ========================================================================

class _TransactionsPreview extends StatelessWidget {
  final TransactionProvider provider;
  final AccountProvider accountProvider;

  const _TransactionsPreview({
    required this.provider,
    required this.accountProvider,
  });

  @override
  Widget build(BuildContext context) {
    final int count = provider.transactions.length > 5
        ? 5
        : provider.transactions.length;

    // Build account name lookup
    final Map<String, String> accountNames = {};
    for (final acc in accountProvider.accounts) {
      final data = acc.data();
      accountNames[acc.id] = data['name']?.toString() ?? 'Account';
    }

    return Column(
      children: [
        for (int index = 0; index < count; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildTransactionItem(
              context,
              provider.transactions[index],
              accountNames,
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    dynamic txDoc,
    Map<String, String> accountNames,
  ) {
    final data = txDoc.data();
    final String type = data['type']?.toString().toLowerCase() ?? 'credit';
    final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
    final String category = data['categoryId']?.toString() ?? (type == 'transfer' ? 'Transfer' : 'General');
    final String description = data['description']?.toString() ?? '';
    final dynamic dateRaw = data['date'];
    final DateTime date = dateRaw is Timestamp
        ? dateRaw.toDate()
        : (dateRaw is DateTime ? dateRaw : DateTime.now());

    String title;
    if (type == 'transfer') {
      final fromName = accountNames[data['fromAccountId']?.toString() ?? ''] ?? 'Account';
      final toName = accountNames[data['toAccountId']?.toString() ?? ''] ?? 'Account';
      title = '$fromName → $toName';
    } else {
      final accName = accountNames[data['accountId']?.toString() ?? ''] ?? 'Account';
      title = '$accName (${type == 'credit' ? 'Credit' : 'Debit'})';
    }

    return TransactionCard(
      title: title,
      category: category,
      description: description,
      amount: amount,
      date: date,
      type: type,
      onTap: () {
        Navigator.pushNamed(context, '/TransactionsScreen');
      },
    );
  }
}

// ========================================================================
// ACCOUNTS PREVIEW
// ========================================================================

class _AccountsPreview extends StatelessWidget {
  final AccountProvider provider;

  const _AccountsPreview({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    // Show maximum 3 accounts on dashboard
    final int count =
    provider.accounts.length > 3
        ? 3
        : provider.accounts.length;

    return Column(
      children: [
        for (int index = 0; index < count; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AccountItem(
              account: provider.accounts[index],
            ),
          ),
      ],
    );
  }
}

// ========================================================================
// ACCOUNT ITEM
// ========================================================================

class _AccountItem extends StatelessWidget {
  final dynamic account;

  const _AccountItem({
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final data = account.data();

    final String name =
        data['name']?.toString() ?? 'Unnamed Account';

    final dynamic balanceValue = data['balance'];

    final double balance =
    balanceValue is num
        ? balanceValue.toDouble()
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            CurrencyHelper.format(balance),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// QUICK ACTION
// ========================================================================

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: Column(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================================================
// OVERVIEW
// ========================================================================

class _OverviewCard extends StatelessWidget {
  const _OverviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          const Text(
            'No spending data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Add some debit transactions to see your spending overview.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}