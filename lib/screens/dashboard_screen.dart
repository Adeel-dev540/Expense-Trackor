import 'package:flutter/material.dart';

import '../widgets/account_card.dart';
import '../widgets/balance_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/transaction_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Open notifications
            },
            icon: const Icon(
              Icons.person,
              color: Colors.black87,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ----------------------------------------------------------
              // Welcome
              // ----------------------------------------------------------

              const Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
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

              // ----------------------------------------------------------
              // Balance
              // ----------------------------------------------------------

              const BalanceCard(
                title: 'Total Balance',
                amount: 0,
                icon: Icons.account_balance_wallet_outlined,
                isPositive: true,
              ),

              const SizedBox(height: 12),

              // ----------------------------------------------------------
              // Credit / Debit
              // ----------------------------------------------------------

              Row(
                children: [
                  Expanded(
                    child: BalanceCard(
                      title: 'Credit',
                      amount: 0,
                      icon: Icons.arrow_downward_rounded,
                      isPositive: true,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: BalanceCard(
                      title: 'Debit',
                      amount: 0,
                      icon: Icons.arrow_upward_rounded,
                      isPositive: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ----------------------------------------------------------
              // Quick Actions
              // ----------------------------------------------------------

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
                        // TODO: Navigate to Add Credit
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
                        // TODO: Navigate to Add Debit
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
                        // TODO: Navigate to Transfer
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
                        Navigator.pushNamed(context, "/AccountsScreen");
                        // TODO: Navigate to Accounts
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ----------------------------------------------------------
              // Accounts
              // ----------------------------------------------------------

              SectionHeader(
                title: 'My Accounts',
                actionText: 'View All',
                onAction: () {
                  Navigator.pushNamed(context, "/AccountsScreen");
                },
              ),

              const SizedBox(height: 12),

              const EmptyState(
                icon: Icons.account_balance_wallet_outlined,
                title: 'No accounts yet',
                message: 'Add an account to start tracking your money.',
              ),

              const SizedBox(height: 28),

              // ----------------------------------------------------------
              // Recent Transactions
              // ----------------------------------------------------------

              SectionHeader(
                title: 'Recent Transactions',
                actionText: 'View All',
                onAction: () {
                  // TODO: Navigate to Transactions
                },
              ),

              const SizedBox(height: 12),

              const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No transactions yet',
                message:
                'Your credit and debit transactions will appear here.',
              ),

              const SizedBox(height: 28),

              // ----------------------------------------------------------
              // Spending Overview
              // ----------------------------------------------------------

              const SectionHeader(
                title: 'Spending Overview',
              ),

              const SizedBox(height: 12),

              _OverviewCard(),

            ],
          ),
        ),
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