import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/work_provider.dart';
import '../../utils/format_utils.dart';

class WorkListScreen extends StatefulWidget {
  const WorkListScreen({super.key});

  @override
  State<WorkListScreen> createState() => _WorkListScreenState();
}

class _WorkListScreenState extends State<WorkListScreen> {
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<WorkProvider>().loadMonthRecords(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('\u8bb0\u5de5\u8bb0\u5f55'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.group_add),
            label: const Text('\u6279\u91cf\u8bb0'),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<WorkProvider>(
        builder: (context, provider, _) {
          final grouped = provider.groupByDate();
          final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildChip('\u5168\u90e8', true),
                    _buildChip('\u70b9\u5de5', false),
                    _buildChip('\u5305\u5de5', false),
                    _buildChip('\u52a0\u73ed', false),
                  ],
                ),
              ),
              Expanded(
                child: dates.isEmpty
                    ? const Center(child: Text('\u6682\u65e0\u8bb0\u5f55', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: dates.length,
                        itemBuilder: (context, index) {
                          final date = dates[index];
                          final dayRecords = grouped[date]!;
                          final dayTotal = dayRecords.fold<double>(0, (s, r) => s + r.totalAmount);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    Text('\u5408\u8ba1: \${FormatUtils.formatMoney(dayTotal)}',
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                  ],
                                ),
                              ),
                              ...dayRecords.map((r) => Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getTypeColor(r.type).withValues(alpha: 0.1),
                                    child: Icon(_getTypeIcon(r.type), color: _getTypeColor(r.type), size: 20),
                                  ),
                                  title: Text(_getTypeName(r.type)),
                                  subtitle: Text('\${r.days ?? 0}\u5929 \${r.hours ?? 0}\u5c0f\u65f6 | \u5355\u4ef7: \${FormatUtils.formatMoney(r.unitPrice ?? 0)}'),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(FormatUtils.formatMoney(r.totalAmount),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      if (r.remark?.isNotEmpty == true)
                                        Text(r.remark!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                  onTap: () => Navigator.pushNamed(context, '/work/form', arguments: r),
                                  onLongPress: () => _showDeleteDialog(context, provider, r.id!),
                                ),
                              )),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/work/form'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'point_day': return Colors.blue;
      case 'point_hour': return Colors.cyan;
      case 'package_day': return Colors.green;
      case 'package_quantity': return Colors.teal;
      case 'overtime': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'point_day': return Icons.work;
      case 'point_hour': return Icons.access_time;
      case 'package_day': return Icons.workspaces;
      case 'package_quantity': return Icons.inventory;
      case 'overtime': return Icons.nightlight_round;
      default: return Icons.work;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'point_day': return '\u70b9\u5de5\uff08\u6309\u5929\uff09';
      case 'point_hour': return '\u70b9\u5de5\uff08\u6309\u5c0f\u65f6\uff09';
      case 'package_day': return '\u5305\u5de5\uff08\u6309\u5929\uff09';
      case 'package_quantity': return '\u5305\u5de5\uff08\u6309\u91cf\uff09';
      case 'overtime': return '\u52a0\u73ed';
      default: return type;
    }
  }

  void _showDeleteDialog(BuildContext context, WorkProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('\u5220\u9664\u8bb0\u5f55'),
        content: const Text('\u786e\u5b9a\u5220\u9664\u8fd9\u6761\u8bb0\u5f55\u5417\uff1f'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('\u53d6\u6d88')),
          TextButton(
            onPressed: () { provider.deleteRecord(id); Navigator.pop(ctx); },
            child: const Text('\u5220\u9664', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
