import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/presentation/mock_data.dart';
import '../../../../shared/presentation/widgets/flow_widgets.dart';
import '../../../expenses/presentation/pages/add_expense_page.dart';
import '../../../expenses/presentation/pages/expense_detail_page.dart';

class RoomDashboardPage extends StatefulWidget {
  const RoomDashboardPage({required this.room, super.key});

  final RoomMock room;

  @override
  State<RoomDashboardPage> createState() => _RoomDashboardPageState();
}

class _RoomDashboardPageState extends State<RoomDashboardPage> {
  late List<ExpenseMock> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = List.of(
      widget.room.currency == 'MYR' ? householdExpenses : japanExpenses,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = _expenses
        .where((expense) => expense.dateGroup == 'Today')
        .toList();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Flexible(
              child: Text(
                widget.room.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (widget.room.live) ...[
              const SizedBox(width: 8),
              const StatusPill(label: 'Live', color: AppColors.paleCyan),
            ],
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Room members',
            onPressed: () => _openSection('Members'),
            icon: const Icon(Icons.groups_2_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 90),
        children: [
          SurfaceCard(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total spent',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                    ),
                    StatusPill(
                      label: _periodLabel,
                      color: AppColors.paleBlue,
                      textColor: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.room.total,
                  style: const TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.paleBlue.withValues(alpha: 0.64),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Row(
                    children: [
                      _Metric(
                        label: 'Today',
                        value: _money(
                          today.fold(0, (sum, expense) => sum + expense.amount),
                        ),
                      ),
                      const _Metric(label: 'Members', value: '4 active'),
                      const _Metric(label: 'Daily avg', value: 'RM 84.20'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (final action in const [
                      _QuickAction('Members', Icons.groups_outlined),
                      _QuickAction('Settle', Icons.call_split_rounded),
                      _QuickAction('Activity', Icons.dynamic_feed_outlined),
                      _QuickAction('Stats', Icons.bar_chart_rounded),
                    ])
                      Expanded(
                        child: InkWell(
                          onTap: () => _openSection(action.label),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              children: [
                                Container(
                                  width: 39,
                                  height: 39,
                                  decoration: const BoxDecoration(
                                    color: AppColors.paleBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    action.icon,
                                    size: 19,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  action.label,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: () => _openSection('Activity'),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  children: [
                    Container(width: 3, height: 34, color: AppColors.cyan),
                    const SizedBox(width: 9),
                    const MemberAvatar(
                      name: 'John Tan',
                      size: 32,
                      color: AppColors.paleCyan,
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text(
                        'John just added 🚆 Shinkansen tickets',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Text(
                      _money(widget.room.currency == 'JPY' ? 3200 : 18),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SectionHeading(
            'Today’s expenses',
            trailing: TextButton(
              onPressed: () => _openSection('History'),
              child: const Text('View all'),
            ),
          ),
          const SizedBox(height: 5),
          if (today.isEmpty)
            const _RoomEmptyState()
          else
            for (final expense in today.take(4)) ...[
              _ExpenseTile(
                expense: expense,
                amount: _money(expense.amount),
                onTap: () => _openExpense(expense),
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 16),
          const SectionHeading(
            'Who’s in this room',
            trailing: StatusPill(
              label: '4 members',
              color: AppColors.paleBlue,
              textColor: Colors.grey,
            ),
          ),
          const SizedBox(height: 11),
          SurfaceCard(
            onTap: () => _openSection('Members'),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                AvatarStack(names: widget.room.members),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Eric, John, Amy and David',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: const Text(
          'Add expense',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.white),
        ),
      ),
    );
  }

  String get _periodLabel => 'Oct 1 – Oct 31';

  String _money(double amount) {
    switch (widget.room.currency) {
      case 'JPY':
        return '¥${amount.toStringAsFixed(0)}';
      case 'THB':
        return '฿${amount.toStringAsFixed(0)}';
      default:
        return formatMoney(amount);
    }
  }

  Future<void> _addExpense() async {
    final expense = await Navigator.of(context).push<ExpenseMock>(
      MaterialPageRoute<ExpenseMock>(
        builder: (_) => AddExpensePage(room: widget.room),
      ),
    );
    if (expense != null) {
      setState(() => _expenses.insert(0, expense));
      if (mounted) _message('Expense added to ${widget.room.name}.');
    }
  }

  Future<void> _openExpense(ExpenseMock expense) async {
    final result = await Navigator.of(context).push<ExpenseDetailResult>(
      MaterialPageRoute<ExpenseDetailResult>(
        builder: (_) => ExpenseDetailPage(room: widget.room, expense: expense),
      ),
    );
    if (result == null) return;
    setState(() {
      if (result.deleted) {
        _expenses.remove(expense);
      } else if (result.updated != null) {
        final index = _expenses.indexOf(expense);
        if (index >= 0) _expenses[index] = result.updated!;
      }
    });
    if (mounted && result.deleted) {
      _message('Expense removed from this preview.');
    }
    if (mounted && result.updated != null) _message('Expense changes saved.');
  }

  void _openSection(String section) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RoomSectionPage(room: widget.room, section: section),
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class RoomSectionPage extends StatefulWidget {
  const RoomSectionPage({required this.room, required this.section, super.key});

  final RoomMock room;
  final String section;

  @override
  State<RoomSectionPage> createState() => _RoomSectionPageState();
}

class _RoomSectionPageState extends State<RoomSectionPage> {
  final Set<String> _paidSettlements = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.section,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: switch (widget.section) {
          'Members' => _members(),
          'Settle' => _settlements(),
          'Activity' => _activity(),
          'Stats' => _statistics(),
          _ => _history(),
        },
      ),
    );
  }

  List<Widget> _members() => [
    SurfaceCard(
      color: AppColors.paleBlue,
      child: Row(
        children: [
          const Icon(Icons.groups_rounded, color: AppColors.primary),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              '${widget.room.members.length} people are sharing ${widget.room.name}.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 16),
    for (final member in roomMembers) ...[
      SurfaceCard(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        child: Row(
          children: [
            MemberAvatar(name: member.name, size: 42, color: member.color),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    member.role,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Total spending',
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
                Text(
                  _money(member.spending),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            PopupMenuButton<String>(
              tooltip: 'Member options',
              onSelected: (value) => _memberAction(member, value),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'invite',
                  child: Text('Manage invite'),
                ),
                if (member.role == 'Member')
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove member'),
                  ),
                if (member.role == 'Owner')
                  const PopupMenuItem(
                    value: 'regenerate',
                    child: Text('Regenerate invite'),
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 9),
    ],
    const SizedBox(height: 6),
    OutlinedButton.icon(
      onPressed: () => _message('Invite code copied: JAPAN-4K8D'),
      icon: const Icon(Icons.link_rounded),
      label: const Text('Manage room invite'),
    ),
  ];

  List<Widget> _settlements() => [
    SurfaceCard(
      color: AppColors.paleBlue,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everyone is almost even',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 4),
          Text(
            'Suggested transfers keep the number of payments low.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    ),
    const SizedBox(height: 17),
    const SectionHeading(
      'Suggested settlements',
      trailing: StatusPill(label: '2 pending', color: AppColors.accent),
    ),
    const SizedBox(height: 10),
    for (final pair in const [
      ('Eric', 'John', 50.0),
      ('David', 'John', 30.0),
      ('Amy', 'Eric', 20.0),
    ]) ...[
      SurfaceCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _SettlementAvatars(from: pair.$1, to: pair.$2),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pair.$1} → ${pair.$2}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    _paidSettlements.contains(pair.$1)
                        ? 'Paid just now'
                        : 'Pending',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _money(pair.$3),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextButton(
                  onPressed: _paidSettlements.contains(pair.$1)
                      ? null
                      : () => _markPaid(pair.$1),
                  child: Text(
                    _paidSettlements.contains(pair.$1) ? 'Paid' : 'Mark paid',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 9),
    ],
  ];

  List<Widget> _activity() => [
    for (final item in const [
      (
        'John added Food',
        'RM 20.00 · Lunch at the market',
        '12 min ago',
        Icons.add_shopping_cart_rounded,
        AppColors.primary,
      ),
      (
        'Amy joined the room',
        'Monthly Household',
        '2 hours ago',
        Icons.person_add_alt_rounded,
        AppColors.secondary,
      ),
      (
        'Eric edited Hotel',
        'RM 180.00 · corrected amount',
        'Yesterday',
        Icons.edit_outlined,
        AppColors.cyan,
      ),
      (
        'John deleted Coffee',
        'RM 12.00 · duplicate entry',
        'Yesterday',
        Icons.delete_outline_rounded,
        AppColors.danger,
      ),
      (
        'Amy marked settlement as paid',
        'Eric received RM 30.00',
        'Oct 3',
        Icons.check_circle_outline_rounded,
        AppColors.success,
      ),
    ]) ...[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.paleBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(item.$4, size: 18, color: item.$5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SurfaceCard(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.$3,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
    ],
  ];

  List<Widget> _history() {
    final expenses = widget.room.currency == 'MYR'
        ? householdExpenses
        : japanExpenses;
    return [
      SurfaceCard(
        child: Row(
          children: [
            const Icon(Icons.filter_list_rounded, color: AppColors.primary),
            const SizedBox(width: 9),
            const Expanded(
              child: Text(
                'October · All categories',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${expenses.length} items',
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      for (final group in ['Today', 'Yesterday', 'Earlier']) ...[
        if (expenses.any((expense) => expense.dateGroup == group)) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 9, top: 5),
            child: Text(
              group,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          for (final expense in expenses.where(
            (expense) => expense.dateGroup == group,
          )) ...[
            _ExpenseTile(
              expense: expense,
              amount: _money(expense.amount),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ExpenseDetailPage(room: widget.room, expense: expense),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    ];
  }

  List<Widget> _statistics() => [
    SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total spending this month',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 3),
          Text(
            widget.room.total,
            style: const TextStyle(fontSize: 31, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 15),
          const Text(
            'Spending by category',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          for (final row in const [
            ('Food', 0.78, AppColors.primary),
            ('Transport', 0.52, AppColors.secondary),
            ('Travel', 0.4, AppColors.cyan),
            ('Shopping', 0.25, Color(0xFFCBD4F7)),
          ]) ...[
            Row(
              children: [
                Expanded(
                  child: Text(row.$1, style: const TextStyle(fontSize: 13)),
                ),
                Text(
                  '${(row.$2 * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: row.$2,
                color: row.$3,
                backgroundColor: AppColors.paleBlue,
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    ),
    const SizedBox(height: 14),
    SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'By member',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (final member in roomMembers) ...[
            Row(
              children: [
                MemberAvatar(
                  name: member.name,
                  size: 27,
                  color: member.color,
                  border: false,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(member.name.split(' ').first)),
                Text(
                  _money(member.spending),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    ),
  ];

  void _markPaid(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark this payment as paid?'),
        content: Text('This will update the preview status for $name.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark paid'),
          ),
        ],
      ),
    );
    if (confirmed == true) setState(() => _paidSettlements.add(name));
  }

  void _memberAction(MemberMock member, String action) async {
    if (action == 'invite' || action == 'regenerate') {
      _message(
        action == 'invite'
            ? 'Room invite: JAPAN-4K8D'
            : 'A fresh invite code is ready: FMLY-82QK',
      );
      return;
    }
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${member.name.split(' ').first}?'),
        content: const Text(
          'They will no longer appear in this local room preview.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (remove == true) {
      _message('${member.name.split(' ').first} removed from the preview.');
    }
  }

  String _money(double amount) => widget.room.currency == 'JPY'
      ? '¥${amount.toStringAsFixed(0)}'
      : widget.room.currency == 'THB'
      ? '฿${amount.toStringAsFixed(0)}'
      : formatMoney(amount);

  void _message(String value) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(value)));
}

class _QuickAction {
  const _QuickAction(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.amount,
    required this.onTap,
  });

  final ExpenseMock expense;
  final String amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.paleBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(expense.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Paid by ${expense.paidBy} · ${expense.time}',
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Text(
                'Split equally',
                style: TextStyle(fontSize: 9, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoomEmptyState extends StatelessWidget {
  const _RoomEmptyState();

  @override
  Widget build(BuildContext context) {
    return const SurfaceCard(
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, color: AppColors.primary, size: 30),
          SizedBox(height: 8),
          Text(
            'No expenses yet',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 3),
          Text(
            'Add the first shared expense to get started.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _SettlementAvatars extends StatelessWidget {
  const _SettlementAvatars({required this.from, required this.to});

  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 36,
      child: Stack(
        children: [
          MemberAvatar(name: from, size: 34, color: AppColors.paleBlue),
          Positioned(
            left: 25,
            child: MemberAvatar(name: to, size: 34, color: AppColors.paleCyan),
          ),
        ],
      ),
    );
  }
}
