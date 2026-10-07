import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/presentation/mock_data.dart';
import '../../../../shared/presentation/widgets/flow_widgets.dart';
import 'add_expense_page.dart';

class ExpenseDetailResult {
  const ExpenseDetailResult({this.updated, this.deleted = false});

  final ExpenseMock? updated;
  final bool deleted;
}

class ExpenseDetailPage extends StatelessWidget {
  const ExpenseDetailPage({
    required this.room,
    required this.expense,
    super.key,
  });

  final RoomMock room;
  final ExpenseMock expense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense details',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'More actions',
            onPressed: () => _showActions(context),
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          SurfaceCard(
            padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
            child: Column(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    expense.emoji,
                    style: const TextStyle(fontSize: 31),
                  ),
                ),
                const SizedBox(height: 12),
                StatusPill(label: expense.category),
                const SizedBox(height: 6),
                Text(
                  _money(expense.amount),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  expense.note.isEmpty ? expense.title : expense.note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Paid by',
                  value: expense.paidBy,
                ),
                const Divider(
                  height: 1,
                  indent: 58,
                  endIndent: 16,
                  color: AppColors.paleBlue,
                ),
                if (expense.category == 'Transfer') ...[
                  _DetailRow(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transfer method',
                    value: expense.transferMethod ?? 'Bank transfer',
                  ),
                  const Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 16,
                    color: AppColors.paleBlue,
                  ),
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Transfer to',
                    value: expense.transferTo ?? 'Unknown',
                  ),
                  const Divider(
                    height: 1,
                    indent: 58,
                    endIndent: 16,
                    color: AppColors.paleBlue,
                  ),
                ],
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Added by',
                  value: expense.addedBy,
                ),
                const Divider(
                  height: 1,
                  indent: 58,
                  endIndent: 16,
                  color: AppColors.paleBlue,
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: expense.date == null
                      ? '${expense.dateGroup}, Oct 6'
                      : '${expense.dateGroup}, ${expense.date!.day} ${_month(expense.date!.month)}',
                ),
                const Divider(
                  height: 1,
                  indent: 58,
                  endIndent: 16,
                  color: AppColors.paleBlue,
                ),
                _DetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'Time',
                  value: expense.time,
                ),
                const Divider(
                  height: 1,
                  indent: 58,
                  endIndent: 16,
                  color: AppColors.paleBlue,
                ),
                if (expense.category != 'Transfer')
                  _DetailRow(
                    icon: Icons.groups_outlined,
                    label: 'Split',
                    value: expense.splitCount == 1
                        ? 'Just me'
                        : 'Equally · ${expense.splitCount ?? room.members.length} people',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Edit expense',
            icon: Icons.edit_outlined,
            onPressed: () => _edit(context),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete expense'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 50),
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: Color(0xFFE8BFC0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.control),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _money(double amount) {
    switch (room.currency) {
      case 'JPY':
        return '¥${amount.toStringAsFixed(0)}';
      case 'THB':
        return '฿${amount.toStringAsFixed(0)}';
      default:
        return formatMoney(amount);
    }
  }

  String _month(int month) => const [
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
  ][month - 1];

  Future<void> _edit(BuildContext context) async {
    final updated = await Navigator.of(context).push<ExpenseMock>(
      MaterialPageRoute<ExpenseMock>(
        builder: (_) => AddExpensePage(room: room, expense: expense),
      ),
    );
    if (updated != null && context.mounted) {
      Navigator.pop(context, ExpenseDetailResult(updated: updated));
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
        title: const Text('Delete this expense?'),
        content: Text('“${expense.title}” will be removed from this preview.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep expense'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.pop(context, const ExpenseDetailResult(deleted: true));
    }
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit expense'),
              onTap: () {
                Navigator.pop(context);
                _edit(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              title: const Text('Delete expense'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
