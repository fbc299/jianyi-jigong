import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/salary_provider.dart';
import '../../utils/format_utils.dart';

class SalaryListScreen extends StatelessWidget {
  const SalaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('工资管理'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.table_chart),
            label: const Text('明细表'),
            onPressed: () => Navigator.pushNamed(context, '/salary/detail'),
          ),
        ],
      ),
      body: Consumer<SalaryProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Pending settlement card
              Card(
                margin: const EdgeInsets.all(12),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      const Text('💰 待结算', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        FormatUtils.formatMoney(provider.pendingSettle),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: _buildActionButton(context, '记工资', Icons.add_circle, Colors.blue, 'total')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildActionButton(context, '记借支', Icons.money_off, Colors.orange, 'advance')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildActionButton(context, '记结算', Icons.check_circle, Colors.green, 'settle')),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Records list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('📋 最近记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Spacer(),
                    Text('${provider.records.length}条', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              Expanded(
                child: provider.records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text('暂无工资记录', style: TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 8),
                            const Text('点击上方按钮开始记录', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.records.length,
                        itemBuilder: (context, index) {
                          final r = provider.records[index];
                          return Dismissible(
                            key: Key('salary_${r.id}'),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('删除记录'),
                                  content: const Text('确定删除这条记录吗？'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
                                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('删除', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) => provider.deleteRecord(r.id!),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getTypeColor(r.type).withOpacity(0.1),
                                child: Icon(_getTypeIcon(r.type), color: _getTypeColor(r.type), size: 20),
                              ),
                              title: Text(_getTypeName(r.type)),
                              subtitle: Text("${r.date} ${r.remark ?? ''}"),
                              trailing: Text(
                                "${r.type == 'total' ? '+' : '-'}${FormatUtils.formatMoney(r.amount)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: r.type == 'total' ? Colors.green : Colors.red,
                                ),
                              ),
                              onTap: () => Navigator.pushNamed(context, '/salary/form', arguments: r),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/salary/form'),
        icon: const Icon(Icons.add),
        label: const Text('记工资'),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, String type) {
    return OutlinedButton.icon(
      onPressed: () => Navigator.pushNamed(context, '/salary/form', arguments: type),
      icon: Icon(icon, color: color, size: 18),
      label: Text(label),
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
}
