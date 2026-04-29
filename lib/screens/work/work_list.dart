import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/work_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/worker_provider.dart';
import '../../utils/format_utils.dart';

class WorkListScreen extends StatefulWidget {
  const WorkListScreen({super.key});

  @override
  State<WorkListScreen> createState() => _WorkListScreenState();
}

class _WorkListScreenState extends State<WorkListScreen> {
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    context.read<WorkProvider>().loadMonthRecords(now.year, now.month);
    context.read<ProjectProvider>().loadAll();
    context.read<WorkerProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记工记录'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.group_add),
            label: const Text('批量记'),
            onPressed: () => Navigator.pushNamed(context, '/work/batch'),
          ),
        ],
      ),
      body: Consumer3<WorkProvider, ProjectProvider, WorkerProvider>(
        builder: (context, provider, projectProvider, workerProvider, _) {
          final grouped = provider.groupByDate();
          var dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          // Apply filter
          if (_filterType != 'all') {
            dates = dates.where((date) {
              return grouped[date]!.any((r) {
                if (_filterType == 'point') return r.type.startsWith('point');
                if (_filterType == 'package') return r.type.startsWith('package');
                if (_filterType == 'overtime') return r.type == 'overtime';
                return true;
              });
            }).toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildChip('全部', 'all'),
                    _buildChip('点工', 'point'),
                    _buildChip('包工', 'package'),
                    _buildChip('加班', 'overtime'),
                  ],
                ),
              ),
              Expanded(
                child: dates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text('暂无记录', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 8),
                            const Text('点击右下角或上方「批量记」开始记工', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: dates.length,
                        itemBuilder: (context, index) {
                          final date = dates[index];
                          final dayRecords = _filterType == 'all'
                              ? grouped[date]!
                              : grouped[date]!.where((r) {
                                  if (_filterType == 'point') return r.type.startsWith('point');
                                  if (_filterType == 'package') return r.type.startsWith('package');
                                  if (_filterType == 'overtime') return r.type == 'overtime';
                                  return true;
                                }).toList();
                          if (dayRecords.isEmpty) return const SizedBox.shrink();
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
                                    Text('合计: \${FormatUtils.formatMoney(dayTotal)}',
                                        style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                  ],
                                ),
                              ),
                              ...dayRecords.map((r) {
                                final projectName = projectProvider.getProjectById(r.projectId)?.name;
                                final workerName = workerProvider.getWorkerById(r.workerId)?.name;
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getTypeColor(r.type).withOpacity(0.1),
                                      child: Icon(_getTypeIcon(r.type), color: _getTypeColor(r.type), size: 20),
                                    ),
                                    title: Row(
                                      children: [
                                        Text(_getTypeName(r.type)),
                                        if (workerName != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(workerName, style: const TextStyle(fontSize: 11, color: Colors.blue)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    subtitle: Text(
                                      '\${r.days ?? 0}天 \${r.hours ?? 0}小时 | 单价: \${FormatUtils.formatMoney(r.unitPrice ?? 0)}'
                                      '\${projectName != null ? ' | \$projectName' : ''}',
                                    ),
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
                                );
                              }),
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

  Widget _buildChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _filterType == value,
      onSelected: (_) => setState(() => _filterType = value),
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
      case 'point_day': return '点工（按天）';
      case 'point_hour': return '点工（按小时）';
      case 'package_day': return '包工（按天）';
      case 'package_quantity': return '包工（按量）';
      case 'overtime': return '加班';
      default: return type;
    }
  }

  void _showDeleteDialog(BuildContext context, WorkProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('确定删除这条记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              provider.deleteRecord(id);
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
