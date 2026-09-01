import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_constants.dart';
import '../utils/currency_helper.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedType = 'All'; // 'All', 'Credit', 'Debit', 'Transfer'
  String? _selectedAccountId; // null for All Accounts
  DateTime? _selectedDate; // null for All Dates

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().startListening();
      context.read<TransactionProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF202624),
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

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = 'All';
      _selectedAccountId = null;
      _selectedDate = null;
    });
  }

  bool get _hasActiveFilters =>
      _searchController.text.trim().isNotEmpty ||
      _selectedType != 'All' ||
      _selectedAccountId != null ||
      _selectedDate != null;

  @override
  Widget build(BuildContext context) {
    const darkText = Color(0xFF202624);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      resizeToAvoidBottomInset: true,
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
          'All Transactions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: darkText,
          ),
        ),
        actions: [
          if (_hasActiveFilters)
            IconButton(
              tooltip: 'Clear Filters',
              onPressed: _clearFilters,
              icon: const Icon(
                Icons.filter_alt_off_rounded,
                color: Color(0xFFD32F2F),
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Consumer2<TransactionProvider, AccountProvider>(
            builder: (context, txProvider, accProvider, child) {
              final allTransactions = txProvider.transactions;

              // Build a lookup map of account names
              final Map<String, String> accountNames = {};
              for (final acc in accProvider.accounts) {
                final data = acc.data();
                accountNames[acc.id] =
                    data['name']?.toString() ?? 'Unnamed Account';
              }

              // Calculate overall statistics
              double totalIncome = 0;
              double totalExpense = 0;

              for (final tx in allTransactions) {
                final data = tx.data();
                final type = data['type']?.toString().toLowerCase();
                final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

                if (type == 'credit') {
                  totalIncome += amount;
                } else if (type == 'debit') {
                  totalExpense += amount;
                }
              }

              // Filter transactions based on active filters
              final query = _searchController.text.trim().toLowerCase();

              final filteredTransactions = allTransactions.where((tx) {
                final data = tx.data();
                final type = data['type']?.toString().toLowerCase() ?? '';
                final category =
                    data['categoryId']?.toString().toLowerCase() ?? '';
                final description =
                    data['description']?.toString().toLowerCase() ?? '';
                final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
                final accountId = data['accountId']?.toString() ?? '';
                final fromAccountId = data['fromAccountId']?.toString() ?? '';
                final toAccountId = data['toAccountId']?.toString() ?? '';

                final accountName = (accountNames[accountId] ?? '').toLowerCase();
                final fromAccName = (accountNames[fromAccountId] ?? '')
                    .toLowerCase();
                final toAccName = (accountNames[toAccountId] ?? '').toLowerCase();

                // 1. Filter by Type
                if (_selectedType != 'All' &&
                    type != _selectedType.toLowerCase()) {
                  return false;
                }

                // 2. Filter by Account / Bank
                if (_selectedAccountId != null) {
                  if (type == 'transfer') {
                    if (fromAccountId != _selectedAccountId &&
                        toAccountId != _selectedAccountId) {
                      return false;
                    }
                  } else if (accountId != _selectedAccountId) {
                    return false;
                  }
                }

                // 3. Filter by Date
                if (_selectedDate != null) {
                  final dynamic dateRaw = data['date'];
                  final DateTime txDate = dateRaw is Timestamp
                      ? dateRaw.toDate()
                      : (dateRaw is DateTime ? dateRaw : DateTime.now());

                  final bool sameDay =
                      txDate.year == _selectedDate!.year &&
                      txDate.month == _selectedDate!.month &&
                      txDate.day == _selectedDate!.day;

                  if (!sameDay) {
                    return false;
                  }
                }

                // 4. Filter by Search Query
                if (query.isNotEmpty) {
                  final matchesQuery =
                      category.contains(query) ||
                      description.contains(query) ||
                      accountName.contains(query) ||
                      fromAccName.contains(query) ||
                      toAccName.contains(query) ||
                      type.contains(query) ||
                      amount.toString().contains(query);

                  if (!matchesQuery) {
                    return false;
                  }
                }

                return true;
              }).toList();

              return Column(
                children: [
                  // Summary Banner (hide when searching to save vertical space for keyboard)
                  if (query.isEmpty)
                    _buildSummaryHeader(totalIncome, totalExpense),

                  // Search & Filters Header
                  _buildFilterSection(accProvider),

                  const SizedBox(height: 8),

                  // Transaction Count bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transactions (${filteredTransactions.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: darkText,
                          ),
                        ),
                        if (_hasActiveFilters)
                          GestureDetector(
                            onTap: _clearFilters,
                            child: const Text(
                              'Reset Filters',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Transaction List / Empty State
                  Expanded(
                    child: filteredTransactions.isEmpty
                        ? SingleChildScrollView(
                            child: EmptyState(
                              icon: Icons.receipt_long_outlined,
                              title: _hasActiveFilters
                                  ? 'No matching transactions'
                                  : 'No transactions yet',
                              message: _hasActiveFilters
                                  ? 'Try adjusting or clearing your filters to see more transactions.'
                                  : 'Your credit, debit, and transfer transactions will appear here.',
                              buttonText:
                                  _hasActiveFilters ? 'Clear Filters' : null,
                              onPressed:
                                  _hasActiveFilters ? _clearFilters : null,
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final txDoc = filteredTransactions[index];
                              final data = txDoc.data();
                              final String type =
                                  data['type']?.toString().toLowerCase() ??
                                  'debit';
                              final double amount =
                                  (data['amount'] as num?)?.toDouble() ?? 0.0;
                              final String category =
                                  data['categoryId']?.toString() ??
                                  (type == 'transfer' ? 'Transfer' : 'General');
                              final String description =
                                  data['description']?.toString() ?? '';
                              final dynamic dateRaw = data['date'];
                              final DateTime date = dateRaw is Timestamp
                                  ? dateRaw.toDate()
                                  : (dateRaw is DateTime
                                        ? dateRaw
                                        : DateTime.now());

                              // Resolve Account Title
                              String title;
                              if (type == 'transfer') {
                                final fromName =
                                    accountNames[data['fromAccountId']
                                            ?.toString() ??
                                        ''] ??
                                    'Account';
                                final toName =
                                    accountNames[data['toAccountId']
                                            ?.toString() ??
                                        ''] ??
                                    'Account';
                                title = '$fromName → $toName';
                              } else {
                                final accName =
                                    accountNames[data['accountId']?.toString() ??
                                        ''] ??
                                    'Account';
                                title =
                                    '$accName (${type == 'credit' ? 'Credit' : 'Debit'})';
                              }

                                return TransactionCard(
                                  title: title,
                                  category: category,
                                  description: description,
                                  amount: amount,
                                  date: date,
                                  type: type,
                                  onEdit: () {
                                    _showEditTransactionDialog(
                                      context,
                                      txDoc.id,
                                      type,
                                      category,
                                      amount,
                                      description,
                                      date,
                                    );
                                  },
                                  onDelete: () {
                                    _showDeleteTransactionDialog(
                                      context,
                                      txDoc.id,
                                      type,
                                      amount,
                                      title,
                                    );
                                  },
                                );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------
  // SUMMARY HEADER
  // ------------------------------------------------------------------------
  Widget _buildSummaryHeader(double totalIncome, double totalExpense) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total Income
          Expanded(
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_downward_rounded,
                    color: Color(0xFF2E7D32),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Income',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          CurrencyHelper.format(totalIncome),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(height: 34, width: 1, color: Colors.grey.shade200),

          // Total Expense
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Color(0xFFD32F2F),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Expense',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            CurrencyHelper.format(totalExpense),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // FILTERS SECTION
  // ------------------------------------------------------------------------
  Widget _buildFilterSection(AccountProvider accProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by note, category, bank...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.grey,
                  size: 22,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // Type Filter Chips
                ...['All', 'Credit', 'Debit', 'Transfer'].map((type) {
                  final isSelected = _selectedType == type;
                  Color chipColor;
                  if (type == 'Credit') {
                    chipColor = const Color(0xFF2E7D32);
                  } else if (type == 'Debit') {
                    chipColor = const Color(0xFFD32F2F);
                  } else if (type == 'Transfer') {
                    chipColor = const Color(0xFF1E88E5);
                  } else {
                    chipColor = const Color(0xFF202624);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(type),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                      selectedColor: chipColor,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? chipColor : Colors.grey.shade300,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                    ),
                  );
                }),

                // Bank / Account Filter Button
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PopupMenuButton<String?>(
                    initialValue: _selectedAccountId,
                    onSelected: (accId) {
                      setState(() {
                        _selectedAccountId = accId;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem<String?>(
                        value: null,
                        child: Text('All Accounts / Banks'),
                      ),
                      ...accProvider.accounts.map((acc) {
                        final data = acc.data();
                        final name = data['name']?.toString() ?? 'Account';
                        return PopupMenuItem<String?>(
                          value: acc.id,
                          child: Text(name),
                        );
                      }),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedAccountId != null
                            ? const Color(0xFF2E7D32).withOpacity(0.12)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedAccountId != null
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_rounded,
                            size: 16,
                            color: _selectedAccountId != null
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _selectedAccountId == null
                                ? 'Bank'
                                : (accProvider.accounts
                                          .where(
                                            (a) => a.id == _selectedAccountId,
                                          )
                                          .firstOrNull
                                          ?.data()['name']
                                          ?.toString() ??
                                      'Bank'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _selectedAccountId != null
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: _selectedAccountId != null
                                  ? const Color(0xFF2E7D32)
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: _selectedAccountId != null
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.shade700,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Date Filter Button
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedDate != null
                          ? const Color(0xFF2E7D32).withOpacity(0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedDate != null
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 15,
                          color: _selectedDate != null
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _selectedDate == null
                              ? 'Date'
                              : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _selectedDate != null
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: _selectedDate != null
                                ? const Color(0xFF2E7D32)
                                : Colors.black87,
                          ),
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = null;
                              });
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // EDIT TRANSACTION DIALOG
  // ------------------------------------------------------------------------
  void _showEditTransactionDialog(
    BuildContext context,
    String transactionId,
    String type,
    String currentCategory,
    double currentAmount,
    String currentDescription,
    DateTime currentDate,
  ) {
    final amountController = TextEditingController(
      text: currentAmount.toStringAsFixed(2),
    );
    final descController = TextEditingController(text: currentDescription);
    String selectedCategory = currentCategory;
    DateTime selectedDate = currentDate;

    final categories = type == 'credit'
        ? AppConstants.creditCategories
        : (type == 'debit'
              ? AppConstants.debitCategories
              : ['Transfer', 'General']);

    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: type == 'credit'
                    ? const Color(0xFF2E7D32)
                    : (type == 'debit'
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF1E88E5)),
              ),
              const SizedBox(width: 10),
              Text(
                'Edit ${type[0].toUpperCase()}${type.substring(1)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Field
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'Rs. ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter amount';
                      final numVal = double.tryParse(v);
                      if (numVal == null || numVal <= 0) {
                        return 'Enter a valid amount';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedCategory = val;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 14),

                  // Date Picker
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const Icon(Icons.calendar_month_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Description / Note
                  TextFormField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Description / Note',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final newAmount = double.parse(amountController.text.trim());
                final newDesc = descController.text.trim();

                Navigator.pop(ctx);

                final txProvider = context.read<TransactionProvider>();
                final success = await txProvider.updateTransaction(
                  transactionId: transactionId,
                  categoryId: selectedCategory,
                  amount: newAmount,
                  description: newDesc,
                  date: selectedDate,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Transaction updated successfully'
                            : (txProvider.errorMessage ??
                                  'Failed to update transaction'),
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
      ),
    );
  }

  // ------------------------------------------------------------------------
  // DELETE TRANSACTION DIALOG
  // ------------------------------------------------------------------------
  void _showDeleteTransactionDialog(
    BuildContext context,
    String transactionId,
    String type,
    double amount,
    String title,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Delete Transaction',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this $type transaction of ${CurrencyHelper.format(amount)} ($title)?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE0B2)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Colors.orange,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Account balances will automatically be reversed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final txProvider = context.read<TransactionProvider>();
              final success = await txProvider.deleteTransaction(
                transactionId: transactionId,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Transaction deleted & balance reversed'
                          : (txProvider.errorMessage ??
                                'Failed to delete transaction'),
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
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
