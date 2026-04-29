import 'package:flutter/material.dart';
import '../models/work_record.dart';
import '../utils/format_utils.dart';

class WorkCard extends StatelessWidget {
  final WorkRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const WorkCard({
    super.key,
    required this.record,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getTypeColor().withOpacity(0.1),
                child: Icon(_getTypeIcon(), color: _getTypeColor(), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getTypeName(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${record.days ?? 0}天 ${record.hours ?? 0}小时 | 单价: ${FormatUtils.formatMoney(record.unitPrice ?? 0)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (record.remark?.isNotEmpty == true)
                      Text(record.remark!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Text(
                FormatUtils.formatMoney(record.totalAmount ?? 0),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (record.type) {
      case 'point_day': return Colors.blue;
      case 'point_hour': return Colors.cyan;
      case 'package_day': return Colors.green;
      case 'package_quantity': return Colors.teal;
      case 'overtime': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (record.type) {
      case 'point_day': return Icons.work;
      case 'point_hour': return Icons.access_time;
      case 'package_day': return Icons.workspaces;
      case 'package_quantity': return Icons.inventory;
      case 'overtime': return Icons.nightlight_round;
      default: return Icons.work;
    }
  }

  String _getTypeName() {
    switch (record.type) {
      case 'point_day': return '点工（按天）';
      case 'point_hour': return '点工（按小时）';
      case 'package_day': return '包工（按天）';
      case 'package_quantity': return '包工（按量）';
      case 'overtime': return '加班';
      default: return record.type;
    }
  }
}
