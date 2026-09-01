import 'package:flutter/material.dart';
import '../utils/currency_helper.dart';

class TransactionCard extends StatelessWidget {
  final String title;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String type; // 'credit', 'debit', 'transfer'
  final bool? isCredit;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionCard({
    super.key,
    required this.title,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.type = 'debit',
    this.isCredit,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  String get _effectiveType {
    if (isCredit != null) {
      return isCredit! ? 'credit' : 'debit';
    }
    return type.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveType = _effectiveType;
    final bool isTransfer = effectiveType == 'transfer';
    final bool isCreditTx = effectiveType == 'credit';

    final Color bgColor = isTransfer
        ? const Color(0xFFE3F2FD)
        : (isCreditTx ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE));

    final Color iconColor = isTransfer
        ? const Color(0xFF1E88E5)
        : (isCreditTx ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F));

    final IconData icon = isTransfer
        ? Icons.swap_horiz_rounded
        : (isCreditTx ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded);

    final String amountString = isTransfer
        ? CurrencyHelper.format(amount)
        : CurrencyHelper.formatWithSign(amount, isCredit: isCreditTx);

    final bool hasActions = onEdit != null || onDelete != null;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Type Icon
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF202624),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description.isEmpty
                          ? category
                          : '$category • $description',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Amount & Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    amountString,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Optional Actions Menu
              if (hasActions) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: Color(0xFF1E88E5)),
                            SizedBox(width: 10),
                            Text('Edit', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}