import 'package:flutter/material.dart';
import '../models/salary_record.dart';
import '../utils/format_utils.dart';

class SalaryCard extends StatelessWidget {
  final SalaryRecord record;
  final VoidCallback? onTap;

  const SalaryCard({
    super.key,
    required this.record,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor().withOpacity(0.1),
          child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 20),
        ),
        title: Text(_getTypeName()),
        subtitle: Text('${record.date} ${record.remark ?? ''}'),
        trailing: Text(
          '${record.type == 'total' ? '+' : '-'}${FormatUtils.formatMoney(record.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: record.type == 'total' ? Colors.green : Colors.red,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getTypeColor() {
    switch (record.type) {
      case 'total': return Colors.green;
      case 'paid': return Colors.blue;
      case 'advance': return Colors.orange;
      case 'settle': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (record.type) {
      case 'total': return Icons.attach_money;
      case 'paid': return Icons.payments;
      case 'advance': return Icons.money_off;
      case 'settle': return Icons.check_circle;
      default: return Icons.money;
    }
  }

  String _getTypeName() {
    switch (record.type) {
      case 'total': return '总工资';
      case 'paid': return '已发放';
      case 'advance': return '借支/预支';
      case 'settle': return '结算';
      default: return record.type;
    }
  }
}
