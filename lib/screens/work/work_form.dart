import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/work_record.dart';
import '../../providers/work_provider.dart';

class WorkFormScreen extends StatefulWidget {
  const WorkFormScreen({super.key});

  @override
  State<WorkFormScreen> createState() => _WorkFormScreenState();
}

class _WorkFormScreenState extends State<WorkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'point_day';
  DateTime _date = DateTime.now();
  final _daysController = TextEditingController(text: '1');
  final _hoursController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _remarkController = TextEditingController();

  WorkRecord? _editRecord;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is WorkRecord) {
      _editRecord = args;
      _type = args.type;
      _date = DateTime.parse(args.date);
      _daysController.text = args.days?.toString() ?? '';
      _hoursController.text = args.hours?.toString() ?? '';
      _quantityController.text = args.quantity?.toString() ?? '';
      _unitPriceController.text = args.unitPrice?.toString() ?? '';
      _remarkController.text = args.remark ?? '';
    }
  }

  @override
  void dispose() {
    _daysController.dispose();
    _hoursController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  double get _calculatedAmount {
    final days = double.tryParse(_daysController.text) ?? 0;
    final hours = double.tryParse(_hoursController.text) ?? 0;
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;

    switch (_type) {
      case 'point_day':
        return days * unitPrice;
      case 'point_hour':
        return hours * unitPrice;
      case 'package_day':
        return days * unitPrice;
      case 'package_quantity':
        return quantity * unitPrice;
      case 'overtime':
        return hours * unitPrice;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editRecord != null ? '编辑记录' : '记工'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('日期'),
              subtitle: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
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
            const SizedBox(height: 16),

            // Type selector
            const Text('记工类型', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTypeChip('点工（按天）', 'point_day'),
                _buildTypeChip('点工（按小时）', 'point_hour'),
                _buildTypeChip('包工（按天）', 'package_day'),
                _buildTypeChip('包工（按量）', 'package_quantity'),
                _buildTypeChip('加班', 'overtime'),
              ],
            ),
            const SizedBox(height: 16),

            // Conditional fields
            if (_type.contains('day'))
              TextFormField(
                controller: _daysController,
                decoration: const InputDecoration(labelText: '工天', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            if (_type.contains('hour') || _type == 'overtime') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(labelText: '工时（小时）', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ],
            if (_type == 'package_quantity') ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: '工作量', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitPriceController,
              decoration: const InputDecoration(labelText: '单价（元）', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarkController,
              decoration: const InputDecoration(labelText: '备注（选填）', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Amount preview
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('预估金额', style: TextStyle(fontSize: 16)),
                    Text(
                      '¥${_calculatedAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: Text(_editRecord != null ? '保存修改' : '保存记录'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now().toIso8601String();
      final record = WorkRecord(
        id: _editRecord?.id,
        date: _date.toString().substring(0, 10),
        type: _type,
        hours: double.tryParse(_hoursController.text),
        days: double.tryParse(_daysController.text),
        quantity: double.tryParse(_quantityController.text),
        unitPrice: double.tryParse(_unitPriceController.text),
        totalAmount: _calculatedAmount,
        remark: _remarkController.text.isEmpty ? null : _remarkController.text,
        createdAt: _editRecord?.createdAt ?? now,
        updatedAt: now,
      );

      final provider = context.read<WorkProvider>();
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
