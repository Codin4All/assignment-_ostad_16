
import 'package:assignment_firebase_pushn_notification_local_notification/service_model/task_service.dart';
import 'package:flutter/material.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  String _priority = 'Medium';
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await TaskService.addTask(
        title: _title.text,
        description: _description.text,
        dueDate: _dueDate,
        priority: _priority,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Task')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('TITLE'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Complete Flutter Assignment',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text('NOTES'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Add details, links, or notes...',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('DUE DATE'),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    '${_dueDate.month}/${_dueDate.day}/${_dueDate.year}',
                  ),
                ),
                const SizedBox(height: 20),
                const Text('PRIORITY'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'Low',
                      label: Text('Low'),
                    ),
                    ButtonSegment(
                      value: 'Medium',
                      label: Text('Medium'),
                    ),
                    ButtonSegment(
                      value: 'High',
                      label: Text('High'),
                    ),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (value) {
                    setState(() => _priority = value.first);
                  },
                ),
                const SizedBox(height: 30),
                FilledButton(
                  onPressed: _saving ? null : _saveTask,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Save Task'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}