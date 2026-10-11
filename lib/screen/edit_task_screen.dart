
import 'package:assignment_firebase_pushn_notification_local_notification/service_model/task_item.dart';
import 'package:assignment_firebase_pushn_notification_local_notification/service_model/task_service.dart';
import 'package:flutter/material.dart';
class EditTaskScreen extends StatefulWidget {
  final TaskItem task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _description;
  late DateTime _dueDate;
  late String _priority;
  late bool _completed;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task.title);
    _description =
        TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _completed = widget.task.isCompleted;
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await TaskService.updateTask(
        TaskItem(
          id: widget.task.id,
          userId: widget.task.userId,
          title: _title.text.trim(),
          description: _description.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
          isCompleted: _completed,
          createdAt: widget.task.createdAt,
        ),
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
      appBar: AppBar(title: const Text('Edit Task')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text('TASK TITLE'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _title,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text('DESCRIPTION'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 18),
                const Text('DUE DATE'),
                OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(
                    '${_dueDate.month}/${_dueDate.day}/${_dueDate.year}',
                  ),
                ),
                const SizedBox(height: 18),
                const Text('PRIORITY'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Low', label: Text('Low')),
                    ButtonSegment(value: 'Medium', label: Text('Medium')),
                    ButtonSegment(value: 'High', label: Text('High')),
                  ],
                  selected: {_priority},
                  onSelectionChanged: (value) {
                    setState(() => _priority = value.first);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Completed'),
                  subtitle: const Text('Mark task as done'),
                  value: _completed,
                  onChanged: (value) {
                    setState(() => _completed = value);
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}