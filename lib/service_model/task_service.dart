
import 'package:assignment_firebase_pushn_notification_local_notification/service_model/task_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class TaskService {
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>>
      get _tasks => _db.collection('tasks');

  static Stream<List<TaskItem>> watchTasks(String userId) {
    return _tasks
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        return TaskItem.fromMap(doc.id, doc.data());
      }).toList();

      tasks.sort(
        (a, b) => a.dueDate.compareTo(b.dueDate),
      );

      return tasks;
    });
  }

  static Future<void> addTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Please sign in first.');
    }

    final doc = _tasks.doc();

    final task = TaskItem(
      id: doc.id,
      userId: user.uid,
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      priority: priority,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await doc.set(task.toMap());
  }

  static Future<void> updateTask(TaskItem task) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.uid != task.userId) {
      throw Exception('You cannot update this task.');
    }

    await _tasks.doc(task.id).update(task.toMap());
  }

  static Future<void> deleteTask(TaskItem task) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.uid != task.userId) {
      throw Exception('You cannot delete this task.');
    }

    await _tasks.doc(task.id).delete();
  }
}