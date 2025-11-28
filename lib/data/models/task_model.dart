// import 'package:cloud_firestore/cloud_firestore.dart';
//
// import 'subtask_model.dart';
//
// class TaskModel {
//   const TaskModel({
//     required this.id,
//     required this.userId,
//     required this.title,
//     required this.description,
//     required this.date,
//     required this.time,
//     required this.priority,
//     required this.category,
//     this.completedAt,
//     this.recurrenceRule,
//     this.parentTaskId,
//     this.hasAttachment = false,
//     this.subtasks = const [],
//   });
//
//   final String id;
//   final String userId;
//   final String title;
//   final String description;
//   final DateTime date;
//   final String time;
//   final String priority;
//   final String category;
//   final DateTime? completedAt;
//   final String? recurrenceRule;
//   final String? parentTaskId;
//   final bool hasAttachment;
//   final List<SubtaskModel> subtasks;
//
//   factory TaskModel.fromFirestore(
//     DocumentSnapshot<Map<String, dynamic>> doc,
//     SnapshotOptions? _,
//   ) {
//     final data = doc.data() ?? {};
//     final subtasksData = (data['subtasks'] as List<dynamic>? ?? [])
//         .cast<Map<String, dynamic>>();
//     return TaskModel(
//       id: doc.id,
//       userId: data['userId'] as String? ?? '',
//       title: data['title'] as String? ?? '',
//       description: data['description'] as String? ?? '',
//       date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       time: data['time'] as String? ?? '',
//       priority: data['priority'] as String? ?? 'medium',
//       category: data['category'] as String? ?? 'General',
//       completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
//       recurrenceRule: data['recurrenceRule'] as String?,
//       parentTaskId: data['parentTaskId'] as String?,
//       hasAttachment: data['hasAttachment'] as bool? ?? false,
//       subtasks: [
//         for (final Map<String, dynamic> json in subtasksData)
//           SubtaskModel.fromJson(json, json['id'] as String? ?? ''),
//       ],
//     );
//   }
//
//   Map<String, dynamic> toFirestore() => {
//     'userId': userId,
//     'title': title,
//     'description': description,
//     'date': Timestamp.fromDate(date),
//     'time': time,
//     'priority': priority,
//     'category': category,
//     if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
//     if (recurrenceRule != null) 'recurrenceRule': recurrenceRule,
//     if (parentTaskId != null) 'parentTaskId': parentTaskId,
//     'hasAttachment': hasAttachment,
//     if (subtasks.isNotEmpty)
//       'subtasks': [
//         for (final sub in subtasks) {'id': sub.id, ...sub.toJson()},
//       ],
//   };
//
//   TaskModel copyWith({
//     String? title,
//     String? description,
//     DateTime? date,
//     String? time,
//     String? priority,
//     String? category,
//     DateTime? completedAt,
//     String? recurrenceRule,
//     String? parentTaskId,
//     bool? hasAttachment,
//     List<SubtaskModel>? subtasks,
//   }) {
//     return TaskModel(
//       id: id,
//       userId: userId,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       date: date ?? this.date,
//       time: time ?? this.time,
//       priority: priority ?? this.priority,
//       category: category ?? this.category,
//       completedAt: completedAt ?? this.completedAt,
//       recurrenceRule: recurrenceRule ?? this.recurrenceRule,
//       parentTaskId: parentTaskId ?? this.parentTaskId,
//       hasAttachment: hasAttachment ?? this.hasAttachment,
//       subtasks: subtasks ?? this.subtasks,
//     );
//   }
// }
//

import 'package:cloud_firestore/cloud_firestore.dart';
import 'subtask_model.dart';

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String priority;
  final String category;
  final DateTime? completedAt;
  final String? recurrenceRule;
  final String? parentTaskId;
  final bool hasAttachment;
  final List<SubtaskModel> subtasks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.priority,
    required this.category,
    this.completedAt,
    this.recurrenceRule,
    this.parentTaskId,
    this.hasAttachment = false,
    this.subtasks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc, SnapshotOptions? _) {
    final data = doc.data() ?? {};

    return TaskModel(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'],
      priority: data['priority'],
      category: data['category'],
      completedAt:
      data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
      recurrenceRule: data['recurrenceRule'],
      parentTaskId: data['parentTaskId'],
      hasAttachment: data['hasAttachment'] ?? false,
      subtasks: (data['subtasks'] as List<dynamic>? ?? [])
          .map((e) => SubtaskModel.fromJson(e, e['id']))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'title': title,
    'description': description,
    'date': Timestamp.fromDate(date),
    'time': time,
    'priority': priority,
    'category': category,
    'completedAt':
    completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    'recurrenceRule': recurrenceRule,
    'parentTaskId': parentTaskId,
    'hasAttachment': hasAttachment,
    'subtasks': [
      for (final s in subtasks) {'id': s.id, ...s.toJson()}
    ],
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  TaskModel copyWith({
    String? title,
    DateTime? date,
    List<SubtaskModel>? subTasks,
    DateTime? completedAt

  }) {
    return TaskModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description,
      date: date ?? this.date,
      time: time,
      priority: priority,
      category: category,
      completedAt: completedAt,
      recurrenceRule: recurrenceRule,
      parentTaskId: parentTaskId,
      hasAttachment: hasAttachment,
      subtasks: subtasks,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

