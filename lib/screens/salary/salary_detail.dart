import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/work_provider.dart';
import '../../providers/salary_provider.dart';
import '../../utils/format_utils.dart';

class SalaryDetailScreen extends StatefulWidget {
  const SalaryDetailScreen({super.key});

  @override
  State<SalaryDetailScreen> createState() => _SalaryDetailScreenState();
}

class _SalaryDetailScreenState extends State<SalaryDetailScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<WorkProvider>().loadMonthRecords(_selectedYear, _selectedMonth);
    context.read<SalaryProvider>().loadMonthRecords(_selectedYear, _selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工资明细表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickMonth,
          ),
        ],
      ),
      body: Consumer2<WorkProvider, SalaryProvider>(
        builder: (context, workProvider, salaryProvider, _) {
          final workTotal = workProvider.getMonthTotal();
          final salaryTotal = salaryProvider.totalSalary;
          final paidTotal = salaryProvider.paidSalary;
          final advanceTotal = salaryProvider.advanceSalary;
          final settleTotal = salaryProvider.settledSalary;
          final pendingTotal = salaryProvider.pendingSettle;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // Month selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _selectedMonth--;
                            if (_selectedMonth < 1) {
                              _selectedMonth = 12;
                              _selectedYear--;
                            }
                          });
                          _loadData();
                        },
                      ),
                      Text(
                        '\$_selectedYear年\$_selectedMonth月',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _selectedMonth++;
                            if (_selectedMonth > 12) {
                              _selectedMonth = 1;
                              _selectedYear++;
                            }
                          });
                          _loadData();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📊 工资明细表', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      _buildDetailRow('本月工钱（记工总额）', workTotal, Colors.blue),
                      _buildDetailRow('本月工资（记录总额）', salaryTotal, Colors.green),
                      const Divider(),
                      _buildDetailRow('已发放工资', paidTotal, Colors.teal),
                      _buildDetailRow('借支/预支', advanceTotal, Colors.orange),
                      _buildDetailRow('已结算', settleTotal, Colors.purple),
                      const Divider(),
                      _buildDetailRow('待结算', pendingTotal, Colors.red, isBold: true, isLarge: true),
                      const SizedBox(height: 12),
                      if (workTotal > 0 && salaryTotal > 0)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '工钱(\${FormatUtils.formatMoney(workTotal)}) 与 工资(\${FormatUtils.formatMoney(salaryTotal)}) 差额: \${FormatUtils.formatMoney(workTotal - salaryTotal)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Salary records detail
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('📋 工资记录明细', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Spacer(),
                          Text('\${salaryProvider.records.length}条', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (salaryProvider.records.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('暂无工资记录', style: TextStyle(color: Colors.grey))),
                        )
                      else
                        ...salaryProvider.records.map((r) {
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: _getTypeColor(r.type).withOpacity(0.1),
                              child: Icon(_getTypeIcon(r.type), size: 16, color: _getTypeColor(r.type)),
                            ),
                            title: Text(_getTypeName(r.type), style: const TextStyle(fontSize: 14)),
                            subtitle: Text('\${r.date}\${r.remark != null ? ' | \${r.remark}' : ''}', style: const TextStyle(fontSize: 11)),
                            trailing: Text(
                              '\${r.type == 'total' ? '+' : '-'}\${FormatUtils.formatMoney(r.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: r.type == 'total' ? Colors.green : Colors.red,
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, double amount, Color color, {bool isBold = false, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isLarge ? 15 : 14,
          )),
          Text(
            FormatUtils.formatMoney(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: isLarge ? 20 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'total': return Colors.green;
      case 'paid': return Colors.blue;
      case 'advance': return Colors.orange;
      case 'settle': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'total': return Icons.attach_money;
      case 'paid': return Icons.payments;
      case 'advance': return Icons.money_off;
      case 'settle': return Icons.check_circle;
      default: return Icons.money;
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'total': return '总工资';
      case 'paid': return '已发放';
      case 'advance': return '借支/预支';
      case 'settle': return '结算';
      default: return type;
    }
  }

  void _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedYear = picked.year;
        _selectedMonth = picked.month;
      });
      _loadData();
    }
  }
}
