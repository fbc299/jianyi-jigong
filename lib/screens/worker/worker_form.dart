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
      appBar: AppBar(title: Text(_editWorker != null ? '\u7f16\u8f91\u5de5\u4eba' : '\u6dfb\u52a0\u5de5\u4eba')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '\u59d3\u540d *', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? '\u8bf7\u8f93\u5165\u59d3\u540d' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '\u7535\u8bdd', border: OutlineInputBorder(), hintText: '\u53ef\u9009'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _skillController,
              decoration: const InputDecoration(labelText: '\u5de5\u79cd', border: OutlineInputBorder(), hintText: '\u5982\uff1a\u6ce5\u5de5\u3001\u7535\u5de5\u3001\u6728\u5de5'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dailyRateController,
              decoration: const InputDecoration(labelText: '\u65e5\u85aa\uff08\u5143\uff09', border: OutlineInputBorder(), prefixText: '\u00a5 '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarkController,
              decoration: const InputDecoration(labelText: '\u5907\u6ce8\uff08\u9009\u586b\uff09', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: Text(_editWorker != null ? '\u4fdd\u5b58\u4fee\u6539' : '\u6dfb\u52a0\u5de5\u4eba'),
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
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        skill: _skillController.text.trim().isEmpty ? null : _skillController.text.trim(),
        dailyRate: double.tryParse(_dailyRateController.text),
        remark: _remarkController.text.isEmpty ? null : _remarkController.text,
        createdAt: _editWorker?.createdAt ?? now,
      );
      final provider = context.read<WorkerProvider>();
      if (_editWorker != null) {
        provider.updateWorker(worker);
      } else {
        provider.addWorker(worker);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('\u4fdd\u5b58\u6210\u529f'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }
}
