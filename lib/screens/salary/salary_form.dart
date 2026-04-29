import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/salary_record.dart';
import '../../providers/salary_provider.dart';

class SalaryFormScreen extends StatefulWidget {
  const SalaryFormScreen({super.key});

  @override
  State<SalaryFormScreen> createState() => _SalaryFormScreenState();
}

class _SalaryFormScreenState extends State<SalaryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();
  String _type = 'total';
  String _paymentMethod = 'cash';
  DateTime _date = DateTime.now();

  SalaryRecord? _editRecord;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is SalaryRecord) {
      _editRecord = args;
      _type = args.type;
      _amountController.text = args.amount.toString();
      _paymentMethod = args.paymentMethod ?? 'cash';
      _date = DateTime.parse(args.date);
      _remarkController.text = args.remark ?? '';
    } else if (args is String) {
      _type = args;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editRecord != null ? '编辑记录' : '记工资')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('记录类型', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTypeChip('总工资', 'total'),
                _buildTypeChip('已发放', 'paid'),
                _buildTypeChip('借支/预支', 'advance'),
                _buildTypeChip('结算', 'settle'),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: '金额（元）',
                border: OutlineInputBorder(),
                prefixText: '¥ ',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入金额';
                if (double.tryParse(v) == null) return '请输入有效数字';
                return null;
              },
            ),
            const SizedBox(height: 12),

            if (_type == 'paid' || _type == 'settle') ...[
              const Text('支付方式', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildPaymentChip('现金', 'cash'),
                  _buildPaymentChip('微信', 'wechat'),
                  _buildPaymentChip('支付宝', 'alipay'),
                  _buildPaymentChip('银行转账', 'bank'),
                ],
              ),
              const SizedBox(height: 12),
            ],

            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('日期'),
              subtitle: Text("${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}"),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),

            TextFormField(
              controller: _remarkController,
              decoration: const InputDecoration(labelText: '备注（选填）', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: Text(_editRecord != null ? '保存修改' : '保存'),
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _type == value,
      onSelected: (_) => setState(() => _type = value),
    );
  }

  Widget _buildPaymentChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _paymentMethod == value,
      onSelected: (_) => setState(() => _paymentMethod = value),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now().toIso8601String();
      final record = SalaryRecord(
        id: _editRecord?.id,
        date: _date.toString().substring(0, 10),
        type: _type,
        amount: double.parse(_amountController.text),
        paymentMethod: _paymentMethod,
        remark: _remarkController.text.isEmpty ? null : _remarkController.text,
        createdAt: _editRecord?.createdAt ?? now,
        updatedAt: now,
      );

      final provider = context.read<SalaryProvider>();
      if (_editRecord != null) {
        provider.updateRecord(record);
      } else {
        provider.addRecord(record);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }
}
