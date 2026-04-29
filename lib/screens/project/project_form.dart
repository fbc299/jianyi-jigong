import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../providers/project_provider.dart';

class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({super.key});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _remarkController = TextEditingController();
  String _status = 'active';
  DateTime? _startDate;
  DateTime? _endDate;
  Project? _editProject;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Project) {
      _editProject = args;
      _nameController.text = args.name;
      _addressController.text = args.address ?? '';
      _remarkController.text = args.remark ?? '';
      _status = args.status;
      if (args.startDate != null) _startDate = DateTime.tryParse(args.startDate!);
      if (args.endDate != null) _endDate = DateTime.tryParse(args.endDate!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '\u672a\u8bbe\u7f6e';
    return '\\${d.year}-\\${d.month.toString().padLeft(2, "0")}-\\${d.day.toString().padLeft(2, "0")}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editProject != null ? '\u7f16\u8f91\u9879\u76ee' : '\u65b0\u5efa\u9879\u76ee')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '\u9879\u76ee\u540d\u79f0 *', border: OutlineInputBorder(), hintText: '\u5982\uff1aXX\u5c0f\u533a\u88c5\u4fee'),
              validator: (v) => v == null || v.trim().isEmpty ? '\u8bf7\u8f93\u5165\u9879\u76ee\u540d\u79f0' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: '\u5de5\u5730\u5730\u5740', border: OutlineInputBorder(), hintText: '\u53ef\u9009'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('\u5f00\u59cb\u65e5\u671f'),
                    subtitle: Text(_fmtDate(_startDate)),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (picked != null) setState(() => _startDate = picked);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('\u7ed3\u675f\u65e5\u671f'),
                    subtitle: Text(_fmtDate(_endDate)),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(context: context, initialDate: _endDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (picked != null) setState(() => _endDate = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('\u9879\u76ee\u72b6\u6001', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('\u8fdb\u884c\u4e2d'), selected: _status == 'active', onSelected: (_) => setState(() => _status = 'active')),
                ChoiceChip(label: const Text('\u5df2\u5b8c\u5de5'), selected: _status == 'completed', onSelected: (_) => setState(() => _status = 'completed')),
              ],
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
              label: Text(_editProject != null ? '\u4fdd\u5b58\u4fee\u6539' : '\u521b\u5efa\u9879\u76ee'),
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
      final project = Project(
        id: _editProject?.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        startDate: _startDate?.toString().substring(0, 10),
        endDate: _endDate?.toString().substring(0, 10),
        status: _status,
        remark: _remarkController.text.isEmpty ? null : _remarkController.text,
        createdAt: _editProject?.createdAt ?? now,
      );
      final provider = context.read<ProjectProvider>();
      if (_editProject != null) {
        provider.updateProject(project);
      } else {
        provider.addProject(project);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('\u4fdd\u5b58\u6210\u529f'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }
}
