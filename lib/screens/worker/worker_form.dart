import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/worker.dart';
import '../../providers/worker_provider.dart';

class WorkerFormScreen extends StatefulWidget {
  const WorkerFormScreen({super.key});

  @override
  State<WorkerFormScreen> createState() => _WorkerFormScreenState();
}

class _WorkerFormScreenState extends State<WorkerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _skillController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _remarkController = TextEditingController();
  Worker? _editWorker;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Worker) {
      _editWorker = args;
      _nameController.text = args.name;
      _phoneController.text = args.phone ?? '';
      _skillController.text = args.skill ?? '';
      _dailyRateController.text = args.dailyRate?.toString() ?? '';
      _remarkController.text = args.remark ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _skillController.dispose();
    _dailyRateController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editWorker != null ? '编辑工人' : '添加工人')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名 *',
                border: OutlineInputBorder(),
                hintText: '例：张三',
              ),
              validator: (v) => v == null || v.isEmpty ? '请输入姓名' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '手机号',
                border: OutlineInputBorder(),
                hintText: '例：13800138000',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skillController,
              decoration: const InputDecoration(
                labelText: '工种/技能',
                border: OutlineInputBorder(),
                hintText: '例：钢筋工、木工、泥工',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dailyRateController,
              decoration: const InputDecoration(
                labelText: '日薪（元）',
                border: OutlineInputBorder(),
                hintText: '例：350',
                prefixText: '¥ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarkController,
              decoration: const InputDecoration(labelText: '备注', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: Text(_editWorker != null ? '保存修改' : '添加工人'),
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now().toIso8601String();
      final worker = Worker(
        id: _editWorker?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.isEmpty ? null : _phoneController.text.trim(),
        skill: _skillController.text.isEmpty ? null : _skillController.text.trim(),
        dailyRate: _dailyRateController.text.isEmpty ? null : double.tryParse(_dailyRateController.text),
        remark: _remarkController.text.isEmpty ? null : _remarkController.text.trim(),
        createdAt: _editWorker?.createdAt ?? now,
      );

      final provider = context.read<WorkerProvider>();
      if (_editWorker != null) {
        provider.updateWorker(worker);
      } else {
        provider.addWorker(worker);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }
}
