import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/presentation/mock_data.dart';
import '../../../../shared/presentation/widgets/flow_widgets.dart';
import '../widgets/category_bottom_sheet.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({required this.room, this.expense, super.key});

  final RoomMock room;
  final ExpenseMock? expense;

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  late String _amount;
  late final TextEditingController _amountController;
  late String _category;
  late String _emoji;
  late String _paidBy;
  late int _splitCount;
  late String _transferMethod;
  late String _transferTo;
  late final TextEditingController _note;
  late DateTime _date;

  bool get _editing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _amount =
        widget.expense?.amount.toStringAsFixed(
          widget.expense!.amount % 1 == 0 ? 0 : 2,
        ) ??
        '';
    _amountController = TextEditingController(text: _amount);
    _category = widget.expense?.category ?? 'Food';
    _emoji = widget.expense?.emoji ?? '🍜';
    _paidBy = widget.expense?.paidBy ?? 'Eric';
    _splitCount = widget.expense?.splitCount ?? widget.room.members.length;
    _transferMethod = widget.expense?.transferMethod ?? 'Bank transfer';
    final recipients = _transferRecipients(_paidBy);
    _transferTo = widget.expense?.transferTo ?? recipients.first;
    _date = widget.expense?.date ?? DateTime.now();
    _note = TextEditingController(text: widget.expense?.note ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amount) ?? 0;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close',
        ),
        title: Text(
          _editing ? 'Edit expense' : 'Add expense',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: amount > 0 ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 5, 18, 14),
                children: [
                  _AmountCard(
                    controller: _amountController,
                    onAmountChanged: (value) => setState(() => _amount = value),
                    currency: _currencySymbol(widget.room.currency),
                    roomName: widget.room.name,
                    onQuickAdd: _addAmount,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _chooseCategory,
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final category in [
                          'Food',
                          'Transport',
                          'Shopping',
                          'Hotel',
                          'Coffee',
                          'Transfer',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _CategoryChip(
                              name: category,
                              emoji: _emojiFor(category),
                              selected: _category == category,
                              onTap: () => _setCategory(category),
                            ),
                          ),
                        IconButton.filledTonal(
                          onPressed: _chooseCategory,
                          icon: const Icon(Icons.grid_view_rounded),
                          tooltip: 'All categories',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SurfaceCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _MetadataRow(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Paid by',
                          trailing: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _paidBy,
                              borderRadius: BorderRadius.circular(14),
                              items: [
                                for (final member in widget.room.members)
                                  DropdownMenuItem(
                                    value: member,
                                    child: Text(
                                      member == 'Eric'
                                          ? '$member (You)'
                                          : member,
                                    ),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _paidBy = value;
                                  final recipients = _transferRecipients(value);
                                  if (!recipients.contains(_transferTo)) {
                                    _transferTo = recipients.first;
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.paleBlue),
                        if (_isTransfer) ...[
                          _MetadataRow(
                            icon: Icons.swap_horiz_rounded,
                            label: 'Transfer method',
                            trailing: SizedBox(
                              width: 150,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _transferMethod,
                                  isExpanded: true,
                                  alignment: AlignmentDirectional.centerEnd,
                                  borderRadius: BorderRadius.circular(14),
                                  items: [
                                    for (final method in [
                                      'Bank transfer',
                                      'Cash',
                                      'E-wallet',
                                    ])
                                      DropdownMenuItem(
                                        value: method,
                                        child: Text(method),
                                      ),
                                  ],
                                  onChanged: (value) => setState(
                                    () => _transferMethod =
                                        value ?? _transferMethod,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.paleBlue),
                          _MetadataRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Transfer to',
                            trailing: SizedBox(
                              width: 150,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _transferTo,
                                  isExpanded: true,
                                  alignment: AlignmentDirectional.centerEnd,
                                  borderRadius: BorderRadius.circular(14),
                                  items: [
                                    for (final member in _transferRecipients(
                                      _paidBy,
                                    ))
                                      DropdownMenuItem(
                                        value: member,
                                        child: Text(member),
                                      ),
                                  ],
                                  onChanged: (value) => setState(
                                    () => _transferTo = value ?? _transferTo,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ] else
                          _MetadataRow(
                            icon: Icons.call_split_rounded,
                            label: 'Split with',
                            trailing: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: _splitCount,
                                borderRadius: BorderRadius.circular(14),
                                items: [
                                  for (
                                    var count = 1;
                                    count <= widget.room.members.length;
                                    count++
                                  )
                                    DropdownMenuItem(
                                      value: count,
                                      child: Text(
                                        count == 1
                                            ? 'Just me'
                                            : '$count members',
                                      ),
                                    ),
                                ],
                                onChanged: (value) => setState(
                                  () => _splitCount = value ?? _splitCount,
                                ),
                              ),
                            ),
                          ),
                        const Divider(height: 1, color: AppColors.paleBlue),
                        _MetadataRow(
                          icon: Icons.edit_note_rounded,
                          label: 'Note',
                          trailing: SizedBox(
                            width: 150,
                            child: TextField(
                              controller: _note,
                              textAlign: TextAlign.end,
                              decoration: const InputDecoration(
                                hintText: 'Add a note',
                                border: InputBorder.none,
                                filled: false,
                                // contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.paleBlue),
                        _MetadataRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date',
                          trailing: TextButton.icon(
                            onPressed: _chooseDate,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 17,
                            ),
                            label: Text(_dateLabel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: PrimaryButton(
                label:
                    '${_editing ? 'Save changes' : 'Add expense'}  ·  ${_currencySymbol(widget.room.currency)}${_amount.isEmpty ? '0' : _amount}',
                icon: Icons.add_task_rounded,
                onPressed: amount > 0 ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _dateLabel {
    final today = DateTime.now();
    if (_date.year == today.year &&
        _date.month == today.month &&
        _date.day == today.day) {
      return 'Today';
    }
    return '${_date.day} ${_month(_date.month)}';
  }

  bool get _isTransfer => _category == 'Transfer';

  String get _dateGroup {
    final today = DateTime.now();
    final selectedDay = DateTime(_date.year, _date.month, _date.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysAgo = todayDate.difference(selectedDay).inDays;
    if (daysAgo == 0) return 'Today';
    if (daysAgo == 1) return 'Yesterday';
    return 'Earlier';
  }

  List<String> _transferRecipients(String paidBy) {
    final recipients = widget.room.members
        .where((member) => member != paidBy)
        .toList();
    return recipients.isEmpty ? widget.room.members : recipients;
  }

  void _setCategory(String category) {
    setState(() {
      _category = category;
      _emoji = _emojiFor(category);
    });
  }

  Future<void> _chooseCategory() async {
    final selected = await showCategoryBottomSheet(
      context,
      selected: _category,
    );
    if (!mounted || selected == null) return;
    setState(() {
      _category = selected.name;
      _emoji = selected.emoji;
    });
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _addAmount(int amount) {
    final value = (double.tryParse(_amount) ?? 0) + amount;
    final updatedAmount = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
    _amountController.value = TextEditingValue(
      text: updatedAmount,
      selection: TextSelection.collapsed(offset: updatedAmount.length),
    );
    setState(() => _amount = updatedAmount);
  }

  void _save() {
    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0) return;
    Navigator.pop(
      context,
      ExpenseMock(
        title: _note.text.trim().isEmpty ? _category : _note.text.trim(),
        category: _category,
        emoji: _emoji,
        amount: amount,
        paidBy: _paidBy,
        splitCount: _splitCount,
        time: 'Now',
        dateGroup: _dateGroup,
        note: _note.text.trim(),
        transferMethod: _isTransfer ? _transferMethod : null,
        transferTo: _isTransfer ? _transferTo : null,
        date: _date,
      ),
    );
  }

  String _currencySymbol(String currency) {
    switch (currency) {
      case 'JPY':
        return '¥';
      case 'THB':
        return '฿';
      default:
        return 'RM ';
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

  String _emojiFor(String category) => switch (category) {
    'Food' => '🍜',
    'Transport' => '🚆',
    'Shopping' => '🛍️',
    'Hotel' => '🏨',
    'Coffee' => '☕',
    'Transfer' => '↔️',
    _ => '📦',
  };
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.controller,
    required this.onAmountChanged,
    required this.currency,
    required this.roomName,
    required this.onQuickAdd,
  });

  final TextEditingController controller;
  final ValueChanged<String> onAmountChanged;
  final String currency;
  final String roomName;
  final ValueChanged<int> onQuickAdd;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 15),
      child: Column(
        children: [
          StatusPill(
            label: roomName.toUpperCase(),
            color: AppColors.primary,
            textColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                currency,
                style: const TextStyle(
                  fontSize: 23,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  key: const ValueKey('expense-amount'),
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  maxLength: 9,
                  onChanged: onAmountChanged,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    filled: false,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in [50, 100, 150])
                ActionChip(
                  label: Text('+$currency${_group(value)}'),
                  onPressed: () => onQuickAdd(value),
                  backgroundColor: AppColors.paleBlue,
                  side: BorderSide.none,
                  labelStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _group(int value) => value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.name,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Text(emoji, style: const TextStyle(fontSize: 17)),
      label: Text(name),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppColors.paleBlue : AppColors.white,
        foregroundColor: AppColors.ink,
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.6 : 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.paleBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
