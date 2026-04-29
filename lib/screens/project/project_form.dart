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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editProject != null ? '编辑项目' : '新建项目')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '项目名称 *',
                border: OutlineInputBorder(),
                hintText: '例：XX小区二期',
              ),
              validator: (v) => v == null || v.isEmpty ? '请输入项目名称' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: '项目地址',
                border: OutlineInputBorder(),
                hintText: '例：北京市朝阳区XX路XX号',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('开工日期'),
                    subtitle: Text(_startDate != null
                        ? '\${_startDate!.year}-\${_startDate!.month.toString().padLeft(2, '0')}-\${_startDate!.day.toString().padLeft(2, '0')}'
                        : '未设置'),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _startDate = picked);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('完工日期'),
                    subtitle: Text(_endDate != null
                        ? '\${_endDate!.year}-\${_endDate!.month.toString().padLeft(2, '0')}-\${_endDate!.day.toString().padLeft(2, '0')}'
                        : '未设置'),
                    leading: const Icon(Icons.event),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) setState(() => _endDate = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('项目状态', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('进行中'),
                  selected: _status == 'active',
                  onSelected: (_) => setState(() => _status = 'active'),
                ),
                ChoiceChip(
                  label: const Text('已完工'),
                  selected: _status == 'completed',
                  onSelected: (_) => setState(() => _status = 'completed'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _remarkController,
              decoration: const InputDecoration(labelText: '备注', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: Text(_editProject != null ? '保存修改' : '创建项目'),
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
        address: _addressController.text.isEmpty ? null : _addressController.text.trim(),
        startDate: _startDate?.toString().substring(0, 10),
        endDate: _endDate?.toString().substring(0, 10),
        status: _status,
        remark: _remarkController.text.isEmpty ? null : _remarkController.text.trim(),
        createdAt: _editProject?.createdAt ?? now,
      );

      final provider = context.read<ProjectProvider>();
      if (_editProject != null) {
        provider.updateProject(project);
      } else {
        provider.addProject(project);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }
}
