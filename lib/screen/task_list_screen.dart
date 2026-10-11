
import 'package:assignment_firebase_pushn_notification_local_notification/screen/addtaskscreen.dart';
import 'package:assignment_firebase_pushn_notification_local_notification/service_model/auth_service.dart';
import 'package:assignment_firebase_pushn_notification_local_notification/service_model/task_item.dart';
import 'package:assignment_firebase_pushn_notification_local_notification/service_model/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_task_screen.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String filter = 'All';

  Future<void> _delete(TaskItem task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await TaskService.deleteTask(task);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return const LoginScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService.signOut();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTaskScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
      body: StreamBuilder<List<TaskItem>>(
        stream: TaskService.watchTasks(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allTasks = snapshot.data!;

          final tasks = allTasks.where((task) {
            if (filter == 'Pending') return !task.isCompleted;
            if (filter == 'Completed') return task.isCompleted;
            return true;
          }).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        for (final item in [
                          'All',
                          'Pending',
                          'Completed',
                        ])
                          ChoiceChip(
                            label: Text(
                              item == 'All'
                                  ? 'All ${allTasks.length}'
                                  : item == 'Pending'
                                      ? 'Pending ${allTasks.where((t) => !t.isCompleted).length}'
                                      : 'Completed ${allTasks.where((t) => t.isCompleted).length}',
                            ),
                            selected: filter == item,
                            onSelected: (_) {
                              setState(() => filter = item);
                            },
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: tasks.isEmpty
                        ? const Center(
                            child: Text(
                              'No tasks yet. Tap New Task to add one.',
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              16, 4, 16, 90,
                            ),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];

                              return Card(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: task.isCompleted,
                                        onChanged: (value) async {
                                          try {
                                            await TaskService.updateTask(
                                              TaskItem(
                                                id: task.id,
                                                userId: task.userId,
                                                title: task.title,
                                                description: task.description,
                                                dueDate: task.dueDate,
                                                priority: task.priority,
                                                isCompleted: value ?? false,
                                                createdAt: task.createdAt,
                                              ),
                                            );
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text('$e'),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${task.priority} Priority',
                                              style: TextStyle(
                                                color: task.priority == 'High'
                                                    ? Colors.red
                                                    : task.priority == 'Low'
                                                        ? Colors.green
                                                        : Colors.orange,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              task.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                decoration: task.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            if (task.description.isNotEmpty)
                                              Text(
                                                task.description,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                                              style: const TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Edit',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  EditTaskScreen(task: task),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete',
                                        onPressed: () => _delete(task),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}