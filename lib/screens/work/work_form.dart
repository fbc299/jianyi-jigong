import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/work_record.dart';
import '../../providers/work_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/worker_provider.dart';
import '../../utils/format_utils.dart';

class WorkFormScreen extends StatefulWidget {
  const WorkFormScreen({super.key});

  @override
  State<WorkFormScreen> createState() => _WorkFormScreenState();
}

class _WorkFormScreenState extends State<WorkFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _daysController = TextEditingController();
  final _hoursController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController(text: '350');
  final _remarkController = TextEditingController();
  String _type = 'point_day';
  DateTime _date = DateTime.now();
  int? _selectedProjectId;
  int? _selectedWorkerId;
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
      _selectedProjectId = args.projectId;
      _selectedWorkerId = args.workerId;
    }
    // Load projects and workers
    context.read<ProjectProvider>().loadAll();
    context.read<WorkerProvider>().loadAll();
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
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    switch (_type) {
      case 'point_day':
      case 'package_day':
        return (double.tryParse(_daysController.text) ?? 0) * unitPrice;
      case 'point_hour':
        return (double.tryParse(_hoursController.text) ?? 0) * unitPrice;
      case 'package_quantity':
        return (double.tryParse(_quantityController.text) ?? 0) * unitPrice;
      case 'overtime':
        return (double.tryParse(_hoursController.text) ?? 0) * unitPrice;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editRecord != null ? '编辑记录' : '记工')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Work type
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
            const SizedBox(height: 16),

            // Project selection
            Consumer<ProjectProvider>(
              builder: (context, provider, _) {
                if (provider.projects.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('所属项目', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedProjectId,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      hint: const Text('选择项目（可选）'),
                      items: [
                        const DropdownMenuItem<int>(value: null, child: Text('无')),
                        ...provider.projects.map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        )),
                      ],
                      onChanged: (val) => setState(() => _selectedProjectId = val),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            // Worker selection
            Consumer<WorkerProvider>(
              builder: (context, provider, _) {
                if (provider.workers.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('工人', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedWorkerId,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      hint: const Text('选择工人（可选）'),
                      items: [
                        const DropdownMenuItem<int>(value: null, child: Text('无')),
                        ...provider.workers.map((w) => DropdownMenuItem(
                          value: w.id,
                          child: Text(w.name),
                        )),
                      ],
                      onChanged: (val) => setState(() => _selectedWorkerId = val),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),

            // Days/Hours/Quantity based on type
            if (_type == 'point_day' || _type == 'package_day') ...[
              TextFormField(
                controller: _daysController,
                decoration: const InputDecoration(
                  labelText: '天数',
                  border: OutlineInputBorder(),
                  hintText: '例：1',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return '请输入天数';
                  if (double.tryParse(v) == null) return '请输入有效数字';
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],

            if (_type == 'point_hour' || _type == 'overtime') ...[
              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(
                  labelText: '小时数',
                  border: OutlineInputBorder(),
                  hintText: '例：8',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return '请输入小时数';
                  if (double.tryParse(v) == null) return '请输入有效数字';
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],

            if (_type == 'package_quantity') ...[
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: '数量',
                  border: OutlineInputBorder(),
                  hintText: '例：100',
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.isEmpty) return '请输入数量';
                  if (double.tryParse(v) == null) return '请输入有效数字';
                  return null;
                },
              ),
              const SizedBox(height: 12),
            ],

            // Unit price
            TextFormField(
              controller: _unitPriceController,
              decoration: const InputDecoration(
                labelText: '单价（元）',
                border: OutlineInputBorder(),
                prefixText: '¥ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入单价';
                if (double.tryParse(v) == null) return '请输入有效数字';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Date picker
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('日期'),
              subtitle: Text(
                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
              ),
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

            // Remark
            TextFormField(
              controller: _remarkController,
              decoration: const InputDecoration(labelText: '备注（选填）', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Preview
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('预计金额', style: TextStyle(fontSize: 16)),
                    Text(
                      FormatUtils.formatMoney(_calculatedAmount),
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
        projectId: _selectedProjectId,
        workerId: _selectedWorkerId,
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
