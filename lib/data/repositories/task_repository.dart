// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/task_model.dart';
//
// class TaskRepository {
//   final _fire = FirebaseFirestore.instance;
//
//   Stream<List<TaskModel>> streamUserTasks(String userId) {
//     return _fire
//         .collection('users')
//         .doc(userId)
//         .collection('tasks')
//         .orderBy('date')
//         .snapshots()
//         .map((snap) =>
//         snap.docs.map((doc) => TaskModel.fromFirestore(doc, null)).toList());
//   }
//
//   Future<void> addTask(TaskModel task) async {
//     await _fire
//         .collection('users')
//         .doc(task.userId)
//         .collection('tasks')
//         .doc(task.id)
//         .set(task.toFirestore());
//   }
//
//   Future<void> updateTask(String userId, String taskId, Map<String, dynamic> data) async {
//     await _fire
//         .collection('users')
//         .doc(userId)
//         .collection('tasks')
//         .doc(taskId)
//         .update(data);
//   }
//
//   Future<void> deleteTask(String userId, String taskId) async {
//     await _fire
//         .collection('users')
//         .doc(userId)
//         .collection('tasks')
//         .doc(taskId)
//         .delete();
//   }
// }


// lib/features/tasks/data/task_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class TaskRepository {
  final _fire = FirebaseFirestore.instance;

  // ---------------- REAL-TIME STREAM ----------------

  Stream<List<TaskModel>> streamUserTasks(String userId) {
    return _fire
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('date')
        .snapshots()
        .map(
          (snap) => snap.docs
          .map((doc) => TaskModel.fromFirestore(doc, null))
          .toList(),
    );
  }

  // ---------------- ADD TASK ----------------

  Future<void> addTask(TaskModel task) async {
    try {
      final data = task.toFirestore();
      debugPrint('🔥 Firestore: Adding task');
      debugPrint('   Collection: users/${task.userId}/tasks');
      debugPrint('   Document ID: ${task.id}');
      debugPrint('   Title: ${task.title}');
      
    await _fire
        .collection('users')
        .doc(task.userId)
        .collection('tasks')
        .doc(task.id)
          .set(data);
      
      debugPrint('✅ Firestore: Task saved successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Firestore: Error adding task: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ---------------- UPDATE TASK ----------------

  Future<void> updateTask(
      String userId, String taskId, Map<String, dynamic> data) async {
    data["updatedAt"] = Timestamp.fromDate(DateTime.now());

    await _fire
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update(data);
  }

  // ---------------- DELETE TASK ----------------

  Future<void> deleteTask(String userId, String taskId) async {
    await _fire
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
