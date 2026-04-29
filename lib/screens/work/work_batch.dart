import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/work_record.dart';
import '../../models/worker.dart';
import '../../providers/work_provider.dart';
import '../../providers/worker_provider.dart';
import '../../utils/format_utils.dart';
import '../../utils/date_utils.dart';

class WorkBatchScreen extends StatefulWidget {
  const WorkBatchScreen({super.key});

  @override
  State<WorkBatchScreen> createState() => _WorkBatchScreenState();
}

class _WorkBatchScreenState extends State<WorkBatchScreen> {
  String _workType = 'point_day';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final _unitPriceController = TextEditingController(text: '350');
  final _remarkController = TextEditingController();
  final Map<int, Map<String, _BatchEntry>> _entries = {}; // workerId -> {dateStr -> entry}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _unitPriceController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  List<DateTime> get _dateRange {
    final dates = <DateTime>[];
    var d = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day);
    while (!d.isAfter(end)) {
      dates.add(d);
      d = d.add(const Duration(days: 1));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('批量记工'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('保存'),
            onPressed: _saveAll,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Work type selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('工种类型', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTypeChip('点工(按天)', 'point_day'),
                      _buildTypeChip('点工(按小时)', 'point_hour'),
                      _buildTypeChip('包工(按天)', 'package_day'),
                      _buildTypeChip('包工(按量)', 'package_quantity'),
                      _buildTypeChip('加班', 'overtime'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Date range selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('日期范围', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(AppDateUtils.formatDate(_startDate)),
                          onPressed: () => _pickDate(true),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('至'),
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(AppDateUtils.formatDate(_endDate)),
                          onPressed: () => _pickDate(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '共 \${_dateRange.length} 天',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Unit price
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Text('单价: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _unitPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixText: '¥ ',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('备注: '),
                  Expanded(
                    child: TextField(
                      controller: _remarkController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Worker selection & batch grid
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('选择工人', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton.icon(
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('全选'),
                        onPressed: _selectAllWorkers,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.person_off, size: 16),
                        label: const Text('清空'),
                        onPressed: () => setState(() => _entries.clear()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer<WorkerProvider>(
                    builder: (context, provider, _) {
                      if (provider.workers.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text('请先在设置中添加工人', style: TextStyle(color: Colors.grey)),
                          ),
                        );
                      }
                      return Column(
                        children: provider.workers.map((worker) => _buildWorkerRow(worker)).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Summary
          _buildSummary(),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAll,
        icon: const Icon(Icons.save),
        label: const Text('保存全部'),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: _workType == value,
      onSelected: (_) => setState(() => _workType = value),
    );
  }

  Widget _buildWorkerRow(Worker worker) {
    final workerEntries = _entries[worker.id] ?? {};
    final dates = _dateRange;
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Text(
          worker.name.isNotEmpty ? worker.name[0] : '?',
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(worker.name),
      subtitle: Text(
        workerEntries.values.where((e) => e.selected).length > 0
            ? '已选 \${workerEntries.values.where((e) => e.selected).length} 天'
            : '未选择',
        style: TextStyle(
          fontSize: 12,
          color: workerEntries.values.any((e) => e.selected) ? Colors.green : Colors.grey,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: dates.map((date) {
              final dateStr = date.toString().substring(0, 10);
              final entry = workerEntries[dateStr];
              final selected = entry?.selected ?? false;
              final isToday = AppDateUtils.isToday(date);
              return FilterChip(
                label: Text(
                  '\${date.month}/\${date.day}\${isToday ? '(今)' : ''}',
                  style: TextStyle(fontSize: 12, color: selected ? Colors.white : null),
                ),
                selected: selected,
                selectedColor: Colors.blue,
                onSelected: (val) {
                  setState(() {
                    _entries.putIfAbsent(worker.id!, () => {});
                    _entries[worker.id!]![dateStr] = _BatchEntry(
                      selected: val,
                      days: 1,
                    );
                  });
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    int totalEntries = 0;
    _entries.forEach((_, dates) {
      totalEntries += dates.values.where((e) => e.selected).length;
    });
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final totalAmount = totalEntries * unitPrice;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('\$totalEntries', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('总工天', style: TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              children: [
                Text(FormatUtils.formatMoney(totalAmount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('总金额', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) _endDate = _startDate;
        } else {
          _endDate = picked;
          if (_startDate.isAfter(_endDate)) _startDate = _endDate;
        }
      });
    }
  }

  void _selectAllWorkers() {
    final workers = context.read<WorkerProvider>().workers;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    setState(() {
      for (final worker in workers) {
        _entries.putIfAbsent(worker.id!, () => {});
        for (final date in _dateRange) {
          final dateStr = date.toString().substring(0, 10);
          _entries[worker.id!]![dateStr] = _BatchEntry(selected: true, days: 1);
        }
      }
    });
  }

  void _saveAll() async {
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    if (unitPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效单价'), backgroundColor: Colors.red),
      );
      return;
    }

    int count = 0;
    final provider = context.read<WorkProvider>();
    final now = DateTime.now().toIso8601String();

    _entries.forEach((workerId, dates) {
      dates.forEach((dateStr, entry) {
        if (entry.selected) {
          final record = WorkRecord(
            date: dateStr,
            type: _workType,
            days: entry.days,
            hours: _workType == 'point_hour' ? 8 : null,
            unitPrice: unitPrice,
            totalAmount: entry.days * unitPrice,
            workerId: workerId,
            remark: _remarkController.text.isEmpty ? null : _remarkController.text.trim(),
            createdAt: now,
            updatedAt: now,
          );
          provider.addRecord(record);
          count++;
        }
      });
    });

    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一天'), backgroundColor: Colors.orange),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('成功保存 \$count 条记录'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }
}

class _BatchEntry {
  bool selected;
  double days;
  _BatchEntry({this.selected = false, this.days = 1});
}
